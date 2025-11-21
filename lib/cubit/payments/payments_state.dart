import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:ndk/domain_layer/usecases/nwc/responses/list_transactions_response.dart'
    as ndk;

class PaymentsState {
  final List<ndk.TransactionResult> transactions;

  const PaymentsState({required this.transactions});

  PaymentsState.initial() : this(transactions: <ndk.TransactionResult>[]);

  PaymentsState copyWith({List<ndk.TransactionResult>? transactions}) {
    return PaymentsState(transactions: transactions ?? this.transactions);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'transactions':
          transactions
              .map((ndk.TransactionResult transaction) => transaction.toJson())
              .toList(),
    };
  }

  factory PaymentsState.fromJson(Map<String, dynamic> json) {
    return PaymentsState(
      transactions:
          (json['transactions'] as List<dynamic>? ?? <dynamic>[])
              .map(
                (dynamic transactionJson) =>
                    ndk.TransactionResult.deserialize(transactionJson),
              )
              .toList(),
    );
  }

  @override
  String toString() => jsonEncode(toJson());

  @override
  int get hashCode => Object.hash(
    transactions.length,
    transactions.fold<int>(
      0,
      (hash, transaction) => hash ^ transaction.hashCode,
    ),
  );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PaymentsState && listEquals(transactions, other.transactions);
  }
}

extension TransactionResultExtension on ndk.TransactionResult {
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'invoice': invoice,
      'description': description,
      'description_hash': descriptionHash,
      'preimage': preimage,
      'payment_hash': paymentHash,
      'state': state,
      'amount': amount,
      'fees_paid': feesPaid,
      'created_at': createdAt,
      'expires_at': expiresAt,
      'settled_at': settledAt,
      'metadata': metadata,
    };
  }

  static ndk.TransactionResult fromJson(Map<String, dynamic> json) {
    return ndk.TransactionResult.deserialize(json);
  }
}
