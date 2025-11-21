import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:logging/logging.dart';

final _logger = Logger("NotificationService");

class NotificationService {
  // Singleton pattern
  static final NotificationService _notificationService =
      NotificationService._internal();
  factory NotificationService() {
    return _notificationService;
  }
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    _logger.info('Initializing notification service');

    // Initialization settings for Android
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Initialization settings for iOS
    const DarwinInitializationSettings darwinInitializationSettings =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      iOS: darwinInitializationSettings,
    );

    // Initialize timezone database
    tz.initializeTimeZones();

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Request permissions for iOS
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    // Request permissions for Android 13+
    await _requestAndroidPermissions();
  }

  /// Request Android notification and exact alarm permissions
  Future<void> _requestAndroidPermissions() async {
    final androidImplementation =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      // Request notification permission for Android 13+
      final bool? notificationPermissionGranted =
          await androidImplementation.requestNotificationsPermission();
      _logger.info(
          'Android notification permission granted: $notificationPermissionGranted');

      // Request exact alarm permission for Android 14+ (required for exactAllowWhileIdle)
      final bool? exactAlarmPermissionGranted =
          await androidImplementation.requestExactAlarmsPermission();
      _logger.info(
          'Android exact alarm permission granted: $exactAlarmPermissionGranted');
    }
  }

  Future<void> scheduleDailyNotifications() async {
    _logger.info('Scheduling daily notifications');

    await _scheduleDailyNotification(
      id: 0,
      title: '💰 Check Your Sats!',
      body: 'Ready to manage your sats today?',
      hour: 9, // 9 AM
      minute: 0,
    );

    await _scheduleDailyNotification(
      id: 1,
      title: '📊 Daily Summary',
      body: 'Did you save or spend any sats today? Check your progress!',
      hour: 19, // 7 PM
      minute: 0,
    );
  }

  // For users who haven't completed onboarding - re-engagement notifications
  Future<void> scheduleOnboardingReminders() async {
    _logger.info('Scheduling onboarding reminders');

    await _scheduleDailyNotification(
      id: 10,
      title: '🚀 Ready to Start Your Bitcoin Journey?',
      body: 'Connect your wallet and start managing sats with Nostrpay!',
      hour: 10, // 10 AM
      minute: 0,
    );

    await _scheduleDailyNotification(
      id: 11,
      title: '💡 Learn About Bitcoin Today!',
      body:
          'Complete your setup and discover how to save and spend sats safely.',
      hour: 16, // 4 PM
      minute: 0,
    );
  }

  Future<void> _scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    try {
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      // Try to schedule with exact timing first (requires permission on Android 14+)
      // If exact alarm permission is not granted, the plugin will log a warning
      // but the notification will still be scheduled (just may not be exact)
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_notification_channel_id',
            'Daily Notifications',
            channelDescription: 'Daily reminder notifications',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents:
            DateTimeComponents.time, // This makes it repeat daily
      );

      _logger.info(
          'Successfully scheduled notification id: $id for $hour:${minute.toString().padLeft(2, '0')}');
    } catch (e, stackTrace) {
      _logger.severe('Failed to schedule notification id: $id', e, stackTrace);
      // Don't rethrow - allow app to continue even if notification scheduling fails
    }
  }

  Future<void> cancelAllNotifications() async {
    _logger.info('Cancelling all notifications');

    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  // Test method to show an immediate notification
  Future<void> showTestNotification() async {
    await _flutterLocalNotificationsPlugin.show(
      999, // Use a unique ID for test notifications
      '🧪 Test Notification',
      'This is a test notification from Nostr Pay Kids!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_notification_channel_id',
          'Test Notifications',
          channelDescription: 'Test notification channel',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  // Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    // Check iOS permissions
    final iosImplementation =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (iosImplementation != null) {
      final bool? result = await iosImplementation.requestPermissions(
          alert: true, badge: true, sound: true);
      return result ?? false;
    }

    // Check Android permissions
    final androidImplementation =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      final bool? result =
          await androidImplementation.areNotificationsEnabled();
      return result ?? false;
    }

    return false;
  }

  // Cancel only onboarding reminder notifications
  Future<void> cancelOnboardingReminders() async {
    _logger.info('Cancelling onboarding reminders');

    await _flutterLocalNotificationsPlugin.cancel(
      10,
    ); // Morning onboarding reminder
    await _flutterLocalNotificationsPlugin.cancel(
      11,
    ); // Evening onboarding reminder
  }
}
