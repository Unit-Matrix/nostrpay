import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nostr_pay_kids/component_library/component_library.dart';
import 'package:nostr_pay_kids/cubit/account/account_cubit.dart';
import 'package:nostr_pay_kids/cubit/account/account_state.dart';
import 'package:nostr_pay_kids/routes/initial_walkthrough/name_prompt_screen.dart';
import 'package:flutter_confetti/flutter_confetti.dart';

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({super.key});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
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
                'All Set!',
                style: theme.textTheme.headlineLarge?.copyWith(fontSize: 32),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Success mascot
              SizedBox(
                width: 200,
                height: 200,
                child: Center(
                  child: SvgPicture.asset('assets/mascot/Banjo-bitcoin.svg'),
                ),
              ),

              SizedBox(height: 24),

              // Success message
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: theme.containerTheme.whiteContainer,
                child: Column(
                  children: [
                    Text(
                      'Your wallet is ready!',
                      style: theme.textTheme.titleLarge?.copyWith(fontSize: 22),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'You can now explore, save, and spend your sats safely.',
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),

              // Balance display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.bolt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    BlocBuilder<AccountCubit, AccountState>(
                      builder: (context, state) {
                        return Text(
                          '${state.balance} sats',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: 18,
                            color: AppColors.success,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 3),

              // Start exploring button
              PrimaryButton(
                text: 'Start Exploring!',
                onPressed: () {
                  // Navigate to main app
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NamePromptScreen(),
                    ),
                    (route) => false,
                  );
                },
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
