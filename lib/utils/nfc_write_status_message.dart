import '../l10n/app_localizations.dart';
import '../services/nfc_service.dart';

/// Maps [NfcWriteStatus] to localized operator-facing messages.
class NfcWriteStatusMessage {
  NfcWriteStatusMessage._();

  static String forStatus(NfcWriteStatus status, AppLocalizations l10n) {
    return switch (status) {
      NfcWriteStatus.notAvailable => l10n.errorNfcNotAvailable,
      NfcWriteStatus.writeNotSupported => l10n.nfcWriteNotSupported,
      NfcWriteStatus.tagTooSmall => l10n.nfcTagTooSmall,
      NfcWriteStatus.tagReadOnly => l10n.tagReadOnly,
      NfcWriteStatus.tagLockedInApp => l10n.tagLocked,
      NfcWriteStatus.writeFailed => l10n.errorWriteFailed,
      NfcWriteStatus.notNovaTag => l10n.errorUnrecognisedTag,
      NfcWriteStatus.tagNotBlank => l10n.initializeTagNotBlank,
      NfcWriteStatus.success => l10n.errorWriteFailed,
    };
  }
}
