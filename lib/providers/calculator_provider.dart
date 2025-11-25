import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/calculator_mode.dart';
import '../models/calculation_history.dart';
import '../models/calculator_settings.dart';
import '../utils/calculator_logic.dart';
import '../utils/expression_parser.dart';
import '../utils/programmer_calculator.dart';
import 'history_provider.dart';

class CalculatorProvider with ChangeNotifier {
  String _display = '0';
  String _expression = '';
  String _previousResult = '';
  String _error = '';
  CalculatorMode _mode = CalculatorMode.basic;
  AngleMode _angleMode = AngleMode.degrees;
  double _memory = 0;
  bool _hasMemory = false;
  CalculatorSettings _settings = CalculatorSettings();
  bool _shouldResetDisplay = false;

  String get display => _display;
  String get expression => _expression;
  String get previousResult => _previousResult;
  String get error => _error;
  CalculatorMode get mode => _mode;
  AngleMode get angleMode => _angleMode;
  bool get hasMemory => _hasMemory;
  CalculatorSettings get settings => _settings;

  void updateSettings(CalculatorSettings newSettings) {
    _settings = newSettings;
    _angleMode = newSettings.angleMode;
    notifyListeners();
  }

  void setMode(CalculatorMode newMode) {
    _mode = newMode;
    clear();
    notifyListeners();
  }

  void toggleAngleMode() {
    _angleMode = _angleMode == AngleMode.degrees 
        ? AngleMode.radians 
        : AngleMode.degrees;
    notifyListeners();
  }

  void input(String value) {
  _error = '';
  
  if (_settings.hapticFeedback) {
    HapticFeedback.lightImpact();
  }

  // Reset display if needed
  if (_shouldResetDisplay) {
    _display = '';
    // Don't add space after bitwise operators in programmer mode
    if (_mode == CalculatorMode.programmer && 
        (_expression.endsWith('AND ') || _expression.endsWith('OR ') || 
         _expression.endsWith('XOR ') || _expression.endsWith('<< ') || 
         _expression.endsWith('>> ') || _expression.endsWith('NOT '))) {
      // Keep the operator with space
    } else {
      _expression = _expression.trimRight();
    }
    _shouldResetDisplay = false;
  }

  // Don't allow multiple decimal points (except in programmer mode)
  if (value == '.' && _mode != CalculatorMode.programmer) {
    List<String> parts = _expression.split(RegExp(r'[+\-×÷^() ]'));
    String lastNumber = parts.isNotEmpty ? parts.last : '';
    
    if (lastNumber.contains('.')) {
      return;
    }
    
    if (_display.isEmpty || _display == '0') {
      _display = '0.';
      _expression += '0.';
      notifyListeners();
      return;
    }
  }

  // Handle first input
  if (_display == '0' && value != '.') {
    _display = value;
    _expression = value;
  } else {
    _display += value;
    _expression += value;
  }
  
  notifyListeners();
}

  void inputOperator(String operator) {
  if (_error.isNotEmpty) return;
  
  if (_settings.hapticFeedback) {
    HapticFeedback.mediumImpact();
  }

  // Handle NOT operator (unary, can be at start)
  if (operator == 'NOT') {
    if (_expression.isEmpty || _shouldResetDisplay) {
      _expression = 'NOT ';
      _display = 'NOT ';
      _shouldResetDisplay = false;
    } else {
      _expression += ' NOT ';
    }
    notifyListeners();
    return;
  }

  // Don't allow other operators at start
  if (_expression.isEmpty) {
    return;
  }

  // For programmer bitwise operators - ALWAYS add spaces
  if (_mode == CalculatorMode.programmer) {
    if (operator == 'AND' || operator == 'OR' || operator == 'XOR' || 
        operator == '<<' || operator == '>>') {
      String trimmed = _expression.trimRight();
      
      // Replace if last is an operator
      List<String> opsToCheck = [' AND', ' OR', ' XOR', ' <<', ' >>'];
      bool replacedOp = false;
      
      for (String op in opsToCheck) {
        if (trimmed.endsWith(op)) {
          int lastSpace = trimmed.lastIndexOf(' ', trimmed.length - 2);
          if (lastSpace != -1) {
            _expression = trimmed.substring(0, lastSpace) + ' $operator ';
          } else {
            _expression = ' $operator ';
          }
          replacedOp = true;
          break;
        }
      }
      
      if (!replacedOp) {
        _expression = trimmed + ' $operator ';
      }
      
      _shouldResetDisplay = true;
      notifyListeners();
      return;
    }
  }

  // Regular operators (no spaces for arithmetic)
  String trimmed = _expression.trimRight();
  String lastChar = trimmed.isNotEmpty ? trimmed[trimmed.length - 1] : '';
  
  if (lastChar == '+' || lastChar == '-' || lastChar == '×' || 
      lastChar == '÷' || lastChar == '^') {
    _expression = trimmed.substring(0, trimmed.length - 1) + operator;
  } else {
    _expression = trimmed + operator;
  }
  
  _shouldResetDisplay = true;
  notifyListeners();
}

