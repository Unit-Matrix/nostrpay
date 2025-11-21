import 'dart:async';

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:logging/logging.dart';
import 'package:ndk/ndk.dart' as ndk;

import '../../services/nwc_ndk_sdk.dart';
import 'payments_state.dart';

final Logger _logger = Logger('PaymentsCubit');

class PaymentsCubit extends Cubit<PaymentsState>
    with HydratedMixin<PaymentsState> {
  final NWCNdkSDK _nwcNdkSdk;

  PaymentsCubit(this._nwcNdkSdk) : super(PaymentsState.initial()) {
    hydrate();
    _listenPaymentChanges();
  }

  void _listenPaymentChanges() {
    _logger.info('_listenPaymentChanges\nListening to changes in payments');

    _nwcNdkSdk.paymentsStream.listen((
      ndk.ListTransactionsResponse listTransactionsResponse,
    ) {
      _logger.info(
        'Received transactions: ${listTransactionsResponse.transactions.length}',
      );
      emit(state.copyWith(transactions: listTransactionsResponse.transactions));
    });
  }

  StreamSubscription<PaymentNotificationEvent> trackPaymentEvents({
    required bool Function(PaymentNotificationEvent) paymentFilter,
    required void Function(PaymentNotificationEvent) onData,
    Function? onError,
  }) {
    return _nwcNdkSdk.paymentNotificationEventStream
        .where(paymentFilter)
        .listen(
          (PaymentNotificationEvent event) => onData.call(event),
          onError: onError,
        );
  }

  Future<ndk.MakeInvoiceResponse?> makeInvoice({
    required int amountSats,
  }) async {
    _logger.info('Making invoice');
    try {
      return await _nwcNdkSdk.makeInvoice(amountSats: amountSats);
    } catch (e) {
      _logger.info('makeInvoice\nError making invoice', e);
      return Future<ndk.MakeInvoiceResponse?>.error(e);
    }
  }

  Future<ndk.PayInvoiceResponse?> payInvoice({required String invoice}) async {
    _logger.info('Paying invoice');
    try {
      return await _nwcNdkSdk.payInvoice(invoice: invoice);
    } catch (e) {
      _logger.info('payInvoice\nError paying invoice', e);
      return Future<ndk.PayInvoiceResponse?>.error(e);
    }
  }

  @override
  PaymentsState? fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      _logger.severe('No stored data found.');
      return null;
    }

    try {
      final PaymentsState result = PaymentsState.fromJson(json);
      _logger.fine('Successfully hydrated with $result');
      return result;
    } catch (e, stackTrace) {
      _logger.severe('Error hydrating: $e');
      _logger.fine('Stack trace: $stackTrace');
      return PaymentsState.initial();
    }
  }

  @override
  Map<String, dynamic>? toJson(PaymentsState state) {
    try {
      final Map<String, dynamic> result = state.toJson();
      _logger.fine('Serialized: $result');
      return result;
    } catch (e) {
      _logger.severe('Error serializing: $e');
      return null;
    }
  }
}
