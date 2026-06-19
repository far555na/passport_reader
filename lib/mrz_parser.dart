class MrzParser {
  /// Parses MRZ text and returns a map with documentNumber, dateOfBirth, and dateOfExpiry.
  /// Returns null if parsing fails or checksums are invalid.
  static Map<String, String>? parse(String mrzText) {
    // Remove all spaces and newlines
    final cleanMrz = mrzText.replaceAll(RegExp(r'\s+'), '');
    
    if (cleanMrz.length < 88) { // TD1 size is 90, TD3 size is 88 (44x2)
      return null;
    }
    
    // Simple extraction for TD3 format (Passport) as an example
    // Line 1: 44 chars (Type, Country, Name)
    // Line 2: 44 chars (DocNum, Nationality, DOB, Sex, DOE, PersonalNum)
    
    // Find the start of the second line which contains the data we need
    // It typically starts with the passport number
    
    // A robust MRZ parser needs to handle different formats (TD1, TD2, TD3).
    // For this example, we assume TD3 where the second line contains:
    // DocNum (9 chars) + Checksum (1) + Nationality (3) + DOB (6) + Checksum (1) + Sex (1) + DOE (6) + Checksum (1)
    
    // Allow 'O' in place of '0' to handle common OCR mistakes in number fields
    final RegExp td3Line2Regex = RegExp(r'([A-Z0-9<]{9})([0-9O])([A-Z<]{3})([0-9O]{6})([0-9O])[MF<]([0-9O]{6})([0-9O])');
    
    final match = td3Line2Regex.firstMatch(cleanMrz);
    
    if (match != null) {
      // Helper to fix common OCR number mistakes
      String sanitizeNumber(String input) => input.replaceAll('O', '0');
      
      String rawDocNum = match.group(1)!;
      String docNumCheck = sanitizeNumber(match.group(2)!);
      String dob = sanitizeNumber(match.group(4)!);
      String dobCheck = sanitizeNumber(match.group(5)!);
      String doe = sanitizeNumber(match.group(6)!);
      String doeCheck = sanitizeNumber(match.group(7)!);
      
      // Document number might genuinely contain letters, but OCR often mistakes '0' for 'O'.
      // Try raw first, fallback to sanitized if checksum fails.
      bool docNumValid = _validateChecksum(rawDocNum, docNumCheck);
      String finalDocNum = rawDocNum;
      
      if (!docNumValid) {
        final sanitizedDocNum = sanitizeNumber(rawDocNum);
        if (_validateChecksum(sanitizedDocNum, docNumCheck)) {
          docNumValid = true;
          finalDocNum = sanitizedDocNum;
        }
      }
      
      if (docNumValid &&
          _validateChecksum(dob, dobCheck) &&
          _validateChecksum(doe, doeCheck)) {
        return {
          'documentNumber': finalDocNum.replaceAll('<', ''),
          'dateOfBirth': dob,
          'dateOfExpiry': doe,
        };
      }
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
