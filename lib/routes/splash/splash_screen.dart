import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:logging/logging.dart';
import 'package:nostr_pay_kids/component_library/component_library.dart';
import 'package:nostr_pay_kids/cubit/account/onboarding_preferences.dart';
import 'package:nostr_pay_kids/cubit/connectivity/connectivity_cubit.dart';
import 'package:nostr_pay_kids/cubit/sdk_connectivity/sdk_connectivity_cubit.dart';
import 'package:nostr_pay_kids/cubit/sdk_connectivity/sdk_connectivity_state.dart';
import 'package:nostr_pay_kids/cubit/ecash/ecash_cubit.dart';
import 'package:nostr_pay_kids/cubit/ecash/ecash_state.dart';
import 'package:nostr_pay_kids/routes/initial_walkthrough/code_entry_screen.dart';
import 'package:nostr_pay_kids/routes/offline_cash/ecash_home_screen.dart';
import 'package:nostr_pay_kids/services/service_injector.dart';

final Logger _logger = Logger('SplashScreen');

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.isOnboardingComplete});
  final bool isOnboardingComplete;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hasNavigated = false;
  Timer? _connectionTimeoutTimer;
  bool _showConnectionError = false;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    if (!widget.isOnboardingComplete) {
      // Schedule onboarding reminders for users who haven't completed setup
      ServiceInjector().notificationService.scheduleOnboardingReminders();

      Timer(const Duration(milliseconds: 1800), () {
        if (mounted && !_hasNavigated) {
          _hasNavigated = true;
          Navigator.of(context).pushReplacementNamed('/intro');
        }
      });
    } else {
      // Start timeout timer for connection (30 seconds)
      _connectionTimeoutTimer = Timer(const Duration(seconds: 30), () {
        if (mounted && !_hasNavigated) {
          setState(() {
            _showConnectionError = true;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _connectionTimeoutTimer?.cancel();
    super.dispose();
  }

  void _navigateToHome() {
    if (mounted && !_hasNavigated) {
      _hasNavigated = true;
      _connectionTimeoutTimer?.cancel();
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  Future<void> _retryConnection() async {
    setState(() {
      _isRetrying = true;
      _showConnectionError = false;
    });
    _connectionTimeoutTimer?.cancel();
    _connectionTimeoutTimer = Timer(const Duration(seconds: 30), () {
      if (mounted && !_hasNavigated) {
        setState(() {
          _showConnectionError = true;
          _isRetrying = false;
        });
      }
    });

    try {
      final sdkCubit = context.read<SdkConnectivityCubit>();
      final injector = ServiceInjector();
      final connectionURI = await injector.credentialsManager.restoreSecret();
      if (connectionURI != null) {
        await sdkCubit.reconnect(connectionURI: connectionURI);
      } else {
        // If no connection URI, stop retrying after a brief delay
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          setState(() {
            _isRetrying = false;
            _showConnectionError = true;
          });
        }
      }
    } catch (e) {
      // If retry fails immediately (e.g., no internet), stop loading after brief delay
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _isRetrying = false;
          _showConnectionError = true;
        });
      }
    }
  }

  Future<void> _setupNewConnection() async {
    if (mounted && !_hasNavigated) {
      _hasNavigated = true;
      _connectionTimeoutTimer?.cancel();

      // Clear any remaining credentials and reset onboarding
      try {
        final injector = ServiceInjector();
        await injector.credentialsManager.deleteSecret();
        await OnboardingPreferences.setOnboardingComplete(false);
      } catch (e) {
        // Log but don't block navigation
        _logger.info('Error clearing credentials: $e');
      }

      // Navigate to code entry screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const CodeEntryScreen(showBackButton: false),
        ),
      );
    }
  }

  Future<void> _navigateToEcash(BuildContext context) async {
    if (mounted && !_hasNavigated) {
      _hasNavigated = true;
      _connectionTimeoutTimer?.cancel();

      // Navigate directly to EcashHomeScreen without initializing CDK
      // CDK initialization is only needed for creating new Ecash tokens,
      // which requires internet anyway. Viewing/using existing Ecash items
      // works offline using the hydrated state.
      // Using push instead of pushReplacement so user can navigate back
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const EcashHomeScreen(),
        ),
      );

      // Reset _hasNavigated when user pops back so they can navigate again
      if (mounted) {
        _hasNavigated = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    if (!widget.isOnboardingComplete) {
      // Show normal splash for onboarding flow
      return Scaffold(
        backgroundColor: AppColors.ufoBeamColor,
        body: SafeArea(
          child: Center(
            child: SvgPicture.asset(
              'assets/mascot/UFO.svg',
              fit: BoxFit.contain,
              width: MediaQuery.of(context).size.width / 1.5,
            ),
          ),
        ),
      );
    }

    // For users who completed onboarding, show connection status
    return BlocListener<ConnectivityCubit, ConnectivityState>(
      listener: (context, connectivityState) {
        // When internet comes back, reset error state
        // SdkConnectivityCubit will automatically retry via _retryUntilConnected
        if (connectivityState.hasNetworkConnection && _showConnectionError) {
          setState(() {
            _showConnectionError = false;
          });
        }
      },
      child: BlocListener<SdkConnectivityCubit, SdkConnectivityState>(
        listener: (context, state) {
          // If onboarding is complete, wait for connection before navigating
          if (widget.isOnboardingComplete &&
              state == SdkConnectivityState.connected) {
            _navigateToHome();
          } else if (state == SdkConnectivityState.connecting) {
            // Reset error state when connection starts
            setState(() {
              _showConnectionError = false;
              _isRetrying = false;
            });
          } else if (state == SdkConnectivityState.disconnected &&
              _isRetrying) {
            // If connection fails while retrying, keep loading for a bit then show error
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                final sdkCubit = context.read<SdkConnectivityCubit>();
                if (sdkCubit.state == SdkConnectivityState.disconnected) {
                  setState(() {
                    _isRetrying = false;
                    _showConnectionError = true;
                  });
                }
              }
            });
          }
        },
        child: BlocBuilder<ConnectivityCubit, ConnectivityState>(
          builder: (context, connectivityState) {
            return BlocBuilder<SdkConnectivityCubit, SdkConnectivityState>(
              builder: (context, sdkState) {
                // Check if already connected when widget first builds
                if (widget.isOnboardingComplete &&
                    sdkState == SdkConnectivityState.connected &&
                    !_hasNavigated) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _navigateToHome();
                  });
                }

                final bool hasInternet = connectivityState.hasNetworkConnection;
                final bool isConnecting =
                    sdkState == SdkConnectivityState.connecting;
                final bool isDisconnected =
                    sdkState == SdkConnectivityState.disconnected;
                final bool isUnauthorized =
                    sdkState == SdkConnectivityState.unauthorized;

                // Show error if no internet, connection failed after timeout, or disconnected with internet
                // Don't show error if we're currently retrying (show loading instead)
                final bool showError = (!hasInternet ||
                        (_showConnectionError && isDisconnected) ||
                        (isDisconnected && !isConnecting && hasInternet)) &&
                    !_isRetrying &&
                    !isUnauthorized;

                return Scaffold(
                  backgroundColor: AppColors.ufoBeamColor,
                  body: SafeArea(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/mascot/UFO.svg',
                            fit: BoxFit.contain,
                            width: MediaQuery.of(context).size.width / 1.5,
                          ),
                          const SizedBox(height: 40),
                          if (isUnauthorized) ...[
                            Icon(
                              Icons.link_off_rounded,
                              size: 48,
                              color: theme.colorScheme.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Connection Removed',
                              style: textTheme.headlineSmall,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                'Your NWC connection has been removed from your wallet app. Please set up a new connection to continue.',
                                style: textTheme.bodyMedium?.copyWith(
                                  color:
                                      AppColors.textBody.withValues(alpha: 0.7),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: PrimaryButton(
                                text: 'Set Up New Connection',
                                onPressed: _setupNewConnection,
                                fontSize: 16,
                                height: 50,
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ] else if (showError) ...[
                            Icon(
                              Icons.wifi_off_rounded,
                              size: 48,
                              color: theme.colorScheme.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              !hasInternet
                                  ? 'No Internet Connection'
                                  : 'Connection Failed',
                              style: textTheme.headlineSmall,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                !hasInternet
                                    ? 'Please check your internet connection and try again.'
                                    : 'Unable to connect to your wallet. Please try again.',
                                style: textTheme.bodyMedium?.copyWith(
                                  color:
                                      AppColors.textBody.withValues(alpha: 0.7),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  PrimaryButton(
                                    text: 'Retry Connection',
                                    onPressed:
                                        _isRetrying ? null : _retryConnection,
                                    isLoading: _isRetrying,
                                    fontSize: 16,
                                    height: 50, // Keep height for consistency
                                    backgroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 16,
                                    ),
                                  ),
                                  // Show "Use Ecash" option if user has Ecash items
                                  BlocBuilder<EcashCubit, EcashState>(
                                    builder: (context, ecashState) {
                                      final hasEcashItems =
                                          ecashState.ecashItems.isNotEmpty;
                                      if (!hasEcashItems) {
                                        return const SizedBox.shrink();
                                      }
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 16),
                                        child: TextButton(
                                          onPressed: () {
                                            _navigateToEcash(context);
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Use Ecash',
                                                style: textTheme.bodyLarge,
                                              ),
                                              Icon(
                                                Icons.arrow_forward_ios,
                                                color: AppColors.textPrimary,
                                                size: 14,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ] else if (isConnecting || _isRetrying) ...[
                            const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Connecting to your wallet...',
                              style: textTheme.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
