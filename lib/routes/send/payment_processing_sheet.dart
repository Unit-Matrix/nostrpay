import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:nostr_pay_kids/component_library/component_library.dart';
import 'package:nostr_pay_kids/cubit/payments/payments.dart';
import 'package:nostr_pay_kids/models/ln_invoice.dart';
import 'package:nostr_pay_kids/services/nwc_ndk_sdk.dart';
import 'package:nostr_pay_kids/services/service_injector.dart';
import 'package:flutter_confetti/flutter_confetti.dart';
import 'package:nostr_pay_kids/routes/receive/payment_success_modal.dart';

final Logger _logger = Logger('PaymentProcessingSheet');

class PaymentProcessingSheet extends StatefulWidget {
  final LNInvoice invoice;

  const PaymentProcessingSheet({super.key, required this.invoice});

  @override
  State<PaymentProcessingSheet> createState() => _PaymentProcessingSheetState();
}

class _PaymentProcessingSheetState extends State<PaymentProcessingSheet> {
  bool isProcessing = true;
  String? errorMessage;
  StreamSubscription<PaymentNotificationEvent>? _trackPaymentEventsSubscription;

  @override
  void initState() {
    super.initState();
    _logger.info(
      'PaymentProcessingSheet initState: invoice=${widget.invoice.bolt11}',
    );
    _processPayment();
  }

  @override
  void dispose() {
    _logger.info('PaymentProcessingSheet dispose called.');
    _trackPaymentEventsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _processPayment() async {
    try {
      // Check if PaymentsCubit is available
      if (!context.mounted) {
        _logger.warning('Context not mounted, cannot process payment');
        return;
      }

      final PaymentsCubit paymentsCubit = context.read<PaymentsCubit>();

      _logger.info(
        'Starting payment process for invoice: ${widget.invoice.bolt11}',
      );

      // Start tracking payment events first
      _trackPaymentEventsSubscription = paymentsCubit.trackPaymentEvents(
        paymentFilter: _buildPaymentFilter,
        onData: _onTrackPaymentSucceed,
        onError: _onTrackPaymentError,
      );

      _logger.info('Payment tracking started, now initiating payment...');

      // Pay the invoice
      final response = await paymentsCubit.payInvoice(
        invoice: widget.invoice.bolt11,
      );

      if (response != null) {
        _logger.info('Payment initiated successfully');
        // Payment tracking will handle success/failure via events
        // Keep the processing state active until we get a payment event
      } else {
        _logger.warning('Payment failed to initiate - no response');
        _onPaymentFailed('Payment failed to initiate');
      }
    } catch (e) {
      _logger.severe('Error processing payment: $e');
      _onPaymentFailed('Payment error: ${e.toString()}');
    }
  }

  bool _buildPaymentFilter(PaymentNotificationEvent event) {
    // Check if this is a payment for our specific invoice
    final match =
        event.isPaymentSent &&
        event.notification.invoice.toLowerCase() ==
            widget.invoice.bolt11.toLowerCase();

    _logger.info(
      'Filter check: isPaymentSent=${event.isPaymentSent}, '
      'notification.invoice=${event.notification.invoice}, '
      'expected.invoice=${widget.invoice.bolt11}, match=$match',
    );

    return match;
  }

  void _onTrackPaymentSucceed(PaymentNotificationEvent event) {
    _logger.info(
      'Payment successful! '
      'invoice: ${event.notification.invoice}, '
      'amount: ${event.notification.amount}, '
      'payment: $event',
    );
    _onPaymentSuccess();
  }

  void _onTrackPaymentError(Object e) {
    _logger.warning('Failed to track payment events.', e);
    _onPaymentFailed('Error tracking payment: ${e.toString()}');
  }

  void _onPaymentSuccess() {
    if (!mounted) return;

    // Track successful payment sent
    final analyticsService = ServiceInjector().analyticsService;
    analyticsService.trackPaymentSent(
      amountSats: widget.invoice.amountSat ?? 0,
    );

    // Close the processing sheet
    Navigator.of(context).popUntil((route) => route.settings.name == '/');

    // Show success modal
    _showPaymentSuccess();
  }

  void _onPaymentFailed(String error) {
    if (!mounted) return;

    setState(() {
      isProcessing = false;
      errorMessage = error;
    });
  }

  void _showPaymentSuccess() {
    showDialog(
      context: context,
      builder: (context) {
        // Launch confetti after a short delay when dialog appears
        Future.delayed(const Duration(milliseconds: 300), () {
          Confetti.launch(
            context,
            options: const ConfettiOptions(
              particleCount: 100,
              spread: 70,
              y: 0.9,
            ),
          );
        });

        return PaymentSuccessModal(
          amount: widget.invoice.amountSat ?? 0,
          type: PaymentType.send,
        );
      },
    );
  }

  void _closeSheet() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(height: 24),

              // Status content
              if (isProcessing) ...[
                // Processing state
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.secondary,
                      strokeWidth: 3,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  'Sending your sats...',
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                Text(
                  'Please wait while we process your payment',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Payment details
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Amount:', style: theme.textTheme.bodySmall),
                          Text(
                            '${widget.invoice.amountSat ?? 0} sats',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Description:',
                            style: theme.textTheme.bodySmall,
                          ),
                          Expanded(
                            child: Text(
                              widget.invoice.description ?? '-',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Error state
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Text('😔', style: TextStyle(fontSize: 40)),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  'Payment Failed',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColors.error,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                Text(
                  errorMessage ?? 'Something went wrong with your payment',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 32),

              // Action button - only show when not processing
              if (!isProcessing) ...[
                PrimaryButton(
                  onPressed: _closeSheet,
                  text: 'Try Again',
                  backgroundColor: AppColors.error,
                ),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
