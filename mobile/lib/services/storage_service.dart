import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../models/user_model.dart';

class StorageService {
  static StorageService? _instance;
  SharedPreferences? _prefs;

  StorageService._();

  static StorageService get instance {
    _instance ??= StorageService._();
    return _instance!;
  }

  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> saveToken(String token) async {
    final p = await prefs;
    await p.setString(kTokenKey, token);
  }

  Future<String?> getToken() async {
    final p = await prefs;
    return p.getString(kTokenKey);
  }

  Future<void> removeToken() async {
    final p = await prefs;
    await p.remove(kTokenKey);
  }

  Future<void> saveUser(UserModel user) async {
    final p = await prefs;
    await p.setString(kUserKey, jsonEncode(user.toJson()));
  }

  Future<UserModel?> getUser() async {
    final p = await prefs;
    final userStr = p.getString(kUserKey);
    if (userStr == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(userStr) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> removeUser() async {
    final p = await prefs;
    await p.remove(kUserKey);
  }

  Future<void> saveCustomBaseUrl(String url) async {
    final p = await prefs;
    await p.setString('custom_base_url', url);
  }

  Future<String> getBaseUrl() async {
    final p = await prefs;
    return p.getString('custom_base_url') ?? apiBaseUrl;
  }

  Future<void> clearAuth() async {
    await removeToken();
    await removeUser();
  }
}
