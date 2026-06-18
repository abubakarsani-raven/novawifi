import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../l10n/app_localizations.dart';
import '../models/wifi_network.dart';
import '../services/nfc_service.dart';
import '../services/storage_service.dart';
import '../theme/app_components.dart';
import '../widgets/nova_sheet.dart';
import '../theme/app_spacing.dart';
import '../widgets/nfc_prompt_widget.dart';
import '../widgets/nfc_write_animator.dart';
import '../widgets/nh_logo.dart';
import '../utils/factory_admin_entry.dart';
import '../utils/nfc_write_status_message.dart';
import 'setup_tag_screen.dart';

/// Factory admin: write Nova Heronix security records + UUID to a blank tag before shipping.
class InitializeTagScreen extends StatefulWidget {
  const InitializeTagScreen({super.key});

  @override
  State<InitializeTagScreen> createState() => _InitializeTagScreenState();
}

class _InitializeTagScreenState extends State<InitializeTagScreen> {
  NfcWritePhase? _phase;
  String _failureMessage = '';
  String? _lastTagId;
  WifiNetwork? _lastNetwork;
  bool _showPostInit = false;

  @override
  void dispose() {
    // Release the reader session/exclusive if the screen is left mid-write, so
    // we never strand Android in app-exclusive mode (which would suppress the
    // Activity's tag handling and let the system tag screen appear) until the
    // write times out.
    NfcService.stopSession();
    super.dispose();
  }

  Future<void> _startInitialize() async {
    final l10n = AppLocalizations.of(context)!;
    final authOk = await FactoryAdminEntry.requireAuth(context);
    if (!authOk || !mounted) return;

    setState(() {
      _phase = NfcWritePhase.scanning;
      _showPostInit = false;
    });

    final network = WifiNetwork.createProvisioned(id: const Uuid().v4());
    final result = await NfcService.writeNetwork(
      network,
      blankOnly: true,
      onTapPrompt: () {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.initializeTagTapPrompt)),
        );
      },
    );

    if (!mounted) return;

    if (result.status == NfcWriteStatus.success) {
      await StorageService.upsert(network);
      if (!mounted) return;
      setState(() {
        _phase = NfcWritePhase.success;
        _lastTagId = network.id;
        _lastNetwork = network;
      });
      await Future.delayed(const Duration(milliseconds: 1400));
      if (mounted) {
        setState(() {
          _phase = null;
          _showPostInit = true;
        });
      }
    } else {
      final message = NfcWriteStatusMessage.forStatus(result.status, l10n);
      setState(() {
        _phase = NfcWritePhase.failure;
        _failureMessage = message;
      });
      await Future.delayed(const Duration(milliseconds: 1600));
      if (!mounted) return;
      setState(() => _phase = null);
      await NovaErrorSheet.show(
        context,
        title: l10n.initializeTag,
        message: message,
        onRetry: _startInitialize,
      );
    }
  }

  Future<void> _goToSetup() async {
    final network = _lastNetwork;
    if (network == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SetupTagScreen(network: network),
      ),
    );
    if (mounted) {
      setState(() => _showPostInit = false);
    }
  }

  void _initializeAnother() {
    setState(() {
      _showPostInit = false;
      _lastNetwork = null;
    });
  }

  Widget _buildBody(AppLocalizations l10n, ThemeData theme) {
    if (_phase != null) {
      return Center(
        key: const ValueKey('animator'),
        child: NfcWriteAnimator(
          phase: _phase!,
          scanLabel: l10n.holdPhoneToTag,
          successLabel: l10n.tagInitializedSuccess,
          failureLabel: _failureMessage,
        ),
      );
    }
    if (_showPostInit) {
      return Center(
        key: const ValueKey('postInit'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 72,
                color: Color(0xFF22C55E),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.tagInitializedSuccess,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_lastTagId != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.lastInitializedTagId(_lastTagId!),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      );
    }
    return NfcPromptWidget(
      key: const ValueKey('prompt'),
      prompt: l10n.initializeTagTapPrompt,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.initializeTag),
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
            if (_phase == null && !_showPostInit)
              Text(l10n.initializeTagDescription, style: theme.textTheme.bodyLarge),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildBody(l10n, theme),
              ),
            ),
            if (_showPostInit && _phase == null) ...[
              NovaPrimaryButton(
                label: l10n.setupTagTitle,
                icon: Icons.wifi,
                onPressed: _goToSetup,
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: _initializeAnother,
                icon: const Icon(Icons.nfc, size: 18),
                label: Text(l10n.initializeTag),
              ),
            ] else if (_phase == null)
              NovaPrimaryButton(
                label: l10n.initializeTag,
                icon: Icons.nfc,
                onPressed: _startInitialize,
              ),
          ],
        ),
      ),
    );
  }
}
