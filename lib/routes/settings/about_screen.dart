import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nostr_pay_kids/component_library/component_library.dart';
import 'package:nostr_pay_kids/services/external_browser_service.dart';
import 'package:nostr_pay_kids/services/service_injector.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _versionText = 'Loading...';
  String _appName = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    final appVersionService = ServiceInjector().appVersionService;
    if (!appVersionService.isInitialized) {
      await appVersionService.initialize();
    }
    setState(() {
      _versionText = appVersionService.formattedVersion;
      _appName = appVersionService.appName;
    });
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppPageScaffold(
      title: 'About Nostrpay',
      body: Column(
        children: [
          const SizedBox(height: 24),

          // App Logo/Mascot
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(60),
              image: DecorationImage(
                image: AssetImage('assets/mascot/UFO_Splash.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // App Name
          Text(
            _appName,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          // Version Number
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              _versionText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 32),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Legal Links Section
              _buildSectionTitle('Legal', theme),
              const SizedBox(height: 16),
              Container(
                decoration: theme.containerTheme.whiteContainer,
                child: Column(
                  children: [
                    _buildSettingsOption(
                      icon: Icons.description_outlined,
                      title: 'Terms of Use',
                      subtitle: 'Read our terms of use',
                      color: AppColors.primary,
                      onTap: () => _launchTermsOfUse(context),
                    ),
                    const Divider(height: 1, indent: 20, endIndent: 20),
                    _buildSettingsOption(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      subtitle: 'How we handle your data',
                      color: AppColors.accent,
                      onTap: () => _launchPrivacyPolicy(context),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Community & Contact Section
              _buildSectionTitle('Community & Contact', theme),
              const SizedBox(height: 16),
              Container(
                decoration: theme.containerTheme.whiteContainer,
                child: Column(
                  children: [
                    _buildSettingsOption(
                      icon: Icons.alternate_email,
                      title: 'Follow us on X (Twitter)',
                      subtitle: '@UnitMatrixOrg',
                      color: AppColors.primary,
                      onTap: () => _launchUnitMatrixTwitter(context),
                    ),
                    const Divider(height: 1, indent: 20, endIndent: 20),
                    _buildSettingsOption(
                      icon: Icons.hub_outlined,
                      title: 'Find us on Nostr',
                      subtitle: 'The open social network',
                      color: AppColors.accent,
                      onTap: () => _launchNostr(context),
                    ),
                    const Divider(height: 1, indent: 20, endIndent: 20),
                    _buildSettingsOption(
                      icon: Icons.telegram,
                      title: 'Join our Telegram Group',
                      subtitle: 'Connect with the community',
                      color: AppColors.primary,
                      onTap: () => _launchTelegram(context),
                    ),
                    const Divider(height: 1, indent: 20, endIndent: 20),
                    _buildSettingsOption(
                      icon: Icons.support_agent,
                      title: 'Contact & Support',
                      subtitle: 'hello@unitmatrix.org',
                      color: AppColors.success,
                      onTap: () => _launchEmail(context),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Creator credit
          InkWell(
            onTap: () => _launchAnipyTwitter(context),
            child: Text(
              "Created by Aniket A. (@Anipy1)",
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.primary,
                decoration: TextDecoration.underline,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 8),

          // Made with love
          // Container(
          //   padding: const EdgeInsets.all(16),
          //   decoration: BoxDecoration(
          //     color: AppColors.background,
          //     borderRadius: BorderRadius.circular(16),
          //     border: Border.all(
          //       color: AppColors.primary.withValues(alpha: 0.1),
          //       width: 1,
          //     ),
          //   ),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       Icon(
          //         Icons.favorite,
          //         color: AppColors.secondary,
          //         size: 20,
          //       ),
          //       const SizedBox(width: 8),
          //       Expanded(
          //         child: Text(
          //           'Made with love for the Bitcoin community',
          //           style: theme.textTheme.bodySmall?.copyWith(
          //             color: AppColors.textSecondary,
          //             fontStyle: FontStyle.italic,
          //           ),
          //           textAlign: TextAlign.center,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildSettingsOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          leading: Container(
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

  void _launchTermsOfUse(BuildContext context) async {
    try {
      await ExternalBrowserService.launchLink(
        context,
        linkAddress: 'https://www.nostrpay.org/terms-and-conditions',
      );
    } catch (e) {
      if (mounted) {
        _showErrorFlushbar(context, 'Failed to open Terms of Use');
      }
    }
  }

  void _launchPrivacyPolicy(BuildContext context) async {
    try {
      await ExternalBrowserService.launchLink(
        context,
        linkAddress: 'https://www.nostrpay.org/privacy-policy',
      );
    } catch (e) {
      if (mounted) {
        _showErrorFlushbar(context, 'Failed to open Privacy Policy');
      }
    }
  }

  void _launchUnitMatrixTwitter(BuildContext context) async {
    try {
      await ExternalBrowserService.launchLink(
        context,
        linkAddress: 'https://x.com/UnitMatrixOrg',
      );
    } catch (e) {
      if (mounted) {
        _showErrorFlushbar(context, 'Failed to open X (Twitter)');
      }
    }
  }

  void _launchAnipyTwitter(BuildContext context) async {
    try {
      await ExternalBrowserService.launchLink(
        context,
        linkAddress: 'https://x.com/Anipy1',
      );
    } catch (e) {
      if (mounted) {
        _showErrorFlushbar(context, 'Failed to open X (Twitter)');
      }
    }
  }

  void _launchNostr(BuildContext context) async {
    try {
      await ExternalBrowserService.launchLink(
        context,
        linkAddress:
            'https://primal.net/p/nprofile1qqs2gxr7hu6p738knyqudxwgszp89ecqzts3sx8za2dzj6vctmfrfwcczenhr',
      );
    } catch (e) {
      if (mounted) {
        _showErrorFlushbar(context, 'Failed to open Nostr profile');
      }
    }
  }

  void _launchTelegram(BuildContext context) async {
    try {
      await ExternalBrowserService.launchLink(
        context,
        linkAddress: 'https://t.me/nostrpaytesters',
      );
    } catch (e) {
      if (mounted) {
        _showErrorFlushbar(context, 'Failed to open Telegram group');
      }
    }
  }

  void _launchEmail(BuildContext context) async {
    try {
      await ExternalBrowserService.launchEmail(
        context,
        emailAddress: 'hello@unitmatrix.org',
      );
    } catch (e) {
      if (mounted) {
        _showErrorFlushbar(context, 'Failed to open email client');
      }
    }
  }

  void _showErrorFlushbar(BuildContext context, String message) {
    showErrorFlushbar(context, message: message);
  }
}
