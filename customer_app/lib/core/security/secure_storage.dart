import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  SecureStorageService() : _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  final FlutterSecureStorage _storage;

  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  Future<bool> containsKey(String key) async {
    return _storage.containsKey(key: key);
  }

  // Token management
  Future<void> saveAccessToken(String token) async {
    await write('access_token', token);
  }

  Future<String?> getAccessToken() async {
    return read('access_token');
  }

  Future<void> saveRefreshToken(String token) async {
    await write('refresh_token', token);
  }

  Future<String?> getRefreshToken() async {
    return read('refresh_token');
  }

  Future<void> clearTokens() async {
    await delete('access_token');
    await delete('refresh_token');
  }
}
