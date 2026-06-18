import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../models/wifi_network.dart';
import '../theme/app_components.dart';
import '../theme/app_spacing.dart';

class CredentialCard extends StatefulWidget {
  const CredentialCard({super.key, required this.network});

  final WifiNetwork network;

  @override
  State<CredentialCard> createState() => _CredentialCardState();
}

class _CredentialCardState extends State<CredentialCard> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return NovaCard(
      margin: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.network.label,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.networkName),
            subtitle: Text(widget.network.ssid),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.password),
            subtitle: Text(
              _obscured ? '••••••••••••' : widget.network.password,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: _obscured ? l10n.showPassword : l10n.hidePassword,
                  onPressed: () => setState(() => _obscured = !_obscured),
                  icon: Icon(
                    _obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  ),
                ),
                IconButton(
                  tooltip: l10n.copyPassword,
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(text: widget.network.password),
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.passwordCopied)),
                      );
                    }
                  },
                  icon: const Icon(Icons.copy_outlined),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
