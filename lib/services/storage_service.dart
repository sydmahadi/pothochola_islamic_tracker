import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tracker_data.dart';

class StorageService {
  static const String _dataKey = 'pathchola_v1_data';
  static const String _englishKey = 'pathchola_english';
  static const String _darkKey = 'pathchola_dark';

  Future<Map<String, dynamic>> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_dataKey);

    if (raw == null || raw.isEmpty) {
      return TrackerData.empty();
    }

    return TrackerData.normalize(jsonDecode(raw));
  }

  Future<void> saveData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dataKey, jsonEncode(data));
  }

  Future<bool> loadEnglish() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_englishKey) ?? false;
  }

  Future<bool> loadDark() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkKey) ?? true;
  }

  Future<void> saveEnglish(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_englishKey, value);
  }

  Future<void> saveDark(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkKey, value);
  }
}
