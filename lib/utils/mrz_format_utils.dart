import 'country_codes.dart';

class MrzFormatUtils {
  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  /// Formats a YYMMDD string to `dd MMM yyyy`.
  /// Uses century inference based on whether it is an expiry date or birth date.
  static String formatDate(String yymmdd, {bool isExpiry = false}) {
    if (yymmdd.length != 6) return yymmdd;

    final yyStr = yymmdd.substring(0, 2);
    final mmStr = yymmdd.substring(2, 4);
    final ddStr = yymmdd.substring(4, 6);

    final yy = int.tryParse(yyStr);
    final mm = int.tryParse(mmStr);
    final dd = int.tryParse(ddStr);

    if (yy == null || mm == null || dd == null) return yymmdd;
    if (mm < 1 || mm > 12) return yymmdd;

    final currentYear = DateTime.now().year;
    final currentCentury = (currentYear ~/ 100) * 100;
    final currentYearTwoDigits = currentYear % 100;

    int fullYear;
    if (isExpiry) {
      // Expiry dates are typically in the future, up to ~15 years ahead.
      // E.g., if current year is 2026, 36 is likely 2036. 95 is likely 1995.
      if (yy < currentYearTwoDigits + 20) {
        fullYear = currentCentury + yy;
      } else {
        fullYear = currentCentury - 100 + yy;
      }
    } else {
      // Birth dates are in the past.
      // E.g., if current year is 2026, 25 is likely 2025 (1 yr old). 27 is likely 1927.
      if (yy <= currentYearTwoDigits) {
        fullYear = currentCentury + yy;
      } else {
        fullYear = currentCentury - 100 + yy;
      }
    }

    final monthStr = _months[mm - 1];
    return '$ddStr $monthStr $fullYear';
  }

  /// Title-cases a name and replaces filler `<` with spaces.
  static String formatName(String name) {
    if (name.isEmpty) return name;
    final cleaned = name.replaceAll('<', ' ').trim();
    if (cleaned.isEmpty) return cleaned;
    
    // Title case each word
    final words = cleaned.split(RegExp(r'\s+'));
    final titleCased = words.map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');

    return titleCased;
  }

  /// Converts sex code to readable string.
  static String formatSex(String sex) {
    if (sex == 'M') return 'Male';
    if (sex == 'F') return 'Female';
    return 'Unspecified';
  }

  /// Formats document code.
  static String formatDocumentCode(String code) {
    final cleaned = cleanString(code);
    if (cleaned.startsWith('P')) {
      return 'Passport (P)';
    } else if (cleaned.startsWith('I')) {
      return 'Identity Card (I)';
    } else if (cleaned.startsWith('V')) {
      return 'Visa (V)';
    }
    return cleaned;
  }

  /// Formats a 3-letter ISO country code into its full name.
  static String formatCountry(String code) {
    final cleaned = cleanString(code);
    return CountryCodes.map[cleaned] ?? cleaned;
  }

  /// Strips trailing `<` characters.
  static String cleanString(String text) {
    // Trim trailing '<'
    var result = text;
    while (result.endsWith('<')) {
      result = result.substring(0, result.length - 1);
    }
    return result;
  }

  /// Parses a 6-digit YYMMDD string into a DateTime object.
  /// Used for calculating BAC and PACE keys.
  static DateTime parseDate(String yymmdd, {bool isExpiry = false}) {
    final yy = int.parse(yymmdd.substring(0, 2));
    final mm = int.parse(yymmdd.substring(2, 4));
    final dd = int.parse(yymmdd.substring(4, 6));

    final currentYear = DateTime.now().year;
    final currentTwoDigitYear = currentYear % 100;

    int prefix;
    if (isExpiry) {
      prefix = 2000;
    } else {
      prefix = yy > currentTwoDigitYear ? 1900 : 2000;
    }

    return DateTime(prefix + yy, mm, dd);
  }
}
