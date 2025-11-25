import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calculator_provider.dart';
import '../providers/history_provider.dart';
import '../widgets/display_area.dart';
import '../widgets/button_grid.dart';
import '../widgets/mode_selector.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Calculator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HistoryScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Mode selector
            const ModeSelector(),
            
            // Display area - flex 2
            const Expanded(
              flex: 3,
              child: DisplayArea(),
            ),
            
            // Button grid - flex 5
            Expanded(
              flex: 4,
              child: Consumer2<CalculatorProvider, HistoryProvider>(
                builder: (context, calcProvider, historyProvider, _) {
                  return ButtonGrid(
                    mode: calcProvider.mode,
                    onInput: calcProvider.input,
                    onOperator: calcProvider.inputOperator,
                    onCalculate: () => calcProvider.calculate(historyProvider),
                    onClear: calcProvider.clear,
                    onClearEntry: calcProvider.clearEntry,
                    onBackspace: calcProvider.backspace,
                    onPercent: calcProvider.percent,
                    onNegate: calcProvider.negate,
                    onScientific: calcProvider.scientificFunction,
                    onMemoryAdd: calcProvider.memoryAdd,
                    onMemorySubtract: calcProvider.memorySubtract,
                    onMemoryRecall: calcProvider.memoryRecall,
                    onMemoryClear: calcProvider.memoryClear,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}