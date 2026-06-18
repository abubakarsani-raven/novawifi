import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../services/nfc_constants.dart';

part 'wifi_network.g.dart';

@HiveType(typeId: 0)
class WifiNetwork extends HiveObject {
  WifiNetwork({
    required this.id,
    required this.ssid,
    required this.password,
    required this.label,
    this.writtenToTag = false,
    this.updatedAt,
    this.tagLocked = false,
    this.tagProvisioned = false,
    this.isConfigured = false,
    this.securityType = 'WPA2',
    this.isHidden = false,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String ssid;

  @HiveField(2)
  String password;

  @HiveField(3)
  String label;

  @HiveField(4)
  bool writtenToTag;

  @HiveField(5)
  DateTime? updatedAt;

  @HiveField(6)
  bool tagLocked;

  /// Factory-initialized by Nova Heronix admin (shipped blank for end-user setup).
  @HiveField(7)
  bool tagProvisioned;

  /// End user has written SSID and password to the tag.
  @HiveField(8)
  bool isConfigured;

  /// WiFi security type: WPA2, WPA3, WPA, WEP, or Open.
  @HiveField(9)
  String securityType;

  /// Whether the WiFi network broadcasts its SSID.
  @HiveField(10)
  bool isHidden;

  /// Tag is Nova Heronix format but waiting for WiFi credentials.
  bool get needsSetup => tagProvisioned && !isConfigured;

  Map<String, dynamic> toJson() => {
        'id': id,
        'ssid': ssid,
        'password': password,
        'label': label,
      };

  /// Metadata written to NFC (v2). SSID/password are in the WSC record on Android.
  /// Uses single-letter keys to minimise NDEF size on small tags (e.g. NTAG213).
  Map<String, dynamic> toTagJson() => {
        'v': NfcConstants.tagFormatVersion,
        'i': id,
        'l': label,
        'p': tagProvisioned,
        'c': isConfigured,
      };

  /// iOS tag JSON (v2 with embedded credentials — iOS has no WSC record).
  /// Uses single-letter keys to minimise NDEF size on small tags.
  Map<String, dynamic> toIosTagJson() => {
        'v': NfcConstants.tagFormatVersion,
        'i': id,
        'l': label,
        'p': tagProvisioned,
        'c': isConfigured,
        's': ssid,
        'pw': password,
        'st': securityType,
        'h': isHidden,
      };

  /// True if tag JSON still embeds credentials (pre-v2 tags).
  static bool isLegacyTagJson(Map<String, dynamic> json) {
    final version = json['v'] as int?;
    if (version != null && version >= NfcConstants.tagFormatVersion) {
      return false;
    }
    return json.containsKey('password') || json.containsKey('ssid');
  }

  factory WifiNetwork.fromJson(Map<String, dynamic> json) {
    return WifiNetwork.fromTagJson(
      json,
      ssid: json['ssid'] as String?,
      password: json['password'] as String?,
    );
  }

  factory WifiNetwork.fromTagJson(
    Map<String, dynamic> json, {
    String? ssid,
    String? password,
  }) {
    // Support both compact single-letter keys (v2+) and legacy verbose keys.
    final resolvedSsid = ssid
        ?? json['s'] as String?
        ?? json['ssid'] as String?
        ?? '';
    final resolvedPassword = password
        ?? json['pw'] as String?
        ?? json['password'] as String?
        ?? '';
    final securityType =
        json['st'] as String? ?? json['securityType'] as String? ?? 'WPA2';
    final configured = json['c'] as bool?
        ?? json['isConfigured'] as bool?
        ?? isConfiguredFromTagData(
             resolvedSsid,
             resolvedPassword,
             securityType: securityType,
           );
    return WifiNetwork(
      id: (json['i'] as String?)
          ?? (json['id'] as String?)
          ?? const Uuid().v4(),
      ssid: resolvedSsid,
      password: resolvedPassword,
      label: (json['l'] as String?) ?? (json['label'] as String?) ?? '',
      tagProvisioned: json['p'] as bool?
          ?? json['tagProvisioned'] as bool?
          ?? true,
      isConfigured: configured,
      writtenToTag: true,
      securityType: securityType,
      isHidden: json['h'] as bool? ?? json['isHidden'] as bool? ?? false,
    );
  }

  WifiNetwork copyWith({
    String? id,
    String? ssid,
    String? password,
    String? label,
    bool? writtenToTag,
    DateTime? updatedAt,
    bool? tagLocked,
    bool? tagProvisioned,
    bool? isConfigured,
    String? securityType,
    bool? isHidden,
  }) {
    return WifiNetwork(
      id: id ?? this.id,
      ssid: ssid ?? this.ssid,
      password: password ?? this.password,
      label: label ?? this.label,
      writtenToTag: writtenToTag ?? this.writtenToTag,
      updatedAt: updatedAt ?? this.updatedAt,
      tagLocked: tagLocked ?? this.tagLocked,
      tagProvisioned: tagProvisioned ?? this.tagProvisioned,
      isConfigured: isConfigured ?? this.isConfigured,
      securityType: securityType ?? this.securityType,
      isHidden: isHidden ?? this.isHidden,
    );
  }

  static WifiNetwork createProvisioned({required String id}) {
    return WifiNetwork(
      id: id,
      ssid: '',
      password: '',
      label: '',
      writtenToTag: true,
      tagProvisioned: true,
      isConfigured: false,
      updatedAt: DateTime.now(),
    );
  }

  static bool isConfiguredFromTagData(
    String ssid,
    String password, {
    String securityType = 'WPA2',
  }) {
    if (ssid.trim().isEmpty) return false;
    if (securityType == 'Open') return true;
    return password.length >= 8;
  }

  @override
  String toString() => 'WifiNetwork(id: $id, ssid: $ssid, label: $label)';
}
