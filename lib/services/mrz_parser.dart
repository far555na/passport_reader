import '../models/mrz_result.dart';

/// Parses Machine Readable Zone (MRZ) text from OCR output.
///
/// Supports all three ICAO 9303 formats:
/// - TD1: 3 lines × 30 characters (ID cards)
/// - TD2: 2 lines × 36 characters (visas / some IDs)
/// - TD3: 2 lines × 44 characters (passport booklets)
class MrzParser {
  /// Parses raw OCR text and returns an [MrzResult] if a valid MRZ is found.
  ///
  /// Returns `null` if no valid MRZ is detected or checksums fail.
  static MrzResult? parse(String ocrText) {
    // print('--- RAW OCR TEXT ---');
    // print(ocrText);
    // print('--------------------');

    final collapsedText = _collapseMrzText(ocrText);

    // print('--- COLLAPSED MRZ TEXT ---');
    // print(collapsedText);
    // print('--------------------------');

    // Try TD3 first (most common: passport), then TD1, then TD2
    final td3 = _tryTD3(collapsedText);
    if (td3 != null) return td3;

    final td1 = _tryTD1(collapsedText);
    if (td1 != null) return td1;

    final td2 = _tryTD2(collapsedText);
    if (td2 != null) return td2;

    return null;
  }

  // ──────────────────────────────────────────────
  // Text collapsing
  // ──────────────────────────────────────────────

  /// Collapses raw OCR text into a single continuous string of MRZ characters.
  static String _collapseMrzText(String ocrText) {
    var cleaned = ocrText.toUpperCase().replaceAll(RegExp(r'[ \n\r]'), '');
    cleaned = cleaned.replaceAll(RegExp(r'[|]'), '<');
    cleaned = cleaned.replaceAll(RegExp(r'[^A-Z0-9<]'), '');
    return cleaned;
  }

  // ──────────────────────────────────────────────
  // TD3: Passport — 2 lines × 44 characters
  // ──────────────────────────────────────────────

