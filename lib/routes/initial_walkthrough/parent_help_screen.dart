import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nostr_pay_kids/component_library/component_library.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'code_entry_screen.dart';

class ParentHelpScreen extends StatefulWidget {
  const ParentHelpScreen({super.key});

  @override
  State<ParentHelpScreen> createState() => _ParentHelpScreenState();
}

class _ParentHelpScreenState extends State<ParentHelpScreen> {
  int currentStep = 0;
  final PageController _pageController = PageController();

  final List<StoryStep> steps = [
    StoryStep(
      mascot: 'assets/mascot/Astronaut.svg',
      title: 'Hey there!',
      content:
          'To set up your wallet, we need your parent to help us with something special.',
      isForKids: true,
    ),
    StoryStep(
      mascot: 'assets/mascot/sir.svg',
      title: 'Parents, we need you!',
      content:
          'Your child needs a connection code from your Lightning wallet to get started safely.',
      isForKids: false,
    ),
    StoryStep(
      mascot: 'assets/mascot/Coder.svg',
      title: 'How to get the code',
      content:
          'Open your Lightning wallet app and look for "Connection" or "NWC" settings to generate a code.',
      isForKids: false,
    ),
    StoryStep(
      mascot: 'assets/mascot/Nostrich.svg',
      title: 'Almost ready!',
      content:
          'Once you have the code, we can paste or scan it on the next screen.',
      isForKids: true,
    ),
  ];

  void _nextStep() {
    if (currentStep < steps.length - 1) {
      // setState(() {
      //   currentStep++;
      // });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to code entry screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CodeEntryScreen()),
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
                        color:
                            index <= currentStep
                                ? AppColors.primary
                                : AppColors.primary.withOpacity(0.2),
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
                        const Spacer(flex: 2), // Add flexible space at the top
                        // Mascot
                        Container(
                          width: 240,
                          height: 240,
                          decoration: BoxDecoration(
                            color:
                                step.isForKids
                                    ? AppColors.secondary.withOpacity(0.1)
                                    : AppColors.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color:
                                  step.isForKids
                                      ? AppColors.secondary.withOpacity(0.3)
                                      : AppColors.warning.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: SvgPicture.asset(step.mascot),
                        ),

                        const SizedBox(height: 32), // Reduced fixed space
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

                        const Spacer(
                          flex: 3,
                        ), // Add flexible space at the bottom
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
                  // CHANGE: Removed the SizedBox wrapper to let the button size itself.
                  PrimaryButton(
                    text: currentStep == steps.length - 1 ? 'Ready!' : 'Next',
                    onPressed: _nextStep,
                    fontSize: 16,
                    height: 50, // Keep height for consistency
                    borderRadius: BorderRadius.circular(16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                    ), // Add padding
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

class StoryStep {
  final String mascot;
  final String title;
  final String content;
  final bool isForKids;

  StoryStep({
    required this.mascot,
    required this.title,
    required this.content,
    required this.isForKids,
  });
}
