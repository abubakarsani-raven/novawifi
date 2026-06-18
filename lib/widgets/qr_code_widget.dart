import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../services/qr_service.dart';
import '../theme/app_components.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';

/// Visual customization for a [QrCodeWidget].
///
/// Colors are restricted by the picker UI to dark, high-contrast values so the
/// QR code stays reliably scannable against its white background.
class QrStyleOptions {
  const QrStyleOptions({
    this.dotColor = const Color(0xFF18181B),
    this.rounded = false,
  });

  /// Color applied to both the data modules (dots) and the finder eyes.
  final Color dotColor;

  /// When true, dots and eyes are drawn with rounded shapes instead of squares.
  final bool rounded;

  QrStyleOptions copyWith({Color? dotColor, bool? rounded}) {
    return QrStyleOptions(
      dotColor: dotColor ?? this.dotColor,
      rounded: rounded ?? this.rounded,
    );
  }
}

class QrCodeWidget extends StatelessWidget {
  const QrCodeWidget({
    super.key,
    required this.ssid,
    required this.password,
    required this.boundaryKey,
    this.securityType = 'WPA2',
    this.isHidden = false,
    this.label,
    this.style = const QrStyleOptions(),
  });

  final String ssid;
  final String password;
  final GlobalKey boundaryKey;
  final String securityType;
  final bool isHidden;

  /// Optional display name shown above the QR code inside the capture boundary.
  final String? label;

  /// Shape + color customization for the rendered code.
  final QrStyleOptions style;

  @override
  Widget build(BuildContext context) {
    final data = QrService.wifiQrData(ssid, password, securityType: securityType, isHidden: isHidden);
    final qrColor = style.dotColor;
    final theme = Theme.of(context);

    return NovaCard(
      padding: EdgeInsets.zero,
      child: RepaintBoundary(
        key: boundaryKey,
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (label != null && label!.isNotEmpty) ...[
                Text(
                  label!,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppTheme.brandOnSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
              ],
              QrImageView(
                data: data,
                version: QrVersions.auto,
                size: 220,
                eyeStyle: QrEyeStyle(
                  eyeShape:
                      style.rounded ? QrEyeShape.circle : QrEyeShape.square,
                  color: qrColor,
                ),
                dataModuleStyle: QrDataModuleStyle(
                  dataModuleShape: style.rounded
                      ? QrDataModuleShape.circle
                      : QrDataModuleShape.square,
                  color: qrColor,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                ssid,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF71717A),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
          ),
        ),
      ),
    );
  }
}
