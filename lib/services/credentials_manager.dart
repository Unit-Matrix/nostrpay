import 'package:logging/logging.dart';

import 'keychain.dart';

final Logger _logger = Logger('CredentialsManager');

const String nwcWalletSecretKey = "nwc_wallet_secret";

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
}
