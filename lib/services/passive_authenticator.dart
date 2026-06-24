import 'dart:typed_data';

import '../models/passive_auth_verification_result.dart';
import '../models/parsed_sod_data.dart';
import 'passive_auth/data_group_verifier.dart';
import 'passive_auth/signature_verifier.dart';
import 'passive_auth/csca_verifier.dart';

class PassiveAuthenticator {
  /// Verifies the entire Passive Authentication chain (Hashes, Signature, CSCA).
  static PassiveAuthVerificationResult verify(
      ParsedSODData parsedSOD, Map<int, Uint8List> dataGroups, Map<String, List<String>> cscaIndex) {
    
    // Stage 1: Verify Data Group Hashes
    var dgResults = DataGroupVerifier.verifyHashes(parsedSOD, dataGroups);
    
    // Stage 2: Verify SOD Signature against DSC
    var sigResult = SignatureVerifier.verifySignature(parsedSOD);
    
    // Stage 3: Verify DSC Trust Chain against CSCA
    var cscaResult = CscaVerifier.verifyTrustChain(parsedSOD, cscaIndex);

    return PassiveAuthVerificationResult(
      dgVerification: dgResults,
      signatureVerification: sigResult,
      cscaVerification: cscaResult,
    );
  }
}
