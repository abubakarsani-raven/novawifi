import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/ndef_record.dart';
import 'package:nfc_manager/nfc_manager_android.dart';
import 'package:nfc_manager_ndef/nfc_manager_ndef.dart';

import '../models/wifi_network.dart';
import 'nfc_constants.dart';
import 'wifi_wsc_decoder.dart';
import 'wifi_wsc_encoder.dart';

enum NfcReadStatus {
  success,
  notAvailable,
  unrecognisedTag,
  notWrittenByApp,
  parseError,
  tagNotFound,
}

class NfcReadResult {
  const NfcReadResult(
    this.status, {
    this.network,
    this.isLegacyFormat = false,
  });

  final NfcReadStatus status;
  final WifiNetwork? network;
  /// Tag still stores credentials in Nova JSON / Text (pre-v2).
  final bool isLegacyFormat;
}

enum NfcWriteStatus {
  success,
  notAvailable,
  writeFailed,
  writeNotSupported,
  tagReadOnly,
  tagLockedInApp,
  tagTooSmall,
  /// Tag already holds non-Nova data — refused so we don't overwrite a
  /// foreign tag (e.g. someone's transit card).
  notNovaTag,
  /// Initialize-only: tag already has data (Nova or foreign). Initialize brands
  /// blank tags exclusively; use Clear first to reuse an already-written tag.
  tagNotBlank,
}

class NfcWriteResult {
  const NfcWriteResult(this.status);

  final NfcWriteStatus status;
}

enum NfcLockStatus {
  success,
  notAvailable,
  failed,
}

enum NfcWipeStatus {
  success,
  notAvailable,
  writeFailed,
  tagReadOnly,
  notNovaTag,
}

class NfcWipeResult {
  const NfcWipeResult(this.status, {this.removedTagId});

  final NfcWipeStatus status;
  final String? removedTagId;
}

class NfcService {
  NfcService._();

  static const _platformChannel =
      MethodChannel('com.novaheronix.wifimanager/nfc');

  /// True while the Scan tab should accept background NFC intent routing.
  static bool scanTabActive = false;

  /// True while a read/write/lock/wipe session owns the NFC stack.
  static bool sessionBusy = false;

  /// Usable NDEF bytes on NTAG215 (504 total, ~12 bytes CC/overhead).
  static const int ntag215UsableBytes = 492;

  static Future<bool> isAvailable() async {
    try {
      final availability = await NfcManager.instance.checkAvailability();
      debugPrint('Nova NFC: checkAvailability = $availability');
      return availability == NfcAvailability.enabled;
    } catch (e, st) {
      debugPrint('Nova NFC: checkAvailability failed — $e\n$st');
      return false;
    }
  }

  /// Polls common tag technologies (NTAG21x is ISO 14443 Type A).
  ///
  /// iOS deliberately omits ISO 18092 (FeliCa): Core NFC refuses to start an
  /// NFCTagReaderSession that polls FeliCa unless the app declares
  /// `com.apple.developer.nfc.readersession.felica.systemcodes` in Info.plist,
  /// failing with `readerErrorSecurityViolation: Missing required entitlement`.
  /// Nova tags are ISO 14443, so FeliCa is unnecessary on iOS.
  static Set<NfcPollingOption> get _pollingOptions => Platform.isIOS
      ? const {
          NfcPollingOption.iso14443,
          NfcPollingOption.iso15693,
        }
      : const {
          NfcPollingOption.iso14443,
          NfcPollingOption.iso15693,
          NfcPollingOption.iso18092,
        };

  /// Stops reader mode. When [releaseExclusive] is false, Android keeps
  /// blocking system NFC handlers until the next session starts.
  static Future<void> stopSession({bool releaseExclusive = true}) async {
    try {
      await NfcManager.instance.stopSession();
    } catch (e) {
      debugPrint('Nova NFC: stopSession failed — $e');
    }
    sessionBusy = false;
    if (releaseExclusive) {
      await _setAndroidExclusive(false);
    }
  }

