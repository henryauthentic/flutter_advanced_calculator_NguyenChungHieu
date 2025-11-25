import 'package:flutter_test/flutter_test.dart';
import 'dart:math' as math;

// Copy ExpressionParser class here for testing
enum AngleMode { degrees, radians }

class ExpressionParser {
  final String expression;
  final AngleMode angleMode;
  final int precision;
  int _pos = 0;

  ExpressionParser({
    required this.expression,
    required this.angleMode,
    required this.precision,
  });

  String evaluate() {
    _pos = 0;
    final result = _parseExpression();
    return _formatResult(result);
  }

  String _formatResult(double value) {
    if (value.isNaN) return 'Error';
    if (value.isInfinite) return value > 0 ? '∞' : '-∞';
    if (value == value.toInt() && value.abs() < 1e15) {
      return value.toInt().toString();
    }
    String formatted = value.toStringAsFixed(precision);
    formatted = formatted.replaceAll(RegExp(r'0+$'), '');
    formatted = formatted.replaceAll(RegExp(r'\.$'), '');
    return formatted;
  }

  double _parseExpression() {
    double result = _parseTerm();
    while (_pos < expression.length) {
      _skipWhitespace();
      if (_pos >= expression.length) break;
      final op = expression[_pos];
      if (op == '+') {
        _pos++;
        result += _parseTerm();
      } else if (op == '-') {
        _pos++;
        result -= _parseTerm();
      } else {
        break;
      }
    }
    return result;
  }

  double _parseTerm() {
    double result = _parsePower();
    while (_pos < expression.length) {
      _skipWhitespace();
      if (_pos >= expression.length) break;
      final op = expression[_pos];
      if (op == '×' || op == '*') {
        _pos++;
        result *= _parsePower();
      } else if (op == '÷' || op == '/') {
        _pos++;
        final divisor = _parsePower();
        if (divisor == 0) throw Exception('Division by zero');
        result /= divisor;
      } else if (op == '%') {
        _pos++;
        result = result / 100;
      } else {
        break;
      }
    }
    return result;
  }

  double _parsePower() {
    double result = _parseFactor();
    _skipWhitespace();
    if (_pos < expression.length && expression[_pos] == '^') {
      _pos++;
      result = math.pow(result, _parsePower()).toDouble();
    }
    return result;
  }

  double _parseFactor() {
    _skipWhitespace();
    if (_pos < expression.length && expression[_pos] == '-') {
      _pos++;
      return -_parseFactor();
    }
    if (_pos < expression.length && expression[_pos] == '(') {
      _pos++;
      final result = _parseExpression();
      if (_pos < expression.length && expression[_pos] == ')') {
        _pos++;
      }
      return _applyPostfixOperators(result);
    }
    final funcResult = _tryParseFunction();
    if (funcResult != null) {
      return _applyPostfixOperators(funcResult);
    }
    if (_pos < expression.length) {
      if (expression[_pos] == 'π') {
        _pos++;
        return _applyPostfixOperators(math.pi);
      }
      if (expression[_pos] == 'e' && 
          (_pos + 1 >= expression.length || !_isAlpha(expression[_pos + 1]))) {
        _pos++;
        return _applyPostfixOperators(math.e);
      }
    }
    return _applyPostfixOperators(_parseNumber());
  }

  double _applyPostfixOperators(double value) {
    _skipWhitespace();
    if (_pos < expression.length && expression[_pos] == '!') {
      _pos++;
      return _factorial(value.toInt()).toDouble();
    }
    return value;
  }

  double? _tryParseFunction() {
    final functions = ['sin', 'cos', 'tan', 'asin', 'acos', 'atan', 'ln', 'log', 'sqrt', '√', 'abs'];
    for (final func in functions) {
      if (expression.substring(_pos).startsWith(func)) {
        _pos += func.length;
        _skipWhitespace();
        double arg;
        if (_pos < expression.length && expression[_pos] == '(') {
          _pos++;
          arg = _parseExpression();
          if (_pos < expression.length && expression[_pos] == ')') {
            _pos++;
          }
        } else {
          arg = _parseFactor();
        }
        return _applyFunction(func, arg);
      }
    }
    return null;
  }

