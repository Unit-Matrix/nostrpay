import 'package:shared_preferences/shared_preferences.dart';

import 'analytics_service.dart';
import 'app_version_service.dart';
import 'credentials_manager.dart';
import 'device_client.dart';
import 'keychain.dart';
import 'nostrpay_logger.dart';
import 'notification_service.dart';
import 'nwc_ndk_sdk.dart';

class ServiceInjector {
  static final ServiceInjector _singleton = ServiceInjector._internal();
  static ServiceInjector? _injector;

  NWCNdkSDK? _nwcNdkSDK;
  DeviceClient? _deviceClient;
  Future<SharedPreferences>? _sharedPreferences =
      SharedPreferences.getInstance();
  KeyChain? _keychain;
  CredentialsManager? _credentialsManager;
  NostrpayLogger? _nostrpayLogger;
  AnalyticsService? _analyticsService;
  NotificationService? _notificationService;
  AppVersionService? _appVersionService;

  factory ServiceInjector() => _injector ?? _singleton;

  ServiceInjector._internal();

  static void configure(ServiceInjector injector) => _injector = injector;

  DeviceClient get deviceClient => _deviceClient ??= DeviceClient();

  Future<SharedPreferences> get sharedPreferences =>
      _sharedPreferences ??= SharedPreferences.getInstance();

  KeyChain get keychain => _keychain ??= KeyChain();

  CredentialsManager get credentialsManager =>
      _credentialsManager ??= CredentialsManager(keyChain: keychain);

  NostrpayLogger get nostrpayLogger => _nostrpayLogger ??= NostrpayLogger();

  NWCNdkSDK get nwcNdkSDK => _nwcNdkSDK ??= NWCNdkSDK();

  AnalyticsService get analyticsService =>
      _analyticsService ??= AnalyticsService();

  NotificationService get notificationService =>
      _notificationService ??= NotificationService();

  AppVersionService get appVersionService =>
      _appVersionService ??= AppVersionService();
}
