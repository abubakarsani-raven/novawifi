import '../config/factory_admin_config.dart';

/// In-memory factory service unlock (separate from end-user setup PIN).
class FactoryAdminSession {
  FactoryAdminSession._();

  static DateTime? _expiresAt;

  static bool get isActive =>
      _expiresAt != null && DateTime.now().isBefore(_expiresAt!);

  static void unlock() {
    _expiresAt = DateTime.now().add(FactoryAdminConfig.sessionDuration);
  }

  static void lock() {
    _expiresAt = null;
  }
}
