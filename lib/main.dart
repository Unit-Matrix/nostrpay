import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:nostr_pay_kids/utils/constants.dart';
import 'package:shared_preference_app_group/shared_preference_app_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:nostr_pay_kids/cubit/account/account_cubit.dart';
import 'package:nostr_pay_kids/cubit/account/onboarding_preferences.dart';
import 'package:nostr_pay_kids/cubit/connectivity/connectivity_cubit.dart';
import 'package:nostr_pay_kids/cubit/ecash/ecash_cubit.dart';
import 'package:nostr_pay_kids/cubit/input/input_cubit.dart';
import 'package:nostr_pay_kids/cubit/payments/payments_cubit.dart';
import 'package:nostr_pay_kids/cubit/sdk_connectivity/sdk_connectivity_cubit.dart';
import 'package:nostr_pay_kids/cubit/user_profile/user_profile_cubit.dart';
import 'package:nostr_pay_kids/cubit/currency/currency_cubit.dart';
import 'package:nostr_pay_kids/services/nostrpay_logger.dart';
import 'package:nostr_pay_kids/services/service_injector.dart';
import 'package:nostr_pay_kids/user_app.dart';
import 'hydrated_bloc_storage.dart';

final Logger _logger = Logger('Main');

void main() async {
  // runZonedGuarded wrapper is required to log Dart errors.
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      SystemChrome.setPreferredOrientations(<DeviceOrientation>[
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      // iOS extension requirement
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        SharedPreferenceAppGroup.setAppGroup(
          'group.$APP_ID_PREFIX.$APP_BUNDLE_ID',
        );
      }

      final ServiceInjector injector = ServiceInjector();
      final NostrpayLogger nostrpayLogger = injector.nostrpayLogger;

      // Initialize PostHog analytics
      await injector.analyticsService.initialize();

      // Initialize notification service
      await injector.notificationService.init();

      // Initialize app version info
      await injector.appVersionService.initialize();

      await HydratedBlocStorage().initialize();

      final SdkConnectivityCubit sdkConnectivityCubit = SdkConnectivityCubit(
        nwcNdkSDK: injector.nwcNdkSDK,
        credentialsManager: injector.credentialsManager,
      );

      // Start the app immediately to show splash screen
      runApp(
        MultiBlocProvider(
          providers: [
            BlocProvider<AccountCubit>(
              lazy: false,
              create: (BuildContext context) =>
                  AccountCubit(injector.nwcNdkSDK),
            ),
            BlocProvider<ConnectivityCubit>(
              create: (BuildContext context) => ConnectivityCubit(),
            ),
            BlocProvider<SdkConnectivityCubit>(
              create: (BuildContext context) => sdkConnectivityCubit,
            ),
            BlocProvider<UserProfileCubit>(
              create: (BuildContext context) => UserProfileCubit(),
            ),
            BlocProvider<PaymentsCubit>(
              create: (BuildContext context) =>
                  PaymentsCubit(injector.nwcNdkSDK),
            ),
            BlocProvider<InputCubit>(
              create: (BuildContext context) => InputCubit(),
            ),
            BlocProvider<CurrencyCubit>(
              create: (BuildContext context) =>
                  CurrencyCubit(injector.nwcNdkSDK),
            ),
            BlocProvider<EcashCubit>(
              create: (BuildContext context) => EcashCubit(
                ecashCdkSDK: injector.ecashCdkSDK,
                credentialsManager: injector.credentialsManager,
                nwcNdkSDK: injector.nwcNdkSDK,
              ),
            ),
          ],
          child: const UserApp(),
        ),
      );

      // Start reconnection asynchronously after app is running
      // This allows the splash screen to show while reconnection happens
      final Stopwatch stopwatch = Stopwatch()..start();
      final bool isOnboardingComplete =
          await OnboardingPreferences.isOnboardingComplete();
      if (isOnboardingComplete) {
        _logger.info('Reconnect if secure storage has connectionURI.');
        final String? connectionURI =
            await injector.credentialsManager.restoreSecret();
        if (connectionURI != null) {
          await sdkConnectivityCubit.reconnect(connectionURI: connectionURI);
        }
      }
      stopwatch.stop();
      _logger.info(
          'Onboarding check and reconnect took ${stopwatch.elapsedMilliseconds / 1000.0} seconds');
    },
    (Object error, StackTrace stackTrace) async {
      if (error is! FlutterErrorDetails) {
        _logger.severe('FlutterError: $error', error, stackTrace);
      }
    },
  );
}
