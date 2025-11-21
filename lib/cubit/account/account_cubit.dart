import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:logging/logging.dart';
import 'package:nostr_pay_kids/services/nwc_ndk_sdk.dart';

import 'account_state.dart';

final Logger _logger = Logger('AccountCubit');

class AccountCubit extends Cubit<AccountState>
    with HydratedMixin<AccountState> {
  final NWCNdkSDK nwcNdkSDK;

  AccountCubit(this.nwcNdkSDK) : super(AccountState.initial()) {
    hydrate();

    _listenAccountChanges();
    _listenInitialSyncEvent();
  }

  void _listenAccountChanges() {
    _logger.info('Initial AccountState: $state');
    _logger.info('Listening to account changes');
    nwcNdkSDK.balanceStream
        .map((balance) => state.copyWith(balance: balance.balanceSats))
        .listen(emit);
    nwcNdkSDK.getInfoResponseStream.listen((info) {
      emit(state.copyWith(infoResponse: info));
    });
    nwcNdkSDK.getBudgetResponseStream.listen((budget) {
      emit(state.copyWith(budgetResponse: budget));
    });
  }

  void _listenInitialSyncEvent() {
    _logger.info('Listening to initial sync event.');
    nwcNdkSDK.didCompleteInitialSyncStream.listen((_) {
      _logger.info('Initial sync complete.');
      emit(state.copyWith(isRestoring: false, didCompleteInitialSync: true));
    });
  }

  Future<void> refreshWalletBalance() async {
    _logger.info('Refreshing wallet balance');
    await nwcNdkSDK.refreshWalletBalance();
  }

  Future<void> refreshWalletTransactions() async {
    _logger.info('Refreshing wallet transactions');
    await nwcNdkSDK.refreshWalletTransactions();
  }

  @override
  AccountState? fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      _logger.severe('No stored data found.');
      return null;
    }

    try {
      final AccountState result = AccountState.fromJson(json);
      _logger.fine('Successfully hydrated with $result');
      return result;
    } catch (e, stackTrace) {
      _logger.severe('Error hydrating: $e');
      _logger.fine('Stack trace: $stackTrace');
      return AccountState.initial();
    }
  }

  @override
  Map<String, dynamic>? toJson(AccountState state) {
    try {
      final Map<String, dynamic> result = state.toJson();
      _logger.fine('Serialized: $result');
      return result;
    } catch (e) {
      _logger.severe('Error serializing: $e');
      return null;
    }
  }

  void setIsRestoring(bool isRestoring) {
    emit(state.copyWith(isRestoring: isRestoring));
  }
}
