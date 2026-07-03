import 'package:flutter/material.dart';

import 'dart:io';

import '../l10n/app_localizations.dart';
import '../models/wifi_network.dart';
import '../services/nfc_service.dart';
import '../services/storage_service.dart';
import '../services/wifi_scan_service.dart' show WifiScanService;
import '../utils/nfc_write_status_message.dart';
import '../widgets/nova_sheet.dart';
import '../theme/app_components.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../widgets/nfc_write_animator.dart';
import '../widgets/password_field.dart';
import '../widgets/wifi_picker_sheet.dart';
import 'network_detail_screen.dart';

const _securityTypes = ['WPA2', 'WPA3', 'WPA', 'WEP', 'Open'];

class SetupTagScreen extends StatefulWidget {
  const SetupTagScreen({super.key, required this.network});

  final WifiNetwork network;

  @override
  State<SetupTagScreen> createState() => _SetupTagScreenState();
}

class _SetupTagScreenState extends State<SetupTagScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelController;
  late final TextEditingController _ssidController;
  late final TextEditingController _passwordController;

  String _securityType = 'WPA2';
  bool _isHidden = false;
  NfcWritePhase? _phase;
  String _failureMessage = '';

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.network.label);
    _ssidController = TextEditingController(text: widget.network.ssid);
    _passwordController = TextEditingController(text: widget.network.password);
    _securityType = widget.network.securityType;
    _isHidden = widget.network.isHidden;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _ssidController.dispose();
    _passwordController.dispose();
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

  /// iOS: prefill the SSID with the network this device is connected to.
  Future<void> _useCurrentWifi() async {
    final l10n = AppLocalizations.of(context)!;
    final ssid = await WifiScanService.currentSsid();
    if (!mounted) return;
    if (ssid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.couldNotReadCurrentWifi)),
      );
      return;
    }
    setState(() => _ssidController.text = ssid);
  }

  Future<void> _saveAndWrite() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    final ssid = _ssidController.text.trim();
    final label =
        _labelController.text.trim().isEmpty ? ssid : _labelController.text.trim();

    final updated = widget.network.copyWith(
      label: label,
      ssid: ssid,
      password: _securityType == 'Open' ? '' : _passwordController.text,
      tagProvisioned: true,
      isConfigured: true,
      writtenToTag: true,
      updatedAt: DateTime.now(),
      securityType: _securityType,
      isHidden: _isHidden,
    );

    if (widget.network.tagLocked) {
      await StorageService.upsert(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.tagPhysicallyLockedBanner)),
        );
        Navigator.pop(context, true);
      }
      return;
    }

    if (NfcService.encodedSizeForNetwork(updated) >
        NfcService.ntag215UsableBytes) {
      await NovaErrorSheet.show(
        context,
        title: l10n.setupTagTitle,
        message: l10n.nfcTagTooSmall,
      );
      return;
    }

    setState(() => _phase = NfcWritePhase.scanning);

    final result = await NfcService.writeNetwork(
      updated,
      onTapPrompt: () {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.setupTagTapPrompt)),
        );
      },
    );

    if (!mounted) return;

    if (result.status == NfcWriteStatus.success) {
      await StorageService.upsert(updated);
      if (!mounted) return;
      setState(() => _phase = NfcWritePhase.success);
      await Future.delayed(const Duration(milliseconds: 1400));
      if (!mounted) return;
      setState(() => _phase = null);

      // Land straight on the detail screen; QR export lives there as a button.
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) => NetworkDetailScreen(network: updated),
        ),
      );
    } else {
      final message = NfcWriteStatusMessage.forStatus(result.status, l10n);
      setState(() {
        _phase = NfcWritePhase.failure;
        _failureMessage = message;
      });
      await Future.delayed(const Duration(milliseconds: 1600));
      if (mounted) setState(() => _phase = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
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
            : CustomScrollView(
                key: const ValueKey('form'),
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    backgroundColor: AppTheme.brandPurple,
                    leading: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    title: Text(
                      l10n.setupTagTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    flexibleSpace: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF5B21B6),
                            Color(0xFF7C3AED),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: AppSpacing.screenPadding.copyWith(
                      top: AppSpacing.lg,
                      bottom: AppSpacing.xl * 2,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              l10n.setupTagDescription,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.lg),

                            TextFormField(
                              controller: _ssidController,
                              decoration: InputDecoration(
                                labelText: l10n.networkName,
                                prefixIcon: const Icon(Icons.wifi_outlined),
                                suffixIcon: Platform.isIOS
                                    ? IconButton(
                                        icon: const Icon(
                                            Icons.my_location_outlined),
                                        tooltip: l10n.useCurrentWifi,
                                        onPressed: _useCurrentWifi,
                                      )
                                    : IconButton(
                                        icon: const Icon(
                                            Icons.wifi_find_outlined),
                                        tooltip: 'Scan nearby networks',
                                        onPressed: _scanWifi,
                                      ),
                              ),
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? l10n.networkName
                                  : null,
                            ),
                            const SizedBox(height: AppSpacing.md),

                            if (_securityType != 'Open') ...[
                              PasswordField(
                                controller: _passwordController,
                                showStrength: true,
                                validator: (v) {
                                  if (v == null || v.length < 8) {
                                    return l10n.errorPasswordTooShort;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppSpacing.md),
                            ],

                            Theme(
                              data: Theme.of(context).copyWith(
                                dividerColor: Colors.transparent,
                              ),
                              child: ExpansionTile(
                                tilePadding: EdgeInsets.zero,
                                childrenPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.tune_rounded),
                                title: Text(l10n.advancedSection),
                                children: [
                                  TextFormField(
                                    controller: _labelController,
                                    decoration: InputDecoration(
                                      labelText: '${l10n.label} (optional)',
                                      prefixIcon:
                                          const Icon(Icons.location_on_outlined),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  DropdownButtonFormField<String>(
                                    key: ValueKey(_securityType),
                                    initialValue: _securityType,
                                    decoration: InputDecoration(
                                      labelText: l10n.securityTypeLabel,
                                      prefixIcon:
                                          const Icon(Icons.lock_outline),
                                    ),
                                    items: _securityTypes
                                        .map((t) => DropdownMenuItem(
                                            value: t, child: Text(t)))
                                        .toList(),
                                    onChanged: (v) => setState(
                                        () => _securityType = v ?? 'WPA2'),
                                  ),
                                  SwitchListTile(
                                    value: _isHidden,
                                    onChanged: (v) =>
                                        setState(() => _isHidden = v),
                                    title: Text(l10n.hiddenNetworkLabel),
                                    subtitle: Text(l10n.hiddenNetworkSubtitle),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: AppSpacing.lg),
                            NovaPrimaryButton(
                              label: l10n.saveAndWrite,
                              icon: Icons.nfc,
                              onPressed: _saveAndWrite,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
