enum CalculatorMode {
  basic,
  scientific,
  programmer,
}

enum AngleMode {
  degrees,
  radians,
}

extension CalculatorModeExtension on CalculatorMode {
  String get displayName {
    switch (this) {
      case CalculatorMode.basic:
        return 'Basic';
      case CalculatorMode.scientific:
        return 'Scientific';
      case CalculatorMode.programmer:
        return 'Programmer';
    }
  }
}

extension AngleModeExtension on AngleMode {
  String get displayName {
    switch (this) {
      case AngleMode.degrees:
        return 'DEG';
      case AngleMode.radians:
        return 'RAD';
    }
  }
}