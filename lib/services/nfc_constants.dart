class NfcConstants {
  NfcConstants._();

  /// Current NDEF tag metadata format (credentials live in WSC on Android).
  static const int tagFormatVersion = 2;

  static const String aarPackage = 'com.novaheronix.wifimanager';
  static const String customTypeNamespace = 'novaheronix.com:wifi';
  /// Short MIME type used when writing new tags (saves ~17 bytes vs legacy).
  static const String novaDataMimeType = 'application/x.nova';
  /// Legacy MIME type kept for reading tags written before the size optimisation.
  static const String novaDataMimeTypeLegacy = 'application/vnd.novaheronix.wifi';
  static const String aarType = 'android.com:pkg';
  static const String textLanguageCode = 'en';
  /// Legacy marker written before JSON was stored in the external-type payload.
  static const String customTypePayload = 'v1';

  /// Written at factory init before SSID/password are set by the end user.
  static const String provisionedLabel = '';

  /// Base URL for the iOS App Clip. Credentials are appended as a base64 JSON fragment.
  /// Replace XXXXXXXXXX in .well-known/apple-app-site-association with your Team ID.
  static const String appClipBaseUrl = 'https://appclip.novaheronix.com/wifi';

  static final RegExp uuidV4Pattern = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-4[0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
  );
}