  /// Tears down any active reader session before a write/lock/wipe.
  ///
  /// Critically, this must never leave the NFC field without an owner: if we
  /// drop the Activity's suppression reader mode before the plugin arms its
  /// own, Android's system "new tag" screen grabs whatever tap lands in the
  /// gap. So we only stop a genuinely active plugin session here, and let the
  /// plugin's reader mode atomically replace the Activity's suppression one
  /// (Android allows a single reader mode per Activity — enabling a new one
  /// replaces the old without an unguarded moment).
  static Future<void> prepareWriteSession() async {
    scanTabActive = false;
    if (sessionBusy) {
      await stopSession(releaseExclusive: false);
    }
    sessionBusy = true;
    await _setAndroidExclusive(true);
    // Short settle so the exclusive flag propagates before the plugin arms its
    // reader mode. The Activity's suppression reader mode still owns the field
    // during this window, so the system tag screen can't appear.
    await Future.delayed(const Duration(milliseconds: 150));
  }

  static Future<void> _setAndroidExclusive(bool active) async {
    if (!Platform.isAndroid) return;
    try {
      await _platformChannel.invokeMethod<void>(
        'setAppNfcExclusive',
        {'active': active},
      );
      debugPrint('Nova NFC: setAppNfcExclusive($active)');
    } catch (e) {
      debugPrint('Nova NFC: setAppNfcExclusive($active) failed — $e');
    }
  }

  static Future<void> startReadSession({
    required void Function(NfcReadResult result) onRead,
    void Function(Object error)? onError,
    bool releaseExclusiveAfterRead = false,
  }) async {
    if (!await isAvailable()) {
      onRead(const NfcReadResult(NfcReadStatus.notAvailable));
      return;
    }

    sessionBusy = true;
    await _setAndroidExclusive(true);
    try {
      await NfcManager.instance.startSession(
        pollingOptions: _pollingOptions,
        alertMessageIos: 'Hold your iPhone near the Nova tag',
        onSessionErrorIos: (e) {
          debugPrint(
              'Nova NFC: iOS session invalidated — code=${e.code} message=${e.message}');
          // An OS-side invalidation (user cancel, timeout, first-read) leaves
          // the plugin's session reference set, so the next scan would throw
          // "session_already_exists" and surface as "NFC not available". Reset
          // our state and the plugin's session (deferred to avoid re-entrancy).
          scheduleMicrotask(
              () => stopSession(releaseExclusive: releaseExclusiveAfterRead));
          onError?.call(e);
        },
        onDiscovered: (NfcTag tag) async {
          debugPrint('Nova NFC: iOS tag detected');
          NfcReadResult result;
          try {
            result = await _readTag(tag);
          } catch (e, st) {
            debugPrint('Nova NFC: read session onDiscovered failed — $e\n$st');
            onError?.call(e);
            result = const NfcReadResult(NfcReadStatus.parseError);
          }
          // Close the session first, then deliver the result on a fresh
          // microtask. Running the onRead handler (which navigates) inline
          // deadlocks the iOS main thread, because the plugin delivers this
          // callback from a DispatchQueue.main.sync context.
          await stopSession(releaseExclusive: releaseExclusiveAfterRead);
          scheduleMicrotask(() => onRead(result));
        },
      );
      debugPrint('Nova NFC: read session started');
    } catch (e, st) {
      debugPrint('Nova NFC: startSession (read) failed — $e\n$st');
      onError?.call(e);
      onRead(const NfcReadResult(NfcReadStatus.notAvailable));
      await stopSession();
    }
  }

