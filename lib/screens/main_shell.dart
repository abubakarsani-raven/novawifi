import 'dart:io';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/wifi_network.dart';
import '../services/deep_link_bridge.dart';
import '../services/factory_admin_session.dart';
import '../services/nfc_launch_bridge.dart';
import '../services/nfc_service.dart';
import '../services/storage_service.dart';
import '../utils/nfc_tag_router.dart';
import '../utils/tag_navigation.dart';
import 'networks_screen.dart';
import 'onboarding_screen.dart';
import 'scan_screen.dart';
import 'settings_screen.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeShowOnboarding();
    });
  }

  Future<void> _maybeShowOnboarding() async {
    if (!mounted) return;
    if (await StorageService.hasCompletedOnboarding()) return;
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => const OnboardingScreen(),
      ),
    );
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
    await TagNavigation.openTagWithNetwork(
      context,
      network,
      forSetup: network.needsSetup,
    );
  }

  Future<void> _handleNfcLaunch(NfcReadResult result) async {
    if (!mounted) return;
    if (NfcService.sessionBusy) return;
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
      await TagNavigation.openTag(
        context,
        route.networkId,
      );
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

  void startHomeScan() {
    switchToTab(0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScanScreen.scanKey.currentState?.startScan();
    });
  }

  Future<void> _openTagById(String networkId, {required bool forSetup}) async {
    final network = StorageService.getById(networkId);
    if (network == null || !mounted) return;
    await TagNavigation.openTagWithNetwork(
      context,
      network,
      forSetup: forSetup,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final surface = Theme.of(context).colorScheme.surface;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: IndexedStack(
        index: _currentIndex,
        sizing: StackFit.expand,
        children: [
          ScanScreen(
            key: ScanScreen.scanKey,
            active: _currentIndex == 0,
            onNavigateToNetwork: (id) => _openTagById(id, forSetup: false),
            onNavigateToSetup: (id) => _openTagById(id, forSetup: true),
            onViewNetworks: () => switchToTab(1),
          ),
          NetworksScreen(onScanFirstTag: startHomeScan),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: surface,
          border: Border(
            top: BorderSide(color: Theme.of(context).colorScheme.outline),
          ),
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
              label: l10n.homeTab,
              tooltip: l10n.homeTab,
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
