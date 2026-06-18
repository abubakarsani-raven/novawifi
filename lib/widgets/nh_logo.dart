import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class NhLogo extends StatelessWidget {
  const NhLogo({super.key, this.size = 36});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppTheme.brandPurple,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.brandPurple.withValues(alpha: 0.25),
              blurRadius: size * 0.15,
              offset: Offset(0, size * 0.06),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'NH',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: size * 0.34,
              letterSpacing: -0.5,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}