  static Future<NfcReadResult> _readTag(NfcTag tag) async {
    final ndef = Ndef.from(tag);
    if (ndef == null) {
      return const NfcReadResult(NfcReadStatus.unrecognisedTag);
    }

    NdefMessage? message;
    if (Platform.isIOS) {
      // iOS: the plugin already reads the tag's NDEF during discovery
      // (cachedMessage). Issuing a second ndef.read() collides with the
      // plugin's main-thread dispatch and deadlocks the UI, so reuse the cache
      // and only fall back to a live read if it's somehow empty.
      message = ndef.cachedMessage;
    }
    try {
      message ??= await ndef.read();
    } catch (_) {
      return const NfcReadResult(NfcReadStatus.tagNotFound);
    }

    if (message == null) {
      return const NfcReadResult(NfcReadStatus.unrecognisedTag);
    }
    return _parseMessage(message);
  }

  /// True if message is empty (blank tag) or valid Nova Heronix NDEF.
  static bool isNovaOrEmptyNdef(NdefMessage message) {
    if (message.records.isEmpty) return true;
    return _parseMessage(message).status == NfcReadStatus.success;
  }

  /// Resolves tag UUID from v2 compact (`i`) or legacy (`id`) JSON key.
  static String? _resolveTagId(Map<String, dynamic> json) {
    final id = (json['i'] as String?) ?? (json['id'] as String?);
    if (id == null || !NfcConstants.uuidV4Pattern.hasMatch(id)) {
      return null;
    }
    return id;
  }

  /// Parses Nova JSON from a platform NFC intent (Android cold start).
  static NfcReadResult parseNovaJson(String jsonPayload) {
    try {
      final json = jsonDecode(jsonPayload) as Map<String, dynamic>;
      if (_resolveTagId(json) == null) {
        return const NfcReadResult(NfcReadStatus.unrecognisedTag);
      }
      final isLegacy = WifiNetwork.isLegacyTagJson(json);
      return NfcReadResult(
        NfcReadStatus.success,
        network: WifiNetwork.fromJson(json),
        isLegacyFormat: isLegacy,
      );
    } catch (_) {
      return const NfcReadResult(NfcReadStatus.parseError);
    }
  }

  static NfcReadResult _parseMessage(NdefMessage message) {
    final records = message.records;
    if (records.isEmpty) {
      return const NfcReadResult(NfcReadStatus.unrecognisedTag);
    }

    if (Platform.isAndroid) {
      if (!_hasValidAar(records) && !_hasNovaMarker(records)) {
        return const NfcReadResult(NfcReadStatus.unrecognisedTag);
      }
    } else if (Platform.isIOS) {
      if (!_hasNovaMarker(records)) {
        return const NfcReadResult(NfcReadStatus.notWrittenByApp);
      }
    }

    final jsonPayload = _extractNovaJsonPayload(records);
    if (jsonPayload == null) {
      return const NfcReadResult(NfcReadStatus.parseError);
    }

    try {
      final json = jsonDecode(jsonPayload) as Map<String, dynamic>;
      if (_resolveTagId(json) == null) {
        return const NfcReadResult(NfcReadStatus.unrecognisedTag);
      }

      final wsc = _extractWscCredentials(records);
      final isLegacy = WifiNetwork.isLegacyTagJson(json) ||
          _extractLegacyTextPayload(records) != null;

      final network = WifiNetwork.fromTagJson(
        json,
        ssid: wsc?.ssid,
        password: wsc?.password,
      );

      return NfcReadResult(
        NfcReadStatus.success,
        network: network,
        isLegacyFormat: isLegacy,
      );
    } catch (_) {
      return const NfcReadResult(NfcReadStatus.parseError);
    }
  }

  static bool _hasNovaMarker(List<NdefRecord> records) {
    return _extractNovaJsonPayload(records) != null || _hasCustomType(records);
  }

  static bool _hasValidAar(List<NdefRecord> records) {
    for (final record in records) {
      if (record.typeNameFormat == TypeNameFormat.external) {
        final type = String.fromCharCodes(record.type);
        if (type == NfcConstants.aarType) {
          final pkg = utf8.decode(record.payload);
          if (pkg == NfcConstants.aarPackage) {
            return true;
          }
        }
      }
    }
    return false;
  }

