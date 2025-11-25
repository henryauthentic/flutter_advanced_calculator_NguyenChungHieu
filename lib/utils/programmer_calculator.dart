class ProgrammerCalculator {
  static int evaluateProgrammerExpression(String expression) {
    try {
      expression = expression.trim().toUpperCase();
      
      // Check if contains bitwise operators
      bool hasBitwiseOps = expression.contains(' AND ') || 
                           expression.contains(' OR ') || 
                           expression.contains(' XOR ') || 
                           expression.contains('NOT ') ||
                           expression.contains(' << ') || 
                           expression.contains(' >> ');
      
      if (!hasBitwiseOps) {
        // No bitwise operators, might be arithmetic - throw error to let ExpressionParser handle it
        throw Exception('Not a bitwise expression');
      }
      
      // Convert hex numbers to decimal
      expression = _convertHexToDecimal(expression);
      
      // Parse with proper precedence
      return _parseOr(expression);
    } catch (e) {
      throw Exception('Invalid expression: $e');
    }
  }

  static String _convertHexToDecimal(String expr) {
    // Protect operators by replacing them temporarily
    expr = expr.replaceAll(' AND ', ' #AND# ');
    expr = expr.replaceAll(' OR ', ' #OR# ');
    expr = expr.replaceAll(' XOR ', ' #XOR# ');
    expr = expr.replaceAll('NOT ', '#NOT# ');
    expr = expr.replaceAll(' << ', ' #SHL# ');
    expr = expr.replaceAll(' >> ', ' #SHR# ');
    
    // Convert hex numbers (sequences of hex digits)
    expr = expr.replaceAllMapped(RegExp(r'\b([0-9A-F]+)\b'), (match) {
      String hexStr = match.group(1)!;
      
      // Check if it contains at least one A-F
      if (RegExp(r'[A-F]').hasMatch(hexStr)) {
        try {
          int decimal = int.parse(hexStr, radix: 16);
          return decimal.toString();
        } catch (e) {
          return hexStr;
        }
      }
      
      return hexStr;
    });
    
    // Restore operators
    expr = expr.replaceAll('#AND#', 'AND');
    expr = expr.replaceAll('#OR#', 'OR');
    expr = expr.replaceAll('#XOR#', 'XOR');
    expr = expr.replaceAll('#NOT#', 'NOT');
    expr = expr.replaceAll('#SHL#', '<<');
    expr = expr.replaceAll('#SHR#', '>>');
    
    return expr;
  }

  // OR has lowest precedence
  static int _parseOr(String expr) {
    if (!expr.contains(' OR ')) {
      return _parseXor(expr);
    }
    
    List<String> parts = expr.split(' OR ');
    int result = _parseXor(parts[0].trim());
    
    for (int i = 1; i < parts.length; i++) {
      result = result | _parseXor(parts[i].trim());
    }
    
    return result;
  }

  // XOR
  static int _parseXor(String expr) {
    if (!expr.contains(' XOR ')) {
      return _parseAnd(expr);
    }
    
    List<String> parts = expr.split(' XOR ');
    int result = _parseAnd(parts[0].trim());
    
    for (int i = 1; i < parts.length; i++) {
      result = result ^ _parseAnd(parts[i].trim());
    }
    
    return result;
  }

  // AND
  static int _parseAnd(String expr) {
    if (!expr.contains(' AND ')) {
      return _parseShift(expr);
    }
    
    List<String> parts = expr.split(' AND ');
    int result = _parseShift(parts[0].trim());
    
    for (int i = 1; i < parts.length; i++) {
      result = result & _parseShift(parts[i].trim());
    }
    
    return result;
  }

  // Shift operations
  static int _parseShift(String expr) {
    if (expr.contains(' << ')) {
      List<String> parts = expr.split(' << ');
      return _parseUnary(parts[0].trim()) << _parseUnary(parts[1].trim());
    }
    
    if (expr.contains(' >> ')) {
      List<String> parts = expr.split(' >> ');
      return _parseUnary(parts[0].trim()) >> _parseUnary(parts[1].trim());
    }
    
    return _parseUnary(expr);
  }

  // Unary operations (NOT)
  static int _parseUnary(String expr) {
    expr = expr.trim();
    
    if (expr.startsWith('NOT ')) {
      String operand = expr.substring(4).trim();
      return ~_parseNumber(operand);
    }
    
    return _parseNumber(expr);
  }

  // Parse number
  static int _parseNumber(String expr) {
    expr = expr.trim();
    
    try {
      return int.parse(expr);
    } catch (e) {
      throw Exception('Invalid number: $expr');
    }
  }

  // Helper conversion functions
  static String decimalToHex(int decimal) {
    return decimal.toRadixString(16).toUpperCase();
  }

  static String decimalToBinary(int decimal) {
    return decimal.toRadixString(2);
  }

  static String decimalToOctal(int decimal) {
    return decimal.toRadixString(8);
  }

  static int hexToDecimal(String hex) {
    return int.parse(hex, radix: 16);
  }

  static int binaryToDecimal(String binary) {
    return int.parse(binary, radix: 2);
  }

  static int octalToDecimal(String octal) {
    return int.parse(octal, radix: 8);
  }
}