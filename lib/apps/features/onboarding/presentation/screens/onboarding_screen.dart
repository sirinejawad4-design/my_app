import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../generated/app_colors.dart';
import '../../../../../generated/style_atoms.dart';
import '../../../../core/widgets/custom_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'image': 'assets/images/images.jpg',
      'title': 'Find Trusted Doctors',
      'description':
          'Find trusted doctors near you and get the care you need from qualified healthcare professionals.',
      'buttonText': 'Next',
    },
    {
      'image': 'assets/images/onboarding_2.jpg',
      'title': 'Choose Best Doctors',
      'description':
          'Choose the right doctor based on their specialty, experience, and availability.',
      'buttonText': 'Next',
    },
    {
      'image': 'assets/images/onboarding_3.jpg',
      'title': 'Easy Appointments',
      'description':
          'Book your appointment easily and manage your healthcare anytime, anywhere.',
      'buttonText': 'Get Started',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('onboarding_completed', true);

  if (mounted) {
    context.go('/choose-role');
  }
}

void _onNextPressed() {
  if (_currentPage < _pages.length - 1) {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  } else {
    _completeOnboarding();
  }
}

void _onSkipPressed() {
  _completeOnboarding();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ============================================================
            // PAGE VIEW
            // ============================================================
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ==================================================
                        // IMAGE
                        // ==================================================
                        SizedBox(
                          width: 260,
                          height: 260,
                          child: Image.asset(
                            page['image']!,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: AppColors.grey100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 60,
                                  color: AppColors.textSub,
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 36),

                        // ==================================================
                        // TITLE
                        // ==================================================
                        Text(
                          page['title']!,
                          textAlign: TextAlign.center,
                          style: context.bold22TextMain,
                        ),

                        const SizedBox(height: 12),

                        // ==================================================
                        // DESCRIPTION
                        // ==================================================
                        Text(
                          page['description']!,
                          textAlign: TextAlign.center,
                          style: context.regular14TextSub,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ============================================================
            // PAGE INDICATORS
            // ============================================================
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppColors.primary
                        : AppColors.textBorders,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ============================================================
            // NEXT / GET STARTED BUTTON
            // ============================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: CustomButton(
                text: _pages[_currentPage]['buttonText']!,
                onPressed: _onNextPressed,
              ),
            ),

            const SizedBox(height: 12),

            // ============================================================
            // SKIP
            // ============================================================
            TextButton(
              onPressed: _onSkipPressed,
              child: Text('Skip', style: context.regular14TextSub),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
