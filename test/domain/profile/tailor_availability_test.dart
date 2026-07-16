import 'package:faani/app/domain/profile/tailor_availability.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses persisted availability with a safe default', () {
    expect(
      TailorAvailabilityValue.fromStorage('limited'),
      TailorAvailability.limited,
    );
    expect(
      TailorAvailabilityValue.fromStorage('unknown'),
      TailorAvailability.available,
    );
  });
}
