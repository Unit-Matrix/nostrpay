import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nostr_pay_kids/cubit/user_profile/user_profile_cubit.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:nostr_pay_kids/component_library/component_library.dart';
import 'package:nostr_pay_kids/models/ecash_item.dart';

class EcashQrViewScreen extends StatelessWidget {
  final EcashItem ecashItem;
  final VoidCallback onMarkAsUsed;

  const EcashQrViewScreen({
    super.key,
    required this.ecashItem,
    required this.onMarkAsUsed,
  });

  void _showMarkAsUsedDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text('Mark as Used?', style: theme.textTheme.titleLarge),
        content: Text(
          'Did they scan your Ecash? Mark it as used so you know it\'s been spent.',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              'Not Yet',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onMarkAsUsed();
              Navigator.pop(context); // Close QR view screen
            },
            child: Text(
              'Yes, Mark as Used',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.honeySuckle,
      body: Center(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Calculate dimensions based on the rotated view
              final billWidth = constraints.maxHeight * 0.95;
              final billHeight = constraints.maxWidth * 0.95;

              return RotatedBox(
                quarterTurns: 1,
                child: SizedBox(
                  height: billHeight,
                  width: billWidth,
                  child: _buildBitcoinBill(context),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBitcoinBill(BuildContext context) {
    final userProfileState = context.watch<UserProfileCubit>().state;
    final String userName = userProfileState.name;
    final String avatarAsset = userProfileState.selectedAvatar.assetPath;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.honeySuckle,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppColors.textPrimary,
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.15),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      // We keep Stack for Background Decorations and Footers only
      child: Stack(
        children: [
          // --- BACKGROUND SHAPES (Keep these Positioned) ---
          // Top left - Back button (subtle)
          Positioned(
            top: 20,
            left: 30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.textPrimary.withValues(alpha: 0.1),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Bottom right - Decorative circle
          Positioned(
            bottom: 20,
            right: 30,
            child: GestureDetector(
              onTap: () => _showMarkAsUsedDialog(context),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.textPrimary.withValues(alpha: 0.1),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  color: AppColors.textPrimary.withValues(alpha: 0.2),
                  size: 28,
                ),
              ),
            ),
          ),

          // --- MAIN CONTENT (Use Row for perfect alignment) ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 1. LEFT SECTION (Mascot)
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 110, // Slightly adjusted size
                        height: 110,
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.textPrimary,
                            width: 2,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: SvgPicture.asset(avatarAsset),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        userName.toUpperCase(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. CENTER SECTION (Value)
                Expanded(
                  flex: 3, // Give the center more space
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'BITCOIN ECASH',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Using a Row to center the Symbol and Number nicely
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            '₿',
                            style: TextStyle(
                              fontSize: 70,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              height: 1.0,
                            ),
                          ),
                          SizedBox(width: 10),
                          const Text(
                            '21',
                            style: TextStyle(
                              fontSize: 70,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.textPrimary,
                            width: 1,
                          ),
                        ),
                        child: const Text(
                          '"Immutable Money"',
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. RIGHT SECTION (QR Code)
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onDoubleTap: () {
                          Clipboard.setData(
                              ClipboardData(text: ecashItem.token));
                          showSuccessFlushbar(
                            context,
                            message: 'Ecash token copied to clipboard!',
                          );
                        },
                        child: Container(
                          width: 160, // INCREASED SIZE (was 130)
                          height: 160,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            border: Border.all(
                              color: AppColors.textPrimary,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: QrImageView(
                            data: ecashItem.token,
                            version: QrVersions.auto,
                            backgroundColor: AppColors.surface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock,
                              size: 14, color: AppColors.textPrimary),
                          SizedBox(width: 6),
                          Text(
                            'SECURE',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- FOOTER ELEMENTS (Keep these Positioned) ---
          Positioned(
            bottom: 20,
            left:
                40, // Moved "2009" to left for balance, or keep right if preferred
            child: Text(
              '2025',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary.withValues(alpha: 0.2),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Created by $userName Nakamoto',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textPrimary.withValues(alpha: 0.5),
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


/*
class EcashQrViewScreen2 extends StatelessWidget {
  final EcashItem ecashItem;
  final VoidCallback onMarkAsUsed;

  const EcashQrViewScreen2({
    super.key,
    required this.ecashItem,
    required this.onMarkAsUsed,
  });

  void _showMarkAsUsedDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text('Mark as Used?', style: theme.textTheme.titleLarge),
        content: Text(
          'Did they scan your Ecash? Mark it as used so you know it\'s been spent.',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Not Yet',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onMarkAsUsed();
              Navigator.pop(context); // Close QR view screen
            },
            child: Text(
              'Yes, Mark as Used',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: BackButtonAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // Title
              Text(
                'Pay with Your Ecash',
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // QR Code
              Container(
                padding: const EdgeInsets.all(24),
                decoration: theme.containerTheme.whiteContainer,
                child: QrImageView(
                  data: ecashItem.token,
                  size: 250,
                  backgroundColor: Colors.white,
                ),
              ),

              const SizedBox(height: 32),

              // Instructions
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: theme.containerTheme.whiteContainer,
                child: Column(
                  children: [
                    Text(
                      'Show this to the person you\'re paying',
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'They\'ll scan it with their wallet',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.wifi_off,
                          size: 16,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Works even without internet!',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // Mark as Used button
              PrimaryButton(
                text: 'Mark as Used',
                onPressed: () => _showMarkAsUsedDialog(context),
                backgroundColor: AppColors.success,
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
 */