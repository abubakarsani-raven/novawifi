// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Nova Heronix WiFi Manager';

  @override
  String get scanNfc => 'Scanner la balise NFC';

  @override
  String get scanQrCode => 'Scanner le code QR';

  @override
  String get useCurrentWifi => 'Utiliser le Wi‑Fi actuel';

  @override
  String get couldNotReadCurrentWifi =>
      'Impossible de lire le réseau Wi‑Fi actuel';

  @override
  String get networkName => 'Nom du réseau (SSID)';

  @override
  String get password => 'Mot de passe';

  @override
  String get showPassword => 'Afficher le mot de passe';

  @override
  String get hidePassword => 'Masquer le mot de passe';

  @override
  String get copyPassword => 'Copier le mot de passe';

  @override
  String get changePassword => 'Changer le mot de passe';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get saveAndWrite => 'Enregistrer et écrire sur la balise';

  @override
  String get exportQr => 'Exporter le QR';

  @override
  String get downloadQr => 'Télécharger le QR';

  @override
  String get shareQr => 'Partager le QR';

  @override
  String get addNetwork => 'Ajouter un réseau';

  @override
  String get deleteNetwork => 'Supprimer le réseau';

  @override
  String get noNetworks => 'Aucun réseau enregistré';

  @override
  String get tapNfcPrompt => 'Approchez votre téléphone de la balise NFC';

  @override
  String get writeNfcPrompt =>
      'Approchez votre téléphone de la balise pour écrire';

  @override
  String get successWritten => 'Identifiants écrits sur la balise avec succès';

  @override
  String get errorNfcNotAvailable => 'NFC non disponible sur cet appareil';

  @override
  String get errorTagNotFound => 'Aucune balise NFC détectée';

  @override
  String get errorWriteFailed => 'Échec de l\'écriture sur la balise NFC';

  @override
  String get errorPasswordMismatch => 'Les mots de passe ne correspondent pas';

  @override
  String get errorPasswordTooShort =>
      'Le mot de passe doit contenir au moins 8 caractères';

  @override
  String get settings => 'Paramètres';

  @override
  String get language => 'Langue';

  @override
  String get selectLanguage => 'Choisir la langue';

  @override
  String get networks => 'Réseaux';

  @override
  String get qrCode => 'Code QR';

  @override
  String get scanTab => 'Scanner';

  @override
  String get networksTab => 'Réseaux';

  @override
  String get settingsTab => 'Paramètres';

  @override
  String get printQrReminder =>
      'N\'oubliez pas de remplacer l\'autocollant QR après un changement de mot de passe.';

  @override
  String get cancel => 'Annuler';

  @override
  String get retry => 'Réessayer';

  @override
  String get undo => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get confirmDelete => 'Supprimer ce réseau ?';

  @override
  String get networkDeleted => 'Réseau supprimé';

  @override
  String get loading => 'Chargement…';

  @override
  String get writeToNfc => 'Écrire sur la balise NFC';

  @override
  String get nfcWriteNotSupported =>
      'L\'écriture NFC n\'est pas prise en charge sur cet appareil';

  @override
  String get nfcTagTooSmall =>
      'Mémoire de l\'étiquette trop petite — utilisez NTAG215 ou supérieur';

  @override
  String get qrManualModeBanner =>
      'NFC indisponible — utilisez l\'export QR ou gérez les réseaux manuellement';

  @override
  String pinLocked(int seconds) {
    return 'PIN verrouillé. Réessayez dans $seconds secondes';
  }

  @override
  String get resetPin => 'Réinitialiser le PIN';

  @override
  String get currentPin => 'PIN actuel';

  @override
  String get setPin => 'Définir le PIN';

  @override
  String get confirmPin => 'Confirmer le PIN';

  @override
  String get pinsDoNotMatch => 'Les PIN ne correspondent pas';

  @override
  String get pinSetSuccess => 'PIN défini avec succès';

  @override
  String get pinChangedSuccess => 'PIN modifié avec succès';

  @override
  String get version => 'Version';

  @override
  String get aboutFooter => 'Nova Heronix — gestion WiFi interne';

  @override
  String get aboutHeader => 'À propos';

  @override
  String get syncedToTag => 'Synchronisé avec la balise';

  @override
  String get notYetWritten => 'Pas encore écrit';

  @override
  String get passwordStrengthWeak => 'Faible';

  @override
  String get passwordStrengthMedium => 'Moyen';

  @override
  String get passwordStrengthStrong => 'Fort';

  @override
  String get holdPhoneToTag => 'Maintenez votre téléphone contre la balise';

  @override
  String get writing => 'Écriture sur la balise…';

  @override
  String get writeSuccess => 'Balise mise à jour avec succès';

  @override
  String get invalidTagData => 'Données invalides sur la balise NFC';

  @override
  String get errorUnrecognisedTag =>
      'Balise non reconnue — pas une balise Nova Heronix';

  @override
  String get errorTagNotWrittenByApp =>
      'Cette balise n\'a pas été écrite par Nova Heronix WiFi Manager';

  @override
  String get tagLocked => 'Balise : verrouillée';

  @override
  String get tagWritable => 'Balise : modifiable';

  @override
  String get lockTag => 'Verrouiller la balise (lecture seule)';

  @override
  String get lockTagTitle => 'Verrouiller la balise NFC ?';

  @override
  String get lockTagWarning =>
      'Cette action est irréversible. La balise ne pourra plus jamais être écrasée.';

  @override
  String get lockTagConfirm => 'Verrouiller la balise';

  @override
  String get lockTagSuccess => 'Balise verrouillée avec succès';

  @override
  String get lockTagFailed =>
      'Impossible de verrouiller la balise sur cet appareil';

  @override
  String get tagPhysicallyLockedBanner =>
      'Cette balise est verrouillée physiquement. Remplacez la balise pour mettre à jour les identifiants.';

  @override
  String get iosGuestQrHint =>
      'Sur iPhone, les invités doivent scanner l\'autocollant QR avec l\'appareil photo pour rejoindre le WiFi';

  @override
  String get label => 'Libellé de lieu';

  @override
  String get save => 'Enregistrer';

  @override
  String get copiedToClipboard => 'Copié dans le presse-papiers';

  @override
  String get passwordCopied => 'Mot de passe copié';

  @override
  String get done => 'Terminé';

  @override
  String get ok => 'OK';

  @override
  String get confirm => 'Confirmer';

  @override
  String get networkDetails => 'Détails du réseau';

  @override
  String get addNetworkTitle => 'Ajouter un réseau';

  @override
  String get changePasswordTitle => 'Changer le mot de passe';

  @override
  String get pinMustBeSixDigits => 'Le PIN doit comporter 6 chiffres';

  @override
  String get enterCurrentPinToReset =>
      'Entrez votre PIN actuel pour réinitialiser';

  @override
  String get exportQrTitle => 'Exporter le code QR';

  @override
  String get errorPermissionDenied => 'Permission refusée';

  @override
  String get errorParseFailed => 'Impossible de lire les données de la balise';

  @override
  String get tagReadOnly => 'Balise en lecture seule';

  @override
  String get strengthLabel => 'Force du mot de passe';

  @override
  String get adminSectionTitle => 'Admin usine';

  @override
  String get initializeTag => 'Initialiser la balise NFC';

  @override
  String get initializeTagDescription =>
      'Réserver une balise vierge pour Nova Heronix avant expédition.';

  @override
  String get initializeTagTapPrompt =>
      'Approchez le téléphone d\'une balise NFC vierge';

  @override
  String get tagInitializedSuccess => 'Balise initialisée, prête à expédier';

  @override
  String get initializeTagNotBlank =>
      'Cette balise n\'est pas vierge. N\'initialisez que des balises vierges ; utilisez Effacer d\'abord pour la réutiliser.';

  @override
  String lastInitializedTagId(String tagId) {
    return 'Dernier ID : $tagId';
  }

  @override
  String get awaitingSetup => 'En attente de configuration';

  @override
  String get configured => 'Configuré';

  @override
  String get setupTagTitle => 'Configurer cette balise';

  @override
  String get setupTagDescription => 'Saisissez le WiFi pour la balise scannée.';

  @override
  String get tagNotProvisioned => 'Balise non initialisée par Nova Heronix.';

  @override
  String get scanToSetupPrompt =>
      'Scannez une balise Nova Heronix pour configurer le WiFi';

  @override
  String get noTagsYet => 'Aucune balise scannée';

  @override
  String tagIdLabel(String tagId) {
    return 'ID balise : $tagId';
  }

  @override
  String get editCredentialsTitle => 'Modifier les identifiants WiFi';

  @override
  String get editCredentials => 'Modifier SSID et mot de passe';

  @override
  String get factoryAdminPin => 'Code service';

  @override
  String get factoryAdminPinTitle => 'Accès service';

  @override
  String get factoryAdminPinHint => 'Entrez le code service pour continuer.';

  @override
  String get factoryAdminWrongPin => 'Code service incorrect';

  @override
  String get factoryAdminTitle => 'Outils service';

  @override
  String get factoryAdminDescription =>
      'Provisionnement et maintenance des balises.';

  @override
  String get factoryAdminLock => 'Verrouiller';

  @override
  String get factoryBrandTagSubtitle =>
      'Préparer une balise vierge pour Nova Heronix';

  @override
  String get wipeTagTitle => 'Effacer les données de la balise';

  @override
  String get wipeTagDescription =>
      'Supprimer les données NDEF d\'une balise Nova Heronix ou vierge.';

  @override
  String get wipeTagTapPrompt => 'Approchez le téléphone de la balise';

  @override
  String get wipeTagSuccess => 'Balise effacée';

  @override
  String get wipeTagFailed => 'Impossible d\'effacer la balise';

  @override
  String get wipeNotNovaTag =>
      'Seules les balises Nova Heronix ou vierges peuvent être effacées';

  @override
  String get legacyTagBanner =>
      'Format ancien. Réécrivez la balise depuis les détails pour permettre la connexion WiFi par NFC.';

  @override
  String get downloadQrPdf => 'Télécharger PDF';

  @override
  String get printQr => 'Imprimer le QR';

  @override
  String get printQrFailed => 'Impression indisponible sur cet appareil';

  @override
  String get scanToJoinWifi => 'Scannez pour rejoindre le WiFi';

  @override
  String get scanHeroTitle => 'Approchez une balise pour scanner';

  @override
  String get scanTagButton => 'Scanner une balise';

  @override
  String get scanHeroSubtitle =>
      'Approchez votre téléphone d\'une balise Nova Heronix pour configurer ou gérer le WiFi.';

  @override
  String get scanStep1Title => 'Approchez le téléphone de la balise';

  @override
  String get scanStep1Subtitle =>
      'Placez l\'arrière du téléphone sur la balise NFC.';

  @override
  String get scanStep2Title => 'La balise est lue automatiquement';

  @override
  String get scanStep2Subtitle =>
      'L\'app ouvre la configuration ou les détails du réseau.';

  @override
  String get scanStep3Title => 'Les invités se connectent facilement';

  @override
  String get scanStep3Subtitle => 'Android : NFC ; iPhone : carte QR.';

  @override
  String get setupTagTapPrompt =>
      'Maintenez le téléphone sur la balise pour écrire les détails WiFi';

  @override
  String get qrExportPromptTitle => 'Exporter le QR pour les invités iPhone';

  @override
  String get qrExportPromptMessage =>
      'Les utilisateurs iPhone scannent le QR pour rejoindre le WiFi. Télécharger le PDF maintenant ?';

  @override
  String get qrExportPromptDownload => 'Télécharger PDF';

  @override
  String get qrExportPromptLater => 'Plus tard';

  @override
  String get preShipChecklistTitle => 'Liste de contrôle avant expédition';

  @override
  String get preShipStep1 => 'Initialiser une balise NTAG215 vierge';

  @override
  String get preShipStep2 => 'Terminer l\'écriture de configuration WiFi';

  @override
  String get preShipStep3 =>
      'Test Android : toucher la balise — confirmer l\'invite WiFi (pas l\'app)';

  @override
  String get preShipStep4 => 'Exporter le PDF QR pour les invités iPhone';

  @override
  String get preShipStep5 =>
      'Optionnel : verrouiller la balise avant expédition';

  @override
  String get homeTab => 'Accueil';

  @override
  String get scanReadyBadge => 'Prêt à scanner';

  @override
  String get scanningForTags => 'Recherche de balises…';

  @override
  String get wifiTagManagerTitle => 'Gestionnaire de balises WiFi';

  @override
  String get wifiTagManagerSubtitle =>
      'Gérez vos réseaux WiFi enregistrés et exportez des codes QR.';

  @override
  String get swipeToDeleteHint => 'Glissez vers la gauche pour supprimer';

  @override
  String get noTagsYetTitle => 'Aucune balise';

  @override
  String get noTagsYetDescription =>
      'Scannez votre première balise Nova Heronix depuis l\'accueil.';

  @override
  String get scanFirstTagCta => 'Scanner votre première balise';

  @override
  String get locked => 'Verrouillée';

  @override
  String get exportQrSection => 'Exporter le QR';

  @override
  String get tagActionsSection => 'Actions sur la balise';

  @override
  String get wifiCredentialsSection => 'Identifiants WiFi';

  @override
  String get securityLabel => 'Sécurité';

  @override
  String get advancedSection => 'Avancé';

  @override
  String get securityTypeLabel => 'Type de sécurité';

  @override
  String get hiddenNetworkLabel => 'Réseau masqué';

  @override
  String get nearbyNetworks => 'Réseaux à proximité';

  @override
  String get wifiScanAndroidOnly =>
      'Le scan WiFi n\'est disponible que sur Android.\nSaisissez le nom du réseau manuellement.';

  @override
  String get wifiScanPermissionRequired =>
      'L\'autorisation de localisation est requise pour scanner les réseaux WiFi.\nAccordez-la dans les paramètres.';

  @override
  String get wifiScanNoNetworks => 'Aucun réseau trouvé';

  @override
  String get scanningForNetworks => 'Recherche de réseaux…';

  @override
  String get rescan => 'Rescanner';

  @override
  String get serviceTools => 'Outils de service';

  @override
  String get wipeStartButton => 'Commencer l\'effacement';

  @override
  String get wipeBatchHint =>
      'Maintenez chaque balise pour l\'effacer. La suivante est prête automatiquement après succès.';

  @override
  String get onboardingSkip => 'Passer';

  @override
  String get onboardingNext => 'Suivant';

  @override
  String get onboardingGetStarted => 'Commencer';

  @override
  String get onboardingPage1Title => 'Scannez votre balise Nova';

  @override
  String get onboardingPage1Body =>
      'Approchez votre téléphone d\'une balise NFC Nova Heronix pour configurer le WiFi invité.';

  @override
  String get onboardingPage2Title => 'Ajoutez le WiFi et écrivez sur la balise';

  @override
  String get onboardingPage2Body =>
      'Saisissez les détails une fois. Nova les écrit sur la balise pour un accès invité en un geste.';

  @override
  String get onboardingPage3Title => 'Partagez avec les invités';

  @override
  String get onboardingPage3Body =>
      'Android : toucher pour rejoindre. iPhone : scanner le QR ou utiliser l\'App Clip.';

  @override
  String get forGuestsSection => 'Pour les invités';

  @override
  String get forGuestsSubtitle => 'Code QR que les invités peuvent scanner';

  @override
  String get forYouSection => 'Pour vous';

  @override
  String get forYouSubtitle => 'Identifiants et gestion de la balise';

  @override
  String get advancedSectionSubtitle => 'Actions irréversibles';

  @override
  String get deleteSyncedTagTitle => 'Supprimer la balise synchronisée ?';

  @override
  String get deleteSyncedTagMessage =>
      'Cette balise a été écrite en NFC. La suppression ne retire que l\'entrée dans l\'app — la balise physique reste inchangée.';

  @override
  String tagsNeedSetupBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count balises à configurer',
      one: '1 balise à configurer',
    );
    return '$_temp0';
  }

  @override
  String tagsNotWrittenBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count balises pas encore écrites en NFC',
      one: '1 balise pas encore écrite en NFC',
    );
    return '$_temp0';
  }

  @override
  String get viewNetworks => 'Voir les réseaux';

  @override
  String get appearance => 'Apparence';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get nfcPhaseScanning => 'En attente de la balise NFC';

  @override
  String get nfcPhaseSuccess => 'Succès';

  @override
  String get nfcPhaseFailure => 'Échec';

  @override
  String get hiddenNetworkSubtitle => 'Le réseau ne diffuse pas son nom';
}
