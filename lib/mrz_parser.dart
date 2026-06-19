class MrzParser {
  /// Parses MRZ text and returns a map with documentNumber, dateOfBirth, and dateOfExpiry.
  /// Returns null if parsing fails or checksums are invalid.
  static Map<String, String>? parse(String mrzText) {
    final cleanMrz = mrzText.replaceAll(RegExp(r'\s+'), '');
    
    if (cleanMrz.length < 88) { // TD1 size is 90, TD3 size is 88 (44x2)
      return null;
    }
    
    return _parseTD3(cleanMrz);
  }

  static Map<String, String>? _parseTD3(String mrz) {
    // Break down the regex for better readability. 
    // We allow 'O' in place of '0' to handle common OCR mistakes in number fields.
    const docNumPattern      = r'([A-Z0-9<]{9})';
    const checkDigitPattern  = r'([0-9O])';
    const nationalityPattern = r'([A-Z<]{3})';
    const datePattern        = r'([0-9O]{6})';
    const sexPattern         = r'[MF<]';
    
    final regexStr = 
        '$docNumPattern'
        '$checkDigitPattern'
        '$nationalityPattern'
        '$datePattern'
        '$checkDigitPattern'
        '$sexPattern'
        '$datePattern'
        '$checkDigitPattern';
        
    final match = RegExp(regexStr).firstMatch(mrz);
    if (match == null) return null;

    final rawDocNum   = match.group(1)!;
    final docNumCheck = _sanitizeNumber(match.group(2)!);
    final dob         = _sanitizeNumber(match.group(4)!);
    final dobCheck    = _sanitizeNumber(match.group(5)!);
    final doe         = _sanitizeNumber(match.group(6)!);
    final doeCheck    = _sanitizeNumber(match.group(7)!);

    final validDocNum = _getValidDocNum(rawDocNum, docNumCheck);
    
    if (validDocNum != null &&
        _validateChecksum(dob, dobCheck) &&
        _validateChecksum(doe, doeCheck)) {
      return {
        'documentNumber': validDocNum.replaceAll('<', ''),
        'dateOfBirth': dob,
        'dateOfExpiry': doe,
      };
    }
    
    return null;
  }
  
  /// Helper to fix common OCR number mistakes (e.g. 'O' instead of '0')
  static String _sanitizeNumber(String input) {
    return input.replaceAll('O', '0');
  }

  /// Document number might genuinely contain letters, but OCR often mistakes '0' for 'O'.
  /// Try raw first, fallback to sanitized if checksum fails.
  static String? _getValidDocNum(String docNum, String checkDigit) {
    if (_validateChecksum(docNum, checkDigit)) {
      return docNum;
    }
    
    final sanitizedDocNum = _sanitizeNumber(docNum);
    if (_validateChecksum(sanitizedDocNum, checkDigit)) {
      return sanitizedDocNum;
    }
    
    return null;
  }
  
  static bool _validateChecksum(String data, String checkDigitChar) {
    if (checkDigitChar == '<') return false;
    int checkDigit = int.parse(checkDigitChar);
    
    final weights = [7, 3, 1];
    int sum = 0;
    
    for (int i = 0; i < data.length; i++) {
      int charValue;
      final char = data[i];
      
      if (char == '<') {
        charValue = 0;
      } else if (RegExp(r'[0-9]').hasMatch(char)) {
        charValue = int.parse(char);
      } else {
        charValue = char.codeUnitAt(0) - 55; // A=10, B=11 ... Z=35
      }
      
      sum += charValue * weights[i % 3];
    }
    
    return (sum % 10) == checkDigit;
  }
}
