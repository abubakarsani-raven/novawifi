import 'package:flutter/services.dart';

import 'nfc_service.dart';

/// Receives NFC tags that launched or resumed the app (Android NDEF intent).
class NfcLaunchBridge {
  NfcLaunchBridge._();

  static const _channel = MethodChannel('com.novaheronix.wifimanager/nfc');

  static void Function(NfcReadResult result)? _handler;

  static Future<void> init(void Function(NfcReadResult result) onTag) async {
    _handler = onTag;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onNfcTag') {
        // Skip duplicate delivery while a Dart NFC session is active.
        if (NfcService.sessionBusy) return;
        final json = call.arguments as String?;
        if (json == null || json.isEmpty) return;
        _handler?.call(NfcService.parseNovaJson(json));
      }
    });
    final initial = await _channel.invokeMethod<String>('getPendingNovaJson');
    if (initial != null && initial.isNotEmpty) {
      onTag(NfcService.parseNovaJson(initial));
    }
  }

  static void dispose() {
    _handler = null;
    _channel.setMethodCallHandler(null);
  }
}
