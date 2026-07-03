import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';

class NfcPromptWidget extends StatefulWidget {
  const NfcPromptWidget({
    super.key,
    required this.prompt,
    this.diameter = 210,
  });

  final String prompt;

  /// Overall diameter of the pulsing-ring area. Use a smaller value when the
  /// prompt is shown inline (e.g. the Home scan state) vs full-screen flows.
  final double diameter;

  @override
  State<NfcPromptWidget> createState() => _NfcPromptWidgetState();
}

class _NfcPromptWidgetState extends State<NfcPromptWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _ring(double delay) {
    final core = widget.diameter * 0.42;
    final t = (_controller.value - delay + 1.0) % 1.0;
    final size = core + ((widget.diameter - core) * t);
    final opacity = (1.0 - t) * 0.45;
    return Opacity(
      opacity: opacity,
      child: SizedBox(
        width: size,
        height: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.brandPurple,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final core = widget.diameter * 0.42;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.diameter,
          height: widget.diameter,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  _ring(0.0),
                  _ring(0.33),
                  _ring(0.66),
                  child!,
                ],
              );
            },
            child: Container(
              width: core,
              height: core,
              decoration: BoxDecoration(
                color: AppTheme.brandPurple.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.nfc,
                size: core * 0.55,
                color: AppTheme.brandPurple,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Padding(
          padding: AppSpacing.screenPadding,
          child: Text(
            widget.prompt,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppTheme.brandOnSurface,
            ),
          ),
        ),
      ],
    );
  }
}
