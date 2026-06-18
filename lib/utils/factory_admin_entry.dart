import 'package:flutter/material.dart';

import '../screens/factory_admin_screen.dart';
import '../services/factory_admin_session.dart';
import '../widgets/factory_admin_pin_sheet.dart';

/// Hidden factory admin entry (version taps in Settings, long-press NH logo).
class FactoryAdminEntry {
  FactoryAdminEntry._();

  /// Active factory session or service PIN dialog.
  static Future<bool> requireAuth(BuildContext context) async {
    if (FactoryAdminSession.isActive) return true;
    final ok = await FactoryAdminPinSheet.show(context);
    return ok;
  }

  /// Opens the factory hub, gated behind the factory service PIN.
  static Future<void> open(
    BuildContext context, {
    @Deprecated('User PIN removed; factory entry only uses the service PIN.')
    bool requireUserPinFirst = false,
  }) async {
    final ok = await requireAuth(context);
    if (!ok || !context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const FactoryAdminScreen()),
    );
  }
}
