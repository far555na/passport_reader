// lib/services/mrz_validator.dart

/// Validates Machine Readable Zone (MRZ) formats and check digits.
///
/// Implements the ICAO 9303 check digit 7-3-1 algorithm.
class MrzValidator {
  /// Validates an ICAO 9303 check digit using the 7-3-1 weighted algorithm.
  /// Uses raw code units for maximum performance.
  static bool validateChecksum(String data, String checkDigitChar) {
    if (checkDigitChar.isEmpty) return false;
    final checkCode = checkDigitChar.codeUnitAt(0);
    if (checkCode == 60) return false; // '<'

    int expectedCheckDigit;
    if (checkCode >= 48 && checkCode <= 57) { // '0' - '9'
      expectedCheckDigit = checkCode - 48;
    } else {
      return false; // Check digit itself must be a number
    }

    const weights = [7, 3, 1];
    int sum = 0;

    for (int i = 0; i < data.length; i++) {
      int charValue;
      final code = data.codeUnitAt(i);

      if (code == 60) {
        // '<'
        charValue = 0;
      } else if (code >= 48 && code <= 57) {
        // '0'-'9'
        charValue = code - 48;
      } else if (code >= 65 && code <= 90) {
        // 'A'-'Z'
        charValue = code - 55;
      } else {
        // Invalid character for checksum calculation
        charValue = 0;
      }

      sum += charValue * weights[i % 3];
    }

    return (sum % 10) == expectedCheckDigit;
  }

  /// Replaces common OCR number misreads (e.g. 'O' -> '0').
  static String sanitizeNumber(String input) {
    return input.replaceAll('O', '0');
  }

  /// Tries raw value first, then sanitized. Returns valid value or null.
  static String? getValidValue(String rawValue, String checkDigit) {
    if (validateChecksum(rawValue, checkDigit)) {
      return rawValue;
    }
    final sanitized = sanitizeNumber(rawValue);
    if (validateChecksum(sanitized, checkDigit)) {
      return sanitized;
    }
    return null;
  }
}
