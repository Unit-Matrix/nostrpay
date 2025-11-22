import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nostr_pay_kids/component_library/component_library.dart';
import 'package:nostr_pay_kids/cubit/account/account_state.dart';
import 'package:nostr_pay_kids/handlers/handler/handler.dart';
import 'package:nostr_pay_kids/handlers/handler/handler_context_provider.dart';
import 'package:nostr_pay_kids/handlers/network_connectivity_handler/network_connectivity_handler.dart';
import 'package:nostr_pay_kids/routes/receive/receive_intro_screen.dart';
import 'package:nostr_pay_kids/routes/send/send_intro_screen.dart';
import 'package:nostr_pay_kids/routes/home/history_screen.dart';
import 'package:nostr_pay_kids/routes/home/tools_dialog.dart';
import 'package:nostr_pay_kids/routes/settings/settings_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_pay_kids/cubit/account/account_cubit.dart';
import 'package:nostr_pay_kids/cubit/user_profile/user_profile_cubit.dart';
import 'package:nostr_pay_kids/cubit/currency/currency_cubit.dart';
import 'package:nostr_pay_kids/cubit/currency/currency_state.dart';
import 'package:nostr_pay_kids/models/fiat_currency.dart';
import 'package:nostr_pay_kids/services/service_injector.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with HandlerContextProvider<HomeScreen> {
  bool _showFiatEquivalent = false;
  Timer? _tipTimer;
  int _currentTipIndex = 0;

  // Educational tips that rotate
  final List<String> _educationalTips = [
    "Did you know? Saving sats helps you buy bigger things!",
    "Great job saving! Try to keep some sats for next week!",
    "Every sat you save today is worth more tomorrow!",
    "Smart spending means thinking before you buy!",
  ];

  final List<Handler> handlers = <Handler>[];

  @override
  void initState() {
    super.initState();
    // Start a timer to cycle through tips
    _tipTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (mounted) {
        setState(() {
          _currentTipIndex = Random().nextInt(_educationalTips.length);
        });
      }
    });

    SchedulerBinding.instance.addPostFrameCallback((_) {
      handlers.addAll(<Handler>[NetworkConnectivityHandler()]);
      for (Handler handler in handlers) {
        handler.init(this);
      }

      // Schedule daily notifications for users who have completed onboarding
      ServiceInjector().notificationService.scheduleDailyNotifications();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tipTimer?.cancel();
    for (Handler handler in handlers) {
      handler.dispose();
    }
    handlers.clear();
  }

  Future<void> _onRefresh() async {
    final accountCubit = context.read<AccountCubit>();
    final currencyCubit = context.read<CurrencyCubit>();
    await accountCubit.refreshWalletBalance();
    await currencyCubit.fetchRates();
  }

  void _toggleBalanceDisplay() {
    setState(() {
      _showFiatEquivalent = !_showFiatEquivalent;
    });
    // Trigger a light haptic feedback on toggle
    HapticFeedback.lightImpact();
  }

  void _sendSats() {
    // Navigate to send screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SendIntroScreen()),
    );
  }

  void _receiveSats() {
    // Navigate to receive screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ReceiveIntroScreen()),
    );
  }

  void _viewTransactions() {
    // Navigate to transactions screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HistoryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProfileState = context.watch<UserProfileCubit>().state;
    final String userName = userProfileState.name;
    final String avatarAsset = userProfileState.selectedAvatar.assetPath;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColors.primary,
          backgroundColor: Colors.white,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Welcome header
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, $userName!',
                            style: theme.textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ready to manage your sats?',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    // Settings button
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.settings,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Balance Display - Central and Playful
                BlocBuilder<AccountCubit, AccountState>(
                  builder: (context, accountState) {
                    return BlocBuilder<CurrencyCubit, CurrencyState>(
                      builder: (context, currencyState) {
                        final String satsBalanceText =
                            "${accountState.balance} sats";
                        String fiatBalanceText = "..."; // Default loading text

                        if (currencyState.rates.isNotEmpty) {
                          // ... your fiat calculation logic
                          final fiatValue = (accountState.balance / 100000000) *
                              (currencyState
                                      .rates[currencyState.selectedFiat] ??
                                  0);
                          fiatBalanceText =
                              "${_fiatSymbol(currencyState.selectedFiat)}${fiatValue.toStringAsFixed(2)}";
                        }

                        return GestureDetector(
                          onTap: _toggleBalanceDisplay,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: theme.containerTheme.whiteContainer,
                            child: Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: AppColors.accent.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: SvgPicture.asset(
                                    'assets/mascot/Vault.svg',
                                    width: 60,
                                    height: 60,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Your Balance',
                                        style: theme.textTheme.bodySmall,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _showFiatEquivalent
                                            ? fiatBalanceText
                                            : satsBalanceText,
                                        style: theme.textTheme.headlineMedium,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Tap to switch view',
                                        style: theme.textTheme.labelSmall,
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
                  },
                ),

                const SizedBox(height: 20),

                // Budget Progress Bar
                BlocBuilder<AccountCubit, AccountState>(
                  builder: (context, accountState) {
                    return BlocBuilder<CurrencyCubit, CurrencyState>(
                      builder: (context, currencyState) {
                        return _buildBudgetInfo(
                          accountState,
                          currencyState,
                          theme,
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Quick Actions
                Text('Quick Actions', style: theme.textTheme.titleLarge),

                const SizedBox(height: 16),

                Row(
                  children: [
                    // Send Sats
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.send,
                        label: 'Send',
                        color: AppColors.secondary,
                        onTap: _sendSats,
                        theme: theme,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Receive Sats
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.qr_code,
                        label: 'Receive',
                        color: AppColors.accent,
                        onTap: _receiveSats,
                        theme: theme,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // History
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.history,
                        label: 'History',
                        color: AppColors.primary,
                        onTap: _viewTransactions,
                        theme: theme,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Tools
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.adjust_sharp,
                        label: 'Tools',
                        color: AppColors.warning,
                        onTap: _showToolsDialog,
                        theme: theme,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Mascot Guide & Educational Widget
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Mascot
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: SvgPicture.asset(avatarAsset),
                      ),
                      const SizedBox(width: 16),
                      // Educational tip
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tip of the day',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontSize: 16,
                                color: AppColors.warning,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _educationalTips[_currentTipIndex],
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.textBody,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showToolsDialog() {
    ToolsDialog.show(context);
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 80),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: theme.containerTheme.actionButtonContainer(color),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetInfo(
    AccountState accountState,
    CurrencyState currencyState,
    ThemeData theme,
  ) {
    final budgetResponse = accountState.budgetResponse;
    final int budgetLimit = budgetResponse?.totalBudgetSats ?? 0;
    final int usedBudget = budgetResponse?.userBudgetSats ?? 0;
    final bool hasInfiniteBudget = budgetLimit == 0 && usedBudget == 0;
    final int satsLeft = hasInfiniteBudget ? 0 : (budgetLimit - usedBudget);
    final double budgetProgress = hasInfiniteBudget
        ? 1.0
        : budgetLimit > 0
            ? (usedBudget / budgetLimit).clamp(0.0, 1.0)
            : 0.0;

    String displayText;
    if (budgetResponse == null) {
      displayText = 'Budget tracking not supported by your wallet.';
    } else if (hasInfiniteBudget) {
      displayText = 'No spending limit!';
    } else {
      if (_showFiatEquivalent && currencyState.rates.isNotEmpty) {
        // Show fiat equivalent
        final fiatValue = (satsLeft / 100000000) *
            (currencyState.rates[currencyState.selectedFiat] ?? 0);
        displayText =
            'You have ${_fiatSymbol(currencyState.selectedFiat)}${fiatValue.toStringAsFixed(2)} left to spend!';
      } else {
        // Show sats
        displayText = 'You have $satsLeft sats left to spend!';
      }
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: theme.containerTheme.whiteContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: AppColors.success,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Budget Progress',
                  style: theme.textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          Container(
            height: 12,
            decoration: BoxDecoration(
              color: Colors.grey.shade200, // The background of the bar
              borderRadius: BorderRadius.circular(6),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Calculate the width of the green bar based on progress
                final double progressWidth =
                    constraints.maxWidth * budgetProgress;

                return Stack(
                  children: [
                    // Pending (unused) budget - grey bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    // Animated green bar
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      width: progressWidth, // Animate the width property
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Text(displayText, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }

  String _fiatSymbol(FiatCurrency fiat) {
    return fiat.symbol;
  }
}
