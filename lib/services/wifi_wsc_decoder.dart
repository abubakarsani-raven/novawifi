import 'dart:convert';
import 'dart:typed_data';

/// Parsed Wi-Fi credentials from a WSC (`application/vnd.wfa.wsc`) NDEF payload.
class WifiWscCredentials {
  const WifiWscCredentials({required this.ssid, required this.password});

  final String ssid;
  final String password;
}

/// Decodes Android Wi-Fi Simple Configuration NDEF payloads.
class WifiWscDecoder {
  WifiWscDecoder._();

  static const int _credential = 0x100e;
  static const int _ssid = 0x1045;
  static const int _networkKey = 0x1027;

  static WifiWscCredentials? decode(Uint8List payload) {
    if (payload.length < 4) return null;

    final tlvs = _readTlvs(payload, 0, payload.length);
    for (final tlv in tlvs) {
      if (tlv.type == _credential) {
        return _parseCredential(tlv.value);
      }
    }
    return null;
  }

  static WifiWscCredentials? _parseCredential(Uint8List data) {
    String? ssid;
    String? password;

    for (final tlv in _readTlvs(data, 0, data.length)) {
      if (tlv.type == _ssid) {
        ssid = utf8.decode(tlv.value);
      } else if (tlv.type == _networkKey) {
        password = utf8.decode(tlv.value);
      }
    }

    if (ssid == null || password == null) return null;
    return WifiWscCredentials(ssid: ssid, password: password);
  }

  static List<_Tlv> _readTlvs(Uint8List data, int start, int end) {
    final result = <_Tlv>[];
    var offset = start;
    while (offset + 4 <= end) {
      final type = (data[offset] << 8) | data[offset + 1];
      final length = (data[offset + 2] << 8) | data[offset + 3];
      offset += 4;
      if (offset + length > end) break;
      result.add(
        _Tlv(type, Uint8List.sublistView(data, offset, offset + length)),
      );
      offset += length;
    }
    return result;
  }
}

class _Tlv {
  const _Tlv(this.type, this.value);
  final int type;
  final Uint8List value;
}
