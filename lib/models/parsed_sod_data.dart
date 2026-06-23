import 'dart:typed_data';

class ParsedSODData {
  final Map<int, Uint8List> dgHashes;
  final String hashAlgorithmOid;
  final Uint8List? signature;
  final Uint8List? dsCertificate;

  ParsedSODData({
    required this.dgHashes,
    required this.hashAlgorithmOid,
    this.signature,
    this.dsCertificate,
  });
}
