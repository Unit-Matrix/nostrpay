import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nostr_pay_kids/component_library/component_library.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_pay_kids/cubit/payments/payments.dart';
import 'package:nostr_pay_kids/cubit/account/account_cubit.dart';
import 'package:ndk/domain_layer/usecases/nwc/responses/list_transactions_response.dart'
    as ndk;
import 'package:timeago/timeago.dart' as timeago;

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  Future<void> _onRefresh() async {
    // Call the refreshWalletTransactions method from AccountCubit
    await context.read<AccountCubit>().refreshWalletTransactions();
  }

  String _formatTimeAgo(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return timeago.format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppPageScaffold(
      title: 'Transaction History',
      centerTitle: true,
      onRefresh: _onRefresh,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // Mascot
          Center(
            child: SizedBox(
              width: 120,
              height: 120,
              child: SvgPicture.asset('assets/mascot/Coder.svg'),
            ),
          ),

          const SizedBox(height: 20),

          // Transactions List
          BlocBuilder<PaymentsCubit, PaymentsState>(
            builder: (context, paymentsState) {
              final transactions = paymentsState.transactions;

              if (transactions.isEmpty) {
                return _buildEmptyState();
              }

              // Group transactions by date
              final groupedTransactions =
                  <String, List<ndk.TransactionResult>>{};
              for (final transaction in transactions) {
                final dateKey = _formatTimeAgo(transaction.createdAt);
                groupedTransactions
                    .putIfAbsent(dateKey, () => [])
                    .add(transaction);
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your Activity', style: theme.textTheme.titleLarge),

                  const SizedBox(height: 16),

                  ...groupedTransactions.entries.map((entry) {
                    final date = entry.key;
                    final dayTransactions = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date header
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            date,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Transactions for this date
                        ...dayTransactions.map(
                          (transaction) => _buildTransactionCard(transaction),
                        ),

                        const SizedBox(height: 16),
                      ],
                    ).animate().fadeIn(duration: 300.ms);
                  }),
                ],
              );
            },
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final containerTheme = theme.containerTheme;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: containerTheme.whiteContainer,
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.history,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'No transactions yet',
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                'Your transaction history will appear here once you start sending or receiving sats!',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransactionCard(ndk.TransactionResult transaction) {
    final isIncoming = transaction.isIncoming;
    final amount = transaction.amountSat;
    final description = transaction.description ?? 'No description';
    final time = _formatTimeAgo(transaction.createdAt);
    final isSettled = transaction.settledAt != null;

    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final containerTheme = theme.containerTheme;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: containerTheme.whiteContainer,
          child: Row(
            children: [
              // Transaction icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: (isIncoming ? AppColors.success : AppColors.secondary)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isIncoming ? Icons.download : Icons.upload,
                  color: isIncoming ? AppColors.success : AppColors.secondary,
                  size: 24,
                ),
              ),

              const SizedBox(width: 16),

              // Transaction details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            description.trim().isEmpty
                                ? 'No description'
                                : description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: (isSettled
                                    ? AppColors.success
                                    : AppColors.warning)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isSettled ? 'Completed' : 'Pending',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color:
                                  isSettled
                                      ? AppColors.success
                                      : AppColors.warning,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(time, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isIncoming ? '+' : '-'}$amount sats',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color:
                          isIncoming ? AppColors.success : AppColors.secondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    isIncoming ? 'Received' : 'Sent',
                    style: theme.textTheme.labelMedium,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
