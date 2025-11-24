import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nostr_pay_kids/component_library/component_library.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_pay_kids/cubit/account/account_cubit.dart';
import 'package:nostr_pay_kids/cubit/account/account_state.dart';
import 'create_ecash_processing_screen.dart';

class CreateEcashConfirmationScreen extends StatelessWidget {
  const CreateEcashConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: BackButtonAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Title
              Text(
                'Ready to create your Ecash?',
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Mascot
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: SvgPicture.asset('assets/mascot/cat-two.svg'),
              ),

              const SizedBox(height: 32),

              // Information card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: theme.containerTheme.whiteContainer,
                child: Column(
                  children: [
                    // Cost
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.payments,
                            color: AppColors.success,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cost',
                              style: theme.textTheme.bodySmall,
                            ),
                            Text(
                              '21 sats',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Current balance
                    BlocBuilder<AccountCubit, AccountState>(
                      builder: (context, state) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet,
                                color: AppColors.accent,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your balance',
                                  style: theme.textTheme.bodySmall,
                                ),
                                Text(
                                  '${state.balance} sats',
                                  style: theme.textTheme.titleLarge,
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),

                    // TODO: Show "You'll have X Ecash after this" when we have Ecash list
                  ],
                ),
              ),

              const Spacer(flex: 3),

              // Action buttons
              Column(
                children: [
                  PrimaryButton(
                    text: 'Create My Ecash!',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const CreateEcashProcessingScreen(),
                        ),
                      );
                    },
                    backgroundColor: AppColors.success,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
