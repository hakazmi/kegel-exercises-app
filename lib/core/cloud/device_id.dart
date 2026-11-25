import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

/// Stable hashed installation id for device heartbeat (no model/OS).
class DeviceIdStore {
  DeviceIdStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const String _rawKey = 'kegel_install_id_v1';

  final FlutterSecureStorage _storage;
  String? _cachedHash;

  /// Returns a 32-char hex hash of a permanent install UUID.
  Future<String> hashedDeviceId() async {
    if (_cachedHash != null) {
      return _cachedHash!;
    }
    String? raw = await _storage.read(key: _rawKey);
    if (raw == null || raw.isEmpty) {
      raw = const Uuid().v4();
      await _storage.write(key: _rawKey, value: raw);
    }
    final Digest digest = sha256.convert(utf8.encode(raw));
    final String hex = digest.toString();
    // 32 chars fits devices.device_id check (8–64).
    _cachedHash = hex.substring(0, 32);
    return _cachedHash!;
  }
}
