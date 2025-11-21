import 'package:logging/logging.dart' show Logger;
import 'package:package_info_plus/package_info_plus.dart';

final Logger _logger = Logger('AppVersionService');

/// Service for managing app version information
///
/// Usage examples:
/// ```dart
/// // Get the service instance
/// final appVersionService = ServiceInjector().appVersionService;
///
/// // Get version information
/// String version = appVersionService.version; // "0.1.0"
/// String formatted = appVersionService.formattedVersion; // "Version 0.1.0"
/// String short = appVersionService.shortVersion; // "v0.1.0"
/// ```
class AppVersionService {
  PackageInfo? _packageInfo;
  bool _isInitialized = false;

  /// Initialize the app version info
  Future<void> initialize() async {
    _logger.info('Initializing app version service');
    if (!_isInitialized) {
      try {
        _packageInfo = await PackageInfo.fromPlatform();
        _isInitialized = true;
      } catch (e) {
        _logger.info('Failed to get package info: $e');
      }
    }
  }

  /// Get the app version (e.g., "1.0.0")
  String get version {
    return _packageInfo?.version ?? 'Unknown';
  }

  /// Get the build number (e.g., "1")
  String get buildNumber {
    return _packageInfo?.buildNumber ?? '';
  }

  /// Get the app name
  String get appName {
    return _packageInfo?.appName ?? 'Nostrpay';
  }

  /// Get the package name
  String get packageName {
    return _packageInfo?.packageName ?? '';
  }

  /// Get formatted version string (e.g., "Version 1.0.0 (Build 1)")
  String get formattedVersion {
    if (buildNumber.isNotEmpty) {
      return 'Version $version (Build $buildNumber)';
    }
    return 'Version $version';
  }

  /// Get short version string (e.g., "v1.0.0")
  String get shortVersion {
    return 'v$version';
  }

  /// Check if the service is initialized
  bool get isInitialized => _isInitialized;
}