  static bool _hasCustomType(List<NdefRecord> records) {
    final namespaceBytes = utf8.encode(NfcConstants.customTypeNamespace);
    for (final record in records) {
      if (record.typeNameFormat == TypeNameFormat.external) {
        if (listEquals(record.type, namespaceBytes)) {
          return true;
        }
      }
      if (record.typeNameFormat == TypeNameFormat.media) {
        final mime = String.fromCharCodes(record.type);
        if (mime == NfcConstants.customTypeNamespace ||
            mime == NfcConstants.novaDataMimeType ||
            mime == NfcConstants.novaDataMimeTypeLegacy) {
          return true;
        }
      }
    }
    return false;
  }

  static WifiWscCredentials? _extractWscCredentials(List<NdefRecord> records) {
    final wscMime = utf8.encode(WifiWscEncoder.mimeType);
    for (final record in records) {
      if (record.typeNameFormat == TypeNameFormat.media &&
          listEquals(record.type, wscMime)) {
        return WifiWscDecoder.decode(record.payload);
      }
    }
    return null;
  }

  static String? _extractNovaJsonPayload(List<NdefRecord> records) {
    final namespaceBytes = utf8.encode(NfcConstants.customTypeNamespace);
    final novaMime = utf8.encode(NfcConstants.novaDataMimeType);
    final novaMimeLegacy = utf8.encode(NfcConstants.novaDataMimeTypeLegacy);

    for (final record in records) {
      if (record.typeNameFormat == TypeNameFormat.external &&
          listEquals(record.type, namespaceBytes)) {
        final payload = utf8.decode(record.payload);
        if (payload.isNotEmpty && payload != NfcConstants.customTypePayload) {
          return payload;
        }
      }
      if (record.typeNameFormat == TypeNameFormat.media &&
          (listEquals(record.type, novaMime) ||
              listEquals(record.type, novaMimeLegacy))) {
        return utf8.decode(record.payload);
      }
    }

    return _extractLegacyTextPayload(records);
  }

  static String? _extractLegacyTextPayload(List<NdefRecord> records) {
    for (final record in records) {
      if (record.typeNameFormat == TypeNameFormat.wellKnown) {
        final type = String.fromCharCodes(record.type);
        if (type == 'T') {
          final payload = record.payload;
          if (payload.isEmpty) return null;
          final status = payload[0];
          final languageCodeLength = status & 0x3F;
          if (payload.length <= 1 + languageCodeLength) return null;
          final text = utf8.decode(payload.sublist(1 + languageCodeLength));
          if (text.trim().startsWith('{')) return text;
        }
      }
    }
    return null;
  }

  static bool _shouldWriteWifiConnectRecord(WifiNetwork network) {
    return WifiNetwork.isConfiguredFromTagData(
      network.ssid,
      network.password,
      securityType: network.securityType,
    );
  }

  static NdefMessage buildMessageForNetwork(WifiNetwork network) {
    final tagJson = (Platform.isIOS && _shouldWriteWifiConnectRecord(network))
        ? network.toIosTagJson()
        : network.toTagJson();
    final novaRecord = _buildNovaDataRecord(jsonEncode(tagJson));

    if (_shouldWriteWifiConnectRecord(network)) {
      // Universal configured ("Cube") tag — one tag serves every guest:
      //  1. credential URL → an iPhone tap opens the App Clip (one-tap join) or
      //     the web landing page (copy password + QR) as a fallback;
      //  2. WSC record     → modern Android auto-joins over NFC;
      //  3. Nova metadata  → the operator app reads it back.
      // No AAR, so a guest tap never pushes the Play Store. App-less guests on
      // any device can also scan the printed QR.
      return NdefMessage(records: [
        _buildCredentialUriRecord(network),
        _buildWifiConnectRecord(
          network.ssid,
          network.password,
          network.securityType,
        ),
        novaRecord,
      ]);
    }

    // Provisioned-only tag (no credentials yet) — the owner taps to configure.
    // First record is a Universal Link so iOS auto-opens the app on tap; on
    // Android the AAR stays last so the app still launches via the app record.
    final provisionUri = _buildProvisionUriRecord(network);
    if (Platform.isAndroid) {
      return NdefMessage(
        records: [provisionUri, novaRecord, _buildAarRecord()],
      );
    }
    return NdefMessage(records: [provisionUri, novaRecord]);
  }

