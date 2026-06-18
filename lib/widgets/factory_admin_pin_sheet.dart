import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../services/factory_admin_auth.dart';
import '../services/factory_admin_session.dart';
import '../theme/app_spacing.dart';
import 'nova_sheet.dart';

class FactoryAdminPinSheet {
  FactoryAdminPinSheet._();

  static Future<bool> show(BuildContext context) async {
    final ok = await NovaSheet.show<bool>(
      context,
      isDismissible: false,
      enableDrag: false,
      child: const _FactoryAdminPinSheetContent(),
    );
    return ok ?? false;
  }
}

class _FactoryAdminPinSheetContent extends StatefulWidget {
  const _FactoryAdminPinSheetContent();

  @override
  State<_FactoryAdminPinSheetContent> createState() =>
      _FactoryAdminPinSheetContentState();
}

class _FactoryAdminPinSheetContentState
    extends State<_FactoryAdminPinSheetContent> {
  final _controller = TextEditingController();
  Timer? _lockTimer;
  var _error = '';
  var _lockSeconds = 0;

  @override
  void dispose() {
    _lockTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startLockCountdown(int seconds) {
    _lockTimer?.cancel();
    setState(() => _lockSeconds = seconds);
    _lockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_lockSeconds <= 1) {
        timer.cancel();
        setState(() {
          _lockSeconds = 0;
          _error = '';
        });
      } else {
        setState(() => _lockSeconds--);
      }
    });
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final pin = _controller.text;
    if (pin.length != 6) {
      setState(() => _error = l10n.pinMustBeSixDigits);
      return;
    }

    final response = await FactoryAdminAuth.verifyPin(pin);
    if (!mounted) return;

    switch (response.result) {
      case FactoryPinVerifyResult.success:
        FactoryAdminSession.unlock();
        Navigator.pop(context, true);
      case FactoryPinVerifyResult.wrong:
        setState(() => _error = l10n.factoryAdminWrongPin);
      case FactoryPinVerifyResult.locked:
        _startLockCountdown(response.secondsRemaining);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return NovaSheetScaffold(
      title: l10n.factoryAdminPinTitle,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.factoryAdminPinHint,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          if (_lockSeconds > 0)
            Text(
              l10n.pinLocked(_lockSeconds),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            )
          else
            TextField(
              controller: _controller,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              autofocus: true,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: l10n.factoryAdminPin,
                counterText: '',
                errorText: _error.isEmpty ? null : _error,
              ),
              onSubmitted: (_) => _submit(),
            ),
        ],
      ),
      actions: [
        if (_lockSeconds == 0)
          FilledButton(
            onPressed: _submit,
            child: Text(l10n.confirm),
          ),
        if (_lockSeconds == 0) const SizedBox(height: AppSpacing.sm),
        OutlinedButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
      ],
    );
  }
}
