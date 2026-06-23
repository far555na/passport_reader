import 'dart:typed_data';

class PassiveAuthResult {
  final Map<int, Uint8List> dgHashes;
  final String hashAlgorithmOid;
  final Uint8List? signature;
  final Uint8List? dsCertificate;

  PassiveAuthResult({
    required this.dgHashes,
    required this.hashAlgorithmOid,
    this.signature,
    this.dsCertificate,
  });
}
