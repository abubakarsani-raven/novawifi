import 'package:flutter/material.dart';

import '../config/factory_admin_config.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_spacing.dart';
import '../utils/factory_admin_entry.dart';
import '../widgets/language_selector.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  int _versionTapCount = 0;
  DateTime? _lastVersionTap;

  Future<void> _onVersionTapped() async {
    final now = DateTime.now();
    if (_lastVersionTap == null ||
        now.difference(_lastVersionTap!) > const Duration(seconds: 3)) {
      _versionTapCount = 0;
    }
    _lastVersionTap = now;
    _versionTapCount++;

    if (_versionTapCount < FactoryAdminConfig.secretTapCount) return;

    _versionTapCount = 0;
    if (mounted) {
      await FactoryAdminEntry.open(context, requireUserPinFirst: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.language, style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  const LanguageSelector(),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          GestureDetector(
            onTap: _onVersionTapped,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Text(
                '${l10n.version} 1.0.0',
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.aboutFooter,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
