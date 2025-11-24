import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nostr_pay_kids/component_library/component_library.dart';
import 'package:flutter_confetti/flutter_confetti.dart';
import 'ecash_home_screen.dart';

class CreateEcashSuccessScreen extends StatefulWidget {
  const CreateEcashSuccessScreen({super.key});

  @override
  State<CreateEcashSuccessScreen> createState() =>
      _CreateEcashSuccessScreenState();
}

class _CreateEcashSuccessScreenState extends State<CreateEcashSuccessScreen> {
  @override
  void initState() {
    super.initState();
    // Launch confetti after a short delay when screen appears
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        Confetti.launch(
          context,
          options: const ConfettiOptions(
            particleCount: 120,
            spread: 80,
            y: 0.5,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Success title
              Text(
                'Your Ecash is ready!',
                style: theme.textTheme.headlineLarge?.copyWith(fontSize: 32),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Success mascot
              SizedBox(
                width: 200,
                height: 200,
                child: Center(
                  child: SvgPicture.asset('assets/mascot/Robe.svg'),
                ),
              ),

              const SizedBox(height: 24),

              // Success message
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: theme.containerTheme.whiteContainer,
                child: Column(
                  children: [
                    Text(
                      'You can use it even without internet!',
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Ecash visual representation
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.payments,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '21 sats',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ready to Use',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 3),

              // View Ecash button
              PrimaryButton(
                text: 'View My Ecash',
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EcashHomeScreen(),
                    ),
                  );
                },
                backgroundColor: AppColors.success,
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
