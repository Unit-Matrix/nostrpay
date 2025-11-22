import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nostr_pay_kids/component_library/component_library.dart';
import 'package:nostr_pay_kids/cubit/account/onboarding_preferences.dart';
import 'package:nostr_pay_kids/cubit/sdk_connectivity/sdk_connectivity_cubit.dart';
import 'package:nostr_pay_kids/routes/qr_scan/qr_scan_view.dart';
import 'package:nostr_pay_kids/services/external_browser_service.dart';
import 'package:nostr_pay_kids/services/service_injector.dart';

import 'success_screen.dart';

class CodeEntryScreen extends StatefulWidget {
  const CodeEntryScreen({super.key, this.showBackButton = true});
  final bool showBackButton;

  @override
  State<CodeEntryScreen> createState() => _CodeEntryScreenState();
}

class _CodeEntryScreenState extends State<CodeEntryScreen> {
  final TextEditingController _codeController = TextEditingController();
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Track when user reaches code entry screen
    ServiceInjector().analyticsService.trackCodeEntryScreenReached();
  }

  void _showInfoDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text("What's this code?", style: theme.textTheme.titleLarge),
          content: Text(
            "This code lets you connect your wallet safely. Only your parent should give you this code!",
            style: theme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Got it!',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _scanCode() async {
    try {
      final String? nwcUri = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const QrScanView()),
      );

      // Handle the scan result
      if (!mounted) return;

      if (nwcUri == null || nwcUri.isEmpty) {
        // User cancelled or no QR code detected
        return;
      }

      setState(() {
        _codeController.text = nwcUri;
      });

      _showFlushbar('QR code scanned successfully!', isSuccess: true);
    } catch (e) {
      if (mounted) {
        _showFlushbar(
          'Failed to open camera. Please check permissions.',
          isSuccess: false,
        );
      }
    }
  }

  void _pasteFromClipboard() async {
    ClipboardData? data = await Clipboard.getData('text/plain');
    if (data != null && data.text != null) {
      setState(() {
        _codeController.text = data.text!;
      });
      _showFlushbar('Code pasted successfully!', isSuccess: true);
    } else {
      _showFlushbar('Nothing to paste', isSuccess: false);
    }
  }

  void _showFlushbar(String message, {required bool isSuccess}) {
    if (isSuccess) {
      showSuccessFlushbar(context, message: message);
    } else {
      showErrorFlushbar(context, message: message);
    }
  }

  void _launchTermsOfUse() async {
    try {
      await ExternalBrowserService.launchLink(
        context,
        linkAddress: 'https://www.nostrpay.org/terms-and-conditions',
      );
    } catch (e) {
      _showFlushbar('Failed to open Terms of Use', isSuccess: false);
    }
  }

  void _launchPrivacyPolicy() async {
    try {
      await ExternalBrowserService.launchLink(
        context,
        linkAddress: 'https://www.nostrpay.org/privacy-policy',
      );
    } catch (e) {
      _showFlushbar('Failed to open Privacy Policy', isSuccess: false);
    }
  }

  void _validateAndConnect() async {
    if (_codeController.text.trim().isEmpty) {
      _showFlushbar('Please enter the magic code first', isSuccess: false);
      return;
    }

    final sdkCubit = context.read<SdkConnectivityCubit>();
    final navigator = Navigator.of(context);
    final loaderRoute = createLoaderRoute(context);
    navigator.push(loaderRoute);

    try {
      await sdkCubit.registerOrRestoreConnection(
        connectionURI: _codeController.text.trim(),
      );
      await OnboardingPreferences.setOnboardingComplete(true);

      // Cancel onboarding reminders since user completed setup
      await ServiceInjector().notificationService.cancelOnboardingReminders();

      // Track successful wallet connection
      final analyticsService = ServiceInjector().analyticsService;
      await analyticsService.trackWalletConnected();

      navigator.pushReplacement(
        MaterialPageRoute(builder: (context) => const SuccessScreen()),
      );
    } catch (e) {
      _showFlushbar('Failed to connect wallet', isSuccess: false);
    } finally {
      navigator.removeRoute(loaderRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppPageScaffold(
      title: 'Enter Magic Code',
      centerTitle: true,
      showBackButton: widget.showBackButton,
      actions: [
        IconButton(
          onPressed: _showInfoDialog,
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
      body: Column(
        children: [
          SizedBox(height: 24),

          // Mascot
          SizedBox(
            width: 200,
            height: 200,
            child: SvgPicture.asset('assets/mascot/Astrology.svg'),
          ),

          const SizedBox(height: 24),

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

          const SizedBox(height: 24),

          // Code input field
          Container(
            decoration: theme.containerTheme.smallWhiteContainer,
            child: TextField(
              controller: _codeController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'Magic Code',
                hintText: 'Paste your connection code here...',
                labelStyle: theme.textTheme.bodySmall,
                hintStyle: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary.withOpacity(0.6),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.all(20),
                suffixIcon: _codeController.text.isNotEmpty
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
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
        ],
      ),
      footer: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Terms and Privacy Policy text
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: theme.textTheme.labelMedium?.copyWith(
                  height: 1.3,
                ),
                children: [
                  const TextSpan(
                    text: 'By connecting your wallet, you agree to our ',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  TextSpan(
                    text: 'Terms of Use',
                    style: TextStyle(
                      color: AppColors.primary,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w600,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => _launchTermsOfUse(),
                  ),
                  const TextSpan(
                    text: ' and ',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: AppColors.primary,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w600,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => _launchPrivacyPolicy(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              text: 'Connect My Wallet!',
              onPressed: _isLoading ? null : _validateAndConnect,
              enabled: _codeController.text.trim().isNotEmpty,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

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
