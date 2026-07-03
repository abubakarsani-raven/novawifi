import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_scan/wifi_scan.dart';

class WifiNetwork {
  const WifiNetwork({
    required this.ssid,
    required this.securityType,
    required this.signalLevel,
  });

  final String ssid;
  final String securityType;
  final int signalLevel; // dBm

  int get signalBars {
    if (signalLevel >= -55) return 4;
    if (signalLevel >= -66) return 3;
    if (signalLevel >= -77) return 2;
    return 1;
  }
}

class WifiScanService {
  WifiScanService._();

  static const _channel = MethodChannel('com.novaheronix.wifimanager/nfc');

  /// iOS only: returns the SSID of the network this device is currently joined
  /// to, or null if unavailable/denied. iOS exposes this only after the user
  /// grants Location ("When in Use") permission. Android uses [scan] instead.
  static Future<String?> currentSsid() async {
    if (!Platform.isIOS) return null;
    try {
      final ssid = await _channel.invokeMethod<String>('getCurrentWifiSsid');
      if (ssid == null || ssid.trim().isEmpty) return null;
      return ssid.trim();
    } catch (_) {
      return null;
    }
  }

  /// Returns null if scanning is not supported or permission denied.
  /// Returns empty list if no networks found.
  static Future<List<WifiNetwork>?> scan() async {
    if (!Platform.isAndroid) return null;

    // Check and request location permission (required for WiFi scan on Android 6+).
    final status = await Permission.location.request();
    if (!status.isGranted) return null;

    // Check if scanning is supported.
    final can = await WiFiScan.instance.canStartScan(askPermissions: false);
    if (can != CanStartScan.yes) return null;

    final canGet = await WiFiScan.instance.canGetScannedResults(askPermissions: false);
    if (canGet != CanGetScannedResults.yes) return null;

    // Trigger a fresh scan then wait for the OS to deliver results via stream.
    // Fallback: if the stream doesn't fire within 5 s, read whatever is cached.
    await WiFiScan.instance.startScan();

    final completer = Completer<void>();
    late StreamSubscription<List<WiFiAccessPoint>> sub;
    sub = WiFiScan.instance.onScannedResultsAvailable.listen((_) {
      if (!completer.isCompleted) completer.complete();
      sub.cancel();
    });
    await completer.future
        .timeout(const Duration(seconds: 5), onTimeout: () => sub.cancel());

    final results = await WiFiScan.instance.getScannedResults();

    return results
        .where((ap) => ap.ssid.isNotEmpty)
        .map((ap) => WifiNetwork(
              ssid: ap.ssid,
              securityType: _parseSecurityType(ap.capabilities),
              signalLevel: ap.level,
            ))
        .toList()
      ..sort((a, b) => b.signalLevel.compareTo(a.signalLevel));
  }

  static String _parseSecurityType(String capabilities) {
    final c = capabilities.toUpperCase();
    if (c.contains('SAE') || c.contains('WPA3')) return 'WPA3';
    if (c.contains('WPA2') || c.contains('RSN')) return 'WPA2';
    if (c.contains('WPA')) return 'WPA';
    if (c.contains('WEP')) return 'WEP';
    return 'Open';
  }
}
