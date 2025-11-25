import 'dart:math' as math;
import '../models/calculator_mode.dart';

class CalculatorLogic {
  final AngleMode angleMode;
  final int decimalPrecision;

  CalculatorLogic({
    this.angleMode = AngleMode.degrees,
    this.decimalPrecision = 6,
  });

  double _toRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  double _formatResult(double value) {
    return double.parse(value.toStringAsFixed(decimalPrecision));
  }

  double sin(double value) {
    final angle = angleMode == AngleMode.degrees ? _toRadians(value) : value;
    return _formatResult(math.sin(angle));
  }

  double cos(double value) {
    final angle = angleMode == AngleMode.degrees ? _toRadians(value) : value;
    return _formatResult(math.cos(angle));
  }

  double tan(double value) {
    final angle = angleMode == AngleMode.degrees ? _toRadians(value) : value;
    return _formatResult(math.tan(angle));
  }

  double ln(double value) {
    if (value <= 0) throw Exception('Invalid input for ln');
    return _formatResult(math.log(value));
  }

  double log10(double value) {
    if (value <= 0) throw Exception('Invalid input for log');
    return _formatResult(math.log(value) / math.ln10);
  }

  double sqrt(double value) {
    if (value < 0) throw Exception('Cannot calculate square root of negative');
    return _formatResult(math.sqrt(value));
  }

  double square(double value) {
    return _formatResult(value * value);
  }

  double power(double base, double exponent) {
    return _formatResult(math.pow(base, exponent).toDouble());
  }

  int factorial(int n) {
    if (n < 0) throw Exception('Factorial not defined for negative numbers');
    if (n == 0 || n == 1) return 1;
    int result = 1;
    for (int i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
  }
}