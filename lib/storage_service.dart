import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'subscription.dart';

/// Saves the subscriptions of one user on the device,
/// so they are still there after restart.
class StorageService {
  final String userId;

  StorageService(this.userId);

  String get _key => 'subscriptions_$userId';

  Future<List<Subscription>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => Subscription.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  String get _groupsKey => 'groups_$userId';

  Future<List<String>> loadGroups() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_groupsKey) ?? [...kGroups];
  }

  Future<void> saveGroups(List<String> groups) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_groupsKey, groups);
  }

  Future<void> save(List<Subscription> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(items.map((s) => s.toJson()).toList()),
    );
  }
}
