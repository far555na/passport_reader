import '../models/mrz_result.dart';
import 'mrz_validator.dart';

/// Parses Machine Readable Zone (MRZ) text from OCR output.
///
/// Supports the ICAO 9303 TD3 format:
/// - TD3: 2 lines × 44 characters (passport booklets)
class MrzParser {
  // Pre-compiled RegExps for significantly better performance
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

  /// Parses raw OCR text and returns an [MrzResult] if a valid MRZ is found.
  ///
  /// Returns `null` if no valid MRZ is detected or checksums fail.
  static MrzResult? parse(String ocrText) {
    final collapsedText = _collapseMrzText(ocrText);
    // Only support TD3 (passports)
    return _tryTD3(collapsedText);
  }

  // ──────────────────────────────────────────────
  // Text collapsing
  // ──────────────────────────────────────────────

  /// Collapses raw OCR text into a single continuous string of MRZ characters.
  /// Uses a fast single-pass string builder.
  static String _collapseMrzText(String ocrText) {
    final buffer = StringBuffer();
    final upperText = ocrText.toUpperCase();

    for (int i = 0; i < upperText.length; i++) {
      final code = upperText.codeUnitAt(i);

      // Ignore space, \n, \r
      if (code == 32 || code == 10 || code == 13) continue;

      if (code == 124) {
        // '|' -> '<'
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

  // ──────────────────────────────────────────────
  // TD3: Passport — 2 lines × 44 characters
  // ──────────────────────────────────────────────

  static MrzResult? _tryTD3(String collapsedText) {
    final matches = _line2Pattern.allMatches(collapsedText);
    for (final match in matches) {
      final line2 = match.group(0)!;
      final precedingText = collapsedText.substring(0, match.start);

      final pMatches = _pMatchesPattern.allMatches(precedingText);
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

    // Composite check digit: positions 1–10, 14–20, 22–43
    final compositeData =
        line2.substring(0, 10) + // pos 1–10
        line2.substring(13, 20) + // pos 14–20
        line2.substring(21, 43); // pos 22–43
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
      personalNumber: _cleanFiller(rawPersonal),
      isCompositeValid: isCompositeValid,
      rawLines: [line1, line2],
    );
  }

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

  /// Removes trailing `<` filler characters.
  static String _cleanFiller(String input) {
    return input.replaceAll(_fillerPattern, '');
  }
}
