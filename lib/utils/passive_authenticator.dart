import 'dart:typed_data';
import 'package:pointycastle/export.dart';
import 'package:collection/collection.dart';
import 'passive_auth_parser.dart';

class VerificationResult {
  final bool isVerified;
  final String message;

  VerificationResult(this.isVerified, this.message);
}

class PassiveAuthVerificationResult {
  final Map<int, VerificationResult> dgVerification;
  final VerificationResult signatureVerification;

  PassiveAuthVerificationResult({
    required this.dgVerification,
    required this.signatureVerification,
  });

  bool get isDataIntegrityVerified => 
      dgVerification.isNotEmpty && dgVerification.values.every((v) => v.isVerified);

  bool get isSignatureVerified => signatureVerification.isVerified;
}

class PassiveAuthenticator {
  static const Map<String, String> _oidToDigestName = {
    '1.3.14.3.2.26': 'SHA-1',
    '2.16.840.1.101.3.4.2.4': 'SHA-224',
    '2.16.840.1.101.3.4.2.1': 'SHA-256',
    '2.16.840.1.101.3.4.2.2': 'SHA-384',
    '2.16.840.1.101.3.4.2.3': 'SHA-512',
  };

  /// Verifies the integrity of the Data Groups against the SOD
  static PassiveAuthVerificationResult verify(
      PassiveAuthResult parsedSOD, Map<int, Uint8List> dataGroups) {
    
    String? digestName = _oidToDigestName[parsedSOD.hashAlgorithmOid];
    if (digestName == null) {
      return PassiveAuthVerificationResult(
        dgVerification: {},
        signatureVerification: VerificationResult(false, 'Unsupported hash algorithm OID: ${parsedSOD.hashAlgorithmOid}'),
      );
    }

    Map<int, VerificationResult> dgVerifications = {};
    Digest digest;
    try {
      digest = Digest(digestName);
    } catch (e) {
      return PassiveAuthVerificationResult(
        dgVerification: {},
        signatureVerification: VerificationResult(false, 'Failed to initialize digest: $digestName'),
      );
    }

    // Verify each provided DG
    for (var entry in dataGroups.entries) {
      int dgNum = entry.key;
      Uint8List dgData = entry.value;

      if (!parsedSOD.dgHashes.containsKey(dgNum)) {
        dgVerifications[dgNum] = VerificationResult(false, 'DG$dgNum not found in SOD');
        continue;
      }

      Uint8List expectedHash = parsedSOD.dgHashes[dgNum]!;
      digest.reset();
      Uint8List computedHash = digest.process(dgData);

      if (ListEquality().equals(computedHash, expectedHash)) {
        dgVerifications[dgNum] = VerificationResult(true, 'Hash matches');
      } else {
        dgVerifications[dgNum] = VerificationResult(false, 'Hash mismatch');
      }
    }

    // Missing DGs (e.g. DG3, DG14) that we simply didn't read from the passport
    // should not fail our data integrity check. We only care that the DGs we
    // *did* provide match the hashes in the SOD.
    // 
    // We removed the block that adds `false` VerificationResults for missing DGs.

    // TODO: Implement X.509 signature verification.
    // This requires extracting the PublicKey from the dsCertificate and verifying
    // the 'signature' against the eContent. For now, we stub it.
    VerificationResult sigResult;
    if (parsedSOD.signature != null && parsedSOD.dsCertificate != null) {
      sigResult = VerificationResult(false, 'Signature verification requires X.509 parsing (Not implemented)');
    } else {
      sigResult = VerificationResult(false, 'Missing signature or certificate in SOD');
    }

    return PassiveAuthVerificationResult(
      dgVerification: dgVerifications,
      signatureVerification: sigResult,
    );
  }
}
