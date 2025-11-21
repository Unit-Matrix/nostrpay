import 'dart:convert';

import 'package:ndk/domain_layer/usecases/nwc/responses/get_budget_response.dart'
    as ndk;
import 'package:ndk/ndk.dart' as ndk;

class AccountState {
  final bool isRestoring;
  final bool didCompleteInitialSync;
  final int balance;
  final ndk.GetInfoResponse? infoResponse;
  final ndk.GetBudgetResponse? budgetResponse;

  AccountState({
    required this.isRestoring,
    required this.didCompleteInitialSync,
    required this.balance,
    this.infoResponse,
    this.budgetResponse,
  });

  factory AccountState.initial() {
    return AccountState(
      isRestoring: false,
      didCompleteInitialSync: false,
      balance: 0,
      infoResponse: null,
      budgetResponse: null,
    );
  }

  AccountState copyWith({
    bool? isRestoring,
    bool? didCompleteInitialSync,
    int? balance,
    ndk.GetInfoResponse? infoResponse,
    ndk.GetBudgetResponse? budgetResponse,
  }) {
    return AccountState(
      isRestoring: isRestoring ?? this.isRestoring,
      didCompleteInitialSync:
          didCompleteInitialSync ?? this.didCompleteInitialSync,
      balance: balance ?? this.balance,
      infoResponse: infoResponse ?? this.infoResponse,
      budgetResponse: budgetResponse ?? this.budgetResponse,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'isRestoring': isRestoring,
      'balance': balance,
      'infoResponse': infoResponse?.toJson(),
      'budgetResponse': budgetResponse?.toJson(),
    };
  }

  factory AccountState.fromJson(Map<String, dynamic> json) {
    return AccountState(
      isRestoring: json['isRestoring'] as bool? ?? false,
      didCompleteInitialSync: false,
      balance: json['balance'] as int? ?? 0,
      infoResponse:
          json["infoResponse"] != null
              ? GetInfoResponseExtension.fromJson(json["infoResponse"])
              : null,
      budgetResponse:
          json["budgetResponse"] != null
              ? GetBudgetResponseExtension.fromJson(json["budgetResponse"])
              : null,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

extension GetInfoResponseExtension on ndk.GetInfoResponse {
  Map<String, dynamic> toJson() {
    return {
      'result_type': resultType,
      'result': {
        'alias': alias,
        'color': color,
        'pubkey': pubkey,
        'network': network.plaintext,
        'block_height': blockHeight,
        'block_hash': blockHash,
        'methods': methods,
        'notifications': notifications,
      },
    };
  }

  static ndk.GetInfoResponse fromJson(Map<String, dynamic> json) {
    return ndk.GetInfoResponse.deserialize(json);
  }
}

extension GetBudgetResponseExtension on ndk.GetBudgetResponse {
  Map<String, dynamic> toJson() {
    return {
      'result_type': resultType,
      'result': {
        'usedBudget': usedBudget,
        'totalBudget': totalBudget,
        'renewsAt': renewsAt,
        'renewalPeriod': renewalPeriod.plaintext,
      },
    };
  }

  static ndk.GetBudgetResponse fromJson(Map<String, dynamic> json) {
    return ndk.GetBudgetResponse.deserialize(json);
  }
}
