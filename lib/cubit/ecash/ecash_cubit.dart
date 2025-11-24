import 'dart:async';
import 'package:cdk_flutter/cdk_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:logging/logging.dart';
import 'package:nostr_pay_kids/services/ecash_cdk_sdk.dart';
import 'package:nostr_pay_kids/services/credentials_manager.dart';
import 'package:nostr_pay_kids/services/nwc_ndk_sdk.dart';
import 'package:nostr_pay_kids/models/ecash_item.dart';

import 'ecash_state.dart';

final Logger _logger = Logger('EcashCubit');

class EcashCubit extends Cubit<EcashState> with HydratedMixin<EcashState> {
  final EcashCdkSDK ecashCdkSDK;
  final CredentialsManager credentialsManager;
  final NWCNdkSDK nwcNdkSDK;
  StreamSubscription<MintQuote>? _mintQuoteSubscription;

  EcashCubit({
    required this.ecashCdkSDK,
    required this.credentialsManager,
    required this.nwcNdkSDK,
  }) : super(EcashState.initial()) {
    hydrate();
  }

  /// Initialize CDK wallet - loads or generates mnemonic
  Future<void> initialize() async {
    if (state.initializationState == EcashInitializationState.initialized) {
      return;
    }

    emit(state.copyWith(
      initializationState: EcashInitializationState.initializing,
    ));

    try {
      String? mnemonic = await credentialsManager.restoreEcashMnemonic();

      if (mnemonic == null) {
        mnemonic = generateMnemonic();
        await credentialsManager.storeEcashMnemonic(mnemonic: mnemonic);
      }

      await ecashCdkSDK.initialize(mnemonic: mnemonic);

      emit(state.copyWith(
        initializationState: EcashInitializationState.initialized,
      ));
    } catch (e) {
      _logger.severe('Initialization failed', e);
      emit(state.copyWith(
        initializationState: EcashInitializationState.error,
      ));
      rethrow;
    }
  }

  /// Create new Ecash - handles mint quote stream and pays invoice
  Future<void> createEcash({required int amountSats}) async {
    _logger.info('Creating Ecash: $amountSats sats');

    // Cancel any existing mint subscription
    await _mintQuoteSubscription?.cancel();

    // Reset minting state
    emit(state.copyWith(
      mintingState: const EcashMintingStateIdle(),
    ));

    try {
      final mintStream = ecashCdkSDK.createEcash(amountSats: amountSats);

      _mintQuoteSubscription = mintStream.listen(
        (quote) async {
          _logger.info('Mint quote state: ${quote.state}');

          switch (quote.state) {
            case MintQuoteState.unpaid:
              emit(state.copyWith(
                  mintingState: const EcashMintingStateUnpaid()));
              // Pay the invoice using NWC
              _logger.info('Paying invoice: ${quote.request}');
              try {
                final payResponse = await nwcNdkSDK.payInvoice(
                  invoice: quote.request,
                );
                if (payResponse == null) {
                  _logger.severe('Failed to pay invoice');
                  emit(state.copyWith(
                    mintingState:
                        const EcashMintingStateError('Failed to pay invoice'),
                  ));
                  await _mintQuoteSubscription?.cancel();
                } else {
                  _logger.info('Invoice paid successfully');
                }
              } catch (e) {
                _logger.severe('Error paying invoice', e);
                emit(state.copyWith(
                  mintingState: EcashMintingStateError(e.toString()),
                ));
                await _mintQuoteSubscription?.cancel();
              }
              break;

            case MintQuoteState.paid:
              _logger.info('Payment confirmed, waiting for tokens...');
              emit(state.copyWith(mintingState: const EcashMintingStatePaid()));
              break;

            case MintQuoteState.issued:
              _logger.info('Ecash tokens issued');
              if (quote.token != null) {
                // Convert token to EcashItem and add to state
                final ecashItem = _tokenToEcashItem(
                    quote.token!, quote.amount?.toInt() ?? amountSats);
                final updatedItems = {...state.ecashItems, ecashItem};
                emit(state.copyWith(
                  ecashItems: updatedItems,
                  mintingState: const EcashMintingStateIssued(),
                ));
                _logger.info('Ecash item added: ${ecashItem.id}');
              }
              await _mintQuoteSubscription?.cancel();
              break;

            case MintQuoteState.error:
              _logger.severe('Mint error: ${quote.error}');
              emit(state.copyWith(
                mintingState:
                    EcashMintingStateError(quote.error ?? 'Minting failed'),
              ));
              await _mintQuoteSubscription?.cancel();
              break;
          }
        },
        onError: (error) {
          _logger.severe('Mint stream error', error);
          emit(state.copyWith(
            mintingState: EcashMintingStateError(error.toString()),
          ));
          _mintQuoteSubscription?.cancel();
        },
      );
    } catch (e) {
      _logger.severe('Error creating Ecash', e);
      await _mintQuoteSubscription?.cancel();
      emit(state.copyWith(
        mintingState: EcashMintingStateError(e.toString()),
      ));
      rethrow;
    }
  }

  /// Convert CDK Token to EcashItem
  EcashItem _tokenToEcashItem(Token token, int amountSats) {
    return EcashItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      token: token.encoded,
      amount: amountSats,
      status: EcashStatus.ready,
      createdAt: DateTime.now(),
    );
  }

  /// Mark Ecash as used - updates local state only
  Future<void> markEcashAsUsed(String ecashId) async {
    _logger.info('Marking Ecash as used: $ecashId');

    final updatedItems = state.ecashItems.map((item) {
      if (item.id == ecashId) {
        return item.copyWith(
          status: EcashStatus.used,
          usedAt: DateTime.now(),
        );
      }
      return item;
    }).toSet();
    emit(state.copyWith(ecashItems: updatedItems));
  }

  /// Unmark Ecash (mark as ready again) - updates local state only
  Future<void> unmarkEcash(String ecashId) async {
    _logger.info('Unmarking Ecash: $ecashId');

    final updatedItems = state.ecashItems.map((item) {
      if (item.id == ecashId) {
        return item.copyWith(
          status: EcashStatus.ready,
          usedAt: null,
        );
      }
      return item;
    }).toSet();
    emit(state.copyWith(ecashItems: updatedItems));
  }

  /// Delete Ecash - updates local state only
  Future<void> deleteEcash(String ecashId) async {
    _logger.info('Deleting Ecash: $ecashId');

    final updatedItems =
        state.ecashItems.where((item) => item.id != ecashId).toSet();
    emit(state.copyWith(ecashItems: updatedItems));
  }

  @override
  EcashState? fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      _logger.severe('No stored data found.');
      return null;
    }

    try {
      final EcashState result = EcashState.fromJson(json);
      _logger.fine('Successfully hydrated with $result');
      return result;
    } catch (e, stackTrace) {
      _logger.severe('Error hydrating: $e');
      _logger.fine('Stack trace: $stackTrace');
      return EcashState.initial();
    }
  }

  @override
  Map<String, dynamic>? toJson(EcashState state) {
    try {
      final Map<String, dynamic> result = state.toJson();
      _logger.fine('Serialized: $result');
      return result;
    } catch (e) {
      _logger.severe('Error serializing: $e');
      return null;
    }
  }

  @override
  Future<void> close() {
    _mintQuoteSubscription?.cancel();
    return super.close();
  }
}
