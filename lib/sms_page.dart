import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

import 'auth.dart';

class Verification extends StatefulWidget {
  const Verification(
      {Key? key, required this.verificationId, required this.phoneNumber})
      : super(key: key);
  final String verificationId;
  final String phoneNumber;

  @override
  State<Verification> createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  String smsCode = "";
  bool loading = false;
  bool resend = false;
  int count = 20;

  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    decompte();
  }

  late Timer timer;

  void decompte() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (count < 1) {
        timer.cancel();
        count = 20;
        resend = true;
        setState(() {});
        return;
      }
      count--;
      setState(() {});
    });
  }

  void onResendSmsCode() {
    resend = false;
    setState(() {});
    // authWithPhoneNumber(widget.phoneNumber, onCodeSend: (verificationId, v) {
    //   loading = false;
    //   decompte();
    //   setState(() {});
    // }, onFailed: (e) {
    //   loading = false;
    //   setState(() {});
    //   print("Le code est erroné");
    // }, autoRetrieval: (v) {});
  }

void onVerifySmsCode() async {
  loading = true;
  if (mounted) setState(() {});
  await validateOtp(smsCode, widget.verificationId);
  loading = true;
  if (mounted) {
    setState(() {});
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Entrer le code',
              style: TextStyle(
                color: Color(0xFF1A1C29),
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 0.05,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'qui vous a été envoyé en sms',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0x961A1C29),
                fontSize: 15,
                // fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                height: 0.09,
              ),
            ),
            const SizedBox(height: 60),
            Pinput(
              length: 6,
              autofocus: true,
              defaultPinTheme: PinTheme(
                width: 50,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFA4CEFB),
                    width: 1,
                  ),
                ),
              ),
              onChanged: (value) {
                smsCode = value;
                setState(() {});
              },
            ),
            const SizedBox(height: 35),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(300, 50),
              ),
              onPressed: smsCode.length < 6 || loading
                          ? null
                          : onVerifySmsCode,
              child: loading
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            )
                          : const Text(
                              'Verify',
                              style: TextStyle(fontSize: 20),
                            ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Pas réçu de code',
                  style: TextStyle(
                    color: Color(0xFF797979),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                TextButton(
                    onPressed: !resend ? null : onResendSmsCode,
                    child: Text(!resend
                        ? "00:${count.toString().padLeft(2, "0")}"
                        : 'Envoyer encore',
                      style: const TextStyle(
                        color: Color(0xFFE64D59),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    )),
              ],
            )
          ],
        ),
      ),
    );
  }
}
