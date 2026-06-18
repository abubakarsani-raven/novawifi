// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Nova Heronix WiFi Manager';

  @override
  String get scanNfc => 'Scan NFC tag';

  @override
  String get scanQrCode => 'Scan QR code';

  @override
  String get networkName => 'Network name (SSID)';

  @override
  String get password => 'Password';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get copyPassword => 'Copy password';

  @override
  String get changePassword => 'Change password';

  @override
  String get newPassword => 'New password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get saveAndWrite => 'Save and write to tag';

  @override
  String get exportQr => 'Export QR';

  @override
  String get downloadQr => 'Download QR';

  @override
  String get shareQr => 'Share QR';

  @override
  String get addNetwork => 'Add network';

  @override
  String get deleteNetwork => 'Delete network';

  @override
  String get noNetworks => 'No networks saved yet';

  @override
  String get tapNfcPrompt => 'Hold your phone near the NFC tag';

  @override
  String get writeNfcPrompt => 'Hold your phone near the tag to write';

  @override
  String get successWritten => 'Credentials written to tag successfully';

  @override
  String get errorNfcNotAvailable => 'NFC is not available on this device';

  @override
  String get errorTagNotFound => 'No NFC tag detected';

  @override
  String get errorWriteFailed => 'Failed to write to NFC tag';

  @override
  String get errorPasswordMismatch => 'Passwords do not match';

  @override
  String get errorPasswordTooShort => 'Password must be at least 8 characters';

  @override
  String get adminPin => 'Admin PIN';

  @override
  String get enterPin => 'Enter your 6-digit PIN';

  @override
  String get wrongPin => 'Incorrect PIN';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select language';

  @override
  String get networks => 'Networks';

  @override
  String get qrCode => 'QR code';

  @override
  String get scanTab => 'Scan';

  @override
  String get networksTab => 'Networks';

  @override
  String get settingsTab => 'Settings';

  @override
  String get printQrReminder =>
      'Remember to replace the physical QR sticker after a password change.';

  @override
  String get cancel => 'Cancel';

  @override
  String get retry => 'Retry';

  @override
  String get undo => 'Undo';

  @override
  String get delete => 'Delete';

  @override
  String get confirmDelete => 'Delete this network?';

  @override
  String get networkDeleted => 'Network deleted';

  @override
  String get loading => 'Loading…';

  @override
  String get writeToNfc => 'Write to NFC tag';

  @override
  String get nfcWriteNotSupported =>
      'NFC write is not supported on this device';

  @override
  String get nfcTagTooSmall => 'Tag memory too small — use NTAG215 or larger';

  @override
  String get qrManualModeBanner =>
      'NFC unavailable — use QR export or manage networks manually';

  @override
  String pinLocked(int seconds) {
    return 'PIN locked. Try again in $seconds seconds';
  }

  @override
  String get resetPin => 'Reset PIN';

  @override
  String get currentPin => 'Current PIN';

  @override
  String get setPin => 'Set PIN';

  @override
  String get confirmPin => 'Confirm PIN';

  @override
  String get pinsDoNotMatch => 'PINs do not match';

  @override
  String get pinSetSuccess => 'PIN set successfully';

  @override
  String get pinChangedSuccess => 'PIN changed successfully';

  @override
  String get version => 'Version';

  @override
  String get aboutFooter => 'Nova Heronix — internal WiFi management';

  @override
  String get syncedToTag => 'Synced to tag';

  @override
  String get notYetWritten => 'Not yet written';

  @override
  String get passwordStrengthWeak => 'Weak';

  @override
  String get passwordStrengthMedium => 'Medium';

  @override
  String get passwordStrengthStrong => 'Strong';

  @override
  String get firstLaunchSetPin =>
      'Set a 6-digit admin PIN to protect sensitive actions';

  @override
  String get holdPhoneToTag => 'Hold your phone against the tag';

  @override
  String get writing => 'Writing to tag…';

  @override
  String get writeSuccess => 'Tag updated successfully';

  @override
  String get invalidTagData => 'Invalid data on NFC tag';

  @override
  String get errorUnrecognisedTag =>
      'Unrecognised tag — not a Nova Heronix tag';

  @override
  String get errorTagNotWrittenByApp =>
      'This tag was not written by Nova Heronix WiFi Manager';

  @override
  String get tagLocked => 'Tag: Locked';

  @override
  String get tagWritable => 'Tag: Writable';

  @override
  String get lockTag => 'Lock tag (read-only)';

  @override
  String get lockTagTitle => 'Lock NFC tag?';

  @override
  String get lockTagWarning =>
      'This is irreversible. The tag can never be overwritten again. Only use for networks that will not need password updates.';

  @override
  String get lockTagConfirm => 'Lock tag';

  @override
  String get lockTagSuccess => 'Tag locked successfully';

  @override
  String get lockTagFailed => 'Could not lock tag on this device';

  @override
  String get tagPhysicallyLockedBanner =>
      'This tag is physically locked. Replace the tag to update credentials.';

  @override
  String get iosGuestQrHint =>
      'On iPhone, guests should scan the QR sticker with the Camera app to join WiFi';

  @override
  String get label => 'Location label';

  @override
  String get save => 'Save';

  @override
  String get changeAdminPin => 'Change admin PIN';

  @override
  String get newPin => 'New PIN';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get passwordCopied => 'Password copied';

  @override
  String get done => 'Done';

  @override
  String get ok => 'OK';

  @override
  String get confirm => 'Confirm';

  @override
  String get networkDetails => 'Network details';

  @override
  String get addNetworkTitle => 'Add network';

  @override
  String get changePasswordTitle => 'Change password';

  @override
  String get pinMustBeSixDigits => 'PIN must be 6 digits';

  @override
  String get enterCurrentPinToReset => 'Enter your current PIN to reset';

  @override
  String get settingsLocked => 'Enter PIN to open settings';

  @override
  String get exportQrTitle => 'Export QR code';

  @override
  String get errorPermissionDenied => 'Permission denied';

  @override
  String get errorParseFailed => 'Could not read tag data';

  @override
  String get tagReadOnly => 'Tag is read-only';

  @override
  String get strengthLabel => 'Password strength';

  @override
  String get adminSectionTitle => 'Factory admin';

  @override
  String get initializeTag => 'Initialize NFC tag';

  @override
  String get initializeTagDescription =>
      'Claim a blank tag for Nova Heronix before shipping. End users will add WiFi details later.';

  @override
  String get initializeTagTapPrompt =>
      'Hold the phone on a blank NFC tag to initialize';

  @override
  String get tagInitializedSuccess => 'Tag initialized and ready to ship';

  @override
  String get initializeTagNotBlank =>
      'This tag is not blank. Initialize only blank tags — use Clear first if you want to reuse it.';

  @override
  String lastInitializedTagId(String tagId) {
    return 'Last tag ID: $tagId';
  }

  @override
  String get awaitingSetup => 'Awaiting setup';

  @override
  String get configured => 'Configured';

  @override
  String get setupTagTitle => 'Set up this tag';

  @override
  String get setupTagDescription =>
      'Enter the WiFi details for the tag you scanned. They will be written to this tag after you save.';

  @override
  String get tagNotProvisioned =>
      'This tag was not initialized by Nova Heronix. Use a factory-initialized tag.';

  @override
  String get scanToSetupPrompt =>
      'Scan a Nova Heronix tag to set up or update WiFi';

  @override
  String get noTagsYet => 'No tags scanned yet';

  @override
  String tagIdLabel(String tagId) {
    return 'Tag ID: $tagId';
  }

  @override
  String get editCredentialsTitle => 'Edit WiFi credentials';

  @override
  String get editCredentials => 'Edit SSID and password';

  @override
  String get viewCredentialsPin => 'Enter PIN to view credentials';

  @override
  String get factoryAdminPin => 'Service code';

  @override
  String get factoryAdminPinTitle => 'Service access';

  @override
  String get factoryAdminPinHint => 'Enter the service code to continue.';

  @override
  String get factoryAdminWrongPin => 'Incorrect service code';

  @override
  String get factoryAdminTitle => 'Service tools';

  @override
  String get factoryAdminDescription =>
      'Tag provisioning and maintenance tools.';

  @override
  String get factoryAdminLock => 'Lock';

  @override
  String get factoryBrandTagSubtitle =>
      'Prepare a blank tag for Nova Heronix (WiFi setup later)';

  @override
  String get wipeTagTitle => 'Clear tag data';

  @override
  String get wipeTagDescription =>
      'Remove NDEF data from a Nova Heronix tag or blank writable tag.';

  @override
  String get wipeTagTapPrompt => 'Hold the phone on the tag to clear';

  @override
  String get wipeTagSuccess => 'Tag cleared';

  @override
  String get wipeTagFailed => 'Could not clear tag';

  @override
  String get wipeNotNovaTag =>
      'Only Nova Heronix tags or blank writable tags can be cleared';

  @override
  String get legacyTagBanner =>
      'This tag uses an older format. Re-write it from network details so guests can tap to join WiFi.';

  @override
  String get downloadQrPdf => 'Download PDF';

  @override
  String get printQr => 'Print QR';

  @override
  String get printQrFailed => 'Printing is not available on this device';

  @override
  String get scanToJoinWifi => 'Scan to join WiFi';

  @override
  String get scanHeroTitle => 'Tap a tag to scan';

  @override
  String get scanTagButton => 'Scan a tag';

  @override
  String get scanHeroSubtitle =>
      'Hold your phone near a Nova Heronix tag to set up or manage WiFi.';

  @override
  String get scanStep1Title => 'Hold phone to the tag';

  @override
  String get scanStep1Subtitle =>
      'Place the back of your phone on the NFC tag.';

  @override
  String get scanStep2Title => 'Tag is read automatically';

  @override
  String get scanStep2Subtitle => 'The app opens setup or network details.';

  @override
  String get scanStep3Title => 'Guests connect easily';

  @override
  String get scanStep3Subtitle =>
      'Android guests tap to join WiFi; iPhone guests scan the QR card.';

  @override
  String get setupTagTapPrompt =>
      'Hold your phone on the tag to write WiFi details';

  @override
  String get qrExportPromptTitle => 'Export QR for iPhone guests';

  @override
  String get qrExportPromptMessage =>
      'iPhone users scan the QR code to join WiFi. Download a PDF now?';

  @override
  String get qrExportPromptDownload => 'Download PDF';

  @override
  String get qrExportPromptLater => 'Later';

  @override
  String get preShipChecklistTitle => 'Pre-ship checklist';

  @override
  String get preShipStep1 => 'Initialize a blank NTAG215 tag';

  @override
  String get preShipStep2 => 'Complete WiFi setup write';

  @override
  String get preShipStep3 =>
      'Android test: tap tag — confirm WiFi join prompt (not app launch)';

  @override
  String get preShipStep4 => 'Export QR PDF for iPhone guests';

  @override
  String get preShipStep5 => 'Optional: lock tag before shipping';
}
