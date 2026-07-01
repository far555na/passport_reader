import 'dart:typed_data';
import 'parsed_dsc_data.dart';

class ParsedSODData {
  final Map<int, Uint8List> dgHashes;
  final String hashAlgorithmOid;
  final Uint8List? signature;
  final ParsedDSCData? parsedDSCData;
  final Uint8List? signedDataBytes;
  final String? signatureAlgorithmOid;

  ParsedSODData({
    required this.dgHashes,
    required this.hashAlgorithmOid,
    this.signature,
    this.parsedDSCData,
    this.signedDataBytes,
    this.signatureAlgorithmOid,
  });
}
