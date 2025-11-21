import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:nostr_pay_kids/component_library/component_library.dart';
import 'package:nostr_pay_kids/cubit/payments/payments.dart';
import 'package:nostr_pay_kids/services/nwc_ndk_sdk.dart';
import 'package:nostr_pay_kids/services/service_injector.dart';
import 'package:ndk/ndk.dart' as ndk;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_confetti/flutter_confetti.dart';
import 'package:share_plus/share_plus.dart';

import 'payment_success_modal.dart';

final Logger _logger = Logger('ReceiveQRScreen');

class ReceiveQRScreen extends StatefulWidget {
  final ndk.MakeInvoiceResponse invoiceResponse;

  const ReceiveQRScreen({super.key, required this.invoiceResponse});

  @override
  State<ReceiveQRScreen> createState() => _ReceiveQRScreenState();
}

class _ReceiveQRScreenState extends State<ReceiveQRScreen> {
  bool _hasInteracted = false; // Add this new state variable

  bool isWaitingForPayment = true;
  StreamSubscription<PaymentNotificationEvent>? _trackPaymentEventsSubscription;

  @override
  void initState() {
    super.initState();
    _logger.info(
      'ReceiveQRScreen initState: invoice=${widget.invoiceResponse.invoice}',
    );
    _trackPaymentEvents();
  }

  @override
  void dispose() {
    _logger.info('ReceiveQRScreen dispose called.');
    _trackPaymentEventsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _trackPaymentEvents() async {
    _logger.info(
      'Starting _trackPaymentEvents for invoice: ${widget.invoiceResponse.invoice}',
    );

    final PaymentsCubit paymentsCubit = context.read<PaymentsCubit>();
    _trackPaymentEventsSubscription?.cancel();

    _logger.info('Subscribing to payment events.');
    _trackPaymentEventsSubscription = paymentsCubit.trackPaymentEvents(
      paymentFilter: _buildPaymentFilter,
      onData: _onTrackPaymentSucceed,
      onError: _onTrackPaymentError,
    );
  }

  bool _buildPaymentFilter(PaymentNotificationEvent event) {
    // Check if this is an incoming payment for our specific invoice
    final match =
        event.isPaymentReceived &&
        event.notification.invoice == widget.invoiceResponse.invoice;

    _logger.info(
      'Filter check: isPaymentReceived=${event.isPaymentReceived}, '
      'notification.invoice=${event.notification.invoice}, '
      'expected.invoice=${widget.invoiceResponse.invoice}, match=$match',
    );

    return match;
  }

  void _onTrackPaymentSucceed(PaymentNotificationEvent event) {
    _logger.info(
      'Incoming payment detected! '
      'invoice: ${event.notification.invoice}, '
      'amount: ${event.notification.amount}, '
      'payment: $event',
    );

    // Track successful payment received
    final analyticsService = ServiceInjector().analyticsService;
    analyticsService.trackPaymentReceived(
      amountSats: (event.notification.amount / 1000).toInt(),
    );

    _onPaymentFinished(true);
  }

  void _onTrackPaymentError(Object e) {
    _logger.warning('Failed to track incoming payments.', e);
    if (mounted) {
      showErrorFlushbar(
        context,
        message: 'Error tracking payment: ${e.toString()}',
      );
    }
    _onPaymentFinished(false);
  }

  void _onPaymentFinished(bool isSuccess) {
    _logger.info('Payment finished: $isSuccess');
    if (!mounted) {
      _logger.warning('Widget not mounted in _onPaymentFinished.');
      return;
    }

    if (isSuccess) {
      setState(() {
        isWaitingForPayment = false;
      });
      Navigator.of(context).popUntil((route) => route.settings.name == '/');
      _showPaymentSuccess();
    } else {
      showErrorFlushbar(context, message: 'Payment failed.');
    }
  }

  void _copyInvoice() {
    Clipboard.setData(ClipboardData(text: widget.invoiceResponse.invoice));
    showSuccessFlushbar(context, message: 'Code copied to clipboard!');
    setState(() {
      _hasInteracted = true;
    }); // Add this line
  }

  void _shareInvoice() {
    final ShareParams shareParams = ShareParams(
      subject: 'Lightning Invoice',
      text: widget.invoiceResponse.invoice,
    );
    SharePlus.instance.share(shareParams);
    setState(() {
      _hasInteracted = true;
    }); // Add this line
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
              particleCount: 150,
              spread: 70,
              y: 0.6,
            ),
          );
        });

        return PaymentSuccessModal(
          amount: widget.invoiceResponse.amountSat,
          type: PaymentType.receive,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppPageScaffold(
      title: 'Your Magic Code',
      centerTitle: true,
      body: Column(
        children: [
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: theme.containerTheme.whiteContainer,
            child: Column(
              children: [
                // Amount display
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.invoiceResponse.amountSat} sats',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppColors.accent,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // QR Code
                QrImageView(
                  data: widget.invoiceResponse.invoice,
                  version: QrVersions.auto,
                  size: 220.0,
                ),
              ],
            ),
          ),
        ],
      ),
      footer: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // AnimatedSwitcher will smoothly transition between the two messages
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child:
                  _hasInteracted
                      ? _buildSafetyTipCard(
                        theme,
                      ) // Show safety tip after interaction
                      : _buildInstructionCard(theme), // Show instruction first
            ),
            const SizedBox(height: 16),
            // Action buttons are now cleaner
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  icon: Icons.copy_all_outlined,
                  label: 'Copy',
                  color: AppColors.primary,
                  onTap: _copyInvoice,
                  theme: theme,
                ),
                _buildActionButton(
                  icon: Icons.share_outlined,
                  label: 'Share',
                  color: AppColors.secondary,
                  onTap: _shareInvoice,
                  theme: theme,
                ),
                _buildActionButton(
                  icon: Icons.check,
                  label: 'Done',
                  color: AppColors.success,
                  onTap: () {
                    Navigator.of(
                      context,
                    ).popUntil((route) => route.settings.name == '/');
                  },
                  theme: theme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionCard(ThemeData theme) {
    return Container(
      key: const ValueKey('instruction'), // Key for AnimatedSwitcher
      padding: const EdgeInsets.all(20),
      decoration: theme.containerTheme.whiteContainer,
      child: Text(
        'Ask your parent or friend to scan this code with their wallet to send you sats!',
        style: theme.textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSafetyTipCard(ThemeData theme) {
    return Container(
      key: const ValueKey('safety_tip'), // Key for AnimatedSwitcher
      padding: const EdgeInsets.all(16),
      decoration: theme.containerTheme.actionButtonContainer(AppColors.warning),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.warning, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'This code works only once. To get more sats, make a new one!',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
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
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: theme.containerTheme.actionButtonContainer(color),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
