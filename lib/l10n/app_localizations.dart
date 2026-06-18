import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Nova Heronix WiFi Manager'**
  String get appTitle;

  /// No description provided for @scanNfc.
  ///
  /// In en, this message translates to:
  /// **'Scan NFC tag'**
  String get scanNfc;

  /// No description provided for @scanQrCode.
  ///
  /// In en, this message translates to:
  /// **'Scan QR code'**
  String get scanQrCode;

  /// Label for the Wi-Fi network name (SSID) field.
  ///
  /// In en, this message translates to:
  /// **'Network name (SSID)'**
  String get networkName;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @copyPassword.
  ///
  /// In en, this message translates to:
  /// **'Copy password'**
  String get copyPassword;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @saveAndWrite.
  ///
  /// In en, this message translates to:
  /// **'Save and write to tag'**
  String get saveAndWrite;

  /// No description provided for @exportQr.
  ///
  /// In en, this message translates to:
  /// **'Export QR'**
  String get exportQr;

  /// No description provided for @downloadQr.
  ///
  /// In en, this message translates to:
  /// **'Download QR'**
  String get downloadQr;

  /// No description provided for @shareQr.
  ///
  /// In en, this message translates to:
  /// **'Share QR'**
  String get shareQr;

  /// No description provided for @addNetwork.
  ///
  /// In en, this message translates to:
  /// **'Add network'**
  String get addNetwork;

  /// No description provided for @deleteNetwork.
  ///
  /// In en, this message translates to:
  /// **'Delete network'**
  String get deleteNetwork;

  /// No description provided for @noNetworks.
  ///
  /// In en, this message translates to:
  /// **'No networks saved yet'**
  String get noNetworks;

  /// No description provided for @tapNfcPrompt.
  ///
  /// In en, this message translates to:
  /// **'Hold your phone near the NFC tag'**
  String get tapNfcPrompt;

  /// No description provided for @writeNfcPrompt.
  ///
  /// In en, this message translates to:
  /// **'Hold your phone near the tag to write'**
  String get writeNfcPrompt;

  /// No description provided for @successWritten.
  ///
  /// In en, this message translates to:
  /// **'Credentials written to tag successfully'**
  String get successWritten;

  /// No description provided for @errorNfcNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'NFC is not available on this device'**
  String get errorNfcNotAvailable;

  /// No description provided for @errorTagNotFound.
  ///
  /// In en, this message translates to:
  /// **'No NFC tag detected'**
  String get errorTagNotFound;

  /// No description provided for @errorWriteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to write to NFC tag'**
  String get errorWriteFailed;

  /// No description provided for @errorPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get errorPasswordMismatch;

  /// No description provided for @errorPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get errorPasswordTooShort;

  /// No description provided for @adminPin.
  ///
  /// In en, this message translates to:
  /// **'Admin PIN'**
  String get adminPin;

  /// No description provided for @enterPin.
  ///
  /// In en, this message translates to:
  /// **'Enter your 6-digit PIN'**
  String get enterPin;

  /// No description provided for @wrongPin.
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN'**
  String get wrongPin;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get selectLanguage;

  /// No description provided for @networks.
  ///
  /// In en, this message translates to:
  /// **'Networks'**
  String get networks;

  /// No description provided for @qrCode.
  ///
  /// In en, this message translates to:
  /// **'QR code'**
  String get qrCode;

  /// No description provided for @scanTab.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scanTab;

  /// No description provided for @networksTab.
  ///
  /// In en, this message translates to:
  /// **'Networks'**
  String get networksTab;

  /// No description provided for @settingsTab.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTab;

  /// No description provided for @printQrReminder.
  ///
  /// In en, this message translates to:
  /// **'Remember to replace the physical QR sticker after a password change.'**
  String get printQrReminder;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete this network?'**
  String get confirmDelete;

  /// No description provided for @networkDeleted.
  ///
  /// In en, this message translates to:
  /// **'Network deleted'**
  String get networkDeleted;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @writeToNfc.
  ///
  /// In en, this message translates to:
  /// **'Write to NFC tag'**
  String get writeToNfc;

  /// No description provided for @nfcWriteNotSupported.
  ///
  /// In en, this message translates to:
  /// **'NFC write is not supported on this device'**
  String get nfcWriteNotSupported;

  /// No description provided for @nfcTagTooSmall.
  ///
  /// In en, this message translates to:
  /// **'Tag memory too small — use NTAG215 or larger'**
  String get nfcTagTooSmall;

  /// No description provided for @qrManualModeBanner.
  ///
  /// In en, this message translates to:
  /// **'NFC unavailable — use QR export or manage networks manually'**
  String get qrManualModeBanner;

  /// No description provided for @pinLocked.
  ///
  /// In en, this message translates to:
  /// **'PIN locked. Try again in {seconds} seconds'**
  String pinLocked(int seconds);

  /// No description provided for @resetPin.
  ///
  /// In en, this message translates to:
  /// **'Reset PIN'**
  String get resetPin;

  /// No description provided for @currentPin.
  ///
  /// In en, this message translates to:
  /// **'Current PIN'**
  String get currentPin;

  /// No description provided for @setPin.
  ///
  /// In en, this message translates to:
  /// **'Set PIN'**
  String get setPin;

  /// No description provided for @confirmPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get confirmPin;

  /// No description provided for @pinsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'PINs do not match'**
  String get pinsDoNotMatch;

  /// No description provided for @pinSetSuccess.
  ///
  /// In en, this message translates to:
  /// **'PIN set successfully'**
  String get pinSetSuccess;

  /// No description provided for @pinChangedSuccess.
  ///
  /// In en, this message translates to:
  /// **'PIN changed successfully'**
  String get pinChangedSuccess;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @aboutFooter.
  ///
  /// In en, this message translates to:
  /// **'Nova Heronix — internal WiFi management'**
  String get aboutFooter;

  /// No description provided for @syncedToTag.
  ///
  /// In en, this message translates to:
  /// **'Synced to tag'**
  String get syncedToTag;

  /// No description provided for @notYetWritten.
  ///
  /// In en, this message translates to:
  /// **'Not yet written'**
  String get notYetWritten;

  /// No description provided for @passwordStrengthWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get passwordStrengthWeak;

  /// No description provided for @passwordStrengthMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get passwordStrengthMedium;

  /// No description provided for @passwordStrengthStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get passwordStrengthStrong;

  /// No description provided for @firstLaunchSetPin.
  ///
  /// In en, this message translates to:
  /// **'Set a 6-digit admin PIN to protect sensitive actions'**
  String get firstLaunchSetPin;

  /// No description provided for @holdPhoneToTag.
  ///
  /// In en, this message translates to:
  /// **'Hold your phone against the tag'**
  String get holdPhoneToTag;

  /// No description provided for @writing.
  ///
  /// In en, this message translates to:
  /// **'Writing to tag…'**
  String get writing;

  /// No description provided for @writeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Tag updated successfully'**
  String get writeSuccess;

  /// No description provided for @invalidTagData.
  ///
  /// In en, this message translates to:
  /// **'Invalid data on NFC tag'**
  String get invalidTagData;

  /// No description provided for @errorUnrecognisedTag.
  ///
  /// In en, this message translates to:
  /// **'Unrecognised tag — not a Nova Heronix tag'**
  String get errorUnrecognisedTag;

  /// No description provided for @errorTagNotWrittenByApp.
  ///
  /// In en, this message translates to:
  /// **'This tag was not written by Nova Heronix WiFi Manager'**
  String get errorTagNotWrittenByApp;

  /// No description provided for @tagLocked.
  ///
  /// In en, this message translates to:
  /// **'Tag: Locked'**
  String get tagLocked;

  /// No description provided for @tagWritable.
  ///
  /// In en, this message translates to:
  /// **'Tag: Writable'**
  String get tagWritable;

  /// No description provided for @lockTag.
  ///
  /// In en, this message translates to:
  /// **'Lock tag (read-only)'**
  String get lockTag;

  /// No description provided for @lockTagTitle.
  ///
  /// In en, this message translates to:
  /// **'Lock NFC tag?'**
  String get lockTagTitle;

  /// No description provided for @lockTagWarning.
  ///
  /// In en, this message translates to:
  /// **'This is irreversible. The tag can never be overwritten again. Only use for networks that will not need password updates.'**
  String get lockTagWarning;

  /// No description provided for @lockTagConfirm.
  ///
  /// In en, this message translates to:
  /// **'Lock tag'**
  String get lockTagConfirm;

  /// No description provided for @lockTagSuccess.
  ///
  /// In en, this message translates to:
  /// **'Tag locked successfully'**
  String get lockTagSuccess;

  /// No description provided for @lockTagFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not lock tag on this device'**
  String get lockTagFailed;

  /// No description provided for @tagPhysicallyLockedBanner.
  ///
  /// In en, this message translates to:
  /// **'This tag is physically locked. Replace the tag to update credentials.'**
  String get tagPhysicallyLockedBanner;

  /// No description provided for @iosGuestQrHint.
  ///
  /// In en, this message translates to:
  /// **'On iPhone, guests should scan the QR sticker with the Camera app to join WiFi'**
  String get iosGuestQrHint;

  /// No description provided for @label.
  ///
  /// In en, this message translates to:
  /// **'Location label'**
  String get label;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @changeAdminPin.
  ///
  /// In en, this message translates to:
  /// **'Change admin PIN'**
  String get changeAdminPin;

  /// No description provided for @newPin.
  ///
  /// In en, this message translates to:
  /// **'New PIN'**
  String get newPin;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @passwordCopied.
  ///
  /// In en, this message translates to:
  /// **'Password copied'**
  String get passwordCopied;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @networkDetails.
  ///
  /// In en, this message translates to:
  /// **'Network details'**
  String get networkDetails;

  /// No description provided for @addNetworkTitle.
  ///
  /// In en, this message translates to:
  /// **'Add network'**
  String get addNetworkTitle;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePasswordTitle;

  /// No description provided for @pinMustBeSixDigits.
  ///
  /// In en, this message translates to:
  /// **'PIN must be 6 digits'**
  String get pinMustBeSixDigits;

  /// No description provided for @enterCurrentPinToReset.
  ///
  /// In en, this message translates to:
  /// **'Enter your current PIN to reset'**
  String get enterCurrentPinToReset;

  /// No description provided for @settingsLocked.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN to open settings'**
  String get settingsLocked;

  /// No description provided for @exportQrTitle.
  ///
  /// In en, this message translates to:
  /// **'Export QR code'**
  String get exportQrTitle;

  /// No description provided for @errorPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied'**
  String get errorPermissionDenied;

  /// No description provided for @errorParseFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not read tag data'**
  String get errorParseFailed;

  /// No description provided for @tagReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Tag is read-only'**
  String get tagReadOnly;

  /// No description provided for @strengthLabel.
  ///
  /// In en, this message translates to:
  /// **'Password strength'**
  String get strengthLabel;

  /// No description provided for @adminSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Factory admin'**
  String get adminSectionTitle;

  /// No description provided for @initializeTag.
  ///
  /// In en, this message translates to:
  /// **'Initialize NFC tag'**
  String get initializeTag;

  /// No description provided for @initializeTagDescription.
  ///
  /// In en, this message translates to:
  /// **'Claim a blank tag for Nova Heronix before shipping. End users will add WiFi details later.'**
  String get initializeTagDescription;

  /// No description provided for @initializeTagTapPrompt.
  ///
  /// In en, this message translates to:
  /// **'Hold the phone on a blank NFC tag to initialize'**
  String get initializeTagTapPrompt;

  /// No description provided for @tagInitializedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Tag initialized and ready to ship'**
  String get tagInitializedSuccess;

  /// No description provided for @initializeTagNotBlank.
  ///
  /// In en, this message translates to:
  /// **'This tag is not blank. Initialize only blank tags — use Clear first if you want to reuse it.'**
  String get initializeTagNotBlank;

  /// No description provided for @lastInitializedTagId.
  ///
  /// In en, this message translates to:
  /// **'Last tag ID: {tagId}'**
  String lastInitializedTagId(String tagId);

  /// No description provided for @awaitingSetup.
  ///
  /// In en, this message translates to:
  /// **'Awaiting setup'**
  String get awaitingSetup;

  /// No description provided for @configured.
  ///
  /// In en, this message translates to:
  /// **'Configured'**
  String get configured;

  /// No description provided for @setupTagTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up this tag'**
  String get setupTagTitle;

  /// No description provided for @setupTagDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter the WiFi details for the tag you scanned. They will be written to this tag after you save.'**
  String get setupTagDescription;

  /// No description provided for @tagNotProvisioned.
  ///
  /// In en, this message translates to:
  /// **'This tag was not initialized by Nova Heronix. Use a factory-initialized tag.'**
  String get tagNotProvisioned;

  /// No description provided for @scanToSetupPrompt.
  ///
  /// In en, this message translates to:
  /// **'Scan a Nova Heronix tag to set up or update WiFi'**
  String get scanToSetupPrompt;

  /// No description provided for @noTagsYet.
  ///
  /// In en, this message translates to:
  /// **'No tags scanned yet'**
  String get noTagsYet;

  /// No description provided for @tagIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Tag ID: {tagId}'**
  String tagIdLabel(String tagId);

  /// No description provided for @editCredentialsTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit WiFi credentials'**
  String get editCredentialsTitle;

  /// No description provided for @editCredentials.
  ///
  /// In en, this message translates to:
  /// **'Edit SSID and password'**
  String get editCredentials;

  /// No description provided for @viewCredentialsPin.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN to view credentials'**
  String get viewCredentialsPin;

  /// No description provided for @factoryAdminPin.
  ///
  /// In en, this message translates to:
  /// **'Service code'**
  String get factoryAdminPin;

  /// No description provided for @factoryAdminPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Service access'**
  String get factoryAdminPinTitle;

  /// No description provided for @factoryAdminPinHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the service code to continue.'**
  String get factoryAdminPinHint;

  /// No description provided for @factoryAdminWrongPin.
  ///
  /// In en, this message translates to:
  /// **'Incorrect service code'**
  String get factoryAdminWrongPin;

  /// No description provided for @factoryAdminTitle.
  ///
  /// In en, this message translates to:
  /// **'Service tools'**
  String get factoryAdminTitle;

  /// No description provided for @factoryAdminDescription.
  ///
  /// In en, this message translates to:
  /// **'Tag provisioning and maintenance tools.'**
  String get factoryAdminDescription;

  /// No description provided for @factoryAdminLock.
  ///
  /// In en, this message translates to:
  /// **'Lock'**
  String get factoryAdminLock;

  /// No description provided for @factoryBrandTagSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Prepare a blank tag for Nova Heronix (WiFi setup later)'**
  String get factoryBrandTagSubtitle;

  /// No description provided for @wipeTagTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear tag data'**
  String get wipeTagTitle;

  /// No description provided for @wipeTagDescription.
  ///
  /// In en, this message translates to:
  /// **'Remove NDEF data from a Nova Heronix tag or blank writable tag.'**
  String get wipeTagDescription;

  /// No description provided for @wipeTagTapPrompt.
  ///
  /// In en, this message translates to:
  /// **'Hold the phone on the tag to clear'**
  String get wipeTagTapPrompt;

  /// No description provided for @wipeTagSuccess.
  ///
  /// In en, this message translates to:
  /// **'Tag cleared'**
  String get wipeTagSuccess;

  /// No description provided for @wipeTagFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not clear tag'**
  String get wipeTagFailed;

  /// No description provided for @wipeNotNovaTag.
  ///
  /// In en, this message translates to:
  /// **'Only Nova Heronix tags or blank writable tags can be cleared'**
  String get wipeNotNovaTag;

  /// No description provided for @legacyTagBanner.
  ///
  /// In en, this message translates to:
  /// **'This tag uses an older format. Re-write it from network details so guests can tap to join WiFi.'**
  String get legacyTagBanner;

  /// No description provided for @downloadQrPdf.
  ///
  /// In en, this message translates to:
  /// **'Download PDF'**
  String get downloadQrPdf;

  /// No description provided for @printQr.
  ///
  /// In en, this message translates to:
  /// **'Print QR'**
  String get printQr;

  /// No description provided for @printQrFailed.
  ///
  /// In en, this message translates to:
  /// **'Printing is not available on this device'**
  String get printQrFailed;

  /// No description provided for @scanToJoinWifi.
  ///
  /// In en, this message translates to:
  /// **'Scan to join WiFi'**
  String get scanToJoinWifi;

  /// No description provided for @scanHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Tap a tag to scan'**
  String get scanHeroTitle;

  /// No description provided for @scanTagButton.
  ///
  /// In en, this message translates to:
  /// **'Scan a tag'**
  String get scanTagButton;

  /// No description provided for @scanHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Hold your phone near a Nova Heronix tag to set up or manage WiFi.'**
  String get scanHeroSubtitle;

  /// No description provided for @scanStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Hold phone to the tag'**
  String get scanStep1Title;

  /// No description provided for @scanStep1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Place the back of your phone on the NFC tag.'**
  String get scanStep1Subtitle;

  /// No description provided for @scanStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Tag is read automatically'**
  String get scanStep2Title;

  /// No description provided for @scanStep2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'The app opens setup or network details.'**
  String get scanStep2Subtitle;

  /// No description provided for @scanStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Guests connect easily'**
  String get scanStep3Title;

  /// No description provided for @scanStep3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Android guests tap to join WiFi; iPhone guests scan the QR card.'**
  String get scanStep3Subtitle;

  /// No description provided for @setupTagTapPrompt.
  ///
  /// In en, this message translates to:
  /// **'Hold your phone on the tag to write WiFi details'**
  String get setupTagTapPrompt;

  /// No description provided for @qrExportPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Export QR for iPhone guests'**
  String get qrExportPromptTitle;

  /// No description provided for @qrExportPromptMessage.
  ///
  /// In en, this message translates to:
  /// **'iPhone users scan the QR code to join WiFi. Download a PDF now?'**
  String get qrExportPromptMessage;

  /// No description provided for @qrExportPromptDownload.
  ///
  /// In en, this message translates to:
  /// **'Download PDF'**
  String get qrExportPromptDownload;

  /// No description provided for @qrExportPromptLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get qrExportPromptLater;

  /// No description provided for @preShipChecklistTitle.
  ///
  /// In en, this message translates to:
  /// **'Pre-ship checklist'**
  String get preShipChecklistTitle;

  /// No description provided for @preShipStep1.
  ///
  /// In en, this message translates to:
  /// **'Initialize a blank NTAG215 tag'**
  String get preShipStep1;

  /// No description provided for @preShipStep2.
  ///
  /// In en, this message translates to:
  /// **'Complete WiFi setup write'**
  String get preShipStep2;

  /// No description provided for @preShipStep3.
  ///
  /// In en, this message translates to:
  /// **'Android test: tap tag — confirm WiFi join prompt (not app launch)'**
  String get preShipStep3;

  /// No description provided for @preShipStep4.
  ///
  /// In en, this message translates to:
  /// **'Export QR PDF for iPhone guests'**
  String get preShipStep4;

  /// No description provided for @preShipStep5.
  ///
  /// In en, this message translates to:
  /// **'Optional: lock tag before shipping'**
  String get preShipStep5;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
