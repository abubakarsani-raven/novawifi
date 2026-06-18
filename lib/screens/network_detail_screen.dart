import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../models/wifi_network.dart';
import '../services/nfc_service.dart';
import '../services/qr_export_service.dart';
import '../services/qr_service.dart';
import '../services/storage_service.dart';
import '../theme/app_components.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../utils/nfc_write_status_message.dart';
import '../widgets/nfc_write_animator.dart';
import '../widgets/nova_sheet.dart';
import '../widgets/qr_code_widget.dart';
import '../widgets/qr_style_picker.dart';
import 'change_password_screen.dart';
import 'setup_tag_screen.dart';

class NetworkDetailScreen extends StatefulWidget {
  const NetworkDetailScreen({super.key, required this.network});

  final WifiNetwork network;

  @override
  State<NetworkDetailScreen> createState() => _NetworkDetailScreenState();
}

class _NetworkDetailScreenState extends State<NetworkDetailScreen> {
  late WifiNetwork _network;
  final _qrKey = GlobalKey();
  bool _obscured = true;
  NfcWritePhase? _writePhase;
  String _writeFailureMessage = '';
  // Credentials are always visible now that the PIN gate is removed.
  final bool _credentialsUnlocked = true;
  bool _checkingAccess = true;
  QrStyleOptions _qrStyle = const QrStyleOptions();