  /// Validates outgoing NDEF before write (v2 standard).
  static String? validateOutgoingMessage(
    NdefMessage message,
    WifiNetwork network,
  ) {
    final records = message.records;
    if (records.any((r) {
      if (r.typeNameFormat != TypeNameFormat.wellKnown) return false;
      return String.fromCharCodes(r.type) == 'T';
    })) {
      return 'Text NDEF records are not allowed';
    }

    final configured = _shouldWriteWifiConnectRecord(network);
    if (configured) {
      // Universal configured tag: [credential URI, WSC, Nova]. The URI is first
      // so an iPhone tap opens the App Clip / landing page; WSC lets Android
      // auto-join; Nova metadata is for operator read-back.
      if (records.length != 3) {
        return 'Configured tags require URL, WSC and Nova records';
      }
      if (!_recordIsUri(records[0])) {
        return 'First record must be the guest URL';
      }
      final wscMime = utf8.encode(WifiWscEncoder.mimeType);
      final novaMime = utf8.encode(NfcConstants.novaDataMimeType);
      if (!listEquals(records[1].type, wscMime)) {
        return 'Second record must be WSC';
      }
      if (!listEquals(records[2].type, novaMime)) {
        return 'Third record must be Nova metadata';
      }
      return null;
    }

    // Provisioned tag: the Universal Link is first (so iOS auto-opens). On
    // Android an AAR must also be present so a tap still launches the app.
    if (!_recordIsUri(records.first)) {
      return 'Provisioned tags must start with the launch URL';
    }
    if (Platform.isAndroid && !records.any(_recordIsAar)) {
      return 'Provisioned Android tags must include an AAR';
    }
    return null;
  }

  static bool _recordIsAar(NdefRecord record) {
    if (record.typeNameFormat != TypeNameFormat.external) {
      return false;
    }
    return String.fromCharCodes(record.type) == NfcConstants.aarType;
  }

  static NdefRecord _buildWifiConnectRecord(
    String ssid,
    String password,
    String securityType,
  ) {
    return NdefRecord(
      typeNameFormat: TypeNameFormat.media,
      type: utf8.encode(WifiWscEncoder.mimeType),
      identifier: Uint8List(0),
      payload: WifiWscEncoder.encode(
        ssid: ssid,
        password: password,
        securityType: securityType,
      ),
    );
  }

  static NdefRecord _buildNovaDataRecord(String json) {
    return NdefRecord(
      typeNameFormat: TypeNameFormat.media,
      type: utf8.encode(NfcConstants.novaDataMimeType),
      identifier: Uint8List(0),
      payload: utf8.encode(json),
    );
  }

  /// A single TNF_EMPTY record. Android's `NdefMessage` rejects a zero-record
  /// message, so erasing a tag means writing one empty record (the standard way
  /// the OS / NFC Tools "clear" a tag), not an empty record list.
  static NdefMessage _emptyNdefMessage() {
    return NdefMessage(records: [
      NdefRecord(
        typeNameFormat: TypeNameFormat.empty,
        type: Uint8List(0),
        identifier: Uint8List(0),
        payload: Uint8List(0),
      ),
    ]);
  }

  static NdefRecord _buildAarRecord() {
    return NdefRecord(
      typeNameFormat: TypeNameFormat.external,
      type: utf8.encode(NfcConstants.aarType),
      identifier: Uint8List(0),
      payload: utf8.encode(NfcConstants.aarPackage),
    );
  }

