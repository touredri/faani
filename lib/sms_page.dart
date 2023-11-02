import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class Verification extends StatelessWidget {
  const Verification({super.key});

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
              onSubmitted: (String pin) {
                print(pin);
              },
            ),
            const SizedBox(height: 35),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(300, 50),
              ),
              onPressed: () {},
              child: const Text('Valider'),
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
                    onPressed: () {},
                    child: const Text(
                      'Envoyer encore',
                      style: TextStyle(
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
