import 'dart:typed_data';

class ParsedDSCData {
  final Uint8List rawCertBytes;
  final String issuer;
  final String signatureAlgorithm;
  final Uint8List signedDataBytes;
  final Uint8List signatureBytes;

  ParsedDSCData({
    required this.rawCertBytes,
    required this.issuer,
    required this.signatureAlgorithm,
    required this.signedDataBytes,
    required this.signatureBytes,
  });
}
