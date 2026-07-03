import 'package:flutter/material.dart';

import '../models/wifi_network.dart';
import '../screens/network_detail_screen.dart';
import '../screens/setup_tag_screen.dart';
import '../services/storage_service.dart';

/// Centralized navigation for opening a tag by ID.
///
/// Pushes setup or detail on the nearest [Navigator] without switching tabs.
/// NFC intents, deep links, Home scan, and Networks list should all use this.
class TagNavigation {
  TagNavigation._();

  static Future<void> openTag(BuildContext context, String networkId) async {
    final network = StorageService.getById(networkId);
    if (network == null) return;

    if (network.needsSetup) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => SetupTagScreen(network: network),
        ),
      );
    } else {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => NetworkDetailScreen(network: network),
        ),
      );
    }
  }

  static Future<void> openTagWithNetwork(
    BuildContext context,
    WifiNetwork network, {
    required bool forSetup,
  }) async {
    if (forSetup || network.needsSetup) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => SetupTagScreen(network: network),
        ),
      );
    } else {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => NetworkDetailScreen(network: network),
        ),
      );
    }
  }
}