  /// Well-known URI record pointing at the Universal Link for a provisioned
  /// tag. iOS background tag reading opens the app from this; the `t` query
  /// carries the tag id so the app lands straight on its setup form.
  static NdefRecord _buildProvisionUriRecord(WifiNetwork network) {
    final fullUrl = '${NfcConstants.appClipBaseUrl}?t=${network.id}&new=1';
    // 0x04 is the well-known abbreviation for the "https://" prefix.
    final withoutScheme = fullUrl.replaceFirst('https://', '');
    return NdefRecord(
      typeNameFormat: TypeNameFormat.wellKnown,
      type: utf8.encode('U'),
      identifier: Uint8List(0),
      payload: Uint8List.fromList([0x04, ...utf8.encode(withoutScheme)]),
    );
  }

  /// Well-known URI record carrying guest credentials for a configured tag.
  /// The format matches the App Clip and web landing-page decoder
  /// (ios/NovaClip/WifiConnectView.swift): `…/wifi#d=<base64 JSON {s,p,l}>`.
  /// Credentials live in the URL *fragment*, which browsers never transmit to a
  /// server — they are decoded only on the guest's device (same secret already
  /// stored in the WSC record on the tag).
  static NdefRecord _buildCredentialUriRecord(WifiNetwork network) {
    final encoded = base64.encode(utf8.encode(jsonEncode({
      's': network.ssid,
      'p': network.password,
      'l': network.label,
      't': network.securityType,
    })));
    final fullUrl = '${NfcConstants.appClipBaseUrl}#d=$encoded';
    // 0x04 is the well-known abbreviation for the "https://" prefix.
    final withoutScheme = fullUrl.replaceFirst('https://', '');
    return NdefRecord(
      typeNameFormat: TypeNameFormat.wellKnown,
      type: utf8.encode('U'),
      identifier: Uint8List(0),
      payload: Uint8List.fromList([0x04, ...utf8.encode(withoutScheme)]),
    );
  }

  static bool _recordIsUri(NdefRecord record) {
    if (record.typeNameFormat != TypeNameFormat.wellKnown) return false;
    return String.fromCharCodes(record.type) == 'U';
  }

  /// Encoded NDEF size for [network] on the current platform.
  static int encodedSizeForNetwork(WifiNetwork network) {
    return _ndefEncodedSize(buildMessageForNetwork(network));
  }

  /// Approximates the encoded byte size of an NDEF message as stored on a tag
  /// (NDEF TLV wrapper + per-record header/type/payload bytes).
  static int _ndefEncodedSize(NdefMessage message) {
    int recordBytes = 0;
    for (final r in message.records) {
      final typeLen = r.type.length;
      final payloadLen = r.payload.length;
      final isShort = payloadLen < 256;
      recordBytes += 1 + 1 + (isShort ? 1 : 4) + typeLen + payloadLen;
    }
    // NDEF TLV: T(1) + L(1 if ≤254, else 3) + records + terminator(1)
    final lBytes = recordBytes <= 254 ? 1 : 3;
    return 1 + lBytes + recordBytes + 1;
  }

