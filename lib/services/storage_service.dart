import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/calculation_history.dart';
import '../models/calculator_settings.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // History
  static Future<void> saveHistory(List<CalculationHistory> history) async {
    final List<String> jsonList = history.map((h) => jsonEncode(h.toJson())).toList();
    await _prefs?.setStringList('calculation_history', jsonList);
  }

  static Future<List<CalculationHistory>> getHistory() async {
    final List<String>? jsonList = _prefs?.getStringList('calculation_history');
    if (jsonList == null) return [];
    
    return jsonList.map((json) {
      return CalculationHistory.fromJson(jsonDecode(json));
    }).toList();
  }

  // Theme
  static Future<void> saveTheme(String theme) async {
    await _prefs?.setString('theme', theme);
  }

  static Future<String> getTheme() async {
    return _prefs?.getString('theme') ?? 'system';
  }

  // Settings
  static Future<void> saveSettings(CalculatorSettings settings) async {
    await _prefs?.setString('settings', jsonEncode(settings.toJson()));
  }

  static Future<CalculatorSettings> getSettings() async {
    final String? jsonString = _prefs?.getString('settings');
    if (jsonString == null) return CalculatorSettings();
    
    return CalculatorSettings.fromJson(jsonDecode(jsonString));
  }

  // Memory
  static Future<void> saveMemory(double value) async {
    await _prefs?.setDouble('memory_value', value);
  }

  static Future<double> getMemory() async {
    return _prefs?.getDouble('memory_value') ?? 0.0;
  }
}