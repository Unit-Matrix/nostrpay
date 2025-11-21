import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_pay_kids/component_library/component_library.dart';
import 'package:nostr_pay_kids/cubit/account/account_cubit.dart';
import 'package:nostr_pay_kids/cubit/account/account_state.dart';

class ConnectionInfoScreen extends StatelessWidget {
  const ConnectionInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: 'Connection Info',
      body: BlocBuilder<AccountCubit, AccountState>(
        builder: (context, accountState) {
          final infoResponse = accountState.infoResponse;
          final budgetResponse = accountState.budgetResponse;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildConnectionStatusCard(context, infoResponse != null),
              const SizedBox(height: 24),
              if (infoResponse != null) ...[
                _buildWalletInfoSection(context, infoResponse),
                const SizedBox(height: 24),
              ],
              if (budgetResponse != null) ...[
                _buildBudgetInfoSection(context, budgetResponse),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildConnectionStatusCard(BuildContext context, bool isConnected) {
    final theme = Theme.of(context);
    final containerTheme = theme.containerTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: containerTheme.actionButtonContainer(
        isConnected ? AppColors.success : AppColors.error,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isConnected ? AppColors.success : AppColors.error)
                  .withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isConnected ? Icons.check_circle : Icons.error_outline,
              color: isConnected ? AppColors.success : AppColors.error,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isConnected ? 'Connected' : 'Not Connected',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: isConnected ? AppColors.success : AppColors.error,
                  ),
                ),
                Text(
                  isConnected
                      ? 'Your wallet is connected and ready!'
                      : 'Unable to connect to wallet',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // UPGRADE 2: Use ExpansionTile to hide technical details
  Widget _buildWalletInfoSection(BuildContext context, dynamic infoResponse) {
    final theme = Theme.of(context);
    return Container(
      decoration: theme.containerTheme.whiteContainer,
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.all(20),
        title: Text('Wallet Information', style: theme.textTheme.titleLarge),
        subtitle: Text(
          'Tap to see advanced details',
          style: theme.textTheme.bodySmall,
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.account_balance_wallet,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        children: [
          const Divider(height: 1, indent: 20, endIndent: 20),
          _buildInfoRow('Alias', infoResponse.alias ?? 'N/A'),
          _buildInfoRow(
            'Public Key',
            infoResponse.pubkey ?? 'N/A',
            isCopyable: true,
          ),
          _buildInfoRow('Network', infoResponse.network.plaintext),
          _buildInfoRow(
            'Block Height',
            infoResponse.blockHeight?.toString() ?? 'N/A',
          ),
          _buildInfoRow(
            'Block Hash',
            infoResponse.blockHash ?? 'N/A',
            isCopyable: true,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // UPGRADE 2: Use ExpansionTile for budget details too
  Widget _buildBudgetInfoSection(BuildContext context, dynamic budgetResponse) {
    final theme = Theme.of(context);
    return Container(
      decoration: theme.containerTheme.whiteContainer,
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.all(20),
        title: Text('Budget Information', style: theme.textTheme.titleLarge),
        subtitle: Text(
          '${budgetResponse.totalBudgetSats} sats / ${budgetResponse.renewalPeriod.plaintext}',
          style: theme.textTheme.bodySmall,
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.account_balance,
            color: AppColors.success,
            size: 20,
          ),
        ),
        children: [
          const Divider(height: 1, indent: 20, endIndent: 20),
          _buildInfoRow('Used Budget', '${budgetResponse.userBudgetSats} sats'),
          _buildInfoRow(
            'Total Budget',
            '${budgetResponse.totalBudgetSats} sats',
          ),
          _buildInfoRow(
            'Renewal Period',
            budgetResponse.renewalPeriod.plaintext,
          ),
          if (budgetResponse.renewsAt != null)
            _buildInfoRow(
              'Renews At',
              _formatTimestamp(budgetResponse.renewsAt!),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // UPGRADE 3: Interactive row with copy-to-clipboard functionality
  Widget _buildInfoRow(String label, String value, {bool isCopyable = false}) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return InkWell(
          onTap:
              isCopyable
                  ? () {
                    Clipboard.setData(ClipboardData(text: value));
                    showSuccessFlushbar(
                      context,
                      message: '$label copied to clipboard',
                    );
                  }
                  : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(label, style: theme.textTheme.bodySmall),
                ),
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (isCopyable)
                        Icon(
                          Icons.copy_all_outlined,
                          size: 14,
                          color: AppColors.textSecondary.withValues(alpha: 0.7),
                        ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          isCopyable ? _shortenString(value) : value,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _shortenString(String input) {
    if (input.length <= 16) return input;
    return '${input.substring(0, 8)}...${input.substring(input.length - 8)}';
  }

  String _formatTimestamp(int timestamp) {
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
      timestamp * 1000,
    );
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
