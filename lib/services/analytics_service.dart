import 'package:logging/logging.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:nostr_pay_kids/config/app_secrets.dart';

final Logger _logger = Logger('AnalyticsService');

/// Enum for all analytics events to ensure type safety
enum AnalyticsEvent {
  // Onboarding events
  codeEntryScreenReached('code_entry_screen_reached'),
  walletConnected('wallet_connected'),
  walletDisconnected('wallet_disconnected'),

  // Payment events
  paymentSent('payment_sent'),
  paymentReceived('payment_received'),

  // Test events (for debugging)
  testEvent('test_event');

  const AnalyticsEvent(this.eventName);
  final String eventName;
}

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  bool _isInitialized = false;

  /// Check if we should send analytics events
  bool get _shouldSendEvents => !kDebugMode && _isInitialized;

  /// Initialize PostHog with your configuration
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final config = PostHogConfig(
        AppSecrets.posthogApiKey,
      );
      config.debug = kDebugMode; // Only enable debug in debug mode
      config.captureApplicationLifecycleEvents = true;
      config.host = AppSecrets.posthogHost;

      await Posthog().setup(config);
      _isInitialized = true;

      _logger.info(
        'PostHog initialized successfully (debug mode: $kDebugMode)',
      );
    } catch (e) {
      _logger.severe('Failed to initialize PostHog: $e');
    }
  }

  /// Generic method to track any analytics event
  Future<void> _trackEvent(
    AnalyticsEvent event, {
    Map<String, dynamic>? properties,
  }) async {
    if (!_shouldSendEvents) {
      _logger.info('Skipping ${event.eventName} event (debug mode)');
      return;
    }

    try {
      await Posthog().capture(
        eventName: event.eventName,
        properties: {
          'timestamp': DateTime.now().toIso8601String(),
          ...?properties,
        },
      );
      _logger.info('Tracked ${event.eventName} event');
    } catch (e) {
      _logger.warning('Failed to track ${event.eventName} event: $e');
    }
  }

  /// Track wallet connection event
  Future<void> trackWalletConnected() async {
    await _trackEvent(AnalyticsEvent.walletConnected);
  }

  /// Track when user reaches code entry screen
  Future<void> trackCodeEntryScreenReached() async {
    await _trackEvent(AnalyticsEvent.codeEntryScreenReached);
  }

  /// Track successful payment sent event
  Future<void> trackPaymentSent({required int amountSats}) async {
    await _trackEvent(
      AnalyticsEvent.paymentSent,
      properties: {'amount_sats': amountSats},
    );
  }

  /// Track successful payment received event
  Future<void> trackPaymentReceived({required int amountSats}) async {
    await _trackEvent(
      AnalyticsEvent.paymentReceived,
      properties: {'amount_sats': amountSats},
    );
  }

  /// Track wallet disconnected event
  Future<void> trackWalletDisconnected() async {
    await _trackEvent(AnalyticsEvent.walletDisconnected);
  }

  /// Get the current user's distinct ID (useful for debugging)
  Future<String> getDistinctId() async {
    try {
      return await Posthog().getDistinctId();
    } catch (e) {
      _logger.warning('Failed to get distinct ID: $e');
      return 'unknown';
    }
  }
}
