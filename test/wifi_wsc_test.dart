import 'package:flutter_test/flutter_test.dart';
import 'package:nova_heronix_wifi_manager/services/wifi_wsc_decoder.dart';
import 'package:nova_heronix_wifi_manager/services/wifi_wsc_encoder.dart';

void main() {
  test('WSC encoder and decoder round-trip', () {
    const ssid = 'GuestWiFi';
    const password = 'hunter2pass';

    final payload = WifiWscEncoder.encode(ssid: ssid, password: password);
    final decoded = WifiWscDecoder.decode(payload);

    expect(decoded, isNotNull);
    expect(decoded!.ssid, ssid);
    expect(decoded.password, password);
  });
}