  double _applyFunction(String func, double arg) {
    double angleArg = arg;
    if (['sin', 'cos', 'tan'].contains(func) && angleMode == AngleMode.degrees) {
      angleArg = arg * math.pi / 180;
    }
    switch (func) {
      case 'sin': return math.sin(angleArg);
      case 'cos': return math.cos(angleArg);
      case 'tan': return math.tan(angleArg);
      case 'asin':
        final result = math.asin(arg);
        return angleMode == AngleMode.degrees ? result * 180 / math.pi : result;
      case 'acos':
        final result = math.acos(arg);
        return angleMode == AngleMode.degrees ? result * 180 / math.pi : result;
      case 'atan':
        final result = math.atan(arg);
        return angleMode == AngleMode.degrees ? result * 180 / math.pi : result;
      case 'ln': return math.log(arg);
      case 'log': return math.log(arg) / math.ln10;
      case 'sqrt':
      case '√': return math.sqrt(arg);
      case 'abs': return arg.abs();
      default: return arg;
    }
  }

  int _factorial(int n) {
    if (n < 0) throw Exception('Invalid factorial');
    if (n <= 1) return 1;
    int result = 1;
    for (int i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
  }

  double _parseNumber() {
    _skipWhitespace();
    final start = _pos;
    while (_pos < expression.length && 
           (_isDigit(expression[_pos]) || expression[_pos] == '.')) {
      _pos++;
    }
    if (start == _pos) return 0;
    return double.parse(expression.substring(start, _pos));
  }

  void _skipWhitespace() {
    while (_pos < expression.length && expression[_pos] == ' ') {
      _pos++;
    }
  }

  bool _isDigit(String ch) => ch.codeUnitAt(0) >= 48 && ch.codeUnitAt(0) <= 57;
  bool _isAlpha(String ch) => 
      (ch.codeUnitAt(0) >= 65 && ch.codeUnitAt(0) <= 90) || 
      (ch.codeUnitAt(0) >= 97 && ch.codeUnitAt(0) <= 122);
}

void main() {
  group('Basic Arithmetic Tests', () {
    test('Addition', () {
      final parser = ExpressionParser(
        expression: '5+3',
        angleMode: AngleMode.degrees,
        precision: 8,
      );
      expect(parser.evaluate(), '8');
      print(parser.evaluate());

    });

    test('Subtraction', () {
      final parser = ExpressionParser(
        expression: '10-4',
        angleMode: AngleMode.degrees,
        precision: 8,
      );
      expect(parser.evaluate(), '6');
      print(parser.evaluate());

    });

    test('Multiplication', () {
      final parser = ExpressionParser(
        expression: '6×7',
        angleMode: AngleMode.degrees,
        precision: 8,
      );
      expect(parser.evaluate(), '42');
      print(parser.evaluate());

    });

    test('Division', () {
      final parser = ExpressionParser(
        expression: '20÷4',
        angleMode: AngleMode.degrees,
        precision: 8,
      );
      expect(parser.evaluate(), '5');
      print(parser.evaluate());

    });

    test('Division by zero', () {
      final parser = ExpressionParser(
        expression: '10÷0',
        angleMode: AngleMode.degrees,
        precision: 8,
      );
      expect(() => parser.evaluate(), throwsException);
      
    });
  });

  group('Operator Precedence Tests', () {
    test('Complex expression: (5 + 3) × 2 - 4 ÷ 2 = 14', () {
      final parser = ExpressionParser(
        expression: '(5+3)×2-4÷2',
        angleMode: AngleMode.degrees,
        precision: 8,
      );
      expect(parser.evaluate(), '14');
      print(parser.evaluate());

    });

    test('Parentheses nesting: ((2 + 3) × (4 - 1)) ÷ 5 = 3', () {
      final parser = ExpressionParser(
        expression: '((2+3)×(4-1))÷5',
        angleMode: AngleMode.degrees,
        precision: 8,
      );
      expect(parser.evaluate(), '3');
      print(parser.evaluate());

    });

    test('Power operation', () {
      final parser = ExpressionParser(
        expression: '2^10',
        angleMode: AngleMode.degrees,
        precision: 8,
      );
      expect(parser.evaluate(), '1024');
      print(parser.evaluate());

    });

    test('Mixed operations with precedence', () {
      final parser = ExpressionParser(
        expression: '2+3×4',
        angleMode: AngleMode.degrees,
        precision: 8,
      );
      expect(parser.evaluate(), '14');
      print(parser.evaluate());

    });
  });

  group('Scientific Function Tests', () {
    test('sin(45°) in degrees mode', () {
      final parser = ExpressionParser(
        expression: 'sin(45)',
        angleMode: AngleMode.degrees,
        precision: 8,
      );
      final result = double.parse(parser.evaluate());
      expect(result, closeTo(0.7071067811865476, 0.0001));
      print(parser.evaluate());

    });

    test('cos(45°) in degrees mode', () {
      final parser = ExpressionParser(
        expression: 'cos(45)',
        angleMode: AngleMode.degrees,
        precision: 8,
      );
      final result = double.parse(parser.evaluate());
      expect(result, closeTo(0.7071067811865476, 0.0001));
      print(parser.evaluate());

    });

    test('sin(45°) + cos(45°) ≈ 1.414', () {
      final parser = ExpressionParser(
        expression: 'sin(45)+cos(45)',
        angleMode: AngleMode.degrees,
        precision: 8,
      );
      final result = double.parse(parser.evaluate());
      expect(result, closeTo(1.414, 0.001));
      print(parser.evaluate());

    });

    test('tan(45°) = 1', () {
      final parser = ExpressionParser(
        expression: 'tan(45)',
        angleMode: AngleMode.degrees,
        precision: 8,
      );
      final result = double.parse(parser.evaluate());
      expect(result, closeTo(1.0, 0.0001));
      print(parser.evaluate());

    });

    test('ln(e) = 1', () {
      final parser = ExpressionParser(
        expression: 'ln(e)',
        angleMode: AngleMode.degrees,
        precision: 8,
      );
      final result = double.parse(parser.evaluate());
      expect(result, closeTo(1.0, 0.0001));
      print(parser.evaluate());

    });

    test('log(100) = 2', () {
      final parser = ExpressionParser(
        expression: 'log(100)',
        angleMode: AngleMode.degrees,
        precision: 8,
      );
      expect(parser.evaluate(), '2');
      print(parser.evaluate());

    });

    test('sqrt(9) = 3', () {
      final parser = ExpressionParser(
        expression: 'sqrt(9)',
        angleMode: AngleMode.degrees,
        precision: 8,
      );
      expect(parser.evaluate(), '3');
      print(parser.evaluate());

    });

    test('Mixed scientific: 2 × π × √9 ≈ 18.85', () {
      final parser = ExpressionParser(
        expression: '2×π×sqrt(9)',
        angleMode: AngleMode.degrees,
        precision: 8,
      );
      final result = double.parse(parser.evaluate());
      expect(result, closeTo(18.85, 0.01));
      print(parser.evaluate());

    });
  });

  group('Constants Tests', () {
    test('π constant', () {
      final parser = ExpressionParser(
        expression: 'π',
        angleMode: AngleMode.degrees,
        precision: 8,
      );
      final result = double.parse(parser.evaluate());
      expect(result, closeTo(math.pi, 0.0001));
      print(parser.evaluate());

    });

    test('e constant', () {
      final parser = ExpressionParser(
        expression: 'e',
        angleMode: AngleMode.degrees,
        precision: 8,
      );
      final result = double.parse(parser.evaluate());
      expect(result, closeTo(math.e, 0.0001));
      print(parser.evaluate());

    });

    test('2π', () {
      final parser = ExpressionParser(
        expression: '2×π',
        angleMode: AngleMode.degrees,
        precision: 8,
      );
      final result = double.parse(parser.evaluate());
      expect(result, closeTo(2 * math.pi, 0.0001));
      print(parser.evaluate());

    });
  });

  group('Factorial Tests', () {
    test('5! = 120', () {
      final parser = ExpressionParser(
        expression: '5!',
        angleMode: AngleMode.degrees,
        precision: 8,
      );
      expect(parser.evaluate(), '120');
      print(parser.evaluate());

    });

    test('0! = 1', () {
      final parser = ExpressionParser(
        expression: '0!',
        angleMode: AngleMode.degrees,
        precision: 8,
      );
      expect(parser.evaluate(), '1');
      print(parser.evaluate());

    });

    test('10! = 3628800', () {
      final parser = ExpressionParser(
        expression: '10!',
        angleMode: AngleMode.degrees,
        precision: 8,
      );
      expect(parser.evaluate(), '3628800');
      print(parser.evaluate());

    });
  });

  group('Percentage Tests', () {
    test('50% = 0.5', () {
      final parser = ExpressionParser(
        expression: '50%',
        angleMode: AngleMode.degrees,
        precision: 8,
      );
      expect(parser.evaluate(), '0.5');
      print(parser.evaluate());

    });

    test('25% of 200 = 50', () {
      final parser = ExpressionParser(
        expression: '200×25%',
        angleMode: AngleMode.degrees,
        precision: 8,
      );
      expect(parser.evaluate(), '50');
      print(parser.evaluate());

    });
  });

  group('Negative Numbers Tests', () {
    test('Negative number', () {
      final parser = ExpressionParser(
        expression: '-5+3',
        angleMode: AngleMode.degrees,
        precision: 8,
      );
      expect(parser.evaluate(), '-2');
      print(parser.evaluate());

    });

    test('Double negative', () {
      final parser = ExpressionParser(
        expression: '--5',
        angleMode: AngleMode.degrees,
        precision: 8,
      );
      expect(parser.evaluate(), '5');
      print(parser.evaluate());

    });

    test('Negative in parentheses', () {
      final parser = ExpressionParser(
        expression: '(-5)×(-3)',
        angleMode: AngleMode.degrees,
        precision: 8,
      );
      expect(parser.evaluate(), '15');
      print(parser.evaluate());

    });
  });

  group('Decimal Tests', () {
    test('Decimal addition', () {
      final parser = ExpressionParser(
        expression: '0.1+0.2',
        angleMode: AngleMode.degrees,
        precision: 8,
      );
      final result = double.parse(parser.evaluate());
      expect(result, closeTo(0.3, 0.0001));
      print(parser.evaluate());

    });

    test('Decimal multiplication', () {
      final parser = ExpressionParser(
        expression: '2.5×4',
        angleMode: AngleMode.degrees,
        precision: 8,
      );
      expect(parser.evaluate(), '10');
      print(parser.evaluate());

    });
  });

  group('Angle Mode Tests', () {
    test('sin(π/2) in radians = 1', () {
      final parser = ExpressionParser(
        expression: 'sin(π÷2)',
        angleMode: AngleMode.radians,
        precision: 8,
      );
      final result = double.parse(parser.evaluate());
      expect(result, closeTo(1.0, 0.0001));
      print(parser.evaluate());

    });

    test('cos(π) in radians = -1', () {
      final parser = ExpressionParser(
        expression: 'cos(π)',
        angleMode: AngleMode.radians,
        precision: 8,
      );
      final result = double.parse(parser.evaluate());
      expect(result, closeTo(-1.0, 0.0001));
      print(parser.evaluate());

    });
  });

  group('Edge Cases', () {
    test('Empty expression', () {
      final parser = ExpressionParser(
        expression: '',
        angleMode: AngleMode.degrees,
        precision: 8,
      );
      expect(parser.evaluate(), '0');
      print(parser.evaluate());

    });

    test('Large numbers', () {
      final parser = ExpressionParser(
        expression: '999999999+1',
        angleMode: AngleMode.degrees,
        precision: 8,
      );
      expect(parser.evaluate(), '1000000000');
      print(parser.evaluate());

    });

    test('Very small numbers', () {
      final parser = ExpressionParser(
        expression: '0.000001×0.000001',
        angleMode: AngleMode.degrees,
        precision: 12,
      );
      final result = double.parse(parser.evaluate());
      expect(result, closeTo(0.000000000001, 1e-15));
      print(parser.evaluate());

    });
  });
}