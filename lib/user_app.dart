import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:nostr_pay_kids/component_library/component_library.dart';
import 'package:nostr_pay_kids/cubit/account/onboarding_preferences.dart';
import 'package:nostr_pay_kids/routes/home/home_screen.dart';
import 'package:nostr_pay_kids/routes/initial_walkthrough/welcome_screen.dart';
import 'package:nostr_pay_kids/routes/splash/splash_screen.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

final Logger _logger = Logger('UserApp');

class UserApp extends StatefulWidget {
  const UserApp({super.key});

  @override
  State<UserApp> createState() => _UserAppState();
}

class _UserAppState extends State<UserApp> {
  final GlobalKey _appKey = GlobalKey();
  final GlobalKey<NavigatorState> _homeNavigatorKey =
      GlobalKey<NavigatorState>();
  late Future<bool> _isOnboardingCompleteFuture;

  @override
  void initState() {
    super.initState();
    _isOnboardingCompleteFuture = OnboardingPreferences.isOnboardingComplete();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isOnboardingCompleteFuture,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (!snapshot.hasData) {
          return Container(color: appLightTheme.canvasColor);
        }

        final bool isOnboardingComplete = snapshot.data ?? false;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          key: _appKey,
          title: 'Nostrpay kids wallet',
          theme: appLightTheme,
          navigatorObservers: [PosthogObserver()],
          builder: (BuildContext context, Widget? child) {
            const double kMaxTitleTextScaleFactor = 1.3;

            return MediaQuery.withClampedTextScaling(
              maxScaleFactor: kMaxTitleTextScaleFactor,
              child: child!,
            );
          },
          initialRoute: 'splash',
          onGenerateRoute: (RouteSettings settings) {
            _logger.info('New route: ${settings.name}');
            switch (settings.name) {
              case 'splash':
                return MaterialPageRoute(
                  builder:
                      (context) => SplashScreen(
                        isOnboardingComplete: isOnboardingComplete,
                      ),
                );
              case '/intro':
                return MaterialPageRoute(
                  builder: (context) => const WelcomeScreen(),
                );
              case '/':
                return MaterialPageRoute(
                  builder:
                      (_) => NavigatorPopHandler(
                        onPopWithResult:
                            (Object? result) =>
                                _homeNavigatorKey.currentState!.maybePop(),
                        child: Navigator(
                          initialRoute: '/',
                          key: _homeNavigatorKey,
                          onGenerateRoute: (RouteSettings settings) {
                            _logger.info('New inner route: ${settings.name}');
                            switch (settings.name) {
                              case '/':
                                return MaterialPageRoute(
                                  builder: (context) => const HomeScreen(),
                                  settings: settings,
                                );
                            }
                            assert(false);
                            return null;
                          },
                        ),
                      ),
                  settings: settings,
                );
            }
            assert(false);
            return null;
          },
        );
      },
    );
  }
}
