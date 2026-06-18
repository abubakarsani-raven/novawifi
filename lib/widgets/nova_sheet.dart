import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_spacing.dart';

/// Shared modal bottom sheet presentation for Nova.
class NovaSheet {
  NovaSheet._();

  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      useSafeArea: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: child,
      ),
    );
  }
}

class NovaSheetScaffold extends StatelessWidget {
  const NovaSheetScaffold({
    super.key,
    required this.title,
    required this.body,
    this.icon,
    this.iconColor,
    this.actions = const [],
  });

  final String title;
  final Widget body;
  final IconData? icon;
  final Color? iconColor;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (icon != null) ...[
            Icon(icon, color: iconColor ?? theme.colorScheme.error, size: 36),
            const SizedBox(height: AppSpacing.sm),
          ],
          Text(
            title,
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          body,
          if (actions.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            ...actions,
          ],
        ],
      ),
    );
  }
}

class NovaConfirmSheet {
  NovaConfirmSheet._();

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmLabel,
    String? cancelLabel,
    bool isDestructive = false,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await NovaSheet.show<bool>(
      context,
      child: NovaSheetScaffold(
        title: title,
        body: Text(
          message,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: isDestructive
                ? FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                  )
                : null,
            child: Text(confirmLabel ?? l10n.confirm),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelLabel ?? l10n.cancel),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

class NovaErrorSheet {
  NovaErrorSheet._();

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onRetry,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return NovaSheet.show<void>(
      context,
      child: NovaSheetScaffold(
        title: title,
        icon: Icons.error_outline,
        body: Text(
          message,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        actions: [
          if (onRetry != null)
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                onRetry();
              },
              child: Text(l10n.retry),
            ),
          if (onRetry != null) const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }
}
