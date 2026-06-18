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
}
