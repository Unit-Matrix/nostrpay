import 'dart:async';
import 'package:logging/logging.dart';
import 'package:ndk/domain_layer/usecases/nwc/responses/get_budget_response.dart'
    as ndk;
import 'package:ndk/ndk.dart' as ndk;
import 'package:ndk/domain_layer/usecases/nwc/responses/nwc_response.dart';
import 'package:ndk/domain_layer/usecases/nwc/nwc_notification.dart';
import 'package:rxdart/rxdart.dart';

final Logger _logger = Logger('NWCNdkSDK');

class NWCNdkSDK {
  static final NWCNdkSDK _singleton = NWCNdkSDK._internal();

  factory NWCNdkSDK() => _singleton;

  late final Stream<void> didCompleteInitialSyncStream;

  final StreamController<void> _didCompleteInitialSyncController =
      StreamController<void>.broadcast();

  NWCNdkSDK._internal() {
    didCompleteInitialSyncStream =
        _didCompleteInitialSyncController.stream.take(1);
  }

  ndk.Ndk _instance = ndk.Ndk.emptyBootstrapRelaysConfig();
  ndk.Ndk? get instance => _instance;

  ndk.NwcConnection? _nwcConnection;
  ndk.NwcConnection? get nwcConnection => _nwcConnection;

  Future<void> connect({required String connectionURI}) async {
    _logger.info('Connecting to $connectionURI');
    try {
      _instance = ndk.Ndk.emptyBootstrapRelaysConfig();

      // Check if connectionURI contains nwc.primal.net or relay.primal.net
      final bool isPrimalRelay = connectionURI.contains('nwc.primal.net') ||
          connectionURI.contains('relay.primal.net');

      if (isPrimalRelay) {
        _nwcConnection = await _instance.nwc.connect(
          connectionURI,
          useETagForEachRequest: true,
          ignoreCapabilitiesCheck: true,
          timeout: const Duration(seconds: 16),
        );
        _logger.info(
            'Connected to Primal relay with permissions ${_nwcConnection?.permissions}');
      } else {
        _nwcConnection = await _instance.nwc.connect(
          connectionURI,
          timeout: const Duration(seconds: 16),
        );
      }

      if (_nwcConnection != null) {
        _initializeConnectionStreams(_nwcConnection!);
        _subscribeToConnectionStreams(_nwcConnection!);
        await _fetchWalletData();
      }
    } catch (e) {
      _nwcConnection = null;
      // _instance = null;
      _unsubscribeFromConnectionStreams();
      rethrow;
    }
  }

  void disconnect() {
    _logger.info('Disconnecting from NWC');
    if (_nwcConnection == null) {
      throw Exception('No active NWC connection to disconnect');
    }

    // _nwcConnection!.close();
    _unsubscribeFromConnectionStreams();
    _nwcConnection = null;
    // _instance = null;
  }

  Future<void> _fetchWalletData() async {
    await syncWalletData();
  }

  Future<void> syncWalletData() async {
    _logger.info('Syncing wallet data');
    if (_nwcConnection == null) {
      throw Exception('No active NWC connection to sync wallet data');
    }

    await _getInfo(_nwcConnection!);
    await _getBalance(_nwcConnection!);
    await _listPayments(_nwcConnection!);
  }

  Future<void> refreshWalletBalance() async {
    _logger.info('Refreshing wallet balance');
    if (_nwcConnection != null) {
      await _getBalance(_nwcConnection!);
    }
  }

  Future<void> refreshWalletTransactions() async {
    _logger.info('Refreshing wallet transactions');
    if (_nwcConnection != null) {
      await _listPayments(_nwcConnection!);
    }
  }

  final StreamController<ndk.GetInfoResponse> _getInfoResponseController =
      BehaviorSubject<ndk.GetInfoResponse>();

  Stream<ndk.GetInfoResponse> get getInfoResponseStream =>
      _getInfoResponseController.stream;

  final StreamController<ndk.GetBudgetResponse> _getBudgetResponseController =
      BehaviorSubject<ndk.GetBudgetResponse>();

  Stream<ndk.GetBudgetResponse> get getBudgetResponseStream =>
      _getBudgetResponseController.stream;

  Future<void> _getInfo(ndk.NwcConnection connection) async {
    _logger.info('Getting info');
    final ndk.GetInfoResponse info = await _instance.nwc
        .getInfo(connection, timeout: const Duration(seconds: 16));
    _logger.info('Got info: ${info.methods}');
    _getInfoResponseController.add(info);

    if (info.methods.contains("get_budget")) {
      _logger.info('Getting budget');
      final ndk.GetBudgetResponse budget = await _instance.nwc.getBudget(
        connection,
      );
      _logger.info(
        'Got budget: totalBudgetSats: ${budget.totalBudgetSats}, userBudgetSats: ${budget.userBudgetSats}',
      );
      _getBudgetResponseController.add(budget);
    }
  }