  void calculate(HistoryProvider historyProvider) {
    if (_expression.isEmpty) return;

    try {
      double result;
      String formattedResult;

      // Programmer mode
      if (_mode == CalculatorMode.programmer) {
        if (_expression.contains('AND') || _expression.contains('OR') || 
            _expression.contains('XOR') || _expression.contains('NOT') ||
            _expression.contains('<<') || _expression.contains('>>')) {
          final intResult = ProgrammerCalculator.evaluateProgrammerExpression(_expression);
          result = intResult.toDouble();
          formattedResult = intResult.toString();
        } else {
          final parser = ExpressionParser(
            angleMode: _angleMode,
            decimalPrecision: _settings.decimalPrecision,
          );
          result = parser.evaluate(_expression);
          formattedResult = _formatResult(result);
        }
      } else {
        // Basic and Scientific modes
        final parser = ExpressionParser(
          angleMode: _angleMode,
          decimalPrecision: _settings.decimalPrecision,
        );
        
        result = parser.evaluate(_expression);
        formattedResult = _formatResult(result);
      }
      
      _previousResult = _expression;
      _display = formattedResult;
      
      historyProvider.addHistory(
        CalculationHistory(
          expression: _expression,
          result: formattedResult,
          timestamp: DateTime.now(),
          mode: _mode.displayName,
        ),
      );
      
      _expression = formattedResult;
      _error = '';
      _shouldResetDisplay = true;
      
      if (_settings.hapticFeedback) {
        HapticFeedback.heavyImpact();
      }
    } catch (e) {
      _error = 'Error';
      _shouldResetDisplay = true;
      if (_settings.hapticFeedback) {
        HapticFeedback.vibrate();
      }
    }
    notifyListeners();
  }

  String _formatResult(double value) {
    if (value == value.toInt() && value.abs() < 1e10) {
      return value.toInt().toString();
    }
    
    String result = value.toStringAsFixed(_settings.decimalPrecision);
    result = result.replaceAll(RegExp(r'0*$'), '');
    result = result.replaceAll(RegExp(r'\.$'), '');
    
    return result;
  }

  void clear() {
    _display = '0';
    _expression = '';
    _previousResult = '';
    _error = '';
    _shouldResetDisplay = false;
    notifyListeners();
  }

  void clearEntry() {
    _display = '0';
    _shouldResetDisplay = false;
    notifyListeners();
  }

  void backspace() {
    if (_display.length > 1 && !_shouldResetDisplay) {
      _display = _display.substring(0, _display.length - 1);
      if (_expression.isNotEmpty) {
        _expression = _expression.substring(0, _expression.length - 1);
      }
    } else {
      _display = '0';
      _shouldResetDisplay = false;
    }
    notifyListeners();
  }

  void percent() {
    try {
      final value = double.parse(_display);
      final result = value / 100;
      _display = _formatResult(result);
      
      List<String> parts = _expression.split(RegExp(r'(?=[+\-×÷^()])'));
      if (parts.isNotEmpty) {
        parts[parts.length - 1] = _display;
        _expression = parts.join('');
      } else {
        _expression = _display;
      }
      
      _shouldResetDisplay = true;
      notifyListeners();
    } catch (e) {
      _error = 'Invalid operation';
      notifyListeners();
    }
  }

  void negate() {
    try {
      final value = double.parse(_display);
      final result = -value;
      _display = _formatResult(result);
      
      if (_expression.endsWith(_display.replaceFirst('-', ''))) {
        _expression = _expression.substring(0, _expression.length - _display.replaceFirst('-', '').length) + _display;
      } else {
        _expression = _display;
      }
      
      notifyListeners();
    } catch (e) {
      _error = 'Invalid operation';
      notifyListeners();
    }
  }

  void memoryAdd() {
    try {
      _memory += double.parse(_display);
      _hasMemory = _memory != 0;
      notifyListeners();
    } catch (e) {}
  }

  void memorySubtract() {
    try {
      _memory -= double.parse(_display);
      _hasMemory = _memory != 0;
      notifyListeners();
    } catch (e) {}
  }

  void memoryRecall() {
    _display = _formatResult(_memory);
    _expression = _display;
    _shouldResetDisplay = true;
    notifyListeners();
  }

  void memoryClear() {
    _memory = 0;
    _hasMemory = false;
    notifyListeners();
  }

  void scientificFunction(String function) {
    try {
      final value = double.parse(_display);
      final logic = CalculatorLogic(
        angleMode: _angleMode,
        decimalPrecision: _settings.decimalPrecision,
      );
      
      double result;
      String functionName = function;
      
      switch (function) {
        case 'sin':
          result = logic.sin(value);
          break;
        case 'cos':
          result = logic.cos(value);
          break;
        case 'tan':
          result = logic.tan(value);
          break;
        case 'ln':
          result = logic.ln(value);
          break;
        case 'log':
          result = logic.log10(value);
          functionName = 'log';
          break;
        case 'sqrt':
          result = logic.sqrt(value);
          functionName = '√';
          break;
        case 'square':
          result = logic.square(value);
          functionName = 'sqr';
          break;
        case 'factorial':
          result = logic.factorial(value.toInt()).toDouble();
          functionName = 'fact';
          break;
        default:
          return;
      }
      
      _display = _formatResult(result);
      _previousResult = '$functionName($value)';
      _expression = _display;
      _shouldResetDisplay = true;
      _error = '';
      notifyListeners();
    } catch (e) {
      _error = 'Math Error';
      notifyListeners();
    }
  }
}