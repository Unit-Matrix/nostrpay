import 'dart:async';
import 'package:cdk_flutter/cdk_flutter.dart';
import 'package:logging/logging.dart';
import 'package:nostr_pay_kids/app_config.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:nostr_pay_kids/models/ecash_item.dart';

final Logger _logger = Logger('EcashCdkSDK');

class EcashCdkSDK {
  EcashCdkSDK();

  // CDK wallet instance
  Wallet? _wallet;

  // Streams for ecash updates
  final StreamController<List<EcashItem>> _ecashItemsController =
      BehaviorSubject<List<EcashItem>>();

  Stream<List<EcashItem>> get ecashItemsStream => _ecashItemsController.stream;

  /// Initialize CDK wallet with provided mnemonic
  Future<void> initialize({required String mnemonic}) async {
    if (_wallet != null) {
      _logger.info('CDK already initialized');
      return;
    }

    try {
      _logger.info('Initializing EcashCdkSDK');
      await CdkFlutter.init();

      final directory = await getApplicationDocumentsDirectory();
      final database = await WalletDatabase.newInstance(
        path: '${directory.path}/ecash_wallet.sqlite',
      );

      _wallet = Wallet(
        mintUrl: AppConfig.ecashMintUrl,
        unit: 'sat',
        mnemonic: mnemonic,
        db: database,
      );

      _logger.info('Cdk initialized');
    } catch (e, stackTrace) {
      _logger.severe('Cdk initialization failed', e, stackTrace);
      rethrow;
    }
  }

  /// Create/Mint new Ecash tokens - returns stream of mint quotes
  Stream<MintQuote> createEcash({required int amountSats}) {
    _logger.info('Creating Ecash for $amountSats sats');

    if (_wallet == null) {
      throw Exception('Wallet not initialized');
    }

    return _wallet!.mint(amount: BigInt.from(amountSats));
  }

  void dispose() {
    _ecashItemsController.close();
  }
}
