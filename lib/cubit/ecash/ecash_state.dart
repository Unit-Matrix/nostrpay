import 'dart:convert';
import 'package:nostr_pay_kids/models/ecash_item.dart';

enum EcashInitializationState {
  notInitialized,
  initializing,
  initialized,
  error,
}

sealed class EcashMintingState {
  const EcashMintingState();
}

class EcashMintingStateIdle extends EcashMintingState {
  const EcashMintingStateIdle();
}

class EcashMintingStateUnpaid extends EcashMintingState {
  const EcashMintingStateUnpaid();
}

class EcashMintingStatePaid extends EcashMintingState {
  const EcashMintingStatePaid();
}

class EcashMintingStateIssued extends EcashMintingState {
  const EcashMintingStateIssued();
}

class EcashMintingStateError extends EcashMintingState {
  final String error;
  const EcashMintingStateError(this.error);
}

class EcashState {
  final Set<EcashItem> ecashItems;
  final EcashInitializationState initializationState;
  final EcashMintingState mintingState;

  EcashState({
    required this.ecashItems,
    this.initializationState = EcashInitializationState.notInitialized,
    this.mintingState = const EcashMintingStateIdle(),
  });

  factory EcashState.initial() {
    return EcashState(
      ecashItems: {},
      initializationState: EcashInitializationState.notInitialized,
      mintingState: const EcashMintingStateIdle(),
    );
  }

  EcashState copyWith({
    Set<EcashItem>? ecashItems,
    EcashInitializationState? initializationState,
    EcashMintingState? mintingState,
  }) {
    return EcashState(
      ecashItems: ecashItems ?? this.ecashItems,
      initializationState: initializationState ?? this.initializationState,
      mintingState: mintingState ?? this.mintingState,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ecashItems': ecashItems.map((item) => item.toJson()).toList(),
    };
  }

  factory EcashState.fromJson(Map<String, dynamic> json) {
    return EcashState(
      ecashItems: (json['ecashItems'] as List<dynamic>?)
              ?.map((item) => EcashItem.fromJson(item as Map<String, dynamic>))
              .toSet() ??
          {},
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}
