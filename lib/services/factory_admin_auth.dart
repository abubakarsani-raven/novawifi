import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/factory_admin_config.dart';

enum FactoryPinVerifyResult {
  success,
  wrong,
  locked,
}

class FactoryPinVerifyResponse {
  const FactoryPinVerifyResponse(this.result, {this.secondsRemaining = 0});

  final FactoryPinVerifyResult result;
  final int secondsRemaining;
}

class FactoryAdminAuth {
  FactoryAdminAuth._();

  static const _failCountKey = 'factory_pin_fail_count';
  static const _lockUntilKey = 'factory_pin_lock_until';

  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static String _hashPin(String pin) {
    return sha256.convert(utf8.encode(pin)).toString();
  }

  static Future<int?> _secondsUntilUnlock() async {
    final lockUntilStr = await _storage.read(key: _lockUntilKey);
    if (lockUntilStr == null) return null;
    final lockUntil = int.tryParse(lockUntilStr);
    if (lockUntil == null) return null;
    final remaining = lockUntil - DateTime.now().millisecondsSinceEpoch;
    if (remaining <= 0) {
      await _storage.delete(key: _lockUntilKey);
      await _storage.write(key: _failCountKey, value: '0');
      return null;
    }
    return (remaining / 1000).ceil();
  }

  static Future<FactoryPinVerifyResponse> verifyPin(String pin) async {
    final lockedSeconds = await _secondsUntilUnlock();
    if (lockedSeconds != null) {
      return FactoryPinVerifyResponse(
        FactoryPinVerifyResult.locked,
        secondsRemaining: lockedSeconds,
      );
    }

    if (pin.length != 6) {
      return const FactoryPinVerifyResponse(FactoryPinVerifyResult.wrong);
    }

    if (_hashPin(pin) == FactoryAdminConfig.factoryAdminPinSha256) {
      await _storage.write(key: _failCountKey, value: '0');
      await _storage.delete(key: _lockUntilKey);
      return const FactoryPinVerifyResponse(FactoryPinVerifyResult.success);
    }

    final countStr = await _storage.read(key: _failCountKey) ?? '0';
    var count = int.tryParse(countStr) ?? 0;
    count++;
    await _storage.write(key: _failCountKey, value: count.toString());

    if (count >= FactoryAdminConfig.maxPinAttempts) {
      final lockUntil = DateTime.now().millisecondsSinceEpoch +
          (FactoryAdminConfig.lockoutSeconds * 1000);
      await _storage.write(key: _lockUntilKey, value: lockUntil.toString());
      return FactoryPinVerifyResponse(
        FactoryPinVerifyResult.locked,
        secondsRemaining: FactoryAdminConfig.lockoutSeconds,
      );
    }

    return const FactoryPinVerifyResponse(FactoryPinVerifyResult.wrong);
  }
}
