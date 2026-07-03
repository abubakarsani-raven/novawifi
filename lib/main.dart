import 'package:flutter/material.dart';

import 'app.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await StorageService.init();
    if (const bool.fromEnvironment('SEED_DEMO')) {
      await StorageService.seedDemoNetworks();
    }
  } catch (e) {
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Storage failed to load. Please restart the app.\n\n$e',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    ));
    return;
  }
  runApp(const NovaApp());
}
