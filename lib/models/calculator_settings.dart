import 'calculator_mode.dart';

class CalculatorSettings {
  String theme;
  int decimalPrecision;
  AngleMode angleMode;
  bool hapticFeedback;
  bool soundEffects;
  int historySize;

  CalculatorSettings({
    this.theme = 'system',
    this.decimalPrecision = 6,
    this.angleMode = AngleMode.degrees,
    this.hapticFeedback = true,
    this.soundEffects = false,
    this.historySize = 50,
  });

  Map<String, dynamic> toJson() {
    return {
      'theme': theme,
      'decimalPrecision': decimalPrecision,
      'angleMode': angleMode.index,
      'hapticFeedback': hapticFeedback,
      'soundEffects': soundEffects,
      'historySize': historySize,
    };
  }

  factory CalculatorSettings.fromJson(Map<String, dynamic> json) {
    return CalculatorSettings(
      theme: json['theme'] ?? 'system',
      decimalPrecision: json['decimalPrecision'] ?? 6,
      angleMode: AngleMode.values[json['angleMode'] ?? 0],
      hapticFeedback: json['hapticFeedback'] ?? true,
      soundEffects: json['soundEffects'] ?? false,
      historySize: json['historySize'] ?? 50,
    );
  }
}