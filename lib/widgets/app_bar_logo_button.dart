import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/factory_admin_entry.dart';
import 'nh_logo.dart';

/// NH logo in the app bar with a reliable long-press for hidden service access.
class AppBarLogoButton extends StatelessWidget {
  const AppBarLogoButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Nova Heronix',
      child: SizedBox(
        width: 56,
        height: kToolbarHeight,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onLongPress: () {
            HapticFeedback.mediumImpact();
            FactoryAdminEntry.open(context, requireUserPinFirst: false);
          },
          child: const Center(
            child: NhLogo(size: 34),
          ),
        ),
      ),
    );
  }
}
