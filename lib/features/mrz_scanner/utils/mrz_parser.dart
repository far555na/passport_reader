import '../models/mrz_result.dart';

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

class MrzParser {
  static final _line2Pattern = RegExp(
    r'[A-Z0-9<]{9}' // Document number
    r'[0-9A-Z<]' // Check digit
    r'[A-Z<]{3}' // Nationality
    r'[0-9A-Z<]{6}' // DOB
    r'[0-9A-Z<]' // Check digit
    r'[MF<]' // Sex
    r'[0-9A-Z<]{6}' // DOE
    r'[0-9A-Z<]' // Check digit
    r'[A-Z0-9<]{14}' // Optional data
    r'[0-9A-Z<]{2}', // Check digits
  );
  static final _pMatchesPattern = RegExp(r'P[A-Z<]');
  static final _fillerPattern = RegExp(r'<+$');

  static MrzResult? parse(String ocrText) {
    final collapsedText = _collapseMrzText(ocrText);

    // Only support TD3 (passports)
    return _tryTD3(collapsedText);
  }

  static String _collapseMrzText(String ocrText) {
    final buffer = StringBuffer();
    final upperText = ocrText.toUpperCase();

    for (int i = 0; i < upperText.length; i++) {
      final code = upperText.codeUnitAt(i);

      // Ignore space, \n, \r
      if (code == 32 || code == 10 || code == 13) continue;

      if (code == 124 || code == 171) {
        // '|' or '«' -> '<'
        buffer.writeCharCode(60);
      } else if ((code >= 48 && code <= 57) || // '0'-'9'
          (code >= 65 && code <= 90) || // 'A'-'Z'
          (code == 60)) {
        // '<'
        buffer.writeCharCode(code);
      }
    }

    return buffer.toString();
  }

  // TD3: Passport — 2 lines × 44 characters
  static MrzResult? _tryTD3(String collapsedText) {
    final line2Matches = _line2Pattern.allMatches(collapsedText);
    if (line2Matches.isEmpty) return null;

    final pMatches = _pMatchesPattern.allMatches(collapsedText);

    MrzResult? bestResult;
    int maxFillers = -1;

    for (final l2Match in line2Matches) {
      final line2 = l2Match.group(0)!;

      for (final pMatch in pMatches) {
        if (pMatch.start == l2Match.start) continue;

        int endPos = pMatch.start + 44;
        if (endPos > collapsedText.length) {
          endPos = collapsedText.length;
        }

        if (pMatch.start < l2Match.start && endPos > l2Match.start) {
          endPos = l2Match.start;
        }

        var line1 = collapsedText.substring(pMatch.start, endPos);

        if (!line1.contains('<')) continue;

        // CRITICAL FIX: Score by the UNPADDED filler count!
        int score = line1.split('<').length - 1;

        // Massively prioritize lines that start with 'P<'
        // (99.9% of all passports use 'P<'). This instantly defeats false
        // positives where OCR found a 'P' in words like "Expiry" or "Passport"
        if (line1.startsWith('P<')) {
          score += 100;
        }

        if (line1.length < 44) {
          line1 = line1.padRight(44, '<');
        }

        final result = _parseTD3(line1, line2);
        if (result != null) {
          if (score > maxFillers) {
            maxFillers = score;
            bestResult = result;
          }
        }
      }
    }

    return bestResult;
  }

