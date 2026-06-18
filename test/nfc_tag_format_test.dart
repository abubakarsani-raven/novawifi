import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:nfc_manager/ndef_record.dart';
import 'package:nova_heronix_wifi_manager/models/wifi_network.dart';
import 'package:nova_heronix_wifi_manager/services/nfc_constants.dart';
import 'package:nova_heronix_wifi_manager/services/nfc_service.dart';
import 'package:nova_heronix_wifi_manager/services/wifi_wsc_encoder.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('toTagJson excludes credentials', () {
    final network = WifiNetwork(
      id: '550e8400-e29b-41d4-a716-446655440000',
      ssid: 'Guest',
      password: 'password12',
      label: 'Lobby',
      tagProvisioned: true,
      isConfigured: true,
    );

    final tagJson = network.toTagJson();
    expect(tagJson['v'], NfcConstants.tagFormatVersion);
    expect(tagJson.containsKey('ssid'), isFalse);
    expect(tagJson.containsKey('password'), isFalse);
    expect(WifiNetwork.isLegacyTagJson(tagJson), isFalse);
  });

  test('isLegacyTagJson detects v1 payloads', () {
    expect(
      WifiNetwork.isLegacyTagJson({
        'id': '550e8400-e29b-41d4-a716-446655440000',
        'ssid': 'Guest',
        'password': 'password12',
      }),
      isTrue,
    );
  });

  test('validateOutgoingMessage rejects Text records', () {
    final network = WifiNetwork(
      id: '550e8400-e29b-41d4-a716-446655440000',
      ssid: 'Guest',
      password: 'password12',
      label: 'Lobby',
      isConfigured: true,
    );

    final bad = NdefMessage(records: [
      NdefRecord(
        typeNameFormat: TypeNameFormat.wellKnown,
        type: utf8.encode('T'),
        identifier: Uint8List(0),
        payload: utf8.encode('{"id":"x"}'),
      ),
    ]);

    expect(
      NfcService.validateOutgoingMessage(bad, network),
      isNotNull,
    );
  });

  test('configured Android message is WSC + Nova, no AAR (no app push)', () {
    final network = WifiNetwork(
      id: '550e8400-e29b-41d4-a716-446655440000',
      ssid: 'Guest',
      password: 'password12',
      label: 'Lobby',
      isConfigured: true,
    );

    final message = NfcService.buildMessageForNetwork(network);
    if (!Platform.isAndroid) return;

    // Guest WiFi tags: WSC join record + Nova metadata only. No AAR launcher
    // so tapping never pushes a guest to install the app; app-less guests use
    // the QR code instead.
    expect(message.records.length, 2);
    expect(
      String.fromCharCodes(message.records[0].type),
      WifiWscEncoder.mimeType,
    );
    expect(
      String.fromCharCodes(message.records[1].type),
      NfcConstants.novaDataMimeType,
    );
    final hasUri = message.records.any(
      (r) =>
          r.typeNameFormat == TypeNameFormat.wellKnown &&
          String.fromCharCodes(r.type) == 'U',
    );
    expect(hasUri, isFalse);
    final hasAar = message.records.any(
      (r) =>
          r.typeNameFormat == TypeNameFormat.external &&
          String.fromCharCodes(r.type) == NfcConstants.aarType,
    );
    expect(hasAar, isFalse);
    expect(
      NfcService.validateOutgoingMessage(message, network),
      isNull,
    );

    final novaJson = jsonDecode(
      utf8.decode(message.records[1].payload),
    ) as Map<String, dynamic>;
    expect(novaJson['v'], NfcConstants.tagFormatVersion);
    expect(novaJson.containsKey('password'), isFalse);
  });

  test('parseNovaJson accepts compact i key', () {
    const id = '550e8400-e29b-41d4-a716-446655440000';
    final result = NfcService.parseNovaJson(
      jsonEncode({'v': 2, 'i': id, 'l': 'Lobby', 'p': true, 'c': true}),
    );
    expect(result.status, NfcReadStatus.success);
    expect(result.network?.id, id);
    expect(result.network?.label, 'Lobby');
  });

  test('parseNovaJson rejects payload without tag id', () {
    final result = NfcService.parseNovaJson('{"v":2,"l":""}');
    expect(result.status, NfcReadStatus.unrecognisedTag);
  });

  test('built tag nova JSON round-trips through parseNovaJson', () {
    final network = WifiNetwork(
      id: '550e8400-e29b-41d4-a716-446655440000',
      ssid: 'Guest',
      password: 'password12',
      label: 'Lobby',
      tagProvisioned: true,
      isConfigured: true,
    );

    final message = NfcService.buildMessageForNetwork(network);
    final novaRecord = message.records.last;
    final result = NfcService.parseNovaJson(
      utf8.decode(novaRecord.payload),
    );

    expect(result.status, NfcReadStatus.success);
    expect(result.network?.id, network.id);
    expect(result.network?.tagProvisioned, isTrue);
    expect(result.network?.isConfigured, isTrue);
  });

  test('provisioned tag nova JSON round-trips through parseNovaJson', () {
    final network = WifiNetwork.createProvisioned(
      id: '550e8400-e29b-41d4-a716-446655440000',
    );

    final message = NfcService.buildMessageForNetwork(network);

    // Provisioned tags always lead with the Universal Link URI record so iOS
    // auto-opens the app on tap.
    expect(message.records.first.typeNameFormat, TypeNameFormat.wellKnown);
    expect(String.fromCharCodes(message.records.first.type), 'U');

    if (Platform.isAndroid) {
      // URI + Nova metadata + AAR (last) so Android still launches via the AAR.
      expect(message.records.length, 3);
      expect(
        String.fromCharCodes(message.records.last.type),
        NfcConstants.aarType,
      );
    }

    final novaRecord = message.records.firstWhere(
      (r) =>
          r.typeNameFormat == TypeNameFormat.media &&
          String.fromCharCodes(r.type) == NfcConstants.novaDataMimeType,
    );
    final result = NfcService.parseNovaJson(
      utf8.decode(novaRecord.payload),
    );

    expect(result.status, NfcReadStatus.success);
    expect(result.network?.id, network.id);
    expect(result.network?.tagProvisioned, isTrue);
    expect(result.network?.isConfigured, isFalse);
  });

  test('typical configured tag fits NTAG215', () {
    final network = WifiNetwork(
      id: '550e8400-e29b-41d4-a716-446655440000',
      ssid: 'GuestWiFi',
      password: 'hunter2pass',
      label: 'Lobby',
      isConfigured: true,
    );
    expect(
      NfcService.encodedSizeForNetwork(network),
      lessThanOrEqualTo(NfcService.ntag215UsableBytes),
    );
  });

  test('max-length credentials exceed NTAG215 on Android', () {
    if (!Platform.isAndroid) return;
    final network = WifiNetwork(
      id: '550e8400-e29b-41d4-a716-446655440000',
      ssid: 'A' * 32,
      password: 'x' * 63,
      label: 'B' * 32,
      isConfigured: true,
    );
    expect(
      NfcService.encodedSizeForNetwork(network),
      greaterThan(NfcService.ntag215UsableBytes),
    );
  });
}
