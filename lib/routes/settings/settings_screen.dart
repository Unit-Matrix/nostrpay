import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:logging/logging.dart';
import 'package:nostr_pay_kids/component_library/component_library.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_pay_kids/cubit/user_profile/user_profile_cubit.dart';
import 'package:nostr_pay_kids/cubit/user_profile/user_profile_state.dart';
import 'package:nostr_pay_kids/cubit/sdk_connectivity/sdk_connectivity_cubit.dart';
import 'package:nostr_pay_kids/routes/settings/edit_profile_screen.dart';
import 'package:nostr_pay_kids/routes/settings/connection_info_screen.dart';
import 'package:nostr_pay_kids/routes/settings/credits_screen.dart';
import 'package:nostr_pay_kids/routes/settings/about_screen.dart';
import 'package:nostr_pay_kids/models/fiat_currency.dart';
import 'package:nostr_pay_kids/cubit/currency/currency_cubit.dart';
import 'package:nostr_pay_kids/cubit/currency/currency_state.dart';

final _logger = Logger("SettingsScreen");

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppPageScaffold(
      title: 'Settings',
      body: Column(
        children: [
          const SizedBox(height: 18),
          _buildProfileCard(context),
          const SizedBox(height: 40),
          _buildSectionTitle('Wallet', theme),
          const SizedBox(height: 16),
          Container(
            decoration: theme.containerTheme.whiteContainer,
            child: Column(
              children: [
                _buildCurrencyCard(context),
                const Divider(height: 1, indent: 20, endIndent: 20),
                _buildSettingsOption(
                  icon: Icons.link_outlined,
                  title: 'Connection Info',
                  subtitle: 'Check your wallet connection',
                  color: AppColors.success,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ConnectionInfoScreen(),
                    ),
                  ),
                ),
                const Divider(height: 1, indent: 20, endIndent: 20),
                _buildSettingsOption(
                  icon: Icons.library_books_outlined,
                  title: 'Credits',
                  subtitle: 'Libraries and acknowledgments',
                  color: AppColors.accent,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreditsScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          _buildSectionTitle('About', theme),
          const SizedBox(height: 16),
          Container(
            decoration: theme.containerTheme.whiteContainer,
            child: _buildSettingsOption(
              icon: Icons.info_outline,
              title: 'About Nostrpay',
              subtitle: 'Version, legal, and more',
              color: AppColors.accent,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AboutScreen(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          _buildSectionTitle('Danger Zone', theme),
          const SizedBox(height: 16),
          Container(
            decoration: theme.containerTheme.whiteContainer,
            child: _buildSettingsOption(
              icon: Icons.logout,
              title: 'Disconnect Wallet',
              subtitle: 'This will reset the app',
              color: AppColors.error,
              onTap: () => _showDisconnectDialog(context),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // HELPER METHODS FOR BUILDING UI SECTIONS

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title.toUpperCase(),
      style: theme.textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<UserProfileCubit, UserProfileState>(
      builder: (context, userProfileState) {
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EditProfileScreen(),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: theme.containerTheme.whiteContainer,
            child: Row(
              children: [
                // Avatar
                SizedBox(
                  width: 60,
                  height: 60,
                  // ... decoration
                  child: Center(
                    child: SvgPicture.asset(
                      userProfileState.selectedAvatar.assetPath,
                      width: 40,
                      height: 40,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // User info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userProfileState.name,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap to edit your profile',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.textSecondary.withOpacity(0.5),
                  size: 16,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrencyCard(BuildContext context) {
    return BlocBuilder<CurrencyCubit, CurrencyState>(
      builder: (context, currencyState) {
        return _buildSettingsOption(
          icon:
              Icons.currency_bitcoin, // This will be replaced by custom widget
          title: 'Display Currency',
          subtitle: currencyState.selectedFiat.label,
          color: AppColors.primary,
          onTap: () => _showCurrencyPicker(context, currencyState),
          customLeading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                currencyState.selectedFiat.symbol,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // NEW: MODAL BOTTOM SHEET FOR CURRENCY
  void _showCurrencyPicker(BuildContext context, CurrencyState currencyState) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Select Currency',
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: currencyState.rates.isNotEmpty
                        ? currencyState.rates.keys.length
                        : supportedCurrencies.length,
                    itemBuilder: (context, index) {
                      final fiat = currencyState.rates.isNotEmpty
                          ? currencyState.rates.keys.elementAt(index)
                          : supportedCurrencies[index];
                      final isSelected = fiat == currencyState.selectedFiat;
                      return ListTile(
                        leading: Text(
                          fiat.symbol,
                          style: const TextStyle(fontSize: 24),
                        ),
                        title:
                            Text(fiat.label, style: theme.textTheme.bodyLarge),
                        trailing: isSelected
                            ? Icon(Icons.check_circle, color: AppColors.success)
                            : null,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          context.read<CurrencyCubit>().changeFiat(fiat);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    Widget? customLeading,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);

        // REFINEMENT: Use ListTile for better semantics and tap feedback.
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          onTap: () {
            // Add haptic feedback for a satisfying tap
            HapticFeedback.lightImpact();
            onTap();
          },
          leading: customLeading ??
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
          title: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(fontSize: 16),
          ),
          subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
            size: 16,
          ),
        );
      },
    );
  }

  void _showDisconnectDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text('Disconnect Wallet?', style: theme.textTheme.titleLarge),
          content: Text(
            'Are you sure you want to disconnect your wallet? You\'ll need to reconnect to use the app again.',
            style: theme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _performDisconnect(context);
                },
                child: Text(
                  'Disconnect',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performDisconnect(BuildContext context) async {
    final theme = Theme.of(context);

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: AppColors.primary),
                  const SizedBox(height: 16),
                  Text('Disconnecting...', style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          );
        },
      );

      // Call disconnect method
      await context.read<SdkConnectivityCubit>().disconnect();

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Navigate to welcome screen
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/intro');
      }
    } catch (e) {
      _logger.info('Error disconnecting wallet: $e');
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/intro');
      }
    }
  }
}
