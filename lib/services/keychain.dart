import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nostr_pay_kids/utils/constants.dart';

class KeyChain {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
        groupId: 'group.$APP_ID_PREFIX.$APP_BUNDLE_ID'),
  );

  Future<String?> read(String key) {
    return _storage.read(key: key);
  }

  Future<void> write(String key, String value) {
    return _storage.write(key: key, value: value);
  }

  Future<void> delete(String key) {
    return _storage.delete(key: key);
  }

  Future<void> clear() {
    return _storage.deleteAll();
  }
}
