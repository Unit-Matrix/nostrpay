import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nostr_pay_kids/component_library/component_library.dart';
import 'package:typethis/typethis.dart';

import 'parent_help_screen.dart';

class ExplanationScreen extends StatefulWidget {
  const ExplanationScreen({super.key});

  @override
  State<ExplanationScreen> createState() => _ExplanationScreenState();
}

class _ExplanationScreenState extends State<ExplanationScreen> {
  final TypeThisController _typingController = TypeThisController();
  bool _showContinueButton = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _typingController.reset();

        // Calculate when animation will complete
        const mainText =
            "To start your awesome wallet adventure, you need a special magic code from your parent! 🔐";
        final animationDuration = mainText.length * 80; // 80ms per character

        // Show button and worry container after animation completes
        Future.delayed(Duration(milliseconds: animationDuration + 300), () {
          if (mounted) {
            setState(() {
              _showContinueButton = true;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _typingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) {
          // Navigate directly to welcome screen instead of going back to transition screen
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/intro', (route) => false);
        }
      },
      child: Scaffold(
        appBar: BackButtonAppBar(
          onBackPressed: () {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/intro', (route) => false);
          },
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Main title
                Text(
                  "What's Next?",
                  style: theme.textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Fairy mascot
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: SvgPicture.asset(
                    'assets/mascot/Fairy.svg',
                    width: 180,
                    height: 180,
                  ),
                ),

                const SizedBox(height: 32),

                // Main explanation
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: theme.containerTheme.whiteContainer,
                  child: Column(
                    children: [
                      TypeThis(
                        string:
                            "To start your awesome wallet adventure, you need a special magic code from your parent! 🔐",
                        controller: _typingController,
                        speed: 80,
                        style: theme.textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                        richTextMatchers: const [
                          TypeThisMatcher(
                            'awesome',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.accent,
                            ),
                          ),
                          TypeThisMatcher(
                            'magic code',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_showContinueButton) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F9FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "Don't worry! Your parent will help you ✨",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const Spacer(flex: 3),

                // Continue button - only show when typing is complete
                if (_showContinueButton) ...[
                  PrimaryButton(
                    text: "Got it! Let's continue 🚀",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ParentHelpScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
