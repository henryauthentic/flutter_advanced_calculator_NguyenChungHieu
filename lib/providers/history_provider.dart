import 'package:flutter/material.dart';
import '../models/calculation_history.dart';
import '../services/storage_service.dart';

class HistoryProvider with ChangeNotifier {
  List<CalculationHistory> _history = [];
  int _maxHistorySize = 50;

  HistoryProvider() {
    loadHistory();
  }

  List<CalculationHistory> get history => _history;
  List<CalculationHistory> get recentHistory => 
      _history.take(3).toList();

  void setMaxHistorySize(int size) {
    _maxHistorySize = size;
    if (_history.length > size) {
      _history = _history.take(size).toList();
      saveHistory();
    }
    notifyListeners();
  }

  void addHistory(CalculationHistory item) {
    _history.insert(0, item);
    if (_history.length > _maxHistorySize) {
      _history.removeLast();
    }
    saveHistory();
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    saveHistory();
    notifyListeners();
  }

  void deleteHistoryItem(int index) {
    _history.removeAt(index);
    saveHistory();
    notifyListeners();
  }

  Future<void> loadHistory() async {
    _history = await StorageService.getHistory();
    notifyListeners();
  }

  Future<void> saveHistory() async {
    await StorageService.saveHistory(_history);
  }
}