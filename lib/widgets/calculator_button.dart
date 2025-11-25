import 'package:flutter/material.dart';

enum ButtonType {
  number,
  operator,
  function,
  equals,
}

class CalculatorButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final ButtonType type;

  const CalculatorButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.type = ButtonType.number,
  }) : super(key: key);

  @override
  State<CalculatorButton> createState() => _CalculatorButtonState();
}

class _CalculatorButtonState extends State<CalculatorButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getButtonColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    switch (widget.type) {
      case ButtonType.operator:
        return isDark ? const Color(0xFF4ECDC4) : const Color(0xFFFF6B6B);
      case ButtonType.function:
        return isDark ? const Color(0xFF2C2C2C) : const Color(0xFF424242);
      case ButtonType.equals:
        return isDark ? const Color(0xFF4ECDC4) : const Color(0xFFFF6B6B);
      case ButtonType.number:
        return isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5);
    }
  }

  Color _getTextColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    switch (widget.type) {
      case ButtonType.operator:
      case ButtonType.equals:
        return Colors.white;
      case ButtonType.function:
        return isDark ? Colors.white : Colors.white;
      case ButtonType.number:
        return isDark ? Colors.white : Colors.black87;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Material(
        color: _getButtonColor(context),
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        child: InkWell(
          onTap: () {
            _controller.forward().then((_) => _controller.reverse());
            widget.onPressed();
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: widget.label.length > 3 ? 14 : 20,
                fontWeight: FontWeight.w500,
                color: _getTextColor(context),
                fontFamily: 'Roboto',
              ),
            ),
          ),
        ),
      ),
    );
  }
}