import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import 'animated_checkmark.dart';
import 'nfc_prompt_widget.dart';

enum NfcWritePhase { scanning, success, failure }

/// Full-screen animation widget for NFC write flows.
/// Scanning → pulsing rings.  Success → animated checkmark.  Failure → shake + X.
class NfcWriteAnimator extends StatefulWidget {
  final NfcWritePhase phase;
  final String scanLabel;
  final String successLabel;
  final String failureLabel;

  const NfcWriteAnimator({
    super.key,
    required this.phase,
    required this.scanLabel,
    required this.successLabel,
    required this.failureLabel,
  });

  @override
  State<NfcWriteAnimator> createState() => _NfcWriteAnimatorState();
}

class _NfcWriteAnimatorState extends State<NfcWriteAnimator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    if (widget.phase == NfcWritePhase.failure) {
      _shakeController.forward();
    }
  }

  @override
  void didUpdateWidget(NfcWriteAnimator old) {
    super.didUpdateWidget(old);
    if (old.phase != widget.phase && widget.phase == NfcWritePhase.failure) {
      _shakeController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  Widget _scanningState() {
    return NfcPromptWidget(
      key: const ValueKey('scanning'),
      prompt: widget.scanLabel,
    );
  }

  Widget _successState(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      key: const ValueKey('success'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const AnimatedCheckmark(
          color: AppTheme.brandGreen,
          size: 110,
        ),
        const SizedBox(height: AppSpacing.lg),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            widget.successLabel,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppTheme.brandGreenDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _failureState(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (_, child) {
        final dx = math.sin(_shakeController.value * math.pi * 6) * 12.0;
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: Column(
        key: const ValueKey('failure'),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.error.withValues(alpha: 0.10),
            ),
            child: Icon(
              Icons.close_rounded,
              size: 56,
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              widget.failureLabel,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final semanticsLabel = switch (widget.phase) {
      NfcWritePhase.scanning => l10n.nfcPhaseScanning,
      NfcWritePhase.success => l10n.nfcPhaseSuccess,
      NfcWritePhase.failure => l10n.nfcPhaseFailure,
    };

    return Semantics(
      liveRegion: true,
      label: semanticsLabel,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 320),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.88, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOut),
            ),
            child: child,
          ),
        ),
        child: switch (widget.phase) {
          NfcWritePhase.scanning => _scanningState(),
          NfcWritePhase.success => _successState(context),
          NfcWritePhase.failure => _failureState(context),
        },
      ),
    );
  }
}
