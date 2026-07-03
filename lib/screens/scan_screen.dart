import 'dart:io';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/nfc_service.dart';
import '../services/storage_service.dart';
import '../theme/app_components.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../utils/nfc_tag_router.dart';
import '../widgets/nfc_prompt_widget.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({
    super.key,
    required this.active,
    required this.onNavigateToNetwork,
    required this.onNavigateToSetup,
    required this.onViewNetworks,
  });

  static final GlobalKey<ScanScreenState> scanKey =
      GlobalKey<ScanScreenState>();

  final bool active;
  final void Function(String networkId) onNavigateToNetwork;
  final void Function(String networkId) onNavigateToSetup;
  final VoidCallback onViewNetworks;

  @override
  State<ScanScreen> createState() => ScanScreenState();
}

class ScanScreenState extends State<ScanScreen> {
  bool _nfcAvailable = true;

  /// True only while a one-shot scan the user explicitly started is running.
  bool _scanning = false;

  @override
  void initState() {
    super.initState();
    _checkNfc();
    StorageService.networksRevision.addListener(_onNetworksChanged);
  }

  @override
  void dispose() {
    StorageService.networksRevision.removeListener(_onNetworksChanged);
    if (_scanning) NfcService.stopSession();
    super.dispose();
  }

  void _onNetworksChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _checkNfc() async {
    final available = await NfcService.isAvailable();
    if (mounted) setState(() => _nfcAvailable = available);
  }

  Future<void> startScan() => _scanOnce();

  Future<void> _scanOnce() async {
    if (_scanning || !_nfcAvailable) return;
    setState(() => _scanning = true);

    await NfcService.startReadSession(
      releaseExclusiveAfterRead: true,
      onRead: (result) async {
        if (!mounted) return;
        setState(() => _scanning = false);

        if (result.status == NfcReadStatus.notAvailable) {
          setState(() => _nfcAvailable = false);
          return;
        }

        final route = await NfcTagRouter.handleRead(context, result);
        if (route != null && mounted) {
          if (route.isLegacyFormat) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.legacyTagBanner),
                duration: const Duration(seconds: 6),
              ),
            );
          }
          if (route.forSetup) {
            widget.onNavigateToSetup(route.networkId);
          } else {
            widget.onNavigateToNetwork(route.networkId);
          }
        }
      },
      onError: (_) {
        if (mounted) setState(() => _scanning = false);
      },
    );
  }

  Future<void> _cancelScan() async {
    await NfcService.stopSession();
    if (mounted) setState(() => _scanning = false);
  }

  String? _statusBannerMessage(AppLocalizations l10n) {
    final needsSetup = StorageService.countNeedsSetup();
    if (needsSetup > 0) {
      return l10n.tagsNeedSetupBanner(needsSetup);
    }
    final notWritten = StorageService.countNotWritten();
    if (notWritten > 0) {
      return l10n.tagsNotWrittenBanner(notWritten);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final statusMessage = _statusBannerMessage(l10n);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _HeroSection(
            nfcAvailable: _nfcAvailable,
            scanning: _scanning,
            l10n: l10n,
          ),
        ),
        if (statusMessage != null)
          SliverToBoxAdapter(
            child: _TappableInfoBanner(
              icon: Icons.info_outline,
              message: statusMessage,
              actionLabel: l10n.viewNetworks,
              onTap: widget.onViewNetworks,
            ),
          ),
        if (!_nfcAvailable)
          SliverToBoxAdapter(
            child: _InfoBanner(
              icon: Icons.nfc_outlined,
              message: l10n.qrManualModeBanner,
            ),
          )
        else if (Platform.isIOS)
          SliverToBoxAdapter(
            child: _InfoBanner(
              icon: Icons.tap_and_play_outlined,
              message: l10n.iosGuestQrHint,
            ),
          ),
        if (_nfcAvailable)
          SliverToBoxAdapter(
            child: Padding(
              padding: AppSpacing.screenPadding.copyWith(
                top: AppSpacing.lg,
                bottom: AppSpacing.sm,
              ),
              child: _scanning
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        NfcPromptWidget(
                          prompt: l10n.holdPhoneToTag,
                          diameter: 150,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        NovaSecondaryButton(
                          label: l10n.cancel,
                          onPressed: _cancelScan,
                        ),
                      ],
                    )
                  : NovaPrimaryButton(
                      label: l10n.scanTagButton,
                      icon: Icons.nfc_rounded,
                      onPressed: _scanOnce,
                    ),
            ),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: AppSpacing.screenPadding.copyWith(
              top: AppSpacing.lg,
              bottom: AppSpacing.md,
            ),
            child: Text(
              l10n.scanToSetupPrompt,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: AppSpacing.screenPadding.copyWith(top: 0, bottom: AppSpacing.xl),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _StepTile(
                number: '1',
                title: l10n.scanStep1Title,
                subtitle: l10n.scanStep1Subtitle,
                color: AppTheme.brandPurple,
              ),
              const SizedBox(height: AppSpacing.sm),
              _StepTile(
                number: '2',
                title: l10n.scanStep2Title,
                subtitle: l10n.scanStep2Subtitle,
                color: AppTheme.brandAmber,
              ),
              const SizedBox(height: AppSpacing.sm),
              _StepTile(
                number: '3',
                title: l10n.scanStep3Title,
                subtitle: l10n.scanStep3Subtitle,
                color: AppTheme.brandGreen,
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.nfcAvailable,
    required this.scanning,
    required this.l10n,
  });

  final bool nfcAvailable;
  final bool scanning;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF9333EA), Color(0xFFC084FC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        MediaQuery.of(context).padding.top + AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xl + 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            nfcAvailable ? l10n.scanHeroTitle : l10n.wifiTagManagerTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            nfcAvailable
                ? l10n.scanHeroSubtitle
                : l10n.wifiTagManagerSubtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (nfcAvailable)
            _NfcStatusBadge(
              scanning: scanning,
              idleLabel: l10n.scanReadyBadge,
              scanningLabel: l10n.scanningForTags,
            ),
        ],
      ),
    );
  }
}

class _NfcStatusBadge extends StatefulWidget {
  const _NfcStatusBadge({
    required this.scanning,
    required this.idleLabel,
    required this.scanningLabel,
  });

  final bool scanning;
  final String idleLabel;
  final String scanningLabel;

  @override
  State<_NfcStatusBadge> createState() => _NfcStatusBadgeState();
}

class _NfcStatusBadgeState extends State<_NfcStatusBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _syncAnimation();
  }

  @override
  void didUpdateWidget(_NfcStatusBadge old) {
    super.didUpdateWidget(old);
    if (old.scanning != widget.scanning) _syncAnimation();
  }

  void _syncAnimation() {
    if (widget.scanning) {
      _ctrl.repeat(reverse: true);
    } else {
      _ctrl.stop();
      _ctrl.value = 0;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label =
        widget.scanning ? widget.scanningLabel : widget.idleLabel;
    final pulse = widget.scanning ? _ctrl.value : 0.0;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15 + 0.10 * pulse),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.nfc,
                size: 16,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final String number;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      color: AppTheme.brandAmber.withValues(alpha: 0.08),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppTheme.brandAmber),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.brandAmberDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TappableInfoBanner extends StatelessWidget {
  const _TappableInfoBanner({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onTap,
  });

  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: AppTheme.brandAmberSurface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 4,
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.brandAmberDark),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.brandAmberDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                actionLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppTheme.brandPurple,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
