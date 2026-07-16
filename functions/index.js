const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {onSchedule} = require("firebase-functions/v2/scheduler");
const {onCall, HttpsError} = require("firebase-functions/v2/https");
const {defineSecret} = require("firebase-functions/params");
const crypto = require("node:crypto");
const admin = require("firebase-admin");

admin.initializeApp();

const db = admin.firestore();
const requests = db.collection("notificationRequests");
const AFRIKSMS_CLIENT_ID = defineSecret("AFRIKSMS_CLIENT_ID");
const AFRIKSMS_API_KEY = defineSecret("AFRIKSMS_API_KEY");
const AFRIKSMS_SENDER_ID = defineSecret("AFRIKSMS_SENDER_ID");
const OTP_TTL_MS = 5 * 60 * 1000;
const OTP_RESEND_DELAY_MS = 60 * 1000;
const OTP_MAX_ATTEMPTS = 5;

function normalizePhone(value) {
  const phone = String(value || "").trim();
  if (!/^\+[1-9]\d{7,14}$/.test(phone)) return null;
  return phone;
}

function otpDocumentId(phone) {
  return crypto.createHash("sha256").update(phone).digest("hex");
}

function hashOtp(phone, otp, salt) {
  return crypto
    .createHash("sha256")
    .update(`${phone}:${otp}:${salt}`)
    .digest("hex");
}

async function sendAfrikSms(phone, otp) {
  const endpoint = "https://api.afriksms.com/api/web/web_v1/outbounds/send";
  const body = new URLSearchParams({
    ClientId: AFRIKSMS_CLIENT_ID.value(),
    ApiKey: AFRIKSMS_API_KEY.value(),
    SenderId: AFRIKSMS_SENDER_ID.value(),
    Message: `Faani: votre code de verification est ${otp}. Il expire dans 5 minutes.`,
    MobileNumbers: phone.slice(1),
  });
  const response = await fetch(endpoint, {
    method: "POST",
    headers: {"content-type": "application/x-www-form-urlencoded"},
    body,
  });
  const payload = await response.json().catch(() => ({}));
  if (!response.ok || payload.code !== 100) {
    throw new Error(`AfrikSMS error ${response.status}: ${JSON.stringify(payload)}`);
  }
}

exports.requestAfrikSmsOtp = onCall({
  region: "europe-west1",
  secrets: [AFRIKSMS_CLIENT_ID, AFRIKSMS_API_KEY, AFRIKSMS_SENDER_ID],
}, async (request) => {
  const phone = normalizePhone(request.data?.phoneNumber);
  if (!phone) {
    throw new HttpsError("invalid-argument", "Numero de telephone invalide.");
  }

  const otpRef = db.collection("phoneOtp").doc(otpDocumentId(phone));
  const current = await otpRef.get();
  const currentData = current.exists ? current.data() : null;
  const now = Date.now();
  const lastSentAt = currentData?.lastSentAt?.toMillis?.() || 0;
  if (now - lastSentAt < OTP_RESEND_DELAY_MS) {
    throw new HttpsError("resource-exhausted", "Attendez avant de renvoyer un code.");
  }

  const windowStartedAt = currentData?.windowStartedAt?.toMillis?.() || now;
  const sentCount = windowStartedAt + 60 * 60 * 1000 > now
    ? Number(currentData?.sentCount || 0)
    : 0;
  if (sentCount >= 5) {
    throw new HttpsError("resource-exhausted", "Trop de demandes. Réessayez plus tard.");
  }

  const otp = String(crypto.randomInt(100000, 1000000));
  const salt = crypto.randomBytes(16).toString("hex");
  await sendAfrikSms(phone, otp);
  await otpRef.set({
    phoneNumber: phone,
    codeHash: hashOtp(phone, otp, salt),
    salt,
    expiresAt: admin.firestore.Timestamp.fromMillis(now + OTP_TTL_MS),
    lastSentAt: admin.firestore.Timestamp.fromMillis(now),
    windowStartedAt: admin.firestore.Timestamp.fromMillis(
      windowStartedAt + 60 * 60 * 1000 > now ? windowStartedAt : now,
    ),
    sentCount: sentCount + 1,
    attempts: 0,
  });
  return {ok: true, expiresInSeconds: OTP_TTL_MS / 1000};
});

