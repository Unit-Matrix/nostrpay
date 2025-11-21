import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nostr_pay_kids/component_library/component_library.dart';
import 'package:nostr_pay_kids/routes/qr_scan/qr_scan_view.dart';
import 'package:nostr_pay_kids/routes/send/send_review_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_pay_kids/cubit/input/input_cubit.dart';
import 'package:nostr_pay_kids/models/ln_invoice.dart';

class SendCodeEntryScreen extends StatefulWidget {
  const SendCodeEntryScreen({super.key});

  @override
  State<SendCodeEntryScreen> createState() => _SendCodeEntryScreenState();
}

class _SendCodeEntryScreenState extends State<SendCodeEntryScreen> {
  final TextEditingController _codeController = TextEditingController();

  void _pasteFromClipboard() async {
    ClipboardData? data = await Clipboard.getData('text/plain');
    if (data != null && data.text != null) {
      setState(() {
        _codeController.text = data.text!;
      });
      showSuccessFlushbar(context, message: 'Code pasted successfully!');
    } else {
      showErrorFlushbar(context, message: 'Nothing to paste');
    }
  }

  void _scanCode() async {
    final String? barcode = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QrScanView()),
    );

    // Handle the scan result
    if (!mounted) return;

    if (barcode == null || barcode.isEmpty) {
      showErrorFlushbar(context, message: 'QR code wasn\'t detected.');
      return;
    }

    setState(() {
      _codeController.text = barcode;
    });
  }

  void _decodeAndReview() async {
    if (_codeController.text.trim().isEmpty) {
      showErrorFlushbar(context, message: 'Please enter or scan a code first!');
      return;
    }

    final navigator = Navigator.of(context);
    final loaderRoute = createLoaderRoute(context);
    navigator.push(loaderRoute);

    try {
      // Use InputCubit to decode the invoice
      final inputCubit = context.read<InputCubit>();
      LNInvoice invoice = inputCubit.decodeInvoice(_codeController.text.trim());

      navigator.pop(loaderRoute); // Remove loader

      // Navigate to review screen with decoded invoice
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SendReviewScreen(invoice: invoice),
        ),
      );
    } catch (e) {
      navigator.pop(loaderRoute); // Remove loader
      showErrorFlushbar(
        context,
        message: 'Invalid or unsupported invoice. Please check and try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppPageScaffold(
      title: 'Get Their Code',
      centerTitle: true,
      body: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: theme.containerTheme.whiteContainer,
            child: Text(
              "You can scan your friend's code or paste it here!",
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              _buildActionButton(
                theme: theme,
                icon: Icons.qr_code_scanner,
                label: 'Scan Code',
                color: AppColors.primary,
                onTap: _scanCode,
              ),
              const SizedBox(width: 16),
              _buildActionButton(
                theme: theme,
                icon: Icons.content_paste,
                label: 'Paste Code',
                color: AppColors.accent,
                onTap: _pasteFromClipboard,
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Code input field
          Container(
            decoration: theme.containerTheme.smallWhiteContainer,
            child: TextField(
              controller: _codeController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'Friend\'s Code',
                hintText: 'Paste their special code here...',
                labelStyle: theme.textTheme.bodySmall,
                hintStyle: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.all(20),
                suffixIcon:
                    _codeController.text.isNotEmpty
                        ? IconButton(
                          onPressed: () {
                            setState(() {
                              _codeController.clear();
                            });
                          },
                          icon: const Icon(
                            Icons.clear,
                            color: AppColors.textSecondary,
                          ),
                        )
                        : null,
              ),
              maxLines: 3,
              onChanged: (value) => setState(() {}),
            ),
          ),
        ],
      ),
      footer: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Safety tip (always visible)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      color: AppColors.warning,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'If you\'re not sure, ask your parent before sending.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textBody,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Review button (always visible)
            PrimaryButton(
              text: 'Review Payment',
              onPressed:
                  _codeController.text.trim().isNotEmpty
                      ? _decodeAndReview
                      : null,
              enabled: _codeController.text.trim().isNotEmpty,
            ),
          ],
        ),
      ),
    );
  }

  // Helper for the top action buttons
  Widget _buildActionButton({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 100,
          decoration: theme.containerTheme.primaryButtonContainer(color),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
