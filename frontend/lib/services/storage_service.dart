import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final _secureStorage = const FlutterSecureStorage();
  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: StorageKeys.token, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: StorageKeys.token);
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: StorageKeys.token);
  }

  Future<void> saveUser(UserModel user) async {
    final userJson = json.encode(user.toJson());
    await _prefs?.setString(StorageKeys.user, userJson);
  }

  Future<UserModel?> getUser() async {
    final userJson = _prefs?.getString(StorageKeys.user);
    if (userJson != null) {
      return UserModel.fromJson(json.decode(userJson));
    }
    return null;
  }

  Future<void> deleteUser() async {
    await _prefs?.remove(StorageKeys.user);
  }

  Future<void> saveThemeMode(String mode) async {
    await _prefs?.setString(StorageKeys.theme, mode);
  }

  Future<String?> getThemeMode() async {
    return _prefs?.getString(StorageKeys.theme);
  }

  Future<void> clearAll() async {
    await deleteToken();
    await deleteUser();
    await _prefs?.clear();
  }
}