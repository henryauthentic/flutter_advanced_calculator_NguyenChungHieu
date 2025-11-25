import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/calculator_provider.dart';
import '../providers/history_provider.dart';
import '../models/calculator_settings.dart';
import '../models/calculator_mode.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<CalculatorProvider>(
        builder: (context, calcProvider, _) {
          final settings = calcProvider.settings;
          
          return ListView(
            children: [
              _buildSection('Appearance'),
              _buildThemeSelector(context),
              
              const Divider(),
              
              _buildSection('Calculator'),
              _buildDecimalPrecisionSelector(context, settings, calcProvider),
              _buildAngleModeSelector(context, settings, calcProvider),
              
              const Divider(),
              
              _buildSection('Feedback'),
              _buildSwitchTile(
                'Haptic Feedback',
                settings.hapticFeedback,
                (value) {
                  final newSettings = CalculatorSettings(
                    theme: settings.theme,
                    decimalPrecision: settings.decimalPrecision,
                    angleMode: settings.angleMode,
                    hapticFeedback: value,
                    soundEffects: settings.soundEffects,
                    historySize: settings.historySize,
                  );
                  calcProvider.updateSettings(newSettings);
                  StorageService.saveSettings(newSettings);
                },
              ),
              _buildSwitchTile(
                'Sound Effects',
                settings.soundEffects,
                (value) {
                  final newSettings = CalculatorSettings(
                    theme: settings.theme,
                    decimalPrecision: settings.decimalPrecision,
                    angleMode: settings.angleMode,
                    hapticFeedback: settings.hapticFeedback,
                    soundEffects: value,
                    historySize: settings.historySize,
                  );
                  calcProvider.updateSettings(newSettings);
                  StorageService.saveSettings(newSettings);
                },
              ),
              
              const Divider(),
              
              _buildSection('History'),
              _buildHistorySizeSelector(context, settings, calcProvider),
              _buildClearHistoryButton(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, provider, _) {
        return ListTile(
          title: const Text('Theme'),
          subtitle: Text(_getThemeDisplayName(provider.themeMode)),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Select Theme'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildThemeOption(context, 'Light', 'light', provider),
                    _buildThemeOption(context, 'Dark', 'dark', provider),
                    _buildThemeOption(context, 'System', 'system', provider),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String label,
    String value,
    ThemeProvider provider,
  ) {
    return RadioListTile<String>(
      title: Text(label),
      value: value,
      groupValue: provider.themeMode,
      onChanged: (newValue) {
        if (newValue != null) {
          provider.setTheme(newValue);
          Navigator.pop(context);
        }
      },
    );
  }

  String _getThemeDisplayName(String theme) {
    switch (theme) {
      case 'light':
        return 'Light';
      case 'dark':
        return 'Dark';
      default:
        return 'System';
    }
  }

  Widget _buildDecimalPrecisionSelector(
    BuildContext context,
    CalculatorSettings settings,
    CalculatorProvider provider,
  ) {
    return ListTile(
      title: const Text('Decimal Precision'),
      subtitle: Text('${settings.decimalPrecision} decimal places'),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Decimal Precision'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(9, (index) {
                final precision = index + 2;
                return RadioListTile<int>(
                  title: Text('$precision decimal places'),
                  value: precision,
                  groupValue: settings.decimalPrecision,
                  onChanged: (value) {
                    if (value != null) {
                      final newSettings = CalculatorSettings(
                        theme: settings.theme,
                        decimalPrecision: value,
                        angleMode: settings.angleMode,
                        hapticFeedback: settings.hapticFeedback,
                        soundEffects: settings.soundEffects,
                        historySize: settings.historySize,
                      );
                      provider.updateSettings(newSettings);
                      StorageService.saveSettings(newSettings);
                      Navigator.pop(context);
                    }
                  },
                );
              }),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAngleModeSelector(
    BuildContext context,
    CalculatorSettings settings,
    CalculatorProvider provider,
  ) {
    return ListTile(
      title: const Text('Angle Mode'),
      subtitle: Text(settings.angleMode.displayName),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Angle Mode'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<AngleMode>(
                  title: const Text('Degrees (DEG)'),
                  value: AngleMode.degrees,
                  groupValue: settings.angleMode,
                  onChanged: (value) {
                    if (value != null) {
                      final newSettings = CalculatorSettings(
                        theme: settings.theme,
                        decimalPrecision: settings.decimalPrecision,
                        angleMode: value,
                        hapticFeedback: settings.hapticFeedback,
                        soundEffects: settings.soundEffects,
                        historySize: settings.historySize,
                      );
                      provider.updateSettings(newSettings);
                      StorageService.saveSettings(newSettings);
                      Navigator.pop(context);
                    }
                  },
                ),
                RadioListTile<AngleMode>(
                  title: const Text('Radians (RAD)'),
                  value: AngleMode.radians,
                  groupValue: settings.angleMode,
                  onChanged: (value) {
                    if (value != null) {
                      final newSettings = CalculatorSettings(
                        theme: settings.theme,
                        decimalPrecision: settings.decimalPrecision,
                        angleMode: value,
                        hapticFeedback: settings.hapticFeedback,
                        soundEffects: settings.soundEffects,
                        historySize: settings.historySize,
                      );
                      provider.updateSettings(newSettings);
                      StorageService.saveSettings(newSettings);
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistorySizeSelector(
    BuildContext context,
    CalculatorSettings settings,
    CalculatorProvider provider,
  ) {
    return ListTile(
      title: const Text('History Size'),
      subtitle: Text('${settings.historySize} calculations'),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('History Size'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [25, 50, 100].map((size) {
                return RadioListTile<int>(
                  title: Text('$size calculations'),
                  value: size,
                  groupValue: settings.historySize,
                  onChanged: (value) {
                    if (value != null) {
                      final newSettings = CalculatorSettings(
                        theme: settings.theme,
                        decimalPrecision: settings.decimalPrecision,
                        angleMode: settings.angleMode,
                        hapticFeedback: settings.hapticFeedback,
                        soundEffects: settings.soundEffects,
                        historySize: value,
                      );
                      provider.updateSettings(newSettings);
                      StorageService.saveSettings(newSettings);
                      Provider.of<HistoryProvider>(context, listen: false)
                          .setMaxHistorySize(value);
                      Navigator.pop(context);
                    }
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSwitchTile(
    String title,
    bool value,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildClearHistoryButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Clear All History'),
              content: const Text(
                'Are you sure you want to clear all calculation history? '
                'This action cannot be undone.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Provider.of<HistoryProvider>(context, listen: false)
                        .clearHistory();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('History cleared'),
                      ),
                    );
                  },
                  child: const Text('Clear'),
                ),
              ],
            ),
          );
        },
        child: const Text('Clear All History'),
      ),
    );
  }
}