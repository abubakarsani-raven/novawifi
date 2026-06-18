import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../models/wifi_network.dart';
import 'qr_service.dart';

class QrExportService {
  QrExportService._();

  static Future<Uint8List> buildWifiQrPdf(
    WifiNetwork network, {
    String scanHint = 'Scan to join WiFi',
    int dotColor = 0xFF18181B,
  }) async {
    final doc = pw.Document();
    final qrData = QrService.wifiQrData(
      network.ssid,
      network.password,
      securityType: network.securityType,
      isHidden: network.isHidden,
    );
    final label = network.label.isNotEmpty ? network.label : network.ssid;
    final isOpen = network.securityType == 'Open';

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(48),
        build: (context) {
          // Centered guest card: scan the QR, or read the name/password below.
          return pw.Center(
            child: pw.Container(
              width: 360,
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 32,
              ),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(
                  color: PdfColor.fromInt(0xFFE4E4E7),
                  width: 1.5,
                ),
                borderRadius: pw.BorderRadius.circular(20),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text(
                    'Nova Heronix WiFi',
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    label,
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                  pw.SizedBox(height: 24),
                  pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: qrData,
                    width: 220,
                    height: 220,
                    color: PdfColor.fromInt(dotColor),
                  ),
                  pw.SizedBox(height: 16),
                  pw.Text(
                    scanHint,
                    style: pw.TextStyle(
                      fontSize: 13,
                      fontStyle: pw.FontStyle.italic,
                      color: PdfColor.fromInt(0xFF71717A),
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Divider(color: PdfColor.fromInt(0xFFE4E4E7)),
                  pw.SizedBox(height: 12),
                  // Manual fallback for guests who can't scan the QR.
                  _credentialRow('Network', network.ssid),
                  if (!isOpen) ...[
                    pw.SizedBox(height: 8),
                    _credentialRow('Password', network.password),
                  ] else ...[
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Open network — no password',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );

    return doc.save();
  }

  static pw.Widget _credentialRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 12,
            color: PdfColor.fromInt(0xFF71717A),
          ),
        ),
        pw.SizedBox(width: 16),
        pw.Expanded(
          child: pw.Text(
            value,
            textAlign: pw.TextAlign.right,
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  static Future<void> sharePdf(
    WifiNetwork network, {
    String scanHint = 'Scan to join WiFi',
    int dotColor = 0xFF18181B,
  }) async {
    final bytes =
        await buildWifiQrPdf(network, scanHint: scanHint, dotColor: dotColor);
    await Printing.sharePdf(
      bytes: bytes,
      filename: _fileName(network),
    );
  }

  static Future<bool> printQr(
    WifiNetwork network, {
    String scanHint = 'Scan to join WiFi',
    int dotColor = 0xFF18181B,
  }) async {
    try {
      await Printing.layoutPdf(
        onLayout: (_) =>
            buildWifiQrPdf(network, scanHint: scanHint, dotColor: dotColor),
        name: _fileName(network),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> downloadPdf(
    WifiNetwork network, {
    String scanHint = 'Scan to join WiFi',
    int dotColor = 0xFF18181B,
  }) async {
    final bytes =
        await buildWifiQrPdf(network, scanHint: scanHint, dotColor: dotColor);
    final xFile = XFile.fromData(
      bytes,
      mimeType: 'application/pdf',
      name: '${_fileName(network)}.pdf',
    );
    await Share.shareXFiles([xFile], subject: _fileName(network));
  }

  static String _fileName(WifiNetwork network) {
    final safe = network.ssid.replaceAll(RegExp(r'[^\w\-]+'), '_');
    return 'nova_wifi_$safe';
  }
}
