import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:nostr_pay_kids/component_library/component_library.dart';
import 'package:nostr_pay_kids/models/ecash_item.dart';
import 'package:nostr_pay_kids/cubit/ecash/ecash_cubit.dart';
import 'package:nostr_pay_kids/cubit/ecash/ecash_state.dart';
import 'package:nostr_pay_kids/cubit/connectivity/connectivity_cubit.dart';
import 'ecash_qr_view_screen.dart';
import 'create_ecash_confirmation_screen.dart';

class EcashHomeScreen extends StatefulWidget {
  const EcashHomeScreen({super.key});

  @override
  State<EcashHomeScreen> createState() => _EcashHomeScreenState();
}

class _EcashHomeScreenState extends State<EcashHomeScreen> {
  bool _showUsedEcash = false;

  List<EcashItem> _getReadyEcash(Set<EcashItem> items) =>
      items.where((item) => item.status == EcashStatus.ready).toList();

  List<EcashItem> _getUsedEcash(Set<EcashItem> items) =>
      items.where((item) => item.status == EcashStatus.used).toList();

  int _getTotalReadySats(List<EcashItem> readyItems) =>
      readyItems.fold(0, (sum, item) => sum + item.amount);

  void _markAsUsed(EcashItem item) {
    context.read<EcashCubit>().markEcashAsUsed(item.id);
  }

  void _unmarkAsUsed(EcashItem item) {
    context.read<EcashCubit>().unmarkEcash(item.id);
  }

  void _showUnmarkWarning(EcashItem item) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text('Unmark Ecash?', style: theme.textTheme.titleLarge),
        content: Text(
          'If this Ecash was already redeemed, it won\'t work. Are you sure you want to unmark it?',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _unmarkAsUsed(item);
            },
            child: Text(
              'Unmark',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    return timeago.format(dateTime, locale: 'en_short');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppPageScaffold(
      title: 'My Ecash',
      showBackButton: true,
      actions: [
        IconButton(
          onPressed: () {
            // TODO: Show help dialog explaining Ecash
          },
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.help_outline,
              color: AppColors.accent,
              size: 20,
            ),
          ),
        ),
      ],
      body: BlocBuilder<EcashCubit, EcashState>(
        builder: (context, state) {
          final ecashItems = state.ecashItems.toList();
          final readyEcash = _getReadyEcash(state.ecashItems);
          final usedEcash = _getUsedEcash(state.ecashItems);
          final totalReadySats = _getTotalReadySats(readyEcash);

          return ecashItems.isEmpty
              ? _buildEmptyState(theme)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Header stats with Create button
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: theme.containerTheme.whiteContainer,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.accent.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.payments,
                                  color: AppColors.accent,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'You have ${readyEcash.length} Ecash',
                                      style: theme.textTheme.titleLarge,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Total: $totalReadySats sats ready to use',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Create New Ecash button in header - only show when online and CDK initialized
                          BlocBuilder<ConnectivityCubit, ConnectivityState>(
                            builder: (context, connectivityState) {
                              final hasInternet =
                                  connectivityState.hasNetworkConnection;
                              final isCdkInitialized =
                                  state.initializationState ==
                                      EcashInitializationState.initialized;
                              final canCreateEcash =
                                  hasInternet && isCdkInitialized;

                              if (!canCreateEcash) {
                                return const SizedBox.shrink();
                              }

                              return SizedBox(
                                width: double.infinity,
                                child: PrimaryButton(
                                  text: 'Create New Ecash',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const CreateEcashConfirmationScreen(),
                                      ),
                                    );
                                  },
                                  backgroundColor: AppColors.primary,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Ready Ecash section
                    if (readyEcash.isNotEmpty) ...[
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.check_circle,
                              color: AppColors.success,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Ready to Use',
                            style: theme.textTheme.titleLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...readyEcash.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return _buildEcashCard(item, theme, index);
                      }),
                      const SizedBox(height: 24),
                    ],

                    // Used Ecash section (collapsible)
                    if (usedEcash.isNotEmpty) ...[
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showUsedEcash = !_showUsedEcash;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.textSecondary
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.history,
                                  color: AppColors.textSecondary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Used Ecash',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                _showUsedEcash
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_showUsedEcash) ...[
                        const SizedBox(height: 8),
                        ...usedEcash.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          return _buildEcashCard(item, theme, index);
                        }),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ],
                );
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Mascot
          SizedBox(
            width: 200,
            height: 200,
            child: SvgPicture.asset('assets/mascot/Pyro.svg'),
          ),
          const SizedBox(height: 32),
          // Message
          Text(
            'You don\'t have any Ecash yet!',
            style: theme.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: theme.containerTheme.whiteContainer,
            child: Text(
              'Create your first Ecash to pay offline!',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          // Create button - only show when online and CDK initialized
          BlocBuilder<ConnectivityCubit, ConnectivityState>(
            builder: (context, connectivityState) {
              final ecashState = context.watch<EcashCubit>().state;
              final hasInternet = connectivityState.hasNetworkConnection;
              final isCdkInitialized = ecashState.initializationState ==
                  EcashInitializationState.initialized;
              final canCreateEcash = hasInternet && isCdkInitialized;

              if (!canCreateEcash) {
                return const SizedBox.shrink();
              }

              return PrimaryButton(
                text: 'Create My First Ecash',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const CreateEcashConfirmationScreen(),
                    ),
                  );
                },
                backgroundColor: AppColors.primary,
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getCardColor(int index, bool isReady) {
    if (!isReady) {
      return AppColors.textSecondary;
    }
    // Cycle through different colors for variety
    final colors = [
      AppColors.accent,
      AppColors.primary,
      AppColors.secondary,
      AppColors.warning,
      AppColors.success,
    ];
    return colors[index % colors.length];
  }

  Widget _buildEcashCard(EcashItem item, ThemeData theme, int index) {
    final isReady = item.status == EcashStatus.ready;
    final cardColor = _getCardColor(index, isReady);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: theme.containerTheme.whiteContainer,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (isReady) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EcashQrViewScreen(
                    ecashItem: item,
                    onMarkAsUsed: () => _markAsUsed(item),
                  ),
                ),
              );
            } else {
              // Show details view for used Ecash
              _showUsedEcashDetails(item, theme);
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Ecash icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: cardColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: cardColor.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.payments,
                    color: cardColor,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '21 sats',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: cardColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isReady ? 'Ready to Use' : 'Used',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cardColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Created ${_formatTimeAgo(item.createdAt)} ago',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status icon
                Icon(
                  isReady ? Icons.arrow_forward_ios : Icons.check_circle,
                  color: cardColor,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showUsedEcashDetails(EcashItem item, ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text('Ecash Details', style: theme.textTheme.titleLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This Ecash has been used.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Created: ${_formatTimeAgo(item.createdAt)} ago',
              style: theme.textTheme.bodySmall,
            ),
            if (item.usedAt != null)
              Text(
                'Used: ${_formatTimeAgo(item.usedAt!)} ago',
                style: theme.textTheme.bodySmall,
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showUnmarkWarning(item);
            },
            child: Text(
              'Unmark',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
