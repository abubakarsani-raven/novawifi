import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/app_localizations.dart';
import 'services/factory_admin_session.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';
import 'screens/main_shell.dart';

final ValueNotifier<Locale> localeNotifier = ValueNotifier(const Locale('en'));

class NovaApp extends StatefulWidget {
  const NovaApp({super.key});

  @override
  State<NovaApp> createState() => _NovaAppState();
}

class _NovaAppState extends State<NovaApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    localeNotifier.addListener(_onLocaleChanged);
    _loadLocale();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    localeNotifier.removeListener(_onLocaleChanged);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      FactoryAdminSession.lock();
    }
  }

  void _onLocaleChanged() {
    if (mounted) setState(() {});
  }

  static const _supportedLocales = {'en', 'fr', 'es'};

  Future<void> _loadLocale() async {
    final code = await StorageService.loadLocale();
    if (code == null || !mounted) return;
    // Hausa removed; migrate saved preference to English.
    final normalized = code == 'ha' || !_supportedLocales.contains(code)
        ? 'en'
        : code;
    localeNotifier.value = Locale(normalized);
    if (normalized != code) {
      await StorageService.saveLocale(normalized);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: const Key('nova_material_app'),
      title: 'Nova Heronix WiFi Manager',
      theme: AppTheme.lightFor(localeNotifier.value.languageCode),
      locale: localeNotifier.value,
      localeListResolutionCallback: (locales, supportedLocales) {
        final preferred = localeNotifier.value;
        for (final supported in supportedLocales) {
          if (supported.languageCode == preferred.languageCode) {
            return supported;
          }
        }
        return const Locale('en');
      },
      builder: (context, child) => child ?? const SizedBox.shrink(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const MainShell(),
    );
  }
}
