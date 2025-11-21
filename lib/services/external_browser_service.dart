import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:logging/logging.dart';
import 'package:nostr_pay_kids/component_library/component_library.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

final Logger _logger = Logger('ExternalBrowserService');

/// Service for handling external browser interactions
class ExternalBrowserService {
  /// Private constructor to prevent instantiation
  ExternalBrowserService._();

  /// Launches a link in an external browser
  ///
  /// [context] The build context for UI elements
  /// [linkAddress] The URL to open in the browser
  /// Returns a Future that completes when the browser is launched
  static Future<void> launchLink(BuildContext context,
      {required String linkAddress}) async {
    final NavigatorState navigator = Navigator.of(context);
    final TransparentPageRoute<void> loaderRoute = createLoaderRoute(context);

    _logger.info('Launching link: $linkAddress');
    navigator.push(loaderRoute);

    try {
      if (await canLaunchUrlString(linkAddress)) {
        await ChromeSafariBrowser().open(
          url: WebUri(linkAddress),
          settings: ChromeSafariBrowserSettings(
            // Android
            shareState: CustomTabsShareState.SHARE_STATE_ON,
            // iOS
            dismissButtonStyle: DismissButtonStyle.CLOSE,
            barCollapsingEnabled: true,
          ),
        );
      } else {
        throw Exception('Could not launch $linkAddress');
      }
    } catch (error) {
      _logger.warning('Failed to launch link: $error', error);
      rethrow;
    } finally {
      if (navigator.canPop()) {
        navigator.removeRoute(loaderRoute);
      }
    }
  }

  static Future<void> launchEmail(BuildContext context,
      {required String emailAddress}) async {
    final NavigatorState navigator = Navigator.of(context);
    final TransparentPageRoute<void> loaderRoute = createLoaderRoute(context);

    _logger.info('Launching email: $emailAddress');
    navigator.push(loaderRoute);

    try {
      final emailUri = Uri(
        scheme: 'mailto',
        path: emailAddress,
      );

      if (!await launchUrl(emailUri)) {
        throw Exception('Could not launch email client');
      }
    } catch (error) {
      _logger.warning('Failed to launch email: $error', error);
      rethrow;
    } finally {
      if (navigator.canPop()) {
        navigator.removeRoute(loaderRoute);
      }
    }
  }

  /// Checks if a URL can be launched
  ///
  /// [url] The URL to check
  /// Returns true if the URL can be launched
  static Future<bool> canLaunchUrl(String url) async {
    try {
      return await canLaunchUrlString(url);
    } catch (e) {
      _logger.warning('Error checking if URL can be launched: $e');
      return false;
    }
  }
}
