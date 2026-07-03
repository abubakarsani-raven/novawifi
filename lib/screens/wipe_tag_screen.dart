import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/nfc_service.dart';
import '../services/storage_service.dart';
import '../theme/app_components.dart';
import '../widgets/nova_sheet.dart';
import '../theme/app_spacing.dart';
import '../widgets/nfc_prompt_widget.dart';
import '../widgets/nfc_write_animator.dart';
import '../utils/factory_admin_entry.dart';

class WipeTagScreen extends StatefulWidget {
  const WipeTagScreen({super.key});

  @override
  State<WipeTagScreen> createState() => _WipeTagScreenState();
}

class _WipeTagScreenState extends State<WipeTagScreen> {
  NfcWritePhase? _phase;
  String _failureMessage = '';

  @override
  void dispose() {
    NfcService.stopSession();
    super.dispose();
  }

  Future<void> _arm() async {
    if (_phase == NfcWritePhase.scanning) return;
    final l10n = AppLocalizations.of(context)!;

    final authOk = await FactoryAdminEntry.requireAuth(context);
    if (!mounted) return;
    if (!authOk) return;

    setState(() => _phase = NfcWritePhase.scanning);

    final result = await NfcService.wipeTag(onTapPrompt: () {});

    if (result.removedTagId != null) {
      await StorageService.delete(result.removedTagId!);
    }

    if (!mounted) return;

    if (result.status == NfcWipeStatus.success) {
      setState(() => _phase = NfcWritePhase.success);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.wipeTagSuccess)),
      );
      await Future.delayed(const Duration(milliseconds: 1400));
      if (!mounted) return;
      setState(() => _phase = null);
      _arm();
    } else {
      final message = switch (result.status) {
        NfcWipeStatus.tagReadOnly => l10n.tagReadOnly,
        NfcWipeStatus.notNovaTag => l10n.wipeNotNovaTag,
        NfcWipeStatus.notAvailable => l10n.errorNfcNotAvailable,
        _ => l10n.wipeTagFailed,
      };
      setState(() {
        _phase = NfcWritePhase.failure;
        _failureMessage = message;
      });
      await Future.delayed(const Duration(milliseconds: 1600));
      if (!mounted) return;
      setState(() => _phase = null);
      await NovaErrorSheet.show(
        context,
        title: l10n.wipeTagFailed,
        message: message,
        onRetry: _arm,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.wipeTagTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.wipeTagDescription,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.wipeBatchHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _phase != null
                    ? NfcWriteAnimator(
                        key: const ValueKey('animator'),
                        phase: _phase!,
                        scanLabel: l10n.wipeTagTapPrompt,
                        successLabel: l10n.wipeTagSuccess,
                        failureLabel: _failureMessage,
                      )
                    : NfcPromptWidget(
                        key: const ValueKey('prompt'),
                        prompt: l10n.wipeTagTapPrompt,
                      ),
              ),
            ),
            if (_phase == null)
              NovaPrimaryButton(
                label: l10n.wipeStartButton,
                icon: Icons.delete_forever_outlined,
                onPressed: _arm,
              ),
          ],
        ),
      ),
    );
  }
}
