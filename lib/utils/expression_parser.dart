import 'dart:math' as math;
import '../models/calculator_mode.dart';

class ExpressionParser {
  final AngleMode angleMode;
  final int decimalPrecision;
  
  String _expression = '';
  int _position = 0;

  ExpressionParser({
    this.angleMode = AngleMode.degrees,
    this.decimalPrecision = 6,
  });

  double evaluate(String expression) {
    try {
      _expression = expression.replaceAll('×', '*').replaceAll('÷', '/').replaceAll(' ', '');
      _position = 0;
      
      if (_expression.isEmpty) {
        throw Exception('Empty expression');
      }
      
      double result = _parseExpression();
      
      if (_position < _expression.length) {
        throw Exception('Unexpected character at position $_position');
      }
      
      return result;
    } catch (e) {
      throw Exception('Invalid expression: $e');
    }
  }

  double _parseExpression() {
    double result = _parseTerm();
    
    while (_position < _expression.length) {
      String op = _peek();
      
      if (op == '+' || op == '-') {
        _position++;
        double right = _parseTerm();
        
        if (op == '+') {
          result += right;
        } else {
          result -= right;
        }
      } else {
        break;
      }
    }
    
    return result;
  }

  double _parseTerm() {
    double result = _parseFactor();
    
    while (_position < _expression.length) {
      String op = _peek();
      
      if (op == '*' || op == '/') {
        _position++;
        double right = _parseFactor();
        
        if (op == '*') {
          result *= right;
        } else {
          if (right == 0) throw Exception('Division by zero');
          result /= right;
        }
      } else {
        break;
      }
    }
    
    return result;
  }

  double _parseFactor() {
    double result = _parseUnary();
    
    // Power is right-associative
    if (_position < _expression.length && _peek() == '^') {
      _position++;
      double exponent = _parseFactor();
      result = math.pow(result, exponent).toDouble();
    }
    
    return result;
  }

  double _parseUnary() {
    if (_position < _expression.length) {
      String ch = _peek();
      
      if (ch == '+') {
        _position++;
        return _parseUnary();
      }
      
      if (ch == '-') {
        _position++;
        return -_parseUnary();
      }
    }
    
    return _parsePrimary();
  }

  double _parsePrimary() {
    if (_position >= _expression.length) {
      throw Exception('Unexpected end of expression');
    }
    
    // Handle parentheses
    if (_peek() == '(') {
      _position++;
      double result = _parseExpression();
      
      if (_position >= _expression.length || _peek() != ')') {
        throw Exception('Missing closing parenthesis');
      }
      _position++;
      
      return result;
    }
    
    // Parse number
    return _parseNumber();
  }

  double _parseNumber() {
    int start = _position;
    
    // Parse digits before decimal point
    while (_position < _expression.length && _isDigit(_peek())) {
      _position++;
    }
    
    // Parse decimal point and digits after
    if (_position < _expression.length && _peek() == '.') {
      _position++;
      
      while (_position < _expression.length && _isDigit(_peek())) {
        _position++;
      }
    }
    
    if (start == _position) {
      throw Exception('Expected number at position $_position');
    }
    
    String numberStr = _expression.substring(start, _position);
    
    try {
      return double.parse(numberStr);
    } catch (e) {
      throw Exception('Invalid number: $numberStr');
    }
  }

  String _peek() {
    if (_position >= _expression.length) {
      return '';
    }
    return _expression[_position];
  }

  bool _isDigit(String ch) {
    if (ch.isEmpty) return false;
    int code = ch.codeUnitAt(0);
    return code >= 48 && code <= 57;
  }
}