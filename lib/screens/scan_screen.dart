import 'dart:io';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/nfc_service.dart';
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
  });

  final bool active;
  final void Function(String networkId) onNavigateToNetwork;
  final void Function(String networkId) onNavigateToSetup;

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool _nfcAvailable = true;

  /// True only while a one-shot scan the user explicitly started is running.
  /// Home no longer holds an always-on session — when idle, NFC is owned by the
  /// Activity's suppress-only reader mode, so the system popup never appears and
  /// nothing competes with the Setup/Wipe screens.
  bool _scanning = false;

  @override
  void initState() {
    super.initState();
    _checkNfc();
  }

  @override
  void dispose() {
    if (_scanning) NfcService.stopSession();
    super.dispose();
  }

  Future<void> _checkNfc() async {
    final available = await NfcService.isAvailable();
    if (mounted) setState(() => _nfcAvailable = available);
  }

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _HeroSection(nfcAvailable: _nfcAvailable, l10n: l10n),
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
                      children: [
                        SizedBox(
                          height: 160,
                          child: NfcPromptWidget(prompt: l10n.holdPhoneToTag),
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

// ─────────────────────────── Hero section ──────────────────────────────────

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.nfcAvailable, required this.l10n});
  final bool nfcAvailable;
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
        // Keep the gradient edge-to-edge but push content below the status bar.
        MediaQuery.of(context).padding.top + AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xl + 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            nfcAvailable ? l10n.scanHeroTitle : 'WiFi Tag Manager',
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
                : 'Manage your saved WiFi networks and export QR codes.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (nfcAvailable) const _PulsingNfcBadge(),
        ],
      ),
    );
  }
}

class _PulsingNfcBadge extends StatefulWidget {
  const _PulsingNfcBadge();

  @override
  State<_PulsingNfcBadge> createState() => _PulsingNfcBadgeState();
}

class _PulsingNfcBadgeState extends State<_PulsingNfcBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15 + 0.10 * _ctrl.value),
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
                'Scanning for tags…',
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

// ─────────────────────────── Step tile ─────────────────────────────────────

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
        color: AppTheme.brandWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.brandOutline),
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

// ─────────────────────────── Info banner ───────────────────────────────────

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
                color: const Color(0xFF92400E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
