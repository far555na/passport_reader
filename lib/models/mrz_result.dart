/// Represents the format/size of the MRZ document.
enum MrzFormat {
  /// ID cards — 3 lines × 30 characters
  td1,

  /// Visas / some ID cards — 2 lines × 36 characters
  td2,

  /// Passport booklets — 2 lines × 44 characters
  td3,
}

/// Holds all data extracted from a Machine Readable Zone (MRZ).
///
/// Supports TD1 (3×30), TD2 (2×36), and TD3 (2×44) formats
/// per ICAO Doc 9303.
class MrzResult {
  /// The detected MRZ format.
  final MrzFormat format;

  // ── Common fields (present in all formats) ──

  /// Document code, e.g. "P", "P<", "ID", "I<".
  final String documentCode;

  /// Issuing state or organization (ISO 3166-1 alpha-3), e.g. "THA".
  final String issuingState;

  /// Primary identifier (surname) in raw uppercase.
  /// Filler `<` within the name is replaced with spaces.
  final String surname;

  /// Secondary identifier (given names) in raw uppercase.
  /// Filler `<` within the name is replaced with spaces.
  final String givenNames;

  /// Document number, e.g. "AB1234567".
  final String documentNumber;

  /// Nationality (ISO 3166-1 alpha-3), e.g. "THA".
  final String nationality;

  /// Date of birth in YYMMDD format.
  final String dateOfBirth;

  /// Sex: "M", "F", or "<" (unspecified).
  final String sex;

  /// Date of expiry in YYMMDD format.
  final String dateOfExpiry;

  // ── Optional / format-specific fields ──

  /// TD3: Personal number (positions 29–42).
  /// TD2: Optional data (positions 29–35).
  /// TD1: Not used (empty string).
  final String personalNumber;

  /// TD1 only: Optional data from Line 1 positions 16–30.
  /// Empty string for TD2/TD3.
  final String optionalData1;

  /// TD1 only: Optional data from Line 2 positions 19–29.
  /// Empty string for TD2/TD3.
  final String optionalData2;

  // ── Validation ──

  /// Whether the composite check digit is valid.
  final bool isCompositeValid;

  /// The raw MRZ lines as detected by OCR.
  final List<String> rawLines;

  const MrzResult({
    required this.format,
    required this.documentCode,
    required this.issuingState,
    required this.surname,
    required this.givenNames,
    required this.documentNumber,
    required this.nationality,
    required this.dateOfBirth,
    required this.sex,
    required this.dateOfExpiry,
    this.personalNumber = '',
    this.optionalData1 = '',
    this.optionalData2 = '',
    required this.isCompositeValid,
    required this.rawLines,
  });

  /// Human-readable format label.
  String get formatLabel {
    switch (format) {
      case MrzFormat.td1:
        return 'TD1 (ID Card)';
      case MrzFormat.td2:
        return 'TD2';
      case MrzFormat.td3:
        return 'TD3 (Passport)';
    }
  }

  /// Full name: "SURNAME, GIVEN NAMES".
  String get fullName {
    if (givenNames.isEmpty) return surname;
    return '$surname, $givenNames';
  }

  @override
  String toString() {
    return 'MrzResult($formatLabel: $documentNumber, $surname, $givenNames)';
  }
}
