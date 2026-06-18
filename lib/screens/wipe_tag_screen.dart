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
import '../widgets/nh_logo.dart';

class WipeTagScreen extends StatefulWidget {
  const WipeTagScreen({super.key});

  @override
  State<WipeTagScreen> createState() => _WipeTagScreenState();
}

class _WipeTagScreenState extends State<WipeTagScreen> {
  /// Drives the clear animation: scanning → success (checkmark) / failure (X).
  /// Null means idle (showing the prompt + a button to start).
  NfcWritePhase? _phase;
  String _failureMessage = '';

  @override
  void initState() {
    super.initState();
    // Arm the reader session as soon as the screen opens (mirrors ScanScreen)
    // so system NFC dispatch is suppressed before the user taps their tag.
    WidgetsBinding.instance.addPostFrameCallback((_) => _arm());
  }

  @override
  void dispose() {
    // Release the reader session/exclusive when leaving the screen.
    NfcService.stopSession();
    super.dispose();
  }

  Future<void> _arm() async {
    if (_phase == NfcWritePhase.scanning) return;
    final l10n = AppLocalizations.of(context)!;

    final authOk = await FactoryAdminEntry.requireAuth(context);
    if (!mounted) return;
    if (!authOk) {
      Navigator.pop(context);
      return;
    }

    setState(() => _phase = NfcWritePhase.scanning);

    final result = await NfcService.wipeTag(
      // The scanning animation is already on screen; nothing extra to show when
      // the session actually begins.
      onTapPrompt: () {},
    );

    if (result.removedTagId != null) {
      await StorageService.delete(result.removedTagId!);
    }

    if (!mounted) return;

    if (result.status == NfcWipeStatus.success) {
      setState(() => _phase = NfcWritePhase.success);
      await Future.delayed(const Duration(milliseconds: 1400));
      if (!mounted) return;
      setState(() => _phase = null);
      // Re-arm so the operator can clear tags back-to-back without tapping the
      // button each time (factory batch flow).
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
          icon: const NhLogo(),
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
                label: l10n.wipeTagTitle,
                icon: Icons.delete_forever_outlined,
                onPressed: _arm,
              ),
          ],
        ),
      ),
    );
  }
}