  static MrzResult? _parseTD3(String line1, String line2) {
    // ── Line 1 ──
    final documentCode = line1.substring(0, 2); // Pos 1–2
    final issuingState = line1.substring(2, 5); // Pos 3–5
    final nameField = line1.substring(5, 44); // Pos 6–44

    // Strict validation: Country code must be letters, never fillers
    if (issuingState.contains('<')) return null;

    // ── Line 2 ──
    final rawDocNum = line2.substring(0, 9); // Pos 1–9
    final docNumCheck = line2.substring(9, 10); // Pos 10
    final nationality = line2.substring(10, 13); // Pos 11–13
    final rawDob = line2.substring(13, 19); // Pos 14–19
    final dobCheck = line2.substring(19, 20); // Pos 20
    final sex = line2.substring(20, 21); // Pos 21
    final rawDoe = line2.substring(21, 27); // Pos 22–27
    final doeCheck = line2.substring(27, 28); // Pos 28
    final rawPersonal = line2.substring(28, 42); // Pos 29–42
    final personalCheck = line2.substring(42, 43); // Pos 43
    final compositeCheck = line2.substring(43, 44); // Pos 44

    // Sanitize numeric fields via MrzValidator
    final dob = MrzValidator.sanitizeNumber(rawDob);
    final doe = MrzValidator.sanitizeNumber(rawDoe);

    // Validate individual check digits via MrzValidator
    final validDocNum = MrzValidator.getValidValue(
      rawDocNum,
      MrzValidator.sanitizeNumber(docNumCheck),
    );
    if (validDocNum == null) return null;
    if (!MrzValidator.validateChecksum(
      dob,
      MrzValidator.sanitizeNumber(dobCheck),
    )) {
      return null;
    }
    if (!MrzValidator.validateChecksum(
      doe,
      MrzValidator.sanitizeNumber(doeCheck),
    )) {
      return null;
    }
    String validPersonal = rawPersonal;
    if (personalCheck != '<') {
      final v = MrzValidator.getValidValue(
        rawPersonal,
        MrzValidator.sanitizeNumber(personalCheck),
      );
      if (v == null) return null;
      validPersonal = v;
    }

    // Composite check digit: positions 1–10, 14–20, 22–43
    final compositeData =
        validDocNum + MrzValidator.sanitizeNumber(docNumCheck) + // pos 1–10
        dob + MrzValidator.sanitizeNumber(dobCheck) + // pos 14–20
        doe + MrzValidator.sanitizeNumber(doeCheck) + // pos 22–28
        validPersonal + MrzValidator.sanitizeNumber(personalCheck); // pos 29–43
    
    final isCompositeValid = MrzValidator.validateChecksum(
      compositeData,
      MrzValidator.sanitizeNumber(compositeCheck),
    );

    // Parse name
    final nameParts = _parseName(nameField);

    return MrzResult(
      format: MrzFormat.td3,
      documentCode: _cleanFiller(documentCode),
      issuingState: _cleanFiller(issuingState),
      surname: nameParts[0],
      givenNames: nameParts[1],
      documentNumber: validDocNum.replaceAll('<', ''),
      nationality: _cleanFiller(nationality),
      dateOfBirth: dob,
      sex: sex,
      dateOfExpiry: doe,
      personalNumber: _cleanFiller(validPersonal),
      isCompositeValid: isCompositeValid,
      rawLines: [line1, line2],
    );
  }

  /// Splits a name field on `<<` into [surname, givenNames].
  ///
  /// Within each part, single `<` is replaced with a space.
  /// Result is kept in raw uppercase.
  static List<String> _parseName(String nameField) {
    // A sequence of 3 or more '<' indicates the end of all valid name data.
    // Anything appearing after that is OCR garbage from the edge of the card (e.g. '...<<<<<K').
    final cleanNameField = nameField.split(RegExp(r'<{3,}'))[0];

    final parts = cleanNameField.split('<<');
    final surname = parts.isNotEmpty
        ? parts[0].replaceAll('<', ' ').trim()
        : '';
    final givenNames = parts.length > 1
        ? parts.sublist(1).join(' ').replaceAll('<', ' ').trim()
        : '';

    // Clean up any double spaces just in case
    return [
      surname.replaceAll(RegExp(r'\s+'), ' '),
      givenNames.replaceAll(RegExp(r'\s+'), ' '),
    ];
  }

  /// Removes trailing `<` filler characters.
  static String _cleanFiller(String input) {
    return input.replaceAll(_fillerPattern, '');
  }
}
