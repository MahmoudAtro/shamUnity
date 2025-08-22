import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shamunity/models/verify_otp_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureSharedPrefHelper {
  // private constructor as I don't want to allow creating an instance of this class itself.
  SecureSharedPrefHelper._();

  /// Removes all keys and values in the SharedPreferences
  static clearAllData() async {
    debugPrint('SharedPrefHelper : all data has been cleared');
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
  }

  static logout() async {
    debugPrint('SharedPrefHelper : all data to logout has been cleared');
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.remove("userToken");
    await sharedPreferences.remove('user');
  }

  /// Saves a [value] with a [key] in the SharedPreferences.
  static setData(String key, value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    debugPrint("SharedPrefHelper : setData with key : $key and value : $value");
    switch (value.runtimeType) {
      case const (String):
        await sharedPreferences.setString(key, value);
        break;
      case const (int):
        await sharedPreferences.setInt(key, value);
        break;
      case const (bool):
        await sharedPreferences.setBool(key, value);
        break;
      case const (double):
        await sharedPreferences.setDouble(key, value);
        break;
      default:
        return null;
    }
  }

  /// Gets an String value from SharedPreferences with given [key].
  static getString(String key) async {
    debugPrint('SharedPrefHelper : getString with key : $key');
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(key) ?? '';
  }

  static Future<void> saveUser(UserModel user) async {
    debugPrint("SharedPrefHelper : setData with key : user and value : $user");
    final prefs = await SharedPreferences.getInstance();
    String userJson = jsonEncode(user.toJson());
    debugPrint("SharedPrefHelper : saveUser with key : user and value : $userJson");
    await prefs.setString('user', userJson);
  }

  static Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('user');
    if (userJson == null) return null;
    Map<String, dynamic> userMap = jsonDecode(userJson);
    return UserModel.fromJson(userMap);
  }

  /// Saves the ThemeMode in SharedPreferences.
  static Future<void> setThemeMode(ThemeMode themeMode) async {
    debugPrint('SharedPrefHelper : setThemeMode to $themeMode');
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setInt('themeMode', themeMode.index);
  }

  /// Gets the ThemeMode from SharedPreferences.
  static Future<ThemeMode> getThemeMode() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int themeModeIndex =
        sharedPreferences.getInt('themeMode') ?? 0; // Default to light theme
    return ThemeMode.values[themeModeIndex];
  }
}