  static Future<NfcWriteResult> writeNetwork(
    WifiNetwork network, {
    required void Function() onTapPrompt,
    bool blankOnly = false,
  }) async {
    if (network.tagLocked) {
      return const NfcWriteResult(NfcWriteStatus.tagLockedInApp);
    }

    if (!await isAvailable()) {
      return const NfcWriteResult(NfcWriteStatus.notAvailable);
    }

    final completer = Completer<NfcWriteResult>();
    onTapPrompt();

    await prepareWriteSession();

    void complete(NfcWriteResult result) {
      if (!completer.isCompleted) completer.complete(result);
    }

    try {
      await NfcManager.instance.startSession(
        pollingOptions: _pollingOptions,
        // Suppress the system discovery beep so the user doesn't pull the tag
        // away before the write finishes (we play our own haptic on success).
        noPlatformSoundsAndroid: true,
        onDiscovered: (NfcTag tag) async {
          HapticFeedback.mediumImpact();
          try {
            // Build + validate first so the message is ready for either the
            // standard write path or the format-and-write fallback below.
            final message = buildMessageForNetwork(network);
            final validationError = validateOutgoingMessage(message, network);
            if (validationError != null) {
              debugPrint('Nova NFC: outgoing message invalid — $validationError');
              HapticFeedback.vibrate();
              complete(const NfcWriteResult(NfcWriteStatus.writeFailed));
              return;
            }

            final ndef = Ndef.from(tag);

            // Blank / unformatted tag: Ndef.from is null. Fall back to
            // NdefFormatableAndroid to format and write the first message in
            // one step (Android only; iOS factory tags arrive NDEF-formatted).
            if (ndef == null) {
              final formatable =
                  Platform.isAndroid ? NdefFormatableAndroid.from(tag) : null;
              if (formatable == null) {
                debugPrint(
                    'Nova NFC: tag is neither NDEF nor NDEF-formatable');
                HapticFeedback.vibrate();
                complete(
                  const NfcWriteResult(NfcWriteStatus.writeNotSupported),
                );
                return;
              }
              try {
                await formatable.format(message);
                await HapticFeedback.heavyImpact();
                await Future.delayed(const Duration(milliseconds: 80));
                await HapticFeedback.mediumImpact();
                complete(const NfcWriteResult(NfcWriteStatus.success));
              } catch (e, st) {
                debugPrint('Nova NFC: format() failed — $e\n$st');
                HapticFeedback.vibrate();
                complete(const NfcWriteResult(NfcWriteStatus.writeFailed));
              }
              return;
            }

            if (!ndef.isWritable) {
              HapticFeedback.vibrate();
              complete(const NfcWriteResult(NfcWriteStatus.tagReadOnly));
              return;
            }
            // Initialize brands blank tags only: refuse a tag that already has
            // data (Nova or foreign). Use a live read — the discovery cache
            // isn't reliably populated after the reader-mode handoff, so it can
            // misclassify a real tag. Setup writes freely to the Nova tag the
            // operator already scanned, so it skips this check.
            if (blankOnly) {
              NdefMessage? existing;
              try {
                existing = await ndef.read();
              } catch (e, st) {
                debugPrint('Nova NFC: pre-write read failed — $e\n$st');
                HapticFeedback.vibrate();
                complete(const NfcWriteResult(NfcWriteStatus.writeFailed));
                return;
              }
              // Blank = no records, or only empty (TNF_EMPTY) records. A tag
              // cleared via Clear holds a single empty record, so it must count
              // as blank and stay re-initializable.
              final isBlank = existing == null ||
                  existing.records.every(
                    (r) => r.typeNameFormat == TypeNameFormat.empty,
                  );
              if (!isBlank) {
                HapticFeedback.vibrate();
                complete(const NfcWriteResult(NfcWriteStatus.tagNotBlank));
                return;
              }
            }
            if (_ndefEncodedSize(message) > ndef.maxSize) {
              HapticFeedback.vibrate();
              complete(const NfcWriteResult(NfcWriteStatus.tagTooSmall));
              return;
            }
            await ndef.write(message: message);
            await HapticFeedback.heavyImpact();
            await Future.delayed(const Duration(milliseconds: 80));
            await HapticFeedback.mediumImpact();

            complete(const NfcWriteResult(NfcWriteStatus.success));
          } catch (e, st) {
            debugPrint('Nova NFC: write failed — $e\n$st');
            HapticFeedback.vibrate();
            complete(const NfcWriteResult(NfcWriteStatus.writeFailed));
          } finally {
            await stopSession();
          }
        },
      );
    } catch (e, st) {
      debugPrint('Nova NFC: startSession failed — $e\n$st');
      await stopSession();
      return const NfcWriteResult(NfcWriteStatus.notAvailable);
    }

    return completer.future.timeout(
      const Duration(seconds: 60),
      onTimeout: () async {
        if (!completer.isCompleted) {
          await stopSession();
        }
        return const NfcWriteResult(NfcWriteStatus.writeFailed);
      },
    );
  }

