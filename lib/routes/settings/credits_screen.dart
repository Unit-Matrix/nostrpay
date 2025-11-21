import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nostr_pay_kids/component_library/component_library.dart';
import 'package:nostr_pay_kids/services/external_browser_service.dart';

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppPageScaffold(
      title: 'Credits',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 18),

          // App Info Section
          _buildAppInfoSection(context),
          const SizedBox(height: 24),

          // Framework Section
          _buildSectionTitle('Framework', theme),
          const SizedBox(height: 16),
          _buildFrameworkCard(context),
          const SizedBox(height: 24),

          // Core Libraries Section
          _buildSectionTitle('Core Libraries', theme),
          const SizedBox(height: 16),
          _buildCoreLibrariesSection(context),
          const SizedBox(height: 24),

          // UI & UX Libraries Section
          _buildSectionTitle('UI & UX Libraries', theme),
          const SizedBox(height: 16),
          _buildUILibrariesSection(context),
          const SizedBox(height: 24),

          // Networking & Data Section
          _buildSectionTitle('Networking & Data', theme),
          const SizedBox(height: 16),
          _buildNetworkingSection(context),
          const SizedBox(height: 24),

          // Assets Section
          _buildSectionTitle('Assets & Fonts', theme),
          const SizedBox(height: 16),
          _buildAssetsSection(context),
          const SizedBox(height: 24),

          // Special Thanks Section
          _buildSectionTitle('Special Thanks', theme),
          const SizedBox(height: 16),
          _buildSpecialThanksSection(context),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title.toUpperCase(),
      style: theme.textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildAppInfoSection(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: theme.containerTheme.actionButtonContainer(AppColors.primary),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.favorite,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => _launchUrl(context, 'https://www.unitmatrix.org/'),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    'UnitMatrix',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.open_in_new,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Made with ❤️ for the Bitcoin community',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFrameworkCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: theme.containerTheme.whiteContainer,
      child: _buildCreditsItem(
        icon: Icons.flutter_dash,
        title: 'Built with Flutter',
        subtitle: 'UI Framework',
        description:
            'Software development toolkit for building cross-platform apps from a single codebase.',
        color: const Color(0xFF02569B),
        url: 'https://flutter.dev',
      ),
    );
  }

  Widget _buildCoreLibrariesSection(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: theme.containerTheme.whiteContainer,
      child: Column(
        children: [
          _buildCreditsItem(
            icon: Icons.bolt,
            title: 'Nostr Development Kit (NDK)',
            subtitle: 'Nostr Protocol Implementation',
            description: 'Core Nostr functionality and NWC connection logic',
            color: AppColors.primary,
            url: 'https://github.com/relaystr/ndk',
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          _buildCreditsItem(
            icon: Icons.bluetooth_connected,
            title: 'flutter_bloc',
            subtitle: 'State Management',
            description:
                'Predictable state management for Flutter applications',
            color: AppColors.success,
            url: 'https://bloclibrary.dev',
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          _buildCreditsItem(
            icon: Icons.storage,
            title: 'hydrated_bloc',
            subtitle: 'Persistent State Management',
            description: 'Automatic state persistence for BLoC pattern',
            color: AppColors.secondary,
            url: 'https://bloclibrary.dev',
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          _buildCreditsItem(
            icon: Icons.security,
            title: 'flutter_secure_storage',
            subtitle: 'Secure Data Storage',
            description:
                'Secure storage for sensitive data like keys and credentials',
            color: AppColors.accent,
            url: 'https://pub.dev/packages/flutter_secure_storage',
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          _buildCreditsItem(
            icon: Icons.info,
            title: 'package_info_plus',
            subtitle: 'App Information',
            description: 'Access to app version and package information',
            color: AppColors.warning,
            url: 'https://pub.dev/packages/package_info_plus',
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          _buildCreditsItem(
            icon: Icons.notifications,
            title: 'flutter_local_notifications',
            subtitle: 'Local Notifications',
            description: 'Display local notifications on device',
            color: AppColors.primary,
            url: 'https://pub.dev/packages/flutter_local_notifications',
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          _buildCreditsItem(
            icon: Icons.analytics,
            title: 'PostHog',
            subtitle: 'Analytics Platform',
            description:
                'Helps us understand how the app is used so we can make it better.',
            color: AppColors.accent,
            url: 'https://posthog.com',
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkingSection(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: theme.containerTheme.whiteContainer,
      child: Column(
        children: [
          _buildCreditsItem(
            icon: Icons.wifi,
            title: 'connectivity_plus',
            subtitle: 'Network Connectivity',
            description: 'Monitor network connectivity status',
            color: AppColors.primary,
            url: 'https://pub.dev/packages/connectivity_plus',
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          _buildCreditsItem(
            icon: Icons.http,
            title: 'dio',
            subtitle: 'HTTP Client',
            description: 'Powerful HTTP client for network requests',
            color: AppColors.success,
            url: 'https://pub.dev/packages/dio',
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          _buildCreditsItem(
            icon: Icons.link,
            title: 'url_launcher',
            subtitle: 'URL Handling',
            description: 'Launch URLs in external browsers',
            color: AppColors.accent,
            url: 'https://pub.dev/packages/url_launcher',
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          _buildCreditsItem(
            icon: Icons.web,
            title: 'flutter_inappwebview',
            subtitle: 'In-App Web Browser',
            description: 'Custom in-app web browser implementation',
            color: AppColors.secondary,
            url: 'https://pub.dev/packages/flutter_inappwebview',
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          _buildCreditsItem(
            icon: Icons.bolt,
            title: 'bolt11_decoder',
            subtitle: 'Lightning Invoice Decoder',
            description: 'Decode Lightning Network payment invoices',
            color: AppColors.warning,
            url: 'https://github.com/fusion44/dart_bolt11_decoder',
          ),
        ],
      ),
    );
  }

  Widget _buildUILibrariesSection(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: theme.containerTheme.whiteContainer,
      child: Column(
        children: [
          _buildCreditsItem(
            icon: Icons.qr_code,
            title: 'qr_flutter',
            subtitle: 'QR Code Generation',
            description: 'QR code generation and display for Flutter',
            color: AppColors.primary,
            url: 'https://pub.dev/packages/qr_flutter',
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          _buildCreditsItem(
            icon: Icons.camera_alt,
            title: 'mobile_scanner',
            subtitle: 'QR Code Scanner',
            description: 'Fast and efficient QR code scanning',
            color: AppColors.success,
            url: 'https://pub.dev/packages/mobile_scanner',
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          _buildCreditsItem(
            icon: Icons.image,
            title: 'flutter_svg',
            subtitle: 'SVG Rendering',
            description: 'SVG rendering and display for Flutter',
            color: AppColors.secondary,
            url: 'https://pub.dev/packages/flutter_svg',
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          _buildCreditsItem(
            icon: Icons.notification_important,
            title: 'another_flushbar',
            subtitle: 'Toast Notifications',
            description: 'Beautiful and customizable toast notifications',
            color: AppColors.warning,
            url: 'https://pub.dev/packages/another_flushbar',
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          _buildCreditsItem(
            icon: Icons.celebration,
            title: 'flutter_confetti',
            subtitle: 'Confetti Animation',
            description: 'Celebratory confetti animations for success moments',
            color: AppColors.success,
            url: 'https://pub.dev/packages/flutter_confetti',
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          _buildCreditsItem(
            icon: Icons.animation,
            title: 'flutter_animate',
            subtitle: 'Smooth Animations',
            description: 'Easy-to-use animations for Flutter widgets',
            color: AppColors.accent,
            url: 'https://pub.dev/packages/flutter_animate',
          ),
        ],
      ),
    );
  }

  Widget _buildAssetsSection(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: theme.containerTheme.whiteContainer,
      child: Column(
        children: [
          _buildCreditsItem(
            icon: Icons.font_download,
            title: 'Comic Neue',
            subtitle: 'Typography by Google Fonts',
            description: 'Friendly and readable font family for the app',
            color: AppColors.primary,
            url: 'https://fonts.google.com/specimen/Comic+Neue',
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          _buildCreditsItem(
            icon: Icons.emoji_emotions,
            title: 'Bitcoin Mascots',
            subtitle: 'Community Artwork',
            description:
                'The wonderful characters that bring our app to life. Thank you!',
            color: AppColors.secondary,
            url: 'https://www.herecomesbitcoin.org/',
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialThanksSection(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: theme.containerTheme.whiteContainer,
      child: Column(
        children: [
          _buildCreditsItem(
            icon: Icons.people,
            title: 'Bitcoin Design Community',
            subtitle: 'Open Source Contributors',
            description:
                'To all the designers and contributors in the Bitcoin ecosystem',
            color: AppColors.primary,
            url: 'https://bitcoin.design/',
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          _buildCreditsItem(
            icon: Icons.lightbulb,
            title: 'Nostr Protocol',
            subtitle: 'Open Social Protocol',
            description:
                'For creating the free and open protocol that makes this all possible.',
            color: AppColors.success,
            url: 'https://github.com/nostr-protocol/nips',
          ),
        ],
      ),
    );
  }

  Widget _buildCreditsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required Color color,
    String? url,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return InkWell(
          onTap: url != null ? () => _launchUrl(context, url) : null,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (url != null)
                            Icon(
                              Icons.open_in_new,
                              size: 16,
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.7,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
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

  void _launchUrl(BuildContext context, String url) async {
    try {
      await ExternalBrowserService.launchLink(
        context,
        linkAddress: url,
      );
    } catch (e) {
      // Fallback to clipboard if browser launch fails
      Clipboard.setData(ClipboardData(text: url));
      showErrorFlushbar(context, message: 'Failed to open URL');
    }
  }
}
