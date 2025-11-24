import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nostr_pay_kids/component_library/component_library.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'create_ecash_confirmation_screen.dart';

class OfflineCashExplanationScreen extends StatefulWidget {
  const OfflineCashExplanationScreen({super.key});

  @override
  State<OfflineCashExplanationScreen> createState() =>
      _OfflineCashExplanationScreenState();
}

class _OfflineCashExplanationScreenState
    extends State<OfflineCashExplanationScreen> {
  int currentStep = 0;
  final PageController _pageController = PageController();

  final List<ExplanationStep> steps = [
    ExplanationStep(
      mascot: 'assets/mascot/Pyro.svg',
      title: 'Meet Ecash!',
      content:
          'Ecash is like real cash, but on your phone! You can use it to pay even without internet!',
      isForKids: true,
    ),
    ExplanationStep(
      mascot: 'assets/mascot/cat-two.svg',
      title: 'How it works',
      content:
          'Each cash is worth 21 sats. You create it using sats from your connected wallet, and then you can use it anywhere!',
      isForKids: true,
    ),
    ExplanationStep(
      mascot: 'assets/mascot/Satoshi.svg',
      title: 'Works without internet!',
      content:
          'Once you create your Ecash, it\'s stored on your phone. You can show the Ecash code to pay, even without internet!',
      isForKids: true,
    ),
    ExplanationStep(
      mascot: 'assets/mascot/The-unstoppable.svg',
      title: 'Ready to create?',
      content:
          'Let\'s create your first Ecash! You\'ll need internet to create it, but after that, you can use it anywhere!',
      isForKids: true,
    ),
  ];

  void _nextStep() {
    if (currentStep < steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CreateEcashConfirmationScreen(),
        ),
      );
    }
  }

  void _previousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: BackButtonAppBar(onBackPressed: _previousStep),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: List.generate(steps.length, (index) {
                  return Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: index <= currentStep
                            ? AppColors.success
                            : AppColors.success.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Story content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    currentStep = index;
                  });
                },
                itemCount: steps.length,
                itemBuilder: (context, index) {
                  final step = steps[index];
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Spacer(flex: 2),
                        // Mascot
                        Container(
                          width: 240,
                          height: 240,
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.success.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: SvgPicture.asset(step.mascot),
                        ),

                        const SizedBox(height: 32),
                        // Title
                        Text(
                          step.title,
                          style: theme.textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 24),

                        // Content with AutoSizeText
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: theme.containerTheme.whiteContainer,
                          child: AutoSizeText(
                            step.content,
                            style: theme.textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                            maxLines: 4,
                            minFontSize: 14,
                            maxFontSize: 18,
                            stepGranularity: 1,
                          ),
                        ),

                        const Spacer(flex: 3),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom navigation
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Text(
                    '${currentStep + 1} of ${steps.length}',
                    style: theme.textTheme.bodySmall,
                  ),
                  const Spacer(),
                  PrimaryButton(
                    text: currentStep == steps.length - 1
                        ? 'Create Ecash!'
                        : 'Next',
                    onPressed: _nextStep,
                    fontSize: 16,
                    height: 50,
                    borderRadius: BorderRadius.circular(16),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    backgroundColor: currentStep == steps.length - 1
                        ? AppColors.success
                        : AppColors.secondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExplanationStep {
  final String mascot;
  final String title;
  final String content;
  final bool isForKids;

  ExplanationStep({
    required this.mascot,
    required this.title,
    required this.content,
    required this.isForKids,
  });
}
