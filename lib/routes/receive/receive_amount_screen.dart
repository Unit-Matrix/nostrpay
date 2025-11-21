import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_pay_kids/component_library/component_library.dart';
import 'package:nostr_pay_kids/cubit/payments/payments.dart';

import 'receive_qr_screen.dart';

class ReceiveAmountScreen extends StatefulWidget {
  const ReceiveAmountScreen({super.key});

  @override
  State<ReceiveAmountScreen> createState() => _ReceiveAmountScreenState();
}

class _ReceiveAmountScreenState extends State<ReceiveAmountScreen> {
  String amount = '';
  bool _isCreatingInvoice = false;

  void _onNumberPress(String number) {
    HapticFeedback.lightImpact(); // Add satisfying haptic feedback
    if (amount.length < 8) {
      setState(() {
        amount += number;
      });
    }
  }

  void _onBackspacePress() {
    HapticFeedback.lightImpact();
    if (amount.isNotEmpty) {
      setState(() {
        amount = amount.substring(0, amount.length - 1);
      });
    }
  }

  Future<void> _createInvoice() async {
    if (amount.isEmpty || int.parse(amount) == 0) {
      showErrorFlushbar(context, message: 'Please enter an amount first!');
      return;
    }

    setState(() {
      _isCreatingInvoice = true;
    });

    try {
      final paymentsCubit = context.read<PaymentsCubit>();
      final invoiceResponse = await paymentsCubit.makeInvoice(
        amountSats: int.parse(amount),
      );

      if (mounted) {
        setState(() {
          _isCreatingInvoice = false;
        });

        if (invoiceResponse != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      ReceiveQRScreen(invoiceResponse: invoiceResponse),
            ),
          );
        } else {
          showErrorFlushbar(
            context,
            message: 'Failed to create invoice. Please try again.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCreatingInvoice = false;
        });
        // _showSnackBar('Error creating invoice: ${e.toString()}');
        showErrorFlushbar(
          context,
          message: 'Error creating invoice: ${e.toString()}',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: 'How many sats?',
      centerTitle: true,
      body: _buildContent(context),
      footer: _buildFooter(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 32),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: theme.containerTheme.whiteContainer,
          child: Column(
            children: [
              Text('Amount to receive', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    amount.isEmpty ? '0' : amount,
                    style: theme.textTheme.headlineLarge,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'sats',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: theme.containerTheme.whiteContainer,
            child: Column(
              children: [
                // Row 1: 1, 2, 3
                Row(
                  children: [
                    _buildNumberButton('1'),
                    const SizedBox(width: 12),
                    _buildNumberButton('2'),
                    const SizedBox(width: 12),
                    _buildNumberButton('3'),
                  ],
                ),
                const SizedBox(height: 12),

                // Row 2: 4, 5, 6
                Row(
                  children: [
                    _buildNumberButton('4'),
                    const SizedBox(width: 12),
                    _buildNumberButton('5'),
                    const SizedBox(width: 12),
                    _buildNumberButton('6'),
                  ],
                ),
                const SizedBox(height: 12),

                // Row 3: 7, 8, 9
                Row(
                  children: [
                    _buildNumberButton('7'),
                    const SizedBox(width: 12),
                    _buildNumberButton('8'),
                    const SizedBox(width: 12),
                    _buildNumberButton('9'),
                  ],
                ),
                const SizedBox(height: 12),

                // Row 4: 00, 0, backspace
                Row(
                  children: [
                    _buildNumberButton('00'),
                    const SizedBox(width: 12),
                    _buildNumberButton('0'),
                    const SizedBox(width: 12),
                    _buildBackspaceButton(),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          PrimaryButton(
            onPressed:
                amount.isNotEmpty &&
                        int.tryParse(amount) != 0 &&
                        !_isCreatingInvoice
                    ? _createInvoice
                    : null,
            isLoading: _isCreatingInvoice,
            text: _isCreatingInvoice ? 'Creating...' : 'Create My Code!',
            backgroundColor: AppColors.accent,
          ),
        ],
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: () => _onNumberPress(number),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.accent.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(number, style: theme.textTheme.headlineSmall),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return Expanded(
      child: GestureDetector(
        onTap: _onBackspacePress,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.error.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.backspace_outlined,
              color: AppColors.error,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
