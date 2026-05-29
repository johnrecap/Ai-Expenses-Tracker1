import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AppLockStorage {
  Future<String?> read({required String key});
  Future<void> write({required String key, required String value});
  Future<void> delete({required String key});
}

class SecureAppLockStorage implements AppLockStorage {
  final FlutterSecureStorage _storage;

  const SecureAppLockStorage({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _storage = storage;

  @override
  Future<String?> read({required String key}) => _storage.read(key: key);

  @override
  Future<void> write({required String key, required String value}) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete({required String key}) => _storage.delete(key: key);
}

class PinService {
  static const minPinLength = 4;
  static const maxPinLength = 8;
  static const _pinHashKey = 'app_lock.pin_hash';
  static const _pinSaltKey = 'app_lock.pin_salt';

  final AppLockStorage _storage;
  final Random _random;

  PinService({AppLockStorage? storage, Random? random})
      : _storage = storage ?? const SecureAppLockStorage(),
        _random = random ?? Random.secure();

  Future<bool> hasPin() async {
    final hash = await _storage.read(key: _pinHashKey);
    final salt = await _storage.read(key: _pinSaltKey);
    return hash != null && hash.isNotEmpty && salt != null && salt.isNotEmpty;
  }

  Future<void> setPin(String pin) async {
    final normalized = _normalizePin(pin);
    _validatePin(normalized);
    final salt = _createSalt();
    final hash = _hashPin(normalized, salt);
    await _storage.write(key: _pinSaltKey, value: salt);
    await _storage.write(key: _pinHashKey, value: hash);
  }

  Future<bool> verifyPin(String pin) async {
    final normalized = _normalizePin(pin);
    if (!_isValidPin(normalized)) return false;
    final salt = await _storage.read(key: _pinSaltKey);
    final expectedHash = await _storage.read(key: _pinHashKey);
    if (salt == null || expectedHash == null) return false;
    final actualHash = _hashPin(normalized, salt);
    return _constantTimeEquals(actualHash, expectedHash);
  }

  Future<void> clearPin() async {
    await _storage.delete(key: _pinSaltKey);
    await _storage.delete(key: _pinHashKey);
  }

  static String _normalizePin(String pin) => pin.trim();

  static void _validatePin(String pin) {
    if (!_isValidPin(pin)) {
      throw const FormatException('PIN must be 4 to 8 digits.');
    }
  }

  static bool _isValidPin(String pin) =>
      RegExp(r'^\d{4,8}$').hasMatch(pin);

  String _createSalt() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  static String _hashPin(String pin, String salt) {
    final bytes = utf8.encode('$salt:$pin');
    return sha256.convert(bytes).toString();
  }

  static bool _constantTimeEquals(String left, String right) {
    final leftBytes = utf8.encode(left);
    final rightBytes = utf8.encode(right);
    var diff = leftBytes.length ^ rightBytes.length;
    final maxLen = max(leftBytes.length, rightBytes.length);
    for (var i = 0; i < maxLen; i++) {
      diff |= (i < leftBytes.length ? leftBytes[i] : 0) ^
          (i < rightBytes.length ? rightBytes[i] : 0);
    }
    return diff == 0;
  }
}
