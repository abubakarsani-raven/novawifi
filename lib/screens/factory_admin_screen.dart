import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/factory_admin_session.dart';
import '../theme/app_spacing.dart';
import 'initialize_tag_screen.dart';
import 'wipe_tag_screen.dart';

/// Hidden factory tools: brand unbranded tags, wipe tags, etc.
class FactoryAdminScreen extends StatelessWidget {
  const FactoryAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.factoryAdminTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              FactoryAdminSession.lock();
              Navigator.pop(context);
            },
            child: Text(l10n.factoryAdminLock),
          ),
        ],
      ),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          Text(
            l10n.factoryAdminDescription,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.label_outline),
                  title: Text(l10n.initializeTag),
                  subtitle: Text(l10n.factoryBrandTagSubtitle),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const InitializeTagScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.cleaning_services_outlined),
                  title: Text(l10n.wipeTagTitle),
                  subtitle: Text(l10n.wipeTagDescription),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const WipeTagScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.preShipChecklistTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Column(
              children: [
                _PreShipStep(number: '1', text: l10n.preShipStep1),
                const Divider(height: 1),
                _PreShipStep(number: '2', text: l10n.preShipStep2),
                const Divider(height: 1),
                _PreShipStep(number: '3', text: l10n.preShipStep3),
                const Divider(height: 1),
                _PreShipStep(number: '4', text: l10n.preShipStep4),
                const Divider(height: 1),
                _PreShipStep(number: '5', text: l10n.preShipStep5),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PreShipStep extends StatelessWidget {
  const _PreShipStep({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 14,
        child: Text(number, style: const TextStyle(fontSize: 12)),
      ),
      title: Text(text),
    );
  }
}
