import 'package:equatable/equatable.dart';
import 'package:nostr_pay_kids/models/fiat_currency.dart';

class CurrencyState extends Equatable {
  final Map<FiatCurrency, double>
  rates; // e.g. {FiatCurrency.usd: 67000.0, ...}
  final FiatCurrency selectedFiat;
  final bool isLoading;
  final String? error;

  const CurrencyState({
    required this.rates,
    required this.selectedFiat,
    required this.isLoading,
    this.error,
  });

  factory CurrencyState.initial() => CurrencyState(
    rates: const {},
    selectedFiat: supportedCurrencies.first,
    isLoading: false,
    error: null,
  );

  CurrencyState copyWith({
    Map<FiatCurrency, double>? rates,
    FiatCurrency? selectedFiat,
    bool? isLoading,
    String? error,
  }) {
    return CurrencyState(
      rates: rates ?? this.rates,
      selectedFiat: selectedFiat ?? this.selectedFiat,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [rates, selectedFiat, isLoading, error];

  Map<String, dynamic> toJson() => {
    'rates': rates.map((k, v) => MapEntry(k.code, v)),
    'selectedFiat': selectedFiat.code,
    'isLoading': isLoading,
    'error': error,
  };

  factory CurrencyState.fromJson(Map<String, dynamic> json) => CurrencyState(
    rates: (json['rates'] as Map<String, dynamic>? ?? {}).map(
      (k, v) => MapEntry(FiatCurrencyX.fromCode(k)!, (v as num).toDouble()),
    ),
    selectedFiat:
        FiatCurrencyX.fromCode(json['selectedFiat'] as String) ??
        supportedCurrencies.first,
    isLoading: json['isLoading'] as bool? ?? false,
    error: json['error'] as String?,
  );
}
