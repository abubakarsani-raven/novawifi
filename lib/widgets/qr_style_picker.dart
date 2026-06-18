import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import 'qr_code_widget.dart';

/// Lets the user customize the QR code's dot shape and color.
///
/// The palette is intentionally limited to dark, high-contrast colors so the
/// generated code stays reliably scannable on its white background.
class QrStylePicker extends StatelessWidget {
  const QrStylePicker({
    super.key,
    required this.style,
    required this.onChanged,
  });

  final QrStyleOptions style;
  final ValueChanged<QrStyleOptions> onChanged;

  static const List<Color> palette = [
    Color(0xFF18181B), // near-black
    Color(0xFF6A0DAD), // brand purple
    Color(0xFF1D4ED8), // blue
    Color(0xFF15803D), // green
    Color(0xFFB3261E), // red
    Color(0xFF0F766E), // teal
    Color(0xFF9A3412), // burnt orange
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dot color', style: theme.textTheme.labelMedium),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final color in palette)
              _ColorSwatch(
                color: color,
                selected: color == style.dotColor,
                onTap: () => onChanged(style.copyWith(dotColor: color)),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text('Dot shape', style: theme.textTheme.labelMedium),
        const SizedBox(height: AppSpacing.xs),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment<bool>(
              value: false,
              label: Text('Square'),
              icon: Icon(Icons.crop_square, size: 18),
            ),
            ButtonSegment<bool>(
              value: true,
              label: Text('Rounded'),
              icon: Icon(Icons.circle, size: 18),
            ),
          ],
          selected: {style.rounded},
          showSelectedIcon: false,
          onSelectionChanged: (selection) =>
              onChanged(style.copyWith(rounded: selection.first)),
        ),
      ],
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      selected: selected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? theme.colorScheme.primary : Colors.transparent,
              width: 3,
            ),
          ),
          child: selected
              ? const Icon(Icons.check, color: Colors.white, size: 18)
              : null,
        ),
      ),
    );
  }
}
