import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_app_group_directory/flutter_app_group_directory.dart';
import 'package:logging/logging.dart';
import 'package:nostr_pay_kids/utils/constants.dart';
import 'package:path_provider/path_provider.dart';

final Logger _logger = Logger('AppConfig');

class AppConfig {
  static AppConfig? _instance;
  final String workingDir;

  AppConfig._({required this.workingDir});

  static Future<AppConfig> instance() async {
    _logger.info('Getting Config instance');
    if (_instance == null) {
      _logger.info('Creating Config instance');
      final String workingDir = await _getWorkingDir();
      _instance = AppConfig._(workingDir: workingDir);
    }
    return _instance!;
  }

  static Future<String> _getWorkingDir() async {
    String path = '';
    if (defaultTargetPlatform == TargetPlatform.android) {
      final Directory workingDir = await getApplicationDocumentsDirectory();
      path = workingDir.path;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final Directory? sharedDirectory =
          await FlutterAppGroupDirectory.getAppGroupDirectory(
        'group.$APP_ID_PREFIX.$APP_BUNDLE_ID',
      );
      if (sharedDirectory == null) {
        throw Exception('Could not get shared directory');
      }
      path = sharedDirectory.path;
    }
    _logger.info('Using workingDir: $path');
    return path;
  }
}
