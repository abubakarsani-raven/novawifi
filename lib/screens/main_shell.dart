import 'dart:io';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/wifi_network.dart';
import '../services/deep_link_bridge.dart';
import '../services/factory_admin_session.dart';
import '../services/nfc_launch_bridge.dart';
import '../services/nfc_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../utils/nfc_tag_router.dart';
import 'network_detail_screen.dart';
import 'networks_screen.dart';
import 'scan_screen.dart';
import 'settings_screen.dart';
import 'setup_tag_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  static final GlobalKey<MainShellState> shellKey = GlobalKey<MainShellState>();

  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> with WidgetsBindingObserver {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (Platform.isAndroid) {
      NfcLaunchBridge.init(_handleNfcLaunch);
    }
    if (Platform.isIOS) {
      DeepLinkBridge.init(_handleDeepLink);
    }
  }

  @override
  void dispose() {
    if (Platform.isAndroid) {
      NfcLaunchBridge.dispose();
    }
    if (Platform.isIOS) {
      DeepLinkBridge.dispose();
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Handles a Universal Link from a tapped provisioned tag (iOS). The `t`
  /// query carries the tag id; if it isn't stored yet we provision it locally
  /// and open its setup form.
  Future<void> _handleDeepLink(Uri uri) async {
    if (!mounted) return;
    if (!uri.path.contains('wifi')) return;
    final tagId = uri.queryParameters['t'];
    if (tagId == null || tagId.isEmpty) return;

    var network = StorageService.getById(tagId);
    if (network == null) {
      network = WifiNetwork.createProvisioned(id: tagId);
      await StorageService.upsert(network);
    }
    if (!mounted) return;
    switchToTab(0);
    _openTagById(network.id, forSetup: network.needsSetup);
  }

  Future<void> _handleNfcLaunch(NfcReadResult result) async {
    if (!mounted) return;
    if (NfcService.sessionBusy) return;
    switchToTab(0);
    final route = await NfcTagRouter.handleRead(context, result);
    if (route != null && mounted) {
      if (route.isLegacyFormat) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.legacyTagBanner),
            duration: const Duration(seconds: 6),
          ),
        );
      }
      _openTagById(route.networkId, forSetup: route.forSetup);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      FactoryAdminSession.lock();
    }
  }

  void switchToTab(int index) {
    setState(() => _currentIndex = index);
  }

  void _openTagById(String networkId, {required bool forSetup}) {
    final network = StorageService.getById(networkId);
    if (network == null || !mounted) return;

    switchToTab(1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (forSetup || network.needsSetup) {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.brandBackground,
      body: IndexedStack(
        index: _currentIndex,
        sizing: StackFit.expand,
        children: [
          ScanScreen(
            active: _currentIndex == 0,
            onNavigateToNetwork: (id) => _openTagById(id, forSetup: false),
            onNavigateToSetup: (id) => _openTagById(id, forSetup: true),
          ),
          const NetworksScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppTheme.brandOutline)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          labelBehavior:
              NavigationDestinationLabelBehavior.onlyShowSelected,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded),
              label: 'Home',
              tooltip: 'Home',
            ),
            NavigationDestination(
              icon: const Icon(Icons.wifi_outlined),
              selectedIcon: const Icon(Icons.wifi_rounded),
              label: l10n.networksTab,
              tooltip: l10n.networksTab,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings_rounded),
              label: l10n.settingsTab,
              tooltip: l10n.settingsTab,
            ),
          ],
        ),
      ),
    );
  }
}
