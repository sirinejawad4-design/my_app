import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../generated/app_colors.dart';
import '../../../../../generated/style_atoms.dart';
import '../../../../core/widgets/custom_button.dart';

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
      'title': 'Find Trusted Doctors',
      'description':
          'Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of over 2000 years old.',
      'buttonText': 'Next',
    },
    {
      'title': 'Choose Best Doctors',
      'description':
          'Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of over 2000 years old.',
      'buttonText': 'Next',
    },
    {
      'title': 'Easy Appointments',
      'description':
          'Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of over 2000 years old.',
      'buttonText': 'Get Started',
    },
  ];

  void _onNextPressed() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/choose-role');
    }
  }

  void _onSkipPressed() {
    context.go('/choose-role');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
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
                        Container(
                          width: 220,
                          height: 220,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          page['title']!,
                          textAlign: TextAlign.center,
                          style: context.bold22TextMain,
                        ),
                        const SizedBox(height: 12),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: CustomButton(
                text: _pages[_currentPage]['buttonText']!,
                onPressed: _onNextPressed,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _onSkipPressed,
              child: Text(
                'Skip',
                style: context.regular14TextSub,
              ),
            ),
          ],
        ),
      ),
    );
  }
}