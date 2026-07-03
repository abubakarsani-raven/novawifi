import 'package:flutter/material.dart';

import '../app.dart';
import '../config/factory_admin_config.dart';
import '../l10n/app_localizations.dart';
import '../services/storage_service.dart';
import '../theme/app_components.dart';
import '../theme/app_spacing.dart';
import '../utils/factory_admin_entry.dart';
import '../widgets/app_bar_logo_button.dart';
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

  Future<void> _setThemeMode(ThemeMode mode) async {
    themeModeNotifier.value = mode;
    await StorageService.saveThemeMode(switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    });
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final currentTheme = themeModeNotifier.value;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                const AppBarLogoButton(),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    l10n.settingsTab,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: AppSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                NovaSectionLabel(label: l10n.language),
                const SizedBox(height: AppSpacing.sm),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: const LanguageSelector(),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                NovaSectionLabel(label: l10n.appearance),
                const SizedBox(height: AppSpacing.sm),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: SegmentedButton<ThemeMode>(
                      segments: [
                        ButtonSegment(
                          value: ThemeMode.system,
                          label: Text(l10n.themeSystem),
                          icon: const Icon(Icons.brightness_auto, size: 18),
                        ),
                        ButtonSegment(
                          value: ThemeMode.light,
                          label: Text(l10n.themeLight),
                          icon: const Icon(Icons.light_mode_outlined, size: 18),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          label: Text(l10n.themeDark),
                          icon: const Icon(Icons.dark_mode_outlined, size: 18),
                        ),
                      ],
                      selected: {currentTheme},
                      onSelectionChanged: (s) => _setThemeMode(s.first),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                NovaSectionLabel(label: l10n.aboutHeader),
                const SizedBox(height: AppSpacing.sm),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.build_outlined),
                        title: Text(l10n.serviceTools),
                        subtitle: Text(l10n.factoryAdminDescription),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => FactoryAdminEntry.open(
                          context,
                          requireUserPinFirst: false,
                        ),
                      ),
                      const Divider(
                        height: 1,
                        indent: AppSpacing.md,
                        endIndent: AppSpacing.md,
                      ),
                      ListTile(
                        leading: const Icon(Icons.info_outline_rounded),
                        title: Text(l10n.version),
                        trailing: Text(
                          '1.0.0',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onTap: _onVersionTapped,
                      ),
                      const Divider(
                        height: 1,
                        indent: AppSpacing.md,
                        endIndent: AppSpacing.md,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Text(
                          l10n.aboutFooter,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
