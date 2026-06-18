import 'package:flutter_test/flutter_test.dart';
import 'package:nova_heronix_wifi_manager/services/nfc_constants.dart';

void main() {
  test('UUID v4 pattern accepts valid id', () {
    expect(
      NfcConstants.uuidV4Pattern.hasMatch(
        '550e8400-e29b-41d4-a716-446655440000',
      ),
      isTrue,
    );
  });

  test('UUID v4 pattern rejects invalid id', () {
    expect(
      NfcConstants.uuidV4Pattern.hasMatch('not-a-uuid'),
      isFalse,
    );
  });
}
