import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/nfc_service.dart';
import '../services/storage_service.dart';
import '../widgets/nova_sheet.dart';

/// Saves a scanned tag and returns navigation intent for the host screen.
class NfcTagRouter {
  NfcTagRouter._();

  static Future<NfcTagRoute?> handleRead(
    BuildContext context,
    NfcReadResult result,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    switch (result.status) {
      case NfcReadStatus.success:
        final network = result.network!;
        final existing = StorageService.getById(network.id);
        final toSave = (existing != null
                ? network.copyWith(
                    label: network.label.isNotEmpty
                        ? network.label
                        : existing.label,
                    tagLocked: existing.tagLocked,
                    tagProvisioned: true,
                    isConfigured: network.isConfigured,
                    writtenToTag: true,
                  )
                : network.copyWith(
                    tagProvisioned: true,
                    writtenToTag: true,
                  ))
            .copyWith(updatedAt: DateTime.now());
        await StorageService.upsert(toSave);

        if (toSave.needsSetup) {
          return NfcTagRoute.setup(
            toSave.id,
            isLegacyFormat: result.isLegacyFormat,
          );
        }
        if (toSave.isConfigured) {
          return NfcTagRoute.network(
            toSave.id,
            isLegacyFormat: result.isLegacyFormat,
          );
        }
        if (context.mounted) {
          await NovaErrorSheet.show(
            context,
            title: l10n.errorUnrecognisedTag,
            message: l10n.tagNotProvisioned,
          );
        }
        return null;

      case NfcReadStatus.notAvailable:
        return null;
      case NfcReadStatus.unrecognisedTag:
        if (context.mounted) {
          await NovaErrorSheet.show(
            context,
            title: l10n.errorUnrecognisedTag,
            message: l10n.errorUnrecognisedTag,
          );
        }
        return null;
      case NfcReadStatus.notWrittenByApp:
        if (context.mounted) {
          await NovaErrorSheet.show(
            context,
            title: l10n.errorTagNotWrittenByApp,
            message: l10n.errorTagNotWrittenByApp,
          );
        }
        return null;
      case NfcReadStatus.parseError:
        if (context.mounted) {
          await NovaErrorSheet.show(
            context,
            title: l10n.invalidTagData,
            message: l10n.errorParseFailed,
          );
        }
        return null;
      case NfcReadStatus.tagNotFound:
        if (context.mounted) {
          await NovaErrorSheet.show(
            context,
            title: l10n.errorTagNotFound,
            message: l10n.errorTagNotFound,
          );
        }
        return null;
    }
  }
}

class NfcTagRoute {
  const NfcTagRoute._(
    this.networkId,
    this.forSetup, {
    this.isLegacyFormat = false,
  });

  final String networkId;
  final bool forSetup;
  final bool isLegacyFormat;

  factory NfcTagRoute.setup(
    String networkId, {
    bool isLegacyFormat = false,
  }) =>
      NfcTagRoute._(networkId, true, isLegacyFormat: isLegacyFormat);

  factory NfcTagRoute.network(
    String networkId, {
    bool isLegacyFormat = false,
  }) =>
      NfcTagRoute._(networkId, false, isLegacyFormat: isLegacyFormat);
}
