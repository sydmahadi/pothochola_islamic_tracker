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

    if (raw == null || raw.trim().isEmpty) {
      return TrackerData.empty();
    }

    try {
      final decoded = jsonDecode(raw);

      if (decoded is Map<String, dynamic>) {
        return TrackerData.normalize(
          Map<String, dynamic>.from(decoded),
        );
      }

      return TrackerData.empty();
    } catch (_) {
      // ভুল বা অসম্পূর্ণ JSON থাকলে অ্যাপ ক্র্যাশ করবে না।
      // মূল সংরক্ষিত ডেটা এখানে মুছে ফেলা হচ্ছে না।
      return TrackerData.empty();
    }
  }

  Future<void> saveData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();

    final normalized = TrackerData.normalize(
      Map<String, dynamic>.from(data),
    );

    final encoded = jsonEncode(normalized);
    final success = await prefs.setString(_dataKey, encoded);

    if (!success) {
      throw Exception('অ্যাপের ডেটা সংরক্ষণ করা যায়নি।');
    }
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
    final success = await prefs.setBool(_englishKey, value);

    if (!success) {
      throw Exception('ভাষার সেটিং সংরক্ষণ করা যায়নি।');
    }
  }

  Future<void> saveDark(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    final success = await prefs.setBool(_darkKey, value);

    if (!success) {
      throw Exception('থিমের সেটিং সংরক্ষণ করা যায়নি।');
    }
  }
}
