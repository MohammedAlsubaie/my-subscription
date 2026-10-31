import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The signed-in user.
class AppUser {
  final String id;
  final String name;
  final String email;

  const AppUser({required this.id, required this.name, required this.email});
}

/// Result of register / login: either a user, or an error key
/// (the key is translated on screen).
class AuthResult {
  final AppUser? user;
  final String? error;

  const AuthResult._(this.user, this.error);

  factory AuthResult.ok(AppUser user) => AuthResult._(user, null);
  factory AuthResult.fail(String error) => AuthResult._(null, error);
}

/// Accounts are stored on the device. Passwords are never saved as plain text,
/// only as a salted SHA-256 hash.
class AuthService {
  static const String _usersKey = 'users';
  static const String _currentKey = 'currentUserId';
  static const String _legacyKey = 'subscriptions';

  List<Map<String, dynamic>> _readUsers(SharedPreferences prefs) {
    final raw = prefs.getString(_usersKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _writeUsers(
    SharedPreferences prefs,
    List<Map<String, dynamic>> users,
  ) async {
    await prefs.setString(_usersKey, jsonEncode(users));
  }

  String _newSalt() {
    final rnd = Random.secure();
    return base64UrlEncode(List<int>.generate(16, (_) => rnd.nextInt(256)));
  }

  String _hash(String salt, String password) =>
      sha256.convert(utf8.encode('$salt:$password')).toString();

  AppUser _toUser(Map<String, dynamic> m) => AppUser(
        id: m['id'] as String,
        name: m['name'] as String,
        email: m['email'] as String,
      );

  /// The user who is still signed in from the last time, or null.
  Future<AppUser?> currentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_currentKey);
    if (id == null) return null;
    for (final u in _readUsers(prefs)) {
      if (u['id'] == id) return _toUser(u);
    }
    return null;
  }

  Future<AuthResult> register(String name, String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final users = _readUsers(prefs);
    final mail = email.trim().toLowerCase();
    if (users.any((u) => u['email'] == mail)) {
      return AuthResult.fail('emailTaken');
    }

    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final salt = _newSalt();
    users.add({
      'id': id,
      'name': name.trim(),
      'email': mail,
      'salt': salt,
      'hash': _hash(salt, password),
    });
    await _writeUsers(prefs, users);

    // The very first account takes over the subscriptions that were saved
    // before accounts existed, so nothing is lost.
    final legacy = prefs.getString(_legacyKey);
    if (users.length == 1 && legacy != null) {
      await prefs.setString('subscriptions_$id', legacy);
      await prefs.remove(_legacyKey);
    }

    await prefs.setString(_currentKey, id);
    return AuthResult.ok(AppUser(id: id, name: name.trim(), email: mail));
  }

  Future<AuthResult> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final mail = email.trim().toLowerCase();
    for (final u in _readUsers(prefs)) {
      if (u['email'] == mail &&
          u['hash'] == _hash(u['salt'] as String, password)) {
        await prefs.setString(_currentKey, u['id'] as String);
        return AuthResult.ok(_toUser(u));
      }
    }
    return AuthResult.fail('wrongCreds');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentKey);
  }
}
