import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:logging/logging.dart';
import 'package:nostr_pay_kids/cubit/account/onboarding_preferences.dart';
import 'package:nostr_pay_kids/services/credentials_manager.dart';
import 'package:nostr_pay_kids/services/nwc_ndk_sdk.dart';

import 'sdk_connectivity_state.dart';
import 'sync_manager.dart';

final Logger _logger = Logger('SdkConnectivityCubit');

class SdkConnectivityCubit extends Cubit<SdkConnectivityState> {
  final CredentialsManager credentialsManager;
  final NWCNdkSDK nwcNdkSDK;

  SdkConnectivityCubit({
    required this.credentialsManager,
    required this.nwcNdkSDK,
  }) : super(SdkConnectivityState.disconnected);

  Future<void> registerOrRestoreConnection({
    required String connectionURI,
  }) async {
    _logger.info('Registering or restoring a new connection.');
    await _connect(connectionURI, storeConnectionURI: true);
  }

  Future<void> reconnect({String? connectionURI}) async {
    _logger.info(
      connectionURI == null ? 'Attempting to reconnect.' : 'Reconnecting.',
    );
    try {
      final String? restoredConnectionURI =
          connectionURI ?? await credentialsManager.restoreSecret();
      if (restoredConnectionURI != null) {
        await _connect(restoredConnectionURI);
      } else {
        _logger.warning('Failed to restore connectionURI.');
        throw Exception('Failed to restore connectionURI.');
      }
    } catch (e) {
      _logger.warning(
        'Failed to reconnect. Retrying when network connection is detected.',
      );
      await _retryUntilConnected();
    }
  }

  Future<void> _connect(
    String connectionURI, {
    bool storeConnectionURI = false,
  }) async {
    try {
      emit(SdkConnectivityState.connecting);
      _logger.info('Using the connection URI: $connectionURI');
      await nwcNdkSDK.connect(connectionURI: connectionURI);
      _logger.info('Connection established successfully.');

      _startSyncing();

      if (storeConnectionURI) {
        await credentialsManager.storeSecret(secret: connectionURI);
      }

      emit(SdkConnectivityState.connected);
    } catch (e) {
      _logger.severe(
        'Error connecting to the connection URI: $connectionURI',
        e,
      );
      emit(SdkConnectivityState.disconnected);
      rethrow;
    }
  }

  void _startSyncing() {
    final SyncManager syncManager = SyncManager(nwcNdkSDK);
    syncManager.startSyncing();
  }

  Future<void> _retryUntilConnected() async {
    _logger.info('Subscribing to network events.');
    StreamSubscription<List<ConnectivityResult>>? subscription;
    subscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> event,
    ) async {
      final bool hasNetworkConnection =
          !(event.contains(ConnectivityResult.none) ||
              event.every(
                (ConnectivityResult result) => result == ConnectivityResult.vpn,
              ));
      // Attempt to reconnect when internet is back.
      if (hasNetworkConnection && state == SdkConnectivityState.disconnected) {
        _logger.info('Network connection detected.');
        await reconnect();
        if (state == SdkConnectivityState.connected) {
          _logger.info(
            'SDK has reconnected. Unsubscribing from network events.',
          );
          subscription!.cancel();
        }
      }
    });
  }

  Future<void> disconnect() async {
    _logger.info('Disconnecting from the connection URI.');
    await credentialsManager.deleteSecret();
    await OnboardingPreferences.setOnboardingComplete(false);
    nwcNdkSDK.disconnect();
    emit(SdkConnectivityState.disconnected);
  }
}
