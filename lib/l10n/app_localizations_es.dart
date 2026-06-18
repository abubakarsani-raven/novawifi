// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Nova Heronix WiFi Manager';

  @override
  String get scanNfc => 'Escanear etiqueta NFC';

  @override
  String get scanQrCode => 'Escanear código QR';

  @override
  String get networkName => 'Nombre de red (SSID)';

  @override
  String get password => 'Contraseña';

  @override
  String get showPassword => 'Mostrar contraseña';

  @override
  String get hidePassword => 'Ocultar contraseña';

  @override
  String get copyPassword => 'Copiar contraseña';

  @override
  String get changePassword => 'Cambiar contraseña';

  @override
  String get newPassword => 'Nueva contraseña';

  @override
  String get confirmPassword => 'Confirmar contraseña';

  @override
  String get saveAndWrite => 'Guardar y escribir en la etiqueta';

  @override
  String get exportQr => 'Exportar QR';

  @override
  String get downloadQr => 'Descargar QR';

  @override
  String get shareQr => 'Compartir QR';

  @override
  String get addNetwork => 'Añadir red';

  @override
  String get deleteNetwork => 'Eliminar red';

  @override
  String get noNetworks => 'No hay redes guardadas';

  @override
  String get tapNfcPrompt => 'Acerca el teléfono a la etiqueta NFC';

  @override
  String get writeNfcPrompt => 'Acerca el teléfono a la etiqueta para escribir';

  @override
  String get successWritten =>
      'Credenciales escritas en la etiqueta correctamente';

  @override
  String get errorNfcNotAvailable => 'NFC no disponible en este dispositivo';

  @override
  String get errorTagNotFound => 'No se detectó etiqueta NFC';

  @override
  String get errorWriteFailed => 'Error al escribir en la etiqueta NFC';

  @override
  String get errorPasswordMismatch => 'Las contraseñas no coinciden';

  @override
  String get errorPasswordTooShort =>
      'La contraseña debe tener al menos 8 caracteres';

  @override
  String get adminPin => 'PIN de administrador';

  @override
  String get enterPin => 'Introduce tu PIN de 6 dígitos';

  @override
  String get wrongPin => 'PIN incorrecto';

  @override
  String get settings => 'Ajustes';

  @override
  String get language => 'Idioma';

  @override
  String get selectLanguage => 'Seleccionar idioma';

  @override
  String get networks => 'Redes';

  @override
  String get qrCode => 'Código QR';

  @override
  String get scanTab => 'Escanear';

  @override
  String get networksTab => 'Redes';

  @override
  String get settingsTab => 'Ajustes';

  @override
  String get printQrReminder =>
      'Recuerda reemplazar la pegatina QR física después de cambiar la contraseña.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get retry => 'Reintentar';

  @override
  String get undo => 'Deshacer';

  @override
  String get delete => 'Eliminar';

  @override
  String get confirmDelete => '¿Eliminar esta red?';

  @override
  String get networkDeleted => 'Red eliminada';

  @override
  String get loading => 'Cargando…';

  @override
  String get writeToNfc => 'Escribir en etiqueta NFC';

  @override
  String get nfcWriteNotSupported =>
      'La escritura NFC no es compatible con este dispositivo';

  @override
  String get nfcTagTooSmall =>
      'Memoria de la etiqueta demasiado pequeña — use NTAG215 o mayor';

  @override
  String get qrManualModeBanner =>
      'NFC no disponible — usa exportación QR o gestiona redes manualmente';

  @override
  String pinLocked(int seconds) {
    return 'PIN bloqueado. Inténtalo en $seconds segundos';
  }

  @override
  String get resetPin => 'Restablecer PIN';

  @override
  String get currentPin => 'PIN actual';

  @override
  String get setPin => 'Establecer PIN';

  @override
  String get confirmPin => 'Confirmar PIN';

  @override
  String get pinsDoNotMatch => 'Los PIN no coinciden';

  @override
  String get pinSetSuccess => 'PIN establecido correctamente';

  @override
  String get pinChangedSuccess => 'PIN cambiado correctamente';

  @override
  String get version => 'Versión';

  @override
  String get aboutFooter => 'Nova Heronix — gestión WiFi interna';

  @override
  String get syncedToTag => 'Sincronizado con etiqueta';

  @override
  String get notYetWritten => 'Aún no escrito';

  @override
  String get passwordStrengthWeak => 'Débil';

  @override
  String get passwordStrengthMedium => 'Media';

  @override
  String get passwordStrengthStrong => 'Fuerte';

  @override
  String get firstLaunchSetPin =>
      'Establece un PIN de administrador de 6 dígitos para proteger acciones sensibles';

  @override
  String get holdPhoneToTag => 'Mantén el teléfono contra la etiqueta';

  @override
  String get writing => 'Escribiendo en la etiqueta…';

  @override
  String get writeSuccess => 'Etiqueta actualizada correctamente';

  @override
  String get invalidTagData => 'Datos inválidos en la etiqueta NFC';

  @override
  String get errorUnrecognisedTag =>
      'Etiqueta no reconocida — no es una etiqueta Nova Heronix';

  @override
  String get errorTagNotWrittenByApp =>
      'Esta etiqueta no fue escrita por Nova Heronix WiFi Manager';

  @override
  String get tagLocked => 'Etiqueta: bloqueada';

  @override
  String get tagWritable => 'Etiqueta: editable';

  @override
  String get lockTag => 'Bloquear etiqueta (solo lectura)';

  @override
  String get lockTagTitle => '¿Bloquear etiqueta NFC?';

  @override
  String get lockTagWarning =>
      'Esta acción es irreversible. La etiqueta no podrá sobrescribirse nunca más.';

  @override
  String get lockTagConfirm => 'Bloquear etiqueta';

  @override
  String get lockTagSuccess => 'Etiqueta bloqueada correctamente';

  @override
  String get lockTagFailed =>
      'No se pudo bloquear la etiqueta en este dispositivo';

  @override
  String get tagPhysicallyLockedBanner =>
      'Esta etiqueta está bloqueada físicamente. Reemplaza la etiqueta para actualizar credenciales.';

  @override
  String get iosGuestQrHint =>
      'En iPhone, los invitados deben escanear la pegatina QR con la app Cámara para unirse al WiFi';

  @override
  String get label => 'Etiqueta de ubicación';

  @override
  String get save => 'Guardar';

  @override
  String get changeAdminPin => 'Cambiar PIN de administrador';

  @override
  String get newPin => 'Nuevo PIN';

  @override
  String get copiedToClipboard => 'Copiado al portapapeles';

  @override
  String get passwordCopied => 'Contraseña copiada';

  @override
  String get done => 'Hecho';

  @override
  String get ok => 'OK';

  @override
  String get confirm => 'Confirmar';

  @override
  String get networkDetails => 'Detalles de red';

  @override
  String get addNetworkTitle => 'Añadir red';

  @override
  String get changePasswordTitle => 'Cambiar contraseña';

  @override
  String get pinMustBeSixDigits => 'El PIN debe tener 6 dígitos';

  @override
  String get enterCurrentPinToReset =>
      'Introduce tu PIN actual para restablecer';

  @override
  String get settingsLocked => 'Introduce el PIN para abrir ajustes';

  @override
  String get exportQrTitle => 'Exportar código QR';

  @override
  String get errorPermissionDenied => 'Permiso denegado';

  @override
  String get errorParseFailed => 'No se pudieron leer los datos de la etiqueta';

  @override
  String get tagReadOnly => 'Etiqueta de solo lectura';

  @override
  String get strengthLabel => 'Fortaleza de contraseña';

  @override
  String get adminSectionTitle => 'Admin de fábrica';

  @override
  String get initializeTag => 'Inicializar etiqueta NFC';

  @override
  String get initializeTagDescription =>
      'Registrar una etiqueta en blanco para Nova Heronix antes de enviar.';

  @override
  String get initializeTagTapPrompt =>
      'Acerca el teléfono a una etiqueta NFC en blanco';

  @override
  String get tagInitializedSuccess =>
      'Etiqueta inicializada, lista para enviar';

  @override
  String get initializeTagNotBlank =>
      'Esta etiqueta no está vacía. Inicializa solo etiquetas vacías; usa Borrar primero si quieres reutilizarla.';

  @override
  String lastInitializedTagId(String tagId) {
    return 'Último ID: $tagId';
  }

  @override
  String get awaitingSetup => 'Pendiente de configuración';

  @override
  String get configured => 'Configurado';

  @override
  String get setupTagTitle => 'Configurar esta etiqueta';

  @override
  String get setupTagDescription =>
      'Introduce el WiFi para la etiqueta escaneada.';

  @override
  String get tagNotProvisioned => 'Etiqueta no inicializada por Nova Heronix.';

  @override
  String get scanToSetupPrompt =>
      'Escanea una etiqueta Nova Heronix para configurar el WiFi';

  @override
  String get noTagsYet => 'No hay etiquetas escaneadas';

  @override
  String tagIdLabel(String tagId) {
    return 'ID de etiqueta: $tagId';
  }

  @override
  String get editCredentialsTitle => 'Editar credenciales WiFi';

  @override
  String get editCredentials => 'Editar SSID y contraseña';

  @override
  String get viewCredentialsPin => 'Introduce el PIN para ver credenciales';

  @override
  String get factoryAdminPin => 'Código de servicio';

  @override
  String get factoryAdminPinTitle => 'Acceso de servicio';

  @override
  String get factoryAdminPinHint =>
      'Introduce el código de servicio para continuar.';

  @override
  String get factoryAdminWrongPin => 'Código de servicio incorrecto';

  @override
  String get factoryAdminTitle => 'Herramientas de servicio';

  @override
  String get factoryAdminDescription =>
      'Aprovisionamiento y mantenimiento de etiquetas.';

  @override
  String get factoryAdminLock => 'Bloquear';

  @override
  String get factoryBrandTagSubtitle =>
      'Preparar etiqueta en blanco para Nova Heronix';

  @override
  String get wipeTagTitle => 'Borrar datos de etiqueta';

  @override
  String get wipeTagDescription =>
      'Eliminar NDEF de una etiqueta Nova Heronix o en blanco.';

  @override
  String get wipeTagTapPrompt => 'Acerca el teléfono a la etiqueta';

  @override
  String get wipeTagSuccess => 'Etiqueta borrada';

  @override
  String get wipeTagFailed => 'No se pudo borrar la etiqueta';

  @override
  String get wipeNotNovaTag =>
      'Solo se pueden borrar etiquetas Nova Heronix o en blanco';

  @override
  String get legacyTagBanner =>
      'Formato antiguo. Reescribe la etiqueta desde los detalles para que los invitados puedan unirse al WiFi.';

  @override
  String get downloadQrPdf => 'Descargar PDF';

  @override
  String get printQr => 'Imprimir QR';

  @override
  String get printQrFailed => 'Impresión no disponible en este dispositivo';

  @override
  String get scanToJoinWifi => 'Escanea para unirte al WiFi';

  @override
  String get scanHeroTitle => 'Toca una etiqueta para escanear';

  @override
  String get scanTagButton => 'Escanear una etiqueta';

  @override
  String get scanHeroSubtitle =>
      'Acerca el teléfono a una etiqueta Nova Heronix para configurar o gestionar WiFi.';

  @override
  String get scanStep1Title => 'Acerca el teléfono a la etiqueta';

  @override
  String get scanStep1Subtitle =>
      'Coloca la parte trasera del teléfono sobre la etiqueta NFC.';

  @override
  String get scanStep2Title => 'La etiqueta se lee automáticamente';

  @override
  String get scanStep2Subtitle =>
      'La app abre la configuración o los detalles de la red.';

  @override
  String get scanStep3Title => 'Los invitados se conectan fácilmente';

  @override
  String get scanStep3Subtitle =>
      'Android: toque NFC; iPhone: escanear la tarjeta QR.';

  @override
  String get setupTagTapPrompt =>
      'Mantén el teléfono en la etiqueta para escribir los datos WiFi';

  @override
  String get qrExportPromptTitle => 'Exportar QR para invitados iPhone';

  @override
  String get qrExportPromptMessage =>
      'Los usuarios de iPhone escanean el QR para unirse al WiFi. ¿Descargar PDF ahora?';

  @override
  String get qrExportPromptDownload => 'Descargar PDF';

  @override
  String get qrExportPromptLater => 'Más tarde';

  @override
  String get preShipChecklistTitle => 'Lista de verificación antes del envío';

  @override
  String get preShipStep1 => 'Inicializar una etiqueta NTAG215 en blanco';

  @override
  String get preShipStep2 => 'Completar la escritura de configuración WiFi';

  @override
  String get preShipStep3 =>
      'Prueba Android: tocar etiqueta — confirmar aviso de unión WiFi (no abrir app)';

  @override
  String get preShipStep4 => 'Exportar PDF QR para invitados iPhone';

  @override
  String get preShipStep5 => 'Opcional: bloquear etiqueta antes del envío';
}
