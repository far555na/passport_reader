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
    
    // Let's use a regex to find the common TD3 second line pattern
    // [A-Z0-9<]{9}[0-9][A-Z<]{3}[0-9]{6}[0-9][MF<][0-9]{6}[0-9]
    final RegExp td3Line2Regex = RegExp(r'([A-Z0-9<]{9})([0-9])([A-Z<]{3})([0-9]{6})([0-9])[MF<]([0-9]{6})([0-9])');
    
    final match = td3Line2Regex.firstMatch(cleanMrz);
    
    if (match != null) {
      final docNum = match.group(1)!.replaceAll('<', '');
      final docNumCheck = match.group(2)!;
      final dob = match.group(4)!;
      final dobCheck = match.group(5)!;
      final doe = match.group(6)!;
      final doeCheck = match.group(7)!;
      
      if (_validateChecksum(match.group(1)!, docNumCheck) &&
          _validateChecksum(dob, dobCheck) &&
          _validateChecksum(doe, doeCheck)) {
        return {
          'documentNumber': docNum,
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
