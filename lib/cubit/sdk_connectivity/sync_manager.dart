import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:logging/logging.dart';
import 'package:nostr_pay_kids/services/nwc_ndk_sdk.dart';

final Logger _logger = Logger('SyncManager');

const int syncIntervalSeconds = 5;

class SyncManager {
  StreamSubscription<FGBGType>? _lifecycleSubscription;
  StreamSubscription<List<ConnectivityResult>>? _networkSubscription;
  DateTime _lastSync = DateTime.fromMillisecondsSinceEpoch(0);

  final NWCNdkSDK? nwcNdkSDK;

  SyncManager(this.nwcNdkSDK);

  void startSyncing() {
    _logger.info('Starting Sync Manager.');
    _lifecycleSubscription = FGBGEvents.instance.stream.skip(1).listen((
      FGBGType event,
    ) async {
      if (event == FGBGType.foreground && _shouldSync()) {
        await _sync();
      }
    });
    _logger.info('Subscribed to lifecycle events.');

    // Force a sync after Network is back
    _networkSubscription = Connectivity().onConnectivityChanged.skip(1).listen((
      List<ConnectivityResult> event,
    ) async {
      final bool hasNetworkConnection =
          !(event.contains(ConnectivityResult.none) ||
              event.every(
                (ConnectivityResult result) => result == ConnectivityResult.vpn,
              ));
      if (hasNetworkConnection) {
        _logger.info('Re-established network connection.');
        await _sync();
      }
    });
    _logger.info('Subscribed to network events.');
  }

  bool _shouldSync() =>
      DateTime.now().difference(_lastSync).inSeconds > syncIntervalSeconds;

  Future<void> _sync() async {
    if (nwcNdkSDK != null) {
      try {
        _logger.info('Syncing.');
        await nwcNdkSDK!.syncWalletData();
        _lastSync = DateTime.now();
        _logger.info('Synced successfully.');
      } catch (e) {
        _logger.warning('Failed to sync. Reason: $e');
      }
    } else {
      _logger.info('Wallet has disconnected. Shutting down Sync Manager.');
      disconnect();
    }
  }

  void disconnect() {
    _lifecycleSubscription?.cancel();
    _lifecycleSubscription = null;
    _networkSubscription?.cancel();
    _networkSubscription = null;
    _lastSync = DateTime.fromMillisecondsSinceEpoch(0);
  }
}