  final StreamController<ndk.ListTransactionsResponse> _paymentsController =
      BehaviorSubject<ndk.ListTransactionsResponse>();

  Stream<ndk.ListTransactionsResponse> get paymentsStream =>
      _paymentsController.stream;

  Future<void> _listPayments(ndk.NwcConnection connection) async {
    _logger.info('Listing payments');
    final ndk.ListTransactionsResponse payments =
        await _instance.nwc.listTransactions(connection, unpaid: false);
    _logger.info('Listed payments: ${payments.transactions}');
    _paymentsController.add(payments);
  }

  final StreamController<ndk.GetBalanceResponse> _balanceController =
      BehaviorSubject<ndk.GetBalanceResponse>();

  Stream<ndk.GetBalanceResponse> get balanceStream => _balanceController.stream;

  Future<void> _getBalance(ndk.NwcConnection connection) async {
    _logger.info('Getting balance');
    final ndk.GetBalanceResponse balance =
        await _instance.nwc.getBalance(connection);
    _balanceController.add(balance);
  }

  StreamSubscription<NwcResponse>? _nwcResponseSubscription;
  StreamSubscription<NwcNotification>? _nwcNotificationSubscription;

  final StreamController<NwcResponse> _nwcResponseController =
      BehaviorSubject<NwcResponse>();

  Stream<NwcResponse> get nwcResponseStream => _nwcResponseController.stream;

  final StreamController<NwcNotification> _nwcNotificationController =
      BehaviorSubject<NwcNotification>();

  Stream<NwcNotification> get nwcNotificationStream =>
      _nwcNotificationController.stream;

  final StreamController<PaymentNotificationEvent>
      _paymentNotificationEventStream =
      StreamController<PaymentNotificationEvent>.broadcast();

  Stream<PaymentNotificationEvent> get paymentNotificationEventStream =>
      _paymentNotificationEventStream.stream;

  void _initializeConnectionStreams(ndk.NwcConnection connection) {
    // The connection already has response and notification streams
    // We just need to subscribe to them
  }

  void _subscribeToConnectionStreams(ndk.NwcConnection connection) {
    _logger.info('Subscribing to connection streams');
    // Subscribe to response stream
    _nwcResponseSubscription = connection.responseStream.stream.listen(
      (NwcResponse response) {
        _nwcResponseController.add(response);
      },
      onError: (Object e) {
        _nwcResponseController.addError(e);
      },
    );

    // Subscribe to notification stream
    _nwcNotificationSubscription = connection.notificationStream.stream.listen(
      (NwcNotification notification) async {
        _nwcNotificationController.add(notification);
        _logger.info('Payment notification received: $notification');

        // Handle payment-related notifications
        if (notification.isPaymentReceived || notification.isPaymentSent) {
          _paymentNotificationEventStream.add(
            PaymentNotificationEvent.fromNotification(notification),
          );
        }

        // Refresh wallet data on any notification
        await _fetchWalletData();
      },
      onError: (Object e) {
        _nwcNotificationController.addError(e);
      },
    );
  }

  void _unsubscribeFromConnectionStreams() {
    _nwcResponseSubscription?.cancel();
    _nwcNotificationSubscription?.cancel();
  }

  Future<ndk.MakeInvoiceResponse?> makeInvoice({
    required int amountSats,
  }) async {
    _logger.info('Making invoice for $amountSats');

    if (instance != null && nwcConnection != null) {
      final ndk.MakeInvoiceResponse invoiceResponse =
          await instance!.nwc.makeInvoice(
        nwcConnection!,
        amountSats: amountSats,
        description: 'Nostrpay ⚡️',
      );
      return invoiceResponse;
    }
    return null;
  }

  Future<ndk.PayInvoiceResponse?> payInvoice({required String invoice}) async {
    _logger.info('Paying invoice');
    if (instance != null && nwcConnection != null) {
      final ndk.PayInvoiceResponse payInvoiceResponse =
          await instance!.nwc.payInvoice(
        nwcConnection!,
        invoice: invoice,
        timeout: const Duration(seconds: 16),
      );
      return payInvoiceResponse;
    }
    return null;
  }
}

class PaymentNotificationEvent {
  final NwcNotification notification;
  final bool isPaymentReceived;
  final bool isPaymentSent;

  PaymentNotificationEvent({
    required this.notification,
    required this.isPaymentReceived,
    required this.isPaymentSent,
  });

  factory PaymentNotificationEvent.fromNotification(
    NwcNotification notification,
  ) {
    return PaymentNotificationEvent(
      notification: notification,
      isPaymentReceived: notification.isPaymentReceived,
      isPaymentSent: notification.isPaymentSent,
    );
  }
}