  static Future<NfcLockStatus> lockTag({
    required void Function() onTapPrompt,
  }) async {
    if (!await isAvailable()) {
      return NfcLockStatus.notAvailable;
    }

    final completer = Completer<NfcLockStatus>();
    onTapPrompt();

    await prepareWriteSession();
    try {
      await NfcManager.instance.startSession(
        pollingOptions: _pollingOptions,
        noPlatformSoundsAndroid: true,
        onDiscovered: (NfcTag tag) async {
          HapticFeedback.mediumImpact();
          try {
            final ndef = Ndef.from(tag);
            if (ndef == null) {
              HapticFeedback.vibrate();
              if (!completer.isCompleted) {
                completer.complete(NfcLockStatus.failed);
              }
              return;
            }
            await ndef.writeLock();
            HapticFeedback.heavyImpact();
            if (!completer.isCompleted) {
              completer.complete(NfcLockStatus.success);
            }
          } catch (_) {
            if (!completer.isCompleted) {
              completer.complete(NfcLockStatus.failed);
            }
          } finally {
            await stopSession();
          }
        },
      );
    } catch (_) {
      await stopSession();
      return NfcLockStatus.notAvailable;
    }

    return completer.future.timeout(
      const Duration(seconds: 60),
      onTimeout: () async {
        if (!completer.isCompleted) {
          await stopSession();
        }
        return NfcLockStatus.failed;
      },
    );
  }

  /// Clears NDEF contents (removes Nova / other NDEF data from writable tags).
  static Future<NfcWipeResult> wipeTag({
    required void Function() onTapPrompt,
  }) async {
    if (!await isAvailable()) {
      return const NfcWipeResult(NfcWipeStatus.notAvailable);
    }

    final completer = Completer<NfcWipeResult>();
    onTapPrompt();

    await prepareWriteSession();
    try {
      await NfcManager.instance.startSession(
        pollingOptions: _pollingOptions,
        noPlatformSoundsAndroid: true,
        onDiscovered: (NfcTag tag) async {
          HapticFeedback.mediumImpact();
          try {
            final ndef = Ndef.from(tag);
            if (ndef == null) {
              if (!completer.isCompleted) {
                completer.complete(
                  const NfcWipeResult(NfcWipeStatus.writeFailed),
                );
              }
              return;
            }
            if (!ndef.isWritable) {
              if (!completer.isCompleted) {
                completer.complete(
                  const NfcWipeResult(NfcWipeStatus.tagReadOnly),
                );
              }
              return;
            }

            // Clear any writable tag, Nova or not. Best-effort read just to
            // recover the Nova tag id (so we can remove it from local storage);
            // a read failure or a foreign tag must NOT block the wipe.
            String? tagId;
            try {
              final existing = await ndef.read();
              if (existing != null && isNovaOrEmptyNdef(existing)) {
                tagId = _parseMessage(existing).network?.id;
              }
            } catch (e) {
              debugPrint('Nova NFC: wipe pre-read failed (continuing) — $e');
            }

            await ndef.write(message: _emptyNdefMessage());
            if (!completer.isCompleted) {
              completer.complete(
                NfcWipeResult(NfcWipeStatus.success, removedTagId: tagId),
              );
            }
          } catch (_) {
            if (!completer.isCompleted) {
              completer.complete(
                const NfcWipeResult(NfcWipeStatus.writeFailed),
              );
            }
          } finally {
            await stopSession();
          }
        },
      );
    } catch (_) {
      await stopSession();
      return const NfcWipeResult(NfcWipeStatus.notAvailable);
    }

    return completer.future.timeout(
      const Duration(seconds: 60),
      onTimeout: () async {
        if (!completer.isCompleted) {
          await stopSession();
        }
        return const NfcWipeResult(NfcWipeStatus.writeFailed);
      },
    );
  }
}
