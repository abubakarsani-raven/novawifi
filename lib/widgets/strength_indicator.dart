import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

enum PasswordStrength { weak, medium, strong }

PasswordStrength evaluatePasswordStrength(String password) {
  if (password.length < 8) return PasswordStrength.weak;
  var score = 0;
  if (password.length >= 8) score++;
  if (password.length >= 12) score++;
  if (RegExp(r'[A-Z]').hasMatch(password)) score++;
  if (RegExp(r'[a-z]').hasMatch(password)) score++;
  if (RegExp(r'[0-9]').hasMatch(password)) score++;
  if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score++;
  if (score <= 2) return PasswordStrength.weak;
  if (score <= 4) return PasswordStrength.medium;
  return PasswordStrength.strong;
}

class StrengthIndicator extends StatelessWidget {
  const StrengthIndicator({super.key, required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final strength = evaluatePasswordStrength(password);
    final scheme = Theme.of(context).colorScheme;

    late Color color;
    late String label;
    late double value;

    switch (strength) {
      case PasswordStrength.weak:
        color = scheme.error;
        label = l10n.passwordStrengthWeak;
        value = 0.33;
      case PasswordStrength.medium:
        color = Colors.amber;
        label = l10n.passwordStrengthMedium;
        value = 0.66;
      case PasswordStrength.strong:
        color = Colors.green;
        label = l10n.passwordStrengthStrong;
        value = 1.0;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${l10n.strengthLabel}: $label',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 6,
            backgroundColor: scheme.surfaceContainerHighest,
            color: color,
          ),
        ),
      ],
    );
  }
}
