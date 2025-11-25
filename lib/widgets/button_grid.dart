import 'package:flutter/material.dart';
import '../models/calculator_mode.dart';
import 'calculator_button.dart';

class ButtonGrid extends StatelessWidget {
  final CalculatorMode mode;
  final Function(String) onInput;
  final Function(String) onOperator;
  final VoidCallback onCalculate;
  final VoidCallback onClear;
  final VoidCallback onClearEntry;
  final VoidCallback onBackspace;
  final VoidCallback onPercent;
  final VoidCallback onNegate;
  final Function(String) onScientific;
  final VoidCallback onMemoryAdd;
  final VoidCallback onMemorySubtract;
  final VoidCallback onMemoryRecall;
  final VoidCallback onMemoryClear;

  const ButtonGrid({
    Key? key,
    required this.mode,
    required this.onInput,
    required this.onOperator,
    required this.onCalculate,
    required this.onClear,
    required this.onClearEntry,
    required this.onBackspace,
    required this.onPercent,
    required this.onNegate,
    required this.onScientific,
    required this.onMemoryAdd,
    required this.onMemorySubtract,
    required this.onMemoryRecall,
    required this.onMemoryClear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case CalculatorMode.basic:
        return _buildBasicGrid(context);
      case CalculatorMode.scientific:
        return _buildScientificGrid(context);
      case CalculatorMode.programmer:
        return _buildProgrammerGrid(context);
    }
  }

