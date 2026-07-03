import 'dart:io';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/wifi_scan_service.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';

class WifiPickerResult {
  const WifiPickerResult({
    required this.ssid,
    required this.securityType,
  });

  final String ssid;
  final String securityType;
}

class WifiPickerSheet extends StatefulWidget {
  const WifiPickerSheet({super.key});

  static Future<WifiPickerResult?> show(BuildContext context) {
    return showModalBottomSheet<WifiPickerResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const WifiPickerSheet(),
    );
  }

  @override
  State<WifiPickerSheet> createState() => _WifiPickerSheetState();
}

class _WifiPickerSheetState extends State<WifiPickerSheet> {
  List<WifiNetwork>? _networks;
  bool _scanning = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scan();
  }

  Future<void> _scan() async {
    setState(() {
      _scanning = true;
      _error = null;
    });

    final l10n = AppLocalizations.of(context)!;

    if (!Platform.isAndroid) {
      setState(() {
        _scanning = false;
        _error = l10n.wifiScanAndroidOnly;
      });
      return;
    }

    final results = await WifiScanService.scan();
    if (!mounted) return;

    if (results == null) {
      setState(() {
        _scanning = false;
        _error = l10n.wifiScanPermissionRequired;
      });
    } else {
      setState(() {
        _scanning = false;
        _networks = results;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, controller) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
              0,
            ),
            child: Row(
              children: [
                Text(
                  l10n.nearbyNetworks,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (!_scanning)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: l10n.rescan,
                    onPressed: _scan,
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(child: _buildBody(theme, controller, l10n)),
        ],
      ),
    );
  }

  Widget _buildBody(
    ThemeData theme,
    ScrollController controller,
    AppLocalizations l10n,
  ) {
    if (_scanning) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: AppSpacing.md),
            Text(l10n.scanningForNetworks),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.wifi_off_outlined,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final networks = _networks!;
    if (networks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_find_outlined,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(l10n.wifiScanNoNetworks, style: theme.textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.sm),
            TextButton.icon(
              onPressed: _scan,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: controller,
      itemCount: networks.length,
      itemBuilder: (_, i) {
        final n = networks[i];
        return ListTile(
          leading: _SignalIcon(bars: n.signalBars),
          title: Text(
            n.ssid,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: _SecurityBadge(type: n.securityType),
          onTap: () => Navigator.pop(
            context,
            WifiPickerResult(ssid: n.ssid, securityType: n.securityType),
          ),
        );
      },
    );
  }
}

class _SignalIcon extends StatelessWidget {
  const _SignalIcon({required this.bars});
  final int bars;

  @override
  Widget build(BuildContext context) {
    final color = bars >= 3
        ? AppTheme.brandPurple
        : Theme.of(context).colorScheme.onSurfaceVariant;
    final icon = switch (bars) {
      4 => Icons.signal_wifi_4_bar,
      3 => Icons.network_wifi_3_bar,
      2 => Icons.network_wifi_2_bar,
      _ => Icons.network_wifi_1_bar,
    };
    return Icon(icon, color: color, size: 22);
  }
}

class _SecurityBadge extends StatelessWidget {
  const _SecurityBadge({required this.type});
  final String type;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (label, color) = switch (type) {
      'WPA3' => ('WPA3', const Color(0xFF16A34A)),
      'WPA2' => ('WPA2', AppTheme.brandPurple),
      'WPA' => ('WPA', const Color(0xFFF59E0B)),
      'WEP' => ('WEP', theme.colorScheme.error),
      _ => ('Open', theme.colorScheme.onSurfaceVariant),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