exports.verifyAfrikSmsOtp = onCall({region: "europe-west1"}, async (request) => {
  const phone = normalizePhone(request.data?.phoneNumber);
  const code = String(request.data?.code || "").trim();
  if (!phone || !/^\d{6}$/.test(code)) {
    throw new HttpsError("invalid-argument", "Code OTP invalide.");
  }

  const otpRef = db.collection("phoneOtp").doc(otpDocumentId(phone));
  const snapshot = await otpRef.get();
  const data = snapshot.data();
  if (!data || data.expiresAt.toMillis() < Date.now()) {
    throw new HttpsError("deadline-exceeded", "Le code a expire. Demandez un nouveau code.");
  }
  const attempts = Number(data.attempts || 0) + 1;
  if (hashOtp(phone, code, data.salt) !== data.codeHash) {
    if (attempts >= OTP_MAX_ATTEMPTS) await otpRef.delete();
    else await otpRef.update({attempts});
    throw new HttpsError("invalid-argument", "Code OTP incorrect.");
  }
  await otpRef.delete();

  let firebaseUser;
  try {
    firebaseUser = await admin.auth().getUserByPhoneNumber(phone);
  } catch (error) {
    if (error.code !== "auth/user-not-found") throw error;
    firebaseUser = await admin.auth().createUser({phoneNumber: phone});
  }
  return {customToken: await admin.auth().createCustomToken(firebaseUser.uid)};
});

async function createUserActivity(token, payload) {
  const users = await db.collection("users").where("token", "==", token).limit(1).get();
  if (users.empty) return null;

  const user = users.docs[0];
  const preferences = user.data().notificationPreferences || {};
  const category = payload.category || "general";
  const activity = user.ref.collection("notifications").doc();
  await activity.set({
    title: payload.title,
    body: payload.body,
    category,
    targetType: payload.targetType || "",
    targetId: payload.targetId || "",
    isRead: false,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  return {
    token,
    activityId: activity.id,
    shouldPush: preferences.pushEnabled !== false && preferences[`${category}Enabled`] !== false,
  };
}

async function deliverNotification(reference) {
  const claimed = await db.runTransaction(async (transaction) => {
    const snapshot = await transaction.get(reference);
    if (!snapshot.exists) return null;
    const data = snapshot.data();
    if (data.status !== "pending") return null;
    if (data.scheduledAt && data.scheduledAt.toDate() > new Date()) return null;

    transaction.update(reference, {
      status: "processing",
      processingAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    return data;
  });
  if (!claimed) return;

  try {
    const activities = (await Promise.all(
      claimed.tokens.map((token) => createUserActivity(token, claimed)),
    )).filter(Boolean);
    const responses = await Promise.allSettled(
      activities.filter((activity) => activity.shouldPush).map((activity) =>
        admin.messaging().send({
          token: activity.token,
          notification: {title: claimed.title, body: claimed.body},
          data: {
            notificationId: activity.activityId,
            category: claimed.category || "general",
            targetType: claimed.targetType || "",
            targetId: claimed.targetId || "",
          },
          android: {priority: "high"},
          apns: {payload: {aps: {sound: "default"}}},
        }),
      ),
    );
    const successCount = responses.where((result) => result.status === "fulfilled").length;
    const failureCount = responses.length - successCount;
    await reference.update({
      status: failureCount === responses.length && responses.length > 0 ? "failed" : "sent",
      sentAt: admin.firestore.FieldValue.serverTimestamp(),
      successCount,
      failureCount,
    });
  } catch (error) {
    console.error("Unable to deliver notification", reference.id, error);
    await reference.update({
      status: "failed",
      failedAt: admin.firestore.FieldValue.serverTimestamp(),
      error: String(error).slice(0, 500),
    });
  }
}

exports.deliverNotificationOnCreate = onDocumentCreated(
  "notificationRequests/{requestId}",
  async (event) => deliverNotification(event.data.ref),
);

exports.deliverScheduledNotifications = onSchedule("every 1 minutes", async () => {
  const due = await requests
    .where("status", "==", "pending")
    .where("scheduledAt", "<=", admin.firestore.Timestamp.now())
    .limit(100)
    .get();
  await Promise.all(due.docs.map((document) => deliverNotification(document.ref)));
});
