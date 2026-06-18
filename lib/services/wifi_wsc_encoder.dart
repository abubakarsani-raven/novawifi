import 'dart:convert';
import 'dart:typed_data';

/// Wi-Fi Simple Configuration payload for Android `application/vnd.wfa.wsc` NDEF.
class WifiWscEncoder {
  WifiWscEncoder._();

  static const String mimeType = 'application/vnd.wfa.wsc';

  // Wi-Fi Simple Configuration attribute IDs (WSC spec). These must be exact:
  // Android/Samsung's "tap to connect" handler validates the credential and
  // silently falls back to the generic tag viewer if Auth Type / MAC are wrong.
  static const int _credential   = 0x100e;
  static const int _networkIndex = 0x1026;
  static const int _ssid         = 0x1045;
  static const int _authType     = 0x1003; // was 0x1020 (that's MAC Address!)
  static const int _encType      = 0x100f;
  static const int _networkKey   = 0x1027;
  static const int _macAddress   = 0x1020;

  // Auth type flags
  static const int _authOpen   = 0x0001;
  static const int _authWpa    = 0x0002;
  static const int _authWpa2   = 0x0020;
  static const int _authWpa3   = 0x0020; // WPA3-SAE uses same flag + transition mode

  // Encryption type flags
  static const int _encNone = 0x0001;
  static const int _encWep  = 0x0002;
  static const int _encTkip = 0x0004;
  static const int _encAes  = 0x0008;

  /// Builds the WSC credential blob Android expects for the given security type.
  /// [securityType] should be one of: 'WPA2', 'WPA3', 'WPA', 'WEP', 'Open'.
  static Uint8List encode({
    required String ssid,
    required String password,
    String securityType = 'WPA2',
  }) {
    final (auth, enc) = _authEncFor(securityType);

    final innerBuilder = BytesBuilder()
      ..add(_tlv(_networkIndex, Uint8List.fromList([1])))
      ..add(_tlv(_ssid, utf8.encode(ssid)))
      ..add(_tlv(_authType, Uint8List.fromList([0x00, auth])))
      ..add(_tlv(_encType, Uint8List.fromList([0x00, enc])));

    if (securityType != 'Open') {
      innerBuilder.add(_tlv(_networkKey, utf8.encode(password)));
    }

    // MAC Address is a required WSC credential attribute. We don't bind the
    // token to a specific AP, so use the broadcast address (the conventional
    // wildcard for Wi-Fi config tokens).
    innerBuilder.add(
      _tlv(_macAddress, Uint8List.fromList([0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])),
    );

    return _tlv(_credential, innerBuilder.toBytes());
  }

  static (int auth, int enc) _authEncFor(String type) {
    return switch (type) {
      'WPA3' => (_authWpa3, _encAes),
      'WPA2' => (_authWpa2, _encAes),
      'WPA'  => (_authWpa,  _encTkip),
      'WEP'  => (_authOpen, _encWep),
      _      => (_authOpen, _encNone), // Open
    };
  }

  static Uint8List _tlv(int type, List<int> value) {
    final len = value.length;
    return Uint8List.fromList([
      (type >> 8) & 0xff,
      type & 0xff,
      (len >> 8) & 0xff,
      len & 0xff,
      ...value,
    ]);
  }
}
