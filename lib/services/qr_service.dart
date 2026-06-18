import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class QrService {
  QrService._();

  static String wifiQrData(
    String ssid,
    String password, {
    String securityType = 'WPA2',
    bool isHidden = false,
  }) {
    final t = switch (securityType) {
      'WEP'  => 'WEP',
      'Open' => 'nopass',
      _      => 'WPA', // WPA / WPA2 / WPA3 all use WPA in QR spec
    };
    final hidden = isHidden ? 'H:true;' : '';
    if (securityType == 'Open') {
      return 'WIFI:T:nopass;S:${_escape(ssid)};$hidden;';
    }
    return 'WIFI:T:$t;S:${_escape(ssid)};P:${_escape(password)};$hidden;';
  }

  static String _escape(String value) {
    return value
        .replaceAll(r'\', r'\\')
        .replaceAll(';', r'\;')
        .replaceAll(':', r'\:')
        .replaceAll(',', r'\,');
  }

  static Future<Uint8List?> captureWidget(GlobalKey boundaryKey) async {
    final context = boundaryKey.currentContext;
    if (context == null) return null;
    final boundary =
        context.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: 3);
    final byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  static Future<void> shareQr(GlobalKey boundaryKey, String fileName) async {
    final bytes = await captureWidget(boundaryKey);
    if (bytes == null) return;
    final dir = Directory.systemTemp;
    final file = File('${dir.path}/$fileName.png');
    await file.writeAsBytes(bytes);
    try {
      await Share.shareXFiles([XFile(file.path)], subject: fileName);
    } finally {
      try {
        await file.delete();
      } catch (_) {}
    }
  }

  static Future<bool> saveQrToGallery(GlobalKey boundaryKey) async {
    if (Platform.isAndroid) {
      final status = await Permission.photos.request();
      if (!status.isGranted && !status.isLimited) {
        final storage = await Permission.storage.request();
        if (!storage.isGranted) return false;
      }
    } else if (Platform.isIOS) {
      final status = await Permission.photosAddOnly.request();
      if (!status.isGranted && !status.isLimited) {
        return false;
      }
    }

    final bytes = await captureWidget(boundaryKey);
    if (bytes == null) return false;
    await Gal.putImageBytes(bytes);
    return true;
  }
}
