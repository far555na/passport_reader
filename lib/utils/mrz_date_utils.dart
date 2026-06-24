class MrzDateUtils {
  /// Parses a 6-digit YYMMDD string into a DateTime object.
  /// Used for calculating BAC and PACE keys.
  static DateTime parse(String yymmdd, {bool isExpiry = false}) {
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
