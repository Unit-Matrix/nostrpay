import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nostr_pay_kids/component_library/component_library.dart';
import 'package:nostr_pay_kids/models/ln_invoice.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_pay_kids/cubit/account/account_cubit.dart';
import 'package:nostr_pay_kids/cubit/account/account_state.dart';
import 'package:nostr_pay_kids/routes/send/payment_processing_sheet.dart';

class SendReviewScreen extends StatefulWidget {
  final LNInvoice invoice;

  const SendReviewScreen({super.key, required this.invoice});

  @override
  State<SendReviewScreen> createState() => _SendReviewScreenState();
}

class _SendReviewScreenState extends State<SendReviewScreen> {
  final bool _isSending = false;

  void _sendPayment() async {
    // Show payment processing sheet
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaymentProcessingSheet(invoice: widget.invoice),
    );
    // The PaymentProcessingSheet now handles navigation internally
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final containerTheme = theme.containerTheme;

    return BlocBuilder<AccountCubit, AccountState>(
      builder: (context, accountState) {
        final int currentBalance = accountState.balance;
        final bool hasEnoughBalance =
            currentBalance >= (widget.invoice.amountSat ?? 0);

        return AppPageScaffold(
          title: 'Review Payment',
          centerTitle: true,
          body: Column(
            children: [
              const SizedBox(height: 32),
              // Payment details card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: containerTheme.whiteContainer,
                child: Column(
                  children: [
                    // Amount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.bolt,
                            color: AppColors.secondary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${widget.invoice.amountSat ?? 0} sats',
                          style: theme.textTheme.headlineLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Recipient
                    _buildDetailRow(
                      icon: Icons.person_outline,
                      label: 'To',
                      value: _shortInvoice(widget.invoice.bolt11),
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 16),
                    // Description
                    _buildDetailRow(
                      icon: Icons.message_outlined,
                      label: 'For',
                      value: widget.invoice.description ?? '-',
                      color: AppColors.accent,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Balance check
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: containerTheme.actionButtonContainer(
                  hasEnoughBalance ? AppColors.success : AppColors.error,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            hasEnoughBalance
                                ? AppColors.success.withOpacity(0.2)
                                : AppColors.error.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        hasEnoughBalance
                            ? Icons.check_circle_outline
                            : Icons.warning_outlined,
                        color:
                            hasEnoughBalance
                                ? AppColors.success
                                : AppColors.error,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Balance: $currentBalance sats',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            hasEnoughBalance
                                ? 'You have enough sats!'
                                : 'Not enough sats for this payment',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color:
                                  hasEnoughBalance
                                      ? AppColors.success
                                      : AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
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
                // Mascot explanation
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: containerTheme.whiteContainer,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: SvgPicture.asset('assets/mascot/grumpy.svg'),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'You\'re about to send ${widget.invoice.amountSat ?? 0} sats for ${widget.invoice.description ?? '-'} Ready?',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  onPressed:
                      hasEnoughBalance && !_isSending ? _sendPayment : null,
                  isLoading: _isSending,
                  text: _isSending ? 'Sending your sats...' : 'Send Sats!',
                  backgroundColor: AppColors.accent,
                ),
              ],
            ),
          ),
        );
      },
    );

    // return Scaffold(
    //   appBar: AppBar(
    //     backgroundColor: Colors.transparent,
    //     elevation: 0,
    //     leading: IconButton(
    //       icon: Container(
    //         padding: const EdgeInsets.all(8),
    //         decoration: containerTheme.smallWhiteContainer,
    //         child: const Icon(
    //           Icons.arrow_back_ios,
    //           color: AppColors.primary,
    //           size: 18,
    //         ),
    //       ),
    //       onPressed: () => Navigator.pop(context),
    //     ),
    //   ),
    //   body: SafeArea(
    //     child: Padding(
    //       padding: const EdgeInsets.all(24),
    //       child: BlocBuilder<AccountCubit, AccountState>(
    //         builder: (context, accountState) {
    //           final int currentBalance = accountState.balance;
    //           final bool hasEnoughBalance =
    //               currentBalance >= (widget.invoice.amountSat ?? 0);
    //           return Column(
    //             children: [
    //               const SizedBox(height: 20),
    //               // Title
    //               Text(
    //                 'Review Payment',
    //                 style: theme.textTheme.headlineMedium,
    //                 textAlign: TextAlign.center,
    //               ),
    //               const SizedBox(height: 40),
    //               // Payment details card
    //               Container(
    //                 width: double.infinity,
    //                 padding: const EdgeInsets.all(24),
    //                 decoration: containerTheme.whiteContainer,
    //                 child: Column(
    //                   children: [
    //                     // Amount
    //                     Row(
    //                       mainAxisAlignment: MainAxisAlignment.center,
    //                       children: [
    //                         Container(
    //                           padding: const EdgeInsets.all(8),
    //                           decoration: BoxDecoration(
    //                             color: AppColors.secondary.withOpacity(0.1),
    //                             borderRadius: BorderRadius.circular(12),
    //                           ),
    //                           child: const Icon(
    //                             Icons.bolt,
    //                             color: AppColors.secondary,
    //                             size: 24,
    //                           ),
    //                         ),
    //                         const SizedBox(width: 12),
    //                         Text(
    //                           '${widget.invoice.amountSat ?? 0} sats',
    //                           style: theme.textTheme.headlineLarge,
    //                         ),
    //                       ],
    //                     ),
    //                     const SizedBox(height: 24),
    //                     // Recipient
    //                     _buildDetailRow(
    //                       icon: Icons.person_outline,
    //                       label: 'To',
    //                       value: _shortInvoice(widget.invoice.bolt11),
    //                       color: AppColors.primary,
    //                     ),
    //                     const SizedBox(height: 16),
    //                     // Description
    //                     _buildDetailRow(
    //                       icon: Icons.message_outlined,
    //                       label: 'For',
    //                       value: widget.invoice.description ?? '-',
    //                       color: AppColors.accent,
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //               const SizedBox(height: 24),
    //               // Balance check
    //               Container(
    //                 width: double.infinity,
    //                 padding: const EdgeInsets.all(20),
    //                 decoration: containerTheme.actionButtonContainer(
    //                   hasEnoughBalance ? AppColors.success : AppColors.error,
    //                 ),
    //                 child: Row(
    //                   children: [
    //                     Container(
    //                       padding: const EdgeInsets.all(8),
    //                       decoration: BoxDecoration(
    //                         color:
    //                             hasEnoughBalance
    //                                 ? AppColors.success.withOpacity(0.2)
    //                                 : AppColors.error.withOpacity(0.2),
    //                         borderRadius: BorderRadius.circular(12),
    //                       ),
    //                       child: Icon(
    //                         hasEnoughBalance
    //                             ? Icons.check_circle_outline
    //                             : Icons.warning_outlined,
    //                         color:
    //                             hasEnoughBalance
    //                                 ? AppColors.success
    //                                 : AppColors.error,
    //                         size: 20,
    //                       ),
    //                     ),
    //                     const SizedBox(width: 12),
    //                     Expanded(
    //                       child: Column(
    //                         crossAxisAlignment: CrossAxisAlignment.start,
    //                         children: [
    //                           Text(
    //                             'Your Balance: $currentBalance sats',
    //                             style: theme.textTheme.bodySmall?.copyWith(
    //                               color: AppColors.textPrimary,
    //                               fontWeight: FontWeight.w600,
    //                             ),
    //                           ),
    //                           Text(
    //                             hasEnoughBalance
    //                                 ? 'You have enough sats!'
    //                                 : 'Not enough sats for this payment',
    //                             style: theme.textTheme.labelMedium?.copyWith(
    //                               color:
    //                                   hasEnoughBalance
    //                                       ? AppColors.success
    //                                       : AppColors.error,
    //                               fontWeight: FontWeight.w600,
    //                             ),
    //                           ),
    //                         ],
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //               const SizedBox(height: 24),
    //               // Mascot explanation
    //               Container(
    //                 width: double.infinity,
    //                 padding: const EdgeInsets.all(20),
    //                 decoration: containerTheme.whiteContainer,
    //                 child: Row(
    //                   children: [
    //                     SizedBox(
    //                       width: 60,
    //                       height: 60,
    //                       child: SvgPicture.asset('assets/mascot/grumpy.svg'),
    //                     ),
    //                     const SizedBox(width: 16),
    //                     Expanded(
    //                       child: Text(
    //                         'You\'re about to send ${widget.invoice.amountSat ?? 0} sats for ${widget.invoice.description ?? '-'} Ready?',
    //                         style: theme.textTheme.bodySmall?.copyWith(
    //                           color: AppColors.textPrimary,
    //                           fontWeight: FontWeight.w600,
    //                           height: 1.3,
    //                         ),
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //               const Spacer(),
    //               // Send button
    //               PrimaryButton(
    //                 onPressed:
    //                     hasEnoughBalance && !_isSending ? _sendPayment : null,
    //                 isLoading: _isSending,
    //                 text: _isSending ? 'Sending your sats...' : 'Send Sats!',
    //               ),
    //               const SizedBox(height: 24),
    //             ],
    //           );
    //         },
    //       ),
    //     ),
    //   ),
    // );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.labelMedium),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _shortInvoice(String invoice) {
    if (invoice.length <= 16) return invoice;
    return '${invoice.substring(0, 6)}...${invoice.substring(invoice.length - 6)}';
  }
}
