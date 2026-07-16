import 'package:cloud_functions/cloud_functions.dart';

class PhoneOtpService {
  PhoneOtpService({FirebaseFunctions? functions})
      : _functions =
            functions ?? FirebaseFunctions.instanceFor(region: 'europe-west1');

  final FirebaseFunctions _functions;

  Future<void> requestCode(String phoneNumber) async {
    await _functions.httpsCallable('requestAfrikSmsOtp').call({
      'phoneNumber': phoneNumber,
    });
  }

  Future<String> verifyCode({
    required String phoneNumber,
    required String code,
  }) async {
    final result = await _functions.httpsCallable('verifyAfrikSmsOtp').call({
      'phoneNumber': phoneNumber,
      'code': code,
    });
    final token = (result.data as Map?)?['customToken']?.toString() ?? '';
    if (token.isEmpty) throw StateError('Token Firebase absent.');
    return token;
  }
}
