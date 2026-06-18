import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import 'strength_indicator.dart';

class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    this.label,
    this.showStrength = false,
    this.validator,
  });

  final TextEditingController controller;
  final String? label;
  final bool showStrength;
  final String? Function(String?)? validator;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: widget.controller,
          obscureText: _obscured,
          keyboardType: TextInputType.visiblePassword,
          inputFormatters: [LengthLimitingTextInputFormatter(128)],
          decoration: InputDecoration(
            labelText: widget.label ?? l10n.password,
            suffixIcon: IconButton(
              icon: Icon(
                _obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              ),
              onPressed: () => setState(() => _obscured = !_obscured),
              tooltip: _obscured ? l10n.showPassword : l10n.hidePassword,
            ),
          ),
          validator: widget.validator,
          onChanged: (_) => setState(() {}),
        ),
        if (widget.showStrength) ...[
          const SizedBox(height: 8),
          StrengthIndicator(password: widget.controller.text),
        ],
      ],
    );
  }
}
