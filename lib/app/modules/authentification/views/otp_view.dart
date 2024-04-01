import 'package:faani/app/style/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../../globale_widgets/circular_progress.dart';
import '../controllers/authentification_controller.dart';

class OtpView extends GetView<AuthController> {
  final AuthController controller = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: scaffoldBack,
        title: const Text('Verification du numéro'),
        centerTitle: true,
      ),
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
              'qui vous a été envoyé par sms',
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
              controller: controller.smsCodeController,
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
                controller.smsCode.value = value;
              },
              onCompleted: (value) {
                controller.smsCode.value = value;
              },
            ),
            const SizedBox(height: 35),
            Obx(() => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(300, 50),
                  ),
                  onPressed: () {
                    if (controller.smsCode.value.length < 6 ||
                        controller.loading.value) {
                      null;
                    } else {
                      controller
                          .signInWithVerificationCode(controller.smsCode.value);
                    }
                  },
                  child: controller.loading.value
                      ? circularProgress()
                      : const Text(
                          'Verifier',
                          style: TextStyle(fontSize: 20),
                        ),
                )),
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
                Obx(() => TextButton(
                    onPressed: !controller.resend.value
                        ? null
                        : controller.onResendSmsCode,
                    child: Text(
                      !controller.resend.value
                          ? "00:${controller.count.value}"
                          : 'Envoyer encore',
                      style: const TextStyle(
                        color: Color(0xFFE64D59),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ))),
              ],
            )
          ],
        ),
      ),
    );
  }
}
