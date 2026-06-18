import 'package:flutter_test/flutter_test.dart';
import 'package:nova_heronix_wifi_manager/models/wifi_network.dart';

void main() {
  test('WifiNetwork fromTagJson merges WSC credentials', () {
    final network = WifiNetwork.fromTagJson(
      {
        'v': 2,
        'id': '550e8400-e29b-41d4-a716-446655440000',
        'label': 'Lobby',
        'tagProvisioned': true,
      },
      ssid: 'Guest',
      password: 'password12',
    );
    expect(network.ssid, 'Guest');
    expect(network.password, 'password12');
    expect(network.isConfigured, isTrue);
  });

  test('WifiNetwork JSON round-trip', () {
    final network = WifiNetwork(
      id: '550e8400-e29b-41d4-a716-446655440000',
      ssid: 'Office',
      password: 'secret123',
      label: 'Floor 2',
    );
    final json = network.toJson();
    final restored = WifiNetwork.fromJson(json);
    expect(restored.id, network.id);
    expect(restored.ssid, network.ssid);
    expect(restored.password, network.password);
    expect(restored.label, network.label);
  });
}
