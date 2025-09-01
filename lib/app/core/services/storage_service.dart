import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../data/models/user_model.dart';
import 'package:flutter/foundation.dart';
// Required imports for JWT decoding
import 'dart:convert';
import 'dart:typed_data';

class StorageService extends GetxService {
  late final GetStorage _box;
  
  // Storage Keys
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserData = 'user_data';
  static const String _keyLanguage = 'language';
  static const String _keyFirstLaunch = 'first_launch';
  static const String _keyNotificationEnabled = 'notification_enabled';
  static const String _keyLocationPermission = 'location_permission';
  
  @override
  Future<void> onInit() async {
    super.onInit();
    _box = GetStorage();
  }
  
  // Token Management
  String? get accessToken => _box.read(_keyAccessToken);
  
  String? get refreshToken => _box.read(_keyRefreshToken);
  
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _box.write(_keyAccessToken, accessToken);
    await _box.write(_keyRefreshToken, refreshToken);
  }
  
  Future<void> saveAccessToken(String token) async {
    await _box.write(_keyAccessToken, token);
  }
  
  Future<void> clearTokens() async {
    await _box.remove(_keyAccessToken);
    await _box.remove(_keyRefreshToken);
  }
  
  bool hasValidToken() {
    final token = accessToken;
    if (token == null || token.isEmpty) return false;
    
    try {
      // Basic JWT validation - check if token has 3 parts
      final parts = token.split('.');
      if (parts.length != 3) return false;
      
      // Decode payload to check expiration
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> payloadMap = json.decode(decoded);
      
      final exp = payloadMap['exp'] as int?;
      if (exp == null) return false;
      
      final expirationDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().isBefore(expirationDate);
    } catch (e) {
      return false;
    }
  }
  
  // User Data Management
  UserModel? get currentUser {
    final userData = _box.read(_keyUserData);
    if (userData != null) {
      return UserModel.fromJson(Map<String, dynamic>.from(userData));
    }
    return null;
  }
  
  Future<void> saveUser(UserModel user) async {
    await _box.write(_keyUserData, user.toJson());
  }
  
  Future<void> clearUser() async {
    await _box.remove(_keyUserData);
  }
  
  // Language Management
  String get language => _box.read(_keyLanguage) ?? 'ar';
  
  Future<void> saveLanguage(String language) async {
    await _box.write(_keyLanguage, language);
  }
  
  // App State Management
  bool get isFirstLaunch => _box.read(_keyFirstLaunch) ?? true;
  
  Future<void> setFirstLaunchComplete() async {
    await _box.write(_keyFirstLaunch, false);
  }
  
  bool get isNotificationEnabled => _box.read(_keyNotificationEnabled) ?? true;
  
  Future<void> setNotificationEnabled(bool enabled) async {
    await _box.write(_keyNotificationEnabled, enabled);
  }
  
  bool get hasLocationPermission => _box.read(_keyLocationPermission) ?? false;
  
  Future<void> setLocationPermission(bool granted) async {
    await _box.write(_keyLocationPermission, granted);
  }
  
  // Complete logout - clear all user data
  Future<void> logout() async {
    await clearTokens();
    await clearUser();
    // Keep app preferences like language and notification settings
  }
  
  // Clear all data (for testing or complete reset)
  Future<void> clearAll() async {
    await _box.erase();
  }
  
  // Utility methods
  Future<void> write(String key, dynamic value) async {
    await _box.write(key, value);
  }
  
  T? read<T>(String key) {
    return _box.read<T>(key);
  }
  
  Future<void> remove(String key) async {
    await _box.remove(key);
  }
  
  bool hasData(String key) {
    return _box.hasData(key);
  }
}

