/// Factory service PIN (SHA-256 of 6-digit code). Change hash before production.
/// Generate: echo -n 'YOUR_PIN' | shasum -a 256
class FactoryAdminConfig {
  FactoryAdminConfig._();

  /// SHA-256 hex of factory service PIN (default deployment code documented internally).
  static const String factoryAdminPinSha256 =
      '273041ca5beba97b0d34813ead127b824af4d368e90d9b3f0c4c35dfdf6370b4';

  static const int secretTapCount = 7;

  static const Duration sessionDuration = Duration(minutes: 5);

  static const Duration logoLongPressDuration = Duration(milliseconds: 1200);

  static const int maxPinAttempts = 5;

  static const int lockoutSeconds = 60;
}
