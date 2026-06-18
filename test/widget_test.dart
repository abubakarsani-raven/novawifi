import 'package:flutter_test/flutter_test.dart';

import 'package:nova_heronix_wifi_manager/services/qr_service.dart';

void main() {
  test('WiFi QR data escapes special characters', () {
    expect(
      QrService.wifiQrData('My;Network', 'pass:word'),
      'WIFI:T:WPA;S:My\\;Network;P:pass\\:word;;',
    );
  });
}
