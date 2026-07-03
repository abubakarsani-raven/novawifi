import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/wifi_network.dart';

class StorageService {
  StorageService._();

  static const _boxName = 'wifi_networks';
  static const _encryptionKeyName = 'hive_encryption_key';
  static const _localeKey = 'app_locale';
  static const _onboardingKey = 'onboarding_completed';
  static const _themeModeKey = 'theme_mode';

  static final FlutterSecureStorage _secureStorage =
      const FlutterSecureStorage();
  static Box<WifiNetwork>? _box;
  static final ValueNotifier<int> networksRevision = ValueNotifier(0);

  static Box<WifiNetwork> get box {
    final b = _box;
    if (b == null) {
      throw StateError('StorageService not initialized');
    }
    return b;
  }

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(WifiNetworkAdapter());

    var keyString = await _secureStorage
        .read(key: _encryptionKeyName)
        .timeout(const Duration(seconds: 10));
    if (keyString == null) {
      final key = Hive.generateSecureKey();
      keyString = base64Encode(key);
      await _secureStorage
          .write(key: _encryptionKeyName, value: keyString)
          .timeout(const Duration(seconds: 10));
    }

    final encryptionKey = base64Decode(keyString);
    _box = await Hive.openBox<WifiNetwork>(
      _boxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    ).timeout(const Duration(seconds: 10));
  }

  static void _notify() {
    networksRevision.value++;
  }

  /// Inserts sample networks (only when the box is empty) for demos and App
  /// Store screenshots. Gated behind --dart-define=SEED_DEMO=true in main().
  static Future<void> seedDemoNetworks() async {
    if (box.isNotEmpty) return;
    final now = DateTime.now();
    final demo = [
      WifiNetwork(
        id: '11111111-1111-4111-8111-111111111111',
        ssid: 'Nova Lobby',
        password: 'welcome2024',
        label: 'Lobby Guest',
        securityType: 'WPA2',
        isConfigured: true,
        tagProvisioned: true,
        writtenToTag: true,
        updatedAt: now,
      ),
      WifiNetwork(
        id: '22222222-2222-4222-8222-222222222222',
        ssid: 'BrewHouse',
        password: 'espresso123',
        label: 'Café Wi‑Fi',
        securityType: 'WPA2',
        isConfigured: true,
        tagProvisioned: true,
        writtenToTag: true,
        updatedAt: now,
      ),
      WifiNetwork(
        id: '33333333-3333-4333-8333-333333333333',
        ssid: '',
        password: '',
        label: 'Suite 204',
        securityType: 'WPA2',
        isConfigured: false,
        tagProvisioned: true,
        writtenToTag: true,
        updatedAt: now,
      ),
    ];
    for (final n in demo) {
      await box.put(n.id, n);
    }
    _notify();
  }

  static List<WifiNetwork> getAll() {
    return box.values.toList()
      ..sort((a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));
  }

  static WifiNetwork? getById(String id) => box.get(id);

  static Future<void> upsert(WifiNetwork network) async {
    await box.put(network.id, network);
    _notify();
  }

  static Future<void> delete(String id) async {
    await box.delete(id);
    _notify();
  }

  static Future<void> markWritten(String id) async {
    final network = getById(id);
    if (network == null) return;
    network.writtenToTag = true;
    network.updatedAt = DateTime.now();
    await network.save();
    _notify();
  }

  static Future<void> markTagLocked(String id) async {
    final network = getById(id);
    if (network == null) return;
    network.tagLocked = true;
    network.updatedAt = DateTime.now();
    await network.save();
    _notify();
  }

  static Future<void> saveLocale(String languageCode) async {
    await _secureStorage.write(key: _localeKey, value: languageCode);
  }

  static Future<String?> loadLocale() async {
    return _secureStorage.read(key: _localeKey);
  }

  static Future<bool> hasCompletedOnboarding() async {
    final value = await _secureStorage.read(key: _onboardingKey);
    return value == 'true';
  }

  static Future<void> setOnboardingCompleted() async {
    await _secureStorage.write(key: _onboardingKey, value: 'true');
  }

  static Future<void> saveThemeMode(String mode) async {
    await _secureStorage.write(key: _themeModeKey, value: mode);
  }

  static Future<String?> loadThemeMode() async {
    return _secureStorage.read(key: _themeModeKey);
  }

  /// Count of tags awaiting WiFi setup.
  static int countNeedsSetup() =>
      box.values.where((n) => n.needsSetup).length;

  /// Configured tags not yet written to NFC.
  static int countNotWritten() => box.values
      .where((n) => !n.needsSetup && !n.writtenToTag)
      .length;
}
