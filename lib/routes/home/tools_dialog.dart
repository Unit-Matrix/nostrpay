import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_pay_kids/component_library/component_library.dart';
import 'package:nostr_pay_kids/cubit/ecash/ecash_cubit.dart';
import 'package:nostr_pay_kids/cubit/ecash/ecash_state.dart';
import 'package:nostr_pay_kids/routes/offline_cash/offline_cash_explanation_screen.dart';
import 'package:nostr_pay_kids/routes/offline_cash/ecash_home_screen.dart';

class ToolsDialog extends StatelessWidget {
  const ToolsDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ToolsDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Text(
              'Tools for Kids',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Tools grid - using a 3-column layout for consistent alignment
            Column(
              children: [
                // First row - 3 items
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildToolItem(
                      theme: theme,
                      icon: Icons.payments,
                      label: 'Ecash',
                      color: AppColors.success,
                      onTap: () {
                        Navigator.pop(context);
                        _handleEcashToolTap(context);
                      },
                    ),
                    _buildToolItem(
                      theme: theme,
                      icon: Icons.lock_clock_rounded,
                      label: 'Timelock Sats',
                      color: AppColors.primary,
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Navigate to Timelock Sats screen
                      },
                    ),
                    _buildToolItem(
                      theme: theme,
                      icon: Icons.smart_toy_rounded,
                      label: 'AI Savings Buddy',
                      color: AppColors.secondary,
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Navigate to AI Savings Buddy screen
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Second row - 2 items with proper spacing to align with first row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildToolItem(
                      theme: theme,
                      icon: Icons.track_changes_rounded,
                      label: 'Sats Goals',
                      color: AppColors.pinkSalmon,
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Navigate to Sats Goals Tracker screen
                      },
                    ),
                    _buildToolItem(
                      theme: theme,
                      icon: Icons.park_rounded,
                      label: 'Bitcoin Quiz',
                      color: AppColors.anakiwa,
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Navigate to Bitcoin Quiz Master screen
                      },
                    ),
                    _buildToolItem(
                      theme: theme,
                      icon: Icons.bolt,
                      label: 'Coming Soon',
                      color: AppColors.warning,
                      onTap: () {
                        // Coming soon - no action
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _handleEcashToolTap(BuildContext context) async {
    final ecashCubit = context.read<EcashCubit>();
    final currentState = ecashCubit.state;

    // Check if user has any Ecash items (used or unused)
    final hasEcashItems = currentState.ecashItems.isNotEmpty;

    if (hasEcashItems) {
      // User has Ecash items, navigate directly to EcashHomeScreen
      // Ensure CDK is initialized first
      if (currentState.initializationState !=
          EcashInitializationState.initialized) {
        final navigator = Navigator.of(context);
        final loaderRoute = createLoaderRoute(context);
        navigator.push(loaderRoute);

        try {
          await ecashCubit.initialize();
          if (context.mounted) {
            navigator.pushReplacement(
              MaterialPageRoute(
                builder: (context) => const EcashHomeScreen(),
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            showErrorDialog(
              context,
              title: 'Failed to initialize Ecash',
              message: 'Error: $e',
            );
          }
        } finally {
          if (context.mounted) {
            navigator.removeRoute(loaderRoute);
          }
        }
      } else {
        // Already initialized, navigate directly
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const EcashHomeScreen(),
          ),
        );
      }
    } else {
      // User is new, show explanation screen and initialize
      final navigator = Navigator.of(context);
      final loaderRoute = createLoaderRoute(context);
      navigator.push(loaderRoute);

      try {
        await ecashCubit.initialize();
        if (context.mounted) {
          navigator.pushReplacement(
            MaterialPageRoute(
              builder: (context) => const OfflineCashExplanationScreen(),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          showErrorDialog(
            context,
            title: 'Failed to initialize Ecash',
            message: 'Error: $e',
          );
        }
      } finally {
        if (context.mounted) {
          navigator.removeRoute(loaderRoute);
        }
      }
    }
  }

  static Widget _buildToolItem({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: SizedBox(
        width: 80, // Fixed width for consistent alignment
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: color.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textBody,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
