import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/wifi_network.dart';
import '../services/nfc_service.dart';
import '../services/storage_service.dart';
import '../utils/nfc_write_status_message.dart';
import '../theme/app_components.dart';
import '../theme/app_spacing.dart';
import '../widgets/nh_logo.dart';
import '../widgets/nfc_write_animator.dart';
import '../widgets/password_field.dart';
import '../widgets/wifi_picker_sheet.dart';

const _securityTypes = ['WPA2', 'WPA3', 'WPA', 'WEP', 'Open'];

/// Edit SSID, password, and label for a configured tag, then write back to the same tag.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key, required this.network});

  final WifiNetwork network;

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelController;
  late final TextEditingController _ssidController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmController;

  String _securityType = 'WPA2';
  bool _isHidden = false;
  NfcWritePhase? _phase;
  String _failureMessage = '';

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.network.label);
    _ssidController = TextEditingController(text: widget.network.ssid);
    _passwordController = TextEditingController();
    _confirmController = TextEditingController();
    _securityType = widget.network.securityType;
    _isHidden = widget.network.isHidden;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _ssidController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _scanWifi() async {
    final result = await WifiPickerSheet.show(context);
    if (!mounted || result == null) return;
    setState(() {
      _ssidController.text = result.ssid;
      _securityType = result.securityType;
    });
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    if (_securityType != 'Open' &&
        _passwordController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorPasswordMismatch)),
      );
      return;
    }

    final updated = widget.network.copyWith(
      label: _labelController.text.trim(),
      ssid: _ssidController.text.trim(),
      password: _securityType == 'Open' ? '' : _passwordController.text,
      isConfigured: true,
      writtenToTag: true,
      updatedAt: DateTime.now(),
      securityType: _securityType,
      isHidden: _isHidden,
    );

    if (!widget.network.tagLocked) {
      setState(() => _phase = NfcWritePhase.scanning);

      final writeResult = await NfcService.writeNetwork(
        updated,
        onTapPrompt: () {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.holdPhoneToTag)),
          );
        },
      );
      if (!mounted) return;

      if (writeResult.status == NfcWriteStatus.success) {
        await StorageService.upsert(updated);
        await StorageService.markWritten(updated.id);
        if (!mounted) return;
        setState(() => _phase = NfcWritePhase.success);
        await Future.delayed(const Duration(milliseconds: 1400));
        if (mounted) Navigator.pop(context, true);
        return;
      }

      final message =
          NfcWriteStatusMessage.forStatus(writeResult.status, l10n);
      setState(() {
        _phase = NfcWritePhase.failure;
        _failureMessage = message;
      });
      await Future.delayed(const Duration(milliseconds: 1600));
      if (mounted) setState(() => _phase = null);
      return;
    }

    await StorageService.upsert(updated);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editCredentialsTitle),
        leading: IconButton(
          icon: const NhLogo(),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _phase != null
            ? Center(
                key: const ValueKey('animator'),
                child: NfcWriteAnimator(
                  phase: _phase!,
                  scanLabel: l10n.holdPhoneToTag,
                  successLabel: l10n.successWritten,
                  failureLabel: _failureMessage,
                ),
              )
            : Form(
                key: _formKey,
                child: ListView(
                  key: const ValueKey('form'),
                  padding: AppSpacing.screenPadding,
                  children: [
                    Text(l10n.tagIdLabel(widget.network.id), style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: AppSpacing.md),

                    // Label
                    TextFormField(
                      controller: _labelController,
                      decoration: InputDecoration(labelText: l10n.label),
                      validator: (v) => v == null || v.trim().isEmpty ? l10n.label : null,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // SSID with scan button
                    TextFormField(
                      controller: _ssidController,
                      decoration: InputDecoration(
                        labelText: l10n.networkName,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.wifi_find_outlined),
                          tooltip: 'Scan nearby networks',
                          onPressed: _scanWifi,
                        ),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? l10n.networkName : null,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Security type
                    DropdownButtonFormField<String>(
                      key: ValueKey(_securityType),
                      initialValue: _securityType,
                      decoration: InputDecoration(
                        labelText: l10n.securityTypeLabel,
                      ),
                      items: _securityTypes
                          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                          .toList(),
                      onChanged: (v) => setState(() => _securityType = v ?? 'WPA2'),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Password (hidden for Open networks)
                    if (_securityType != 'Open') ...[
                      PasswordField(
                        controller: _passwordController,
                        label: l10n.newPassword,
                        showStrength: true,
                        validator: (v) {
                          if (v == null || v.length < 8) return l10n.errorPasswordTooShort;
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      PasswordField(
                        controller: _confirmController,
                        label: l10n.confirmPassword,
                        validator: (v) {
                          if (_securityType != 'Open' && v != _passwordController.text) {
                            return l10n.errorPasswordMismatch;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],

                    // Hidden network toggle
                    SwitchListTile(
                      value: _isHidden,
                      onChanged: (v) => setState(() => _isHidden = v),
                      title: Text(l10n.hiddenNetworkLabel),
                      subtitle: Text(l10n.hiddenNetworkSubtitle),
                      contentPadding: EdgeInsets.zero,
                    ),

                    const SizedBox(height: AppSpacing.lg),
                    NovaPrimaryButton(label: l10n.saveAndWrite, onPressed: _save),
                  ],
                ),
              ),
      ),
    );
  }
}
