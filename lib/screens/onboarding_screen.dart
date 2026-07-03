import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/storage_service.dart';
import '../theme/app_components.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../widgets/onboarding_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    await StorageService.setOnboardingCompleted();
    if (mounted) Navigator.of(context).pop();
  }

  void _next(AppLocalizations l10n) {
    if (_page >= 2) {
      _complete();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.brandBackground,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _complete,
                child: Text(l10n.onboardingSkip),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  OnboardingPage(
                    icon: Icons.nfc_rounded,
                    title: l10n.onboardingPage1Title,
                    body: l10n.onboardingPage1Body,
                    color: AppTheme.brandPurple,
                  ),
                  OnboardingPage(
                    icon: Icons.wifi_rounded,
                    title: l10n.onboardingPage2Title,
                    body: l10n.onboardingPage2Body,
                    color: AppTheme.brandAmber,
                  ),
                  OnboardingPage(
                    icon: Icons.qr_code_2_rounded,
                    title: l10n.onboardingPage3Title,
                    body: l10n.onboardingPage3Body,
                    color: AppTheme.brandGreen,
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                final active = i == _page;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active
                        ? AppTheme.brandPurple
                        : AppTheme.brandOutline,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: AppSpacing.screenPadding,
              child: Semantics(
                button: true,
                label: _page >= 2
                    ? l10n.onboardingGetStarted
                    : l10n.onboardingNext,
                child: NovaPrimaryButton(
                  label: _page >= 2
                      ? l10n.onboardingGetStarted
                      : l10n.onboardingNext,
                  onPressed: () => _next(l10n),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}