  @override
  void initState() {
    super.initState();
    _network = widget.network;
    if (_network.needsSetup) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => SetupTagScreen(network: _network),
          ),
        );
      });
    } else {
      _checkingAccess = false;
    }
  }

  void _refresh() {
    final updated = StorageService.getById(_network.id);
    if (updated != null) setState(() => _network = updated);
  }

  Future<void> _writeToTag() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _writePhase = NfcWritePhase.scanning);

    final result = await NfcService.writeNetwork(
      _network,
      onTapPrompt: () {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.holdPhoneToTag)),
        );
      },
    );

    if (!mounted) return;

    if (result.status == NfcWriteStatus.success) {
      setState(() => _writePhase = NfcWritePhase.success);
      await StorageService.markWritten(_network.id);
      _refresh();
      await Future.delayed(const Duration(milliseconds: 1400));
      if (mounted) setState(() => _writePhase = null);
      return;
    }

    final message = NfcWriteStatusMessage.forStatus(result.status, l10n);
    setState(() {
      _writePhase = NfcWritePhase.failure;
      _writeFailureMessage = message;
    });
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;
    setState(() => _writePhase = null);
    await NovaErrorSheet.show(
      context,
      title: l10n.errorWriteFailed,
      message: message,
      onRetry: _writeToTag,
    );
  }

  Future<void> _lockTag() async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await NovaConfirmSheet.show(
      context,
      title: l10n.lockTagTitle,
      message: l10n.lockTagWarning,
      confirmLabel: l10n.lockTagConfirm,
      isDestructive: true,
    );
    if (confirm != true || !mounted) return;

    setState(() => _writePhase = NfcWritePhase.scanning);
    final status = await NfcService.lockTag(onTapPrompt: () {});
    if (!mounted) return;

    if (status == NfcLockStatus.success) {
      setState(() => _writePhase = NfcWritePhase.success);
      await StorageService.markTagLocked(_network.id);
      _refresh();
      await Future.delayed(const Duration(milliseconds: 1400));
      if (mounted) setState(() => _writePhase = null);
    } else {
      setState(() {
        _writePhase = NfcWritePhase.failure;
        _writeFailureMessage = l10n.lockTagFailed;
      });
      await Future.delayed(const Duration(milliseconds: 1600));
      if (mounted) setState(() => _writePhase = null);
    }
  }

  Future<void> _changePassword() async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => ChangePasswordScreen(network: _network),
      ),
    );
    if (changed == true) _refresh();
  }

  Future<void> _shareQr() async {
    if (!_credentialsUnlocked) return;
    final l10n = AppLocalizations.of(context)!;
    await QrService.shareQr(_qrKey, 'nova_${_network.ssid}');
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.shareQr)));
    }
  }

  Future<void> _downloadQr() async {
    if (!_credentialsUnlocked) return;
    final l10n = AppLocalizations.of(context)!;
    final ok = await QrService.saveQrToGallery(_qrKey);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? l10n.downloadQr : l10n.errorPermissionDenied),
      ),
    );
  }

  Future<void> _downloadQrPdf() async {
    if (!_credentialsUnlocked) return;
    final l10n = AppLocalizations.of(context)!;
    await QrExportService.downloadPdf(
      _network,
      scanHint: l10n.scanToJoinWifi,
      dotColor: _qrStyle.dotColor.toARGB32(),
    );
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.downloadQrPdf)));
    }
  }

  Future<void> _printQr() async {
    if (!_credentialsUnlocked) return;
    final l10n = AppLocalizations.of(context)!;
    final ok = await QrExportService.printQr(
      _network,
      scanHint: l10n.scanToJoinWifi,
      dotColor: _qrStyle.dotColor.toARGB32(),
    );
    if (!mounted) return;
    if (!ok) {
      await NovaErrorSheet.show(
        context,
        title: l10n.printQr,
        message: l10n.printQrFailed,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_checkingAccess) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _writePhase != null
            ? Center(
                key: const ValueKey('animator'),
                child: NfcWriteAnimator(
                  phase: _writePhase!,
                  scanLabel: l10n.holdPhoneToTag,
                  successLabel: l10n.successWritten,
                  failureLabel: _writeFailureMessage,
                ),
              )
            : CustomScrollView(
                key: const ValueKey('detail'),
                slivers: [
                  _DetailAppBar(network: _network),
                  SliverPadding(
                    padding: AppSpacing.screenPadding
                        .copyWith(top: AppSpacing.lg, bottom: AppSpacing.xl * 2),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        if (_network.tagLocked)
                          _LockedBanner(l10n: l10n),
                        _CredentialsCard(
                          network: _network,
                          obscured: _obscured,
                          onToggleObscure: () =>
                              setState(() => _obscured = !_obscured),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // QR Code section
                        _SectionLabel(label: l10n.qrCode),
                        const SizedBox(height: AppSpacing.sm),
                        QrCodeWidget(
                          ssid: _network.ssid,
                          password: _network.password,
                          boundaryKey: _qrKey,
                          securityType: _network.securityType,
                          isHidden: _network.isHidden,
                          label: _network.label.isNotEmpty
                              ? _network.label
                              : null,
                          style: _qrStyle,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        QrStylePicker(
                          style: _qrStyle,
                          onChanged: (s) => setState(() => _qrStyle = s),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          l10n.printQrReminder,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Export
                        _SectionLabel(label: 'Export QR'),
                        const SizedBox(height: AppSpacing.sm),
                        NovaExportGrid(
                          tiles: [
                            NovaExportTile(
                              label: l10n.shareQr,
                              icon: Icons.share_outlined,
                              onTap: _shareQr,
                              enabled: _credentialsUnlocked,
                            ),
                            NovaExportTile(
                              label: l10n.downloadQr,
                              icon: Icons.download_outlined,
                              onTap: _downloadQr,
                              enabled: _credentialsUnlocked,
                            ),
                            NovaExportTile(
                              label: l10n.downloadQrPdf,
                              icon: Icons.picture_as_pdf_outlined,
                              onTap: _downloadQrPdf,
                              enabled: _credentialsUnlocked,
                            ),
                            NovaExportTile(
                              label: l10n.printQr,
                              icon: Icons.print_outlined,
                              onTap: _printQr,
                              enabled: _credentialsUnlocked,
                            ),
                          ],
                        ),

                        // Tag actions
                        if (!_network.tagLocked) ...[
                          const SizedBox(height: AppSpacing.lg),
                          _SectionLabel(label: 'Tag actions'),
                          const SizedBox(height: AppSpacing.sm),
                          NovaPrimaryButton(
                            label: l10n.writeToNfc,
                            icon: Icons.nfc,
                            onPressed: _writeToTag,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          NovaPrimaryButton(
                            label: l10n.editCredentials,
                            icon: Icons.edit_outlined,
                            onPressed: _changePassword,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          if (_network.writtenToTag)
                            _LockTagButton(onPressed: _lockTag, l10n: l10n),
                        ],
                      ]),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ─────────────────────────── Sub-widgets ───────────────────────────────────

class _DetailAppBar extends StatelessWidget {
  const _DetailAppBar({required this.network});
  final WifiNetwork network;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 140,
      backgroundColor: AppTheme.brandPurple,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding:
            const EdgeInsets.only(left: 56, bottom: 14, right: 16),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              network.label.isNotEmpty ? network.label : network.ssid,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF5B21B6), Color(0xFF7C3AED), Color(0xFF9333EA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
    );
  }
}

class _LockedBanner extends StatelessWidget {
  const _LockedBanner({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline,
              size: 18, color: Color(0xFFD97706)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              l10n.tagPhysicallyLockedBanner,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF92400E),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CredentialsCard extends StatelessWidget {
  const _CredentialsCard({
    required this.network,
    required this.obscured,
    required this.onToggleObscure,
  });
  final WifiNetwork network;
  final bool obscured;
  final VoidCallback onToggleObscure;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.brandOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFFA855F7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.wifi, size: 20, color: Colors.white),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'WiFi Credentials',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (network.tagLocked)
                const Icon(Icons.lock_outline,
                    size: 16, color: AppTheme.brandAmber),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.sm),
          _CredRow(
            label: 'Network',
            value: network.ssid,
            icon: Icons.wifi_outlined,
          ),
          const SizedBox(height: AppSpacing.sm),
          _CredRow(
            label: 'Password',
            value: obscured ? '••••••••••••' : network.password,
            icon: obscured
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            onIconTap: onToggleObscure,
            trailing: IconButton(
              icon: const Icon(Icons.copy_outlined, size: 18),
              color: AppTheme.brandPurple,
              tooltip: 'Copy password',
              onPressed: () async {
                await Clipboard.setData(
                    ClipboardData(text: network.password));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          AppLocalizations.of(context)!.passwordCopied),
                    ),
                  );
                }
              },
            ),
          ),
          if (network.securityType.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            _CredRow(
              label: 'Security',
              value: network.securityType,
              icon: Icons.security_outlined,
            ),
          ],
        ],
      ),
    );
  }
}

class _CredRow extends StatelessWidget {
  const _CredRow({
    required this.label,
    required this.value,
    required this.icon,
    this.onIconTap,
    this.trailing,
  });
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onIconTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        GestureDetector(
          onTap: onIconTap,
          child: Icon(icon, size: 18, color: AppTheme.brandPurple),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
    );
  }
}

class _LockTagButton extends StatelessWidget {
  const _LockTagButton({required this.onPressed, required this.l10n});
  final VoidCallback onPressed;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.brandAmber, width: 1.5),
      ),
      child: TextButton.icon(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.brandAmber,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: const Icon(Icons.lock_outline, size: 18),
        label: Text(l10n.lockTag),
      ),
    );
  }
}
