import 'package:flutter/material.dart';

import '../app.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class LanguageSelector extends StatefulWidget {
  const LanguageSelector({super.key});

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  static const _options = <({String code, String label})>[
    (code: 'en', label: 'English'),
    (code: 'fr', label: 'Français'),
    (code: 'es', label: 'Español'),
  ];

  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = localeNotifier.value.languageCode;
    localeNotifier.addListener(_syncFromNotifier);
  }

  @override
  void dispose() {
    localeNotifier.removeListener(_syncFromNotifier);
    super.dispose();
  }

  void _syncFromNotifier() {
    final code = localeNotifier.value.languageCode;
    if (code != _selected && mounted) {
      setState(() => _selected = code);
    }
  }

  Future<void> _onLanguageSelected(String? code) async {
    if (code == null || code == _selected) return;

    await StorageService.saveLocale(code);
    if (!mounted) return;

    setState(() => _selected = code);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      localeNotifier.value = Locale(code);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: AppTheme.brandPurple,
        selectedForegroundColor: Colors.white,
        foregroundColor: AppTheme.brandOnSurface,
        side: const BorderSide(color: AppTheme.brandOutline),
      ),
      segments: _options
          .map(
            (o) => ButtonSegment<String>(
              value: o.code,
              label: Text(o.label),
            ),
          )
          .toList(),
      selected: {_selected},
      onSelectionChanged: (s) => _onLanguageSelected(s.first),
    );
  }
}
