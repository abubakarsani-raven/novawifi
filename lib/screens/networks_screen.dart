import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/wifi_network.dart';
import '../services/storage_service.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import 'network_detail_screen.dart';
import 'setup_tag_screen.dart';

class NetworksScreen extends StatefulWidget {
  const NetworksScreen({super.key});

  static Future<void> openTag(BuildContext context, String networkId) async {
    final network = StorageService.getById(networkId);
    if (network == null) return;

    if (network.needsSetup) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => SetupTagScreen(network: network),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => NetworkDetailScreen(network: network),
        ),
      );
    }
  }

  @override
  State<NetworksScreen> createState() => _NetworksScreenState();
}

class _NetworksScreenState extends State<NetworksScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      bottom: false,
      child: ValueListenableBuilder<int>(
        valueListenable: StorageService.networksRevision,
        builder: (context, _, __) {
          final networks = StorageService.getAll();

          if (networks.isEmpty) {
            return _EmptyState(l10n: l10n);
          }

          return ListView.builder(
          padding: AppSpacing.screenPadding.copyWith(
            top: AppSpacing.md,
            bottom: AppSpacing.xl * 2,
          ),
          itemCount: networks.length + 1,
          itemBuilder: (context, index) {
            if (index == networks.length) {
              return Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.swipe_left_outlined,
                      size: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Swipe left to delete',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _NetworkCard(network: networks[index]),
            );
          },
          );
        },
      ),
    );
  }
}

// ──────────────────────── Empty state ──────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEDE9FE), Color(0xFFF3E8FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.wifi_tethering_outlined,
                size: 48,
                color: AppTheme.brandPurple,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No tags yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Write your first WiFi tag from the Home tab.\nThen it will appear here.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────── Network card ─────────────────────────────────────

class _NetworkCard extends StatelessWidget {
  const _NetworkCard({required this.network});
  final WifiNetwork network;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Dismissible(
      key: ValueKey(network.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.md),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.delete_outline, color: Colors.white, size: 22),
            const SizedBox(height: 4),
            Text(
              'Delete',
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      onDismissed: (_) async {
        final deleted = network;
        await StorageService.delete(deleted.id);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.networkDeleted),
            action: SnackBarAction(
              label: l10n.undo,
              onPressed: () async => StorageService.upsert(deleted),
            ),
          ),
        );
      },
      child: _CardBody(network: network, l10n: l10n),
    );
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody({required this.network, required this.l10n});
  final WifiNetwork network;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (statusColor, statusBg, statusIcon, statusLabel) = _status(l10n);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => NetworksScreen.openTag(context, network.id),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.brandOutline),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // WiFi icon bubble
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7C3AED), Color(0xFFA855F7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(Icons.wifi, size: 22, color: Colors.white),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          network.label.isNotEmpty
                              ? network.label
                              : network.ssid,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (network.label.isNotEmpty && !network.needsSetup)
                          Text(
                            network.ssid,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (network.needsSetup)
                          Text(
                            l10n.awaitingSetup,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.brandAmber,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: AppTheme.brandPurple,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              const Divider(height: 1),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  _Chip(
                    color: statusColor,
                    bg: statusBg,
                    icon: statusIcon,
                    label: statusLabel,
                  ),
                  if (network.tagLocked) ...[
                    const SizedBox(width: AppSpacing.xs),
                    _Chip(
                      color: const Color(0xFF6D28D9),
                      bg: const Color(0xFFEDE9FE),
                      icon: Icons.lock_outline,
                      label: 'Locked',
                    ),
                  ],
                  const Spacer(),
                  Text(
                    network.securityType,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  (Color, Color, IconData, String) _status(AppLocalizations l10n) {
    if (network.needsSetup) {
      return (
        AppTheme.brandAmber,
        const Color(0xFFFEF3C7),
        Icons.hourglass_top_outlined,
        l10n.awaitingSetup,
      );
    }
    if (network.writtenToTag) {
      return (
        AppTheme.brandGreen,
        const Color(0xFFD1FAE5),
        Icons.check_circle_outline,
        l10n.syncedToTag,
      );
    }
    return (
      const Color(0xFFF59E0B),
      const Color(0xFFFEF3C7),
      Icons.pending_outlined,
      l10n.notYetWritten,
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.color,
    required this.bg,
    required this.icon,
    required this.label,
  });
  final Color color;
  final Color bg;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
