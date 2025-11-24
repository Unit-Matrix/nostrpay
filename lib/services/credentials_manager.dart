import 'package:logging/logging.dart';

import 'keychain.dart';

final Logger _logger = Logger('CredentialsManager');

const String nwcWalletSecretKey = "nwc_wallet_secret";
const String ecashMnemonicKey = "ecash_mnemonic";

class CredentialsManager {
  final KeyChain keyChain;

  CredentialsManager({required this.keyChain});

  Future storeSecret({required String secret}) async {
    try {
      await keyChain.write(nwcWalletSecretKey, secret);
      _logger.info('Stored secret successfully');
    } catch (err) {
      _logger.severe('Failed to store secret', err);
      throw Exception("Failed to store secret: $err");
    }
  }

  Future<String?> restoreSecret() async {
    try {
      final secret = await keyChain.read(nwcWalletSecretKey);
      _logger.info(
        (secret != null)
            ? 'Restored secret successfully'
            : 'No secret found in secure storage',
      );
      return secret;
    } catch (err) {
      _logger.severe('Failed to restore secret', err);
      throw Exception("Failed to restore secret: $err");
    }
  }

  Future<void> deleteSecret() async {
    try {
      await keyChain.delete(nwcWalletSecretKey);
      _logger.info('Deleted secret successfully');
    } catch (err) {
      _logger.severe('Failed to delete secret', err);
      throw Exception("Failed to delete secret: $err");
    }
  }

  Future<void> storeEcashMnemonic({required String mnemonic}) async {
    try {
      await keyChain.write(ecashMnemonicKey, mnemonic);
      _logger.info('Stored ecash mnemonic successfully');
    } catch (err) {
      _logger.severe('Failed to store ecash mnemonic', err);
      throw Exception("Failed to store ecash mnemonic: $err");
    }
  }

  Future<String?> restoreEcashMnemonic() async {
    try {
      final mnemonic = await keyChain.read(ecashMnemonicKey);
      _logger.info(
        (mnemonic != null)
            ? 'Restored ecash mnemonic successfully'
            : 'No ecash mnemonic found in secure storage',
      );
      return mnemonic;
    } catch (err) {
      _logger.severe('Failed to restore ecash mnemonic', err);
      throw Exception("Failed to restore ecash mnemonic: $err");
    }
  }

  Future<void> deleteEcashMnemonic() async {
    try {
      await keyChain.delete(ecashMnemonicKey);
      _logger.info('Deleted ecash mnemonic successfully');
    } catch (err) {
      _logger.severe('Failed to delete ecash mnemonic', err);
      throw Exception("Failed to delete ecash mnemonic: $err");
    }
  }
}
