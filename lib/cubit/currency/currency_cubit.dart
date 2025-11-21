import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:logging/logging.dart';
import 'package:nostr_pay_kids/services/nwc_ndk_sdk.dart';
import 'currency_state.dart';
import 'package:nostr_pay_kids/services/currency_service.dart';
import 'package:nostr_pay_kids/models/fiat_currency.dart';

final Logger _logger = Logger('CurrencyCubit');

class CurrencyCubit extends Cubit<CurrencyState>
    with HydratedMixin<CurrencyState> {
  final NWCNdkSDK nwcNdkSDK;
  final CurrencyService currencyService;

  CurrencyCubit(this.nwcNdkSDK, {CurrencyService? service})
      : currencyService = service ?? CurrencyService(),
        super(CurrencyState.initial()) {
    hydrate();
    _initializeCurrencyCubit();
  }

  void _initializeCurrencyCubit() {
    nwcNdkSDK.getInfoResponseStream.listen((info) {
      fetchRates();
    });
  }

  Future<void> fetchRates() async {
    _logger.info('Fetching btc rates');

    emit(state.copyWith(isLoading: true, error: null));
    try {
      final rates = await currencyService.fetchBtcRates(
        currencies: supportedCurrencies,
      );
      emit(state.copyWith(rates: rates, isLoading: false, error: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void changeFiat(FiatCurrency fiat) {
    // Allow changing to any supported currency, even if rates aren't available yet
    // The rates will be fetched when available
    emit(state.copyWith(selectedFiat: fiat));
  }

  @override
  CurrencyState? fromJson(Map<String, dynamic> json) {
    try {
      return CurrencyState.fromJson(json);
    } catch (_) {
      return CurrencyState.initial();
    }
  }

  @override
  Map<String, dynamic>? toJson(CurrencyState state) => state.toJson();
}