  static MrzResult? _tryTD3(String collapsedText) {
    // TD3 Line 2 is 44 characters.
    final line2Pattern = RegExp(
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

    final matches = line2Pattern.allMatches(collapsedText);
    for (final match in matches) {
      final line2 = match.group(0)!;
      final precedingText = collapsedText.substring(0, match.start);

      final pMatches = RegExp(r'P[A-Z<]').allMatches(precedingText);
      if (pMatches.isNotEmpty) {
        var line1 = precedingText.substring(pMatches.last.start);
        if (line1.length < 44) {
          line1 = line1.padRight(44, '<');
        } else if (line1.length > 44) {
          line1 = line1.substring(0, 44);
        }

        final result = _parseTD3(line1, line2);
        if (result != null) return result;
      }
    }
    return null;
  }

  static MrzResult? _parseTD3(String line1, String line2) {
    // ── Line 1 ──
    final documentCode = line1.substring(0, 2); // Pos 1–2
    final issuingState = line1.substring(2, 5); // Pos 3–5
    final nameField = line1.substring(5, 44); // Pos 6–44

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
    // final personalCheck = line2.substring(42, 43); // Pos 43
    final compositeCheck = line2.substring(43, 44); // Pos 44

    // Sanitize numeric fields
    // final docNum = _sanitizeNumber(rawDocNum);
    final dob = _sanitizeNumber(rawDob);
    final doe = _sanitizeNumber(rawDoe);

    // Validate individual check digits
    final validDocNum = _getValidValue(rawDocNum, _sanitizeNumber(docNumCheck));
    if (validDocNum == null) return null;
    if (!_validateChecksum(dob, _sanitizeNumber(dobCheck))) return null;
    if (!_validateChecksum(doe, _sanitizeNumber(doeCheck))) return null;

    // Composite check digit: positions 1–10, 14–20, 22–43
    final compositeData =
        line2.substring(0, 10) + // pos 1–10
        line2.substring(13, 20) + // pos 14–20
        line2.substring(21, 43); // pos 22–43
    final isCompositeValid = _validateChecksum(
      compositeData,
      _sanitizeNumber(compositeCheck),
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
      personalNumber: _cleanFiller(rawPersonal),
      isCompositeValid: isCompositeValid,
      rawLines: [line1, line2],
    );
  }

  // ──────────────────────────────────────────────
  // TD2: Visa / Some IDs — 2 lines × 36 characters
  // ──────────────────────────────────────────────

  static MrzResult? _tryTD2(String collapsedText) {
    // TD2 Line 2 is 36 characters.
    final line2Pattern = RegExp(
      r'[A-Z0-9<]{9}' // Document number
      r'[0-9A-Z<]' // Check digit
      r'[A-Z<]{3}' // Nationality
      r'[0-9A-Z<]{6}' // DOB
      r'[0-9A-Z<]' // Check digit
      r'[MF<]' // Sex
      r'[0-9A-Z<]{6}' // DOE
      r'[0-9A-Z<]' // Check digit
      r'[A-Z0-9<]{7}' // Optional data
      r'[0-9A-Z<]', // Check digit
    );

    final matches = line2Pattern.allMatches(collapsedText);
    for (final match in matches) {
      final line2 = match.group(0)!;
      final precedingText = collapsedText.substring(0, match.start);

      final codeMatches = RegExp(r'[A-Z][A-Z<]').allMatches(precedingText);
      if (codeMatches.isNotEmpty) {
        var line1 = precedingText.substring(codeMatches.last.start);
        if (line1.length < 36) {
          line1 = line1.padRight(36, '<');
        } else if (line1.length > 36) {
          line1 = line1.substring(0, 36);
        }

        final result = _parseTD2(line1, line2);
        if (result != null) return result;
      }
    }
    return null;
  }

  static MrzResult? _parseTD2(String line1, String line2) {
    // ── Line 1 ──
    final documentCode = line1.substring(0, 2); // Pos 1–2
    final issuingState = line1.substring(2, 5); // Pos 3–5
    final nameField = line1.substring(5, 36); // Pos 6–36

    // ── Line 2 ──
    final rawDocNum = line2.substring(0, 9); // Pos 1–9
    final docNumCheck = line2.substring(9, 10); // Pos 10
    final nationality = line2.substring(10, 13); // Pos 11–13
    final rawDob = line2.substring(13, 19); // Pos 14–19
    final dobCheck = line2.substring(19, 20); // Pos 20
    final sex = line2.substring(20, 21); // Pos 21
    final rawDoe = line2.substring(21, 27); // Pos 22–27
    final doeCheck = line2.substring(27, 28); // Pos 28
    final rawOptional = line2.substring(28, 35); // Pos 29–35
    final compositeCheck = line2.substring(35, 36); // Pos 36

    // Sanitize numeric fields
    final dob = _sanitizeNumber(rawDob);
    final doe = _sanitizeNumber(rawDoe);

    // Validate individual check digits
    final validDocNum = _getValidValue(rawDocNum, _sanitizeNumber(docNumCheck));
    if (validDocNum == null) return null;
    if (!_validateChecksum(dob, _sanitizeNumber(dobCheck))) return null;
    if (!_validateChecksum(doe, _sanitizeNumber(doeCheck))) return null;

    // Composite check digit: positions 1–10, 14–20, 22–35
    final compositeData =
        line2.substring(0, 10) + // pos 1–10
        line2.substring(13, 20) + // pos 14–20
        line2.substring(21, 35); // pos 22–35
    final isCompositeValid = _validateChecksum(
      compositeData,
      _sanitizeNumber(compositeCheck),
    );

    final nameParts = _parseName(nameField);

    return MrzResult(
      format: MrzFormat.td2,
      documentCode: _cleanFiller(documentCode),
      issuingState: _cleanFiller(issuingState),
      surname: nameParts[0],
      givenNames: nameParts[1],
      documentNumber: validDocNum.replaceAll('<', ''),
      nationality: _cleanFiller(nationality),
      dateOfBirth: dob,
      sex: sex,
      dateOfExpiry: doe,
      personalNumber: _cleanFiller(rawOptional),
      isCompositeValid: isCompositeValid,
      rawLines: [line1, line2],
    );
  }

  // ──────────────────────────────────────────────
  // TD1: ID Cards — 3 lines × 30 characters
  // ──────────────────────────────────────────────

  static MrzResult? _tryTD1(String collapsedText) {
    // TD1 Line 2 is 30 characters.
    final line2Pattern = RegExp(
      r'[0-9A-Z<]{6}' // DOB
      r'[0-9A-Z<]' // Check digit
      r'[MF<]' // Sex
      r'[0-9A-Z<]{6}' // DOE
      r'[0-9A-Z<]' // Check digit
      r'[A-Z<]{3}' // Nationality
      r'[A-Z0-9<]{11}' // Optional data
      r'[0-9A-Z<]', // Composite check digit
    );

    final matches = line2Pattern.allMatches(collapsedText);
    for (final match in matches) {
      final line2 = match.group(0)!;
      final precedingText = collapsedText.substring(0, match.start);
      final succeedingText = collapsedText.substring(match.end);

      final codeMatches = RegExp(r'[IAC][A-Z<]').allMatches(precedingText);
      if (codeMatches.isNotEmpty) {
        var line1 = precedingText.substring(codeMatches.last.start);
        if (line1.length < 30) {
          line1 = line1.padRight(30, '<');
        } else if (line1.length > 30) {
          line1 = line1.substring(0, 30);
        }

        final nameMatches = RegExp(r'[A-Z]').allMatches(succeedingText);
        if (nameMatches.isNotEmpty) {
          var line3 = succeedingText.substring(nameMatches.first.start);
          if (line3.length < 30) {
            line3 = line3.padRight(30, '<');
          } else if (line3.length > 30) {
            line3 = line3.substring(0, 30);
          }

          final result = _parseTD1(line1, line2, line3);
          if (result != null) return result;
        }
      }
    }
    return null;
  }

  static MrzResult? _parseTD1(String line1, String line2, String line3) {
    // ── Line 1 ──
    final documentCode = line1.substring(0, 2); // Pos 1–2
    final issuingState = line1.substring(2, 5); // Pos 3–5
    final rawDocNum = line1.substring(5, 14); // Pos 6–14
    final docNumCheck = line1.substring(14, 15); // Pos 15
    final rawOptional1 = line1.substring(15, 30); // Pos 16–30

    // ── Line 2 ──
    final rawDob = line2.substring(0, 6); // Pos 1–6
    final dobCheck = line2.substring(6, 7); // Pos 7
    final sex = line2.substring(7, 8); // Pos 8
    final rawDoe = line2.substring(8, 14); // Pos 9–14
    final doeCheck = line2.substring(14, 15); // Pos 15
    final nationality = line2.substring(15, 18); // Pos 16–18
    final rawOptional2 = line2.substring(18, 29); // Pos 19–29
    final compositeCheck = line2.substring(29, 30); // Pos 30

    // ── Line 3 ──
    final nameField = line3.substring(0, 30); // Pos 1–30

    // Sanitize numeric fields
    final dob = _sanitizeNumber(rawDob);
    final doe = _sanitizeNumber(rawDoe);

    // Validate individual check digits
    final validDocNum = _getValidValue(rawDocNum, _sanitizeNumber(docNumCheck));
    if (validDocNum == null) return null;
    if (!_validateChecksum(dob, _sanitizeNumber(dobCheck))) return null;
    if (!_validateChecksum(doe, _sanitizeNumber(doeCheck))) return null;

    // Composite check digit: L1:6–30, L2:1–7, L2:9–15, L2:19–29
    // Note: L1 pos 6–30 is index 5..30, L2 pos 1–7 is index 0..7, etc.
    final compositeData =
        line1.substring(5, 30) + // L1 pos 6–30
        line2.substring(0, 7) + // L2 pos 1–7
        line2.substring(8, 15) + // L2 pos 9–15
        line2.substring(18, 29); // L2 pos 19–29
    final isCompositeValid = _validateChecksum(
      compositeData,
      _sanitizeNumber(compositeCheck),
    );

    final nameParts = _parseName(nameField);

    return MrzResult(
      format: MrzFormat.td1,
      documentCode: _cleanFiller(documentCode),
      issuingState: _cleanFiller(issuingState),
      surname: nameParts[0],
      givenNames: nameParts[1],
      documentNumber: validDocNum.replaceAll('<', ''),
      nationality: _cleanFiller(nationality),
      dateOfBirth: dob,
      sex: sex,
      dateOfExpiry: doe,
      optionalData1: _cleanFiller(rawOptional1),
      optionalData2: _cleanFiller(rawOptional2),
      isCompositeValid: isCompositeValid,
      rawLines: [line1, line2, line3],
    );
  }

  // ──────────────────────────────────────────────
  // Shared utilities
  // ──────────────────────────────────────────────

  /// Splits a name field on `<<` into [surname, givenNames].
  ///
  /// Within each part, single `<` is replaced with a space.
  /// Result is kept in raw uppercase.
  static List<String> _parseName(String nameField) {
    final parts = nameField.split('<<');
    final surname = parts.isNotEmpty
        ? parts[0].replaceAll('<', ' ').trim()
        : '';
    final givenNames = parts.length > 1
        ? parts.sublist(1).join(' ').replaceAll('<', ' ').trim()
        : '';
    return [surname, givenNames];
  }

  /// Replaces common OCR number misreads: 'O' → '0'.
  static String _sanitizeNumber(String input) {
    return input.replaceAll('O', '0');
  }

  /// Removes trailing `<` filler characters.
  static String _cleanFiller(String input) {
    return input.replaceAll(RegExp(r'<+$'), '');
  }

  /// Tries raw value first, then sanitized. Returns valid value or null.
  static String? _getValidValue(String rawValue, String checkDigit) {
    if (_validateChecksum(rawValue, checkDigit)) {
      return rawValue;
    }
    final sanitized = _sanitizeNumber(rawValue);
    if (_validateChecksum(sanitized, checkDigit)) {
      return sanitized;
    }
    return null;
  }

  /// Validates an ICAO 9303 check digit using the 7-3-1 weighted algorithm.
  static bool _validateChecksum(String data, String checkDigitChar) {
    if (checkDigitChar == '<') return false;
    final checkDigit = int.tryParse(checkDigitChar);
    if (checkDigit == null) return false;

    const weights = [7, 3, 1];
    int sum = 0;

    for (int i = 0; i < data.length; i++) {
      int charValue;
      final char = data[i];

      if (char == '<') {
        charValue = 0;
      } else if (RegExp(r'[0-9]').hasMatch(char)) {
        charValue = int.parse(char);
      } else {
        // A=10, B=11, ..., Z=35
        charValue = char.codeUnitAt(0) - 55;
      }

      sum += charValue * weights[i % 3];
    }

    return (sum % 10) == checkDigit;
  }
}