  Widget _buildBasicGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                _buildButton(context, 'C', onClear, type: ButtonType.function),
                _buildButton(context, 'CE', onClearEntry, type: ButtonType.function),
                _buildButton(context, '%', onPercent, type: ButtonType.function),
                _buildButton(context, '÷', () => onOperator('÷'), type: ButtonType.operator),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                _buildButton(context, '7', () => onInput('7')),
                _buildButton(context, '8', () => onInput('8')),
                _buildButton(context, '9', () => onInput('9')),
                _buildButton(context, '×', () => onOperator('×'), type: ButtonType.operator),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                _buildButton(context, '4', () => onInput('4')),
                _buildButton(context, '5', () => onInput('5')),
                _buildButton(context, '6', () => onInput('6')),
                _buildButton(context, '-', () => onOperator('-'), type: ButtonType.operator),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                _buildButton(context, '1', () => onInput('1')),
                _buildButton(context, '2', () => onInput('2')),
                _buildButton(context, '3', () => onInput('3')),
                _buildButton(context, '+', () => onOperator('+'), type: ButtonType.operator),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                _buildButton(context, '±', onNegate, type: ButtonType.function),
                _buildButton(context, '0', () => onInput('0')),
                _buildButton(context, '.', () => onInput('.')),
                _buildButton(context, '=', onCalculate, type: ButtonType.equals),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScientificGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          // Row 1: Scientific functions
          Expanded(
            child: Row(
              children: [
                _buildButton(context, 'sin', () => onScientific('sin'), type: ButtonType.function),
                _buildButton(context, 'cos', () => onScientific('cos'), type: ButtonType.function),
                _buildButton(context, 'tan', () => onScientific('tan'), type: ButtonType.function),
                _buildButton(context, 'ln', () => onScientific('ln'), type: ButtonType.function),
                _buildButton(context, 'log', () => onScientific('log'), type: ButtonType.function),
              ],
            ),
          ),
          // Row 2: Power and parentheses
          Expanded(
            child: Row(
              children: [
                _buildButton(context, 'x²', () => onScientific('square'), type: ButtonType.function),
                _buildButton(context, '√', () => onScientific('sqrt'), type: ButtonType.function),
                _buildButton(context, 'x^y', () => onOperator('^'), type: ButtonType.operator),
                _buildButton(context, '(', () => onInput('(')),
                _buildButton(context, ')', () => onInput(')')),
              ],
            ),
          ),
          // Row 3: MC, 7, 8, 9, ÷
          Expanded(
            child: Row(
              children: [
                _buildButton(context, 'MC', onMemoryClear, type: ButtonType.function),
                _buildButton(context, '7', () => onInput('7')),
                _buildButton(context, '8', () => onInput('8')),
                _buildButton(context, '9', () => onInput('9')),
                _buildButton(context, '÷', () => onOperator('÷'), type: ButtonType.operator),
              ],
            ),
          ),
          // Row 4: MR, 4, 5, 6, ×
          Expanded(
            child: Row(
              children: [
                _buildButton(context, 'MR', onMemoryRecall, type: ButtonType.function),
                _buildButton(context, '4', () => onInput('4')),
                _buildButton(context, '5', () => onInput('5')),
                _buildButton(context, '6', () => onInput('6')),
                _buildButton(context, '×', () => onOperator('×'), type: ButtonType.operator),
              ],
            ),
          ),
          // Row 5: M+, 1, 2, 3, -
          Expanded(
            child: Row(
              children: [
                _buildButton(context, 'M+', onMemoryAdd, type: ButtonType.function),
                _buildButton(context, '1', () => onInput('1')),
                _buildButton(context, '2', () => onInput('2')),
                _buildButton(context, '3', () => onInput('3')),
                _buildButton(context, '-', () => onOperator('-'), type: ButtonType.operator),
              ],
            ),
          ),
          // Row 6: M-, 0, ., π, +
          Expanded(
            child: Row(
              children: [
                _buildButton(context, 'M-', onMemorySubtract, type: ButtonType.function),
                _buildButton(context, '0', () => onInput('0')),
                _buildButton(context, '.', () => onInput('.')),
                _buildButton(context, 'π', () => onInput('3.14159'), type: ButtonType.function),
                _buildButton(context, '+', () => onOperator('+'), type: ButtonType.operator),
              ],
            ),
          ),
          // Row 7: C, CE, %, =
          Expanded(
            child: Row(
              children: [
                _buildButton(context, 'C', onClear, type: ButtonType.function),
                _buildButton(context, 'CE', onClearEntry, type: ButtonType.function),
                _buildButton(context, '%', onPercent, type: ButtonType.function),
                _buildButton(context, '±', onNegate, type: ButtonType.function),
                _buildButton(context, '=', onCalculate, type: ButtonType.equals),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgrammerGrid(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(8),
    child: Column(
      children: [
        // Row 1: Number system buttons
        Expanded(
          child: Row(
            children: [
              _buildButton(context, 'BIN', () {}, type: ButtonType.function),
              _buildButton(context, 'OCT', () {}, type: ButtonType.function),
              _buildButton(context, 'DEC', () {}, type: ButtonType.function),
              _buildButton(context, 'HEX', () {}, type: ButtonType.function),
            ],
          ),
        ),
        // Row 2: Bitwise operators
        Expanded(
          child: Row(
            children: [
              _buildButton(context, 'AND', () => onOperator('AND'), type: ButtonType.operator),
              _buildButton(context, 'OR', () => onOperator('OR'), type: ButtonType.operator),
              _buildButton(context, 'XOR', () => onOperator('XOR'), type: ButtonType.operator),
              _buildButton(context, 'NOT', () => onOperator('NOT'), type: ButtonType.function),
            ],
          ),
        ),
        // Row 3: Shift operators and C
        Expanded(
          child: Row(
            children: [
              _buildButton(context, '<<', () => onOperator('<<'), type: ButtonType.operator),
              _buildButton(context, '>>', () => onOperator('>>'), type: ButtonType.operator),
              _buildButton(context, 'C', onClear, type: ButtonType.function),
              _buildButton(context, '÷', () => onOperator('÷'), type: ButtonType.operator),
            ],
          ),
        ),
        // Row 4: 7, 8, 9, ×
        Expanded(
          child: Row(
            children: [
              _buildButton(context, '7', () => onInput('7')),
              _buildButton(context, '8', () => onInput('8')),
              _buildButton(context, '9', () => onInput('9')),
              _buildButton(context, '×', () => onOperator('×'), type: ButtonType.operator),
            ],
          ),
        ),
        // Row 5: 4, 5, 6, -
        Expanded(
          child: Row(
            children: [
              _buildButton(context, '4', () => onInput('4')),
              _buildButton(context, '5', () => onInput('5')),
              _buildButton(context, '6', () => onInput('6')),
              _buildButton(context, '-', () => onOperator('-'), type: ButtonType.operator),
            ],
          ),
        ),
        // Row 6: 1, 2, 3, +
        Expanded(
          child: Row(
            children: [
              _buildButton(context, '1', () => onInput('1')),
              _buildButton(context, '2', () => onInput('2')),
              _buildButton(context, '3', () => onInput('3')),
              _buildButton(context, '+', () => onOperator('+'), type: ButtonType.operator),
            ],
          ),
        ),
        // Row 7: 0, A, F, ., =
        Expanded(
          child: Row(
            children: [
              _buildButton(context, '0', () => onInput('0')),
              _buildButton(context, 'A', () => onInput('A')),
              _buildButton(context, 'F', () => onInput('F')),
              _buildButton(context, '.', () => onInput('.')),
              _buildButton(context, '=', onCalculate, type: ButtonType.equals),
            ],
          ),
        ),
      ],
    ),
  );
}

  Widget _buildButton(
    BuildContext context,
    String label,
    VoidCallback onPressed, {
    ButtonType type = ButtonType.number,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: CalculatorButton(
          label: label,
          onPressed: onPressed,
          type: type,
        ),
      ),
    );
  }
}