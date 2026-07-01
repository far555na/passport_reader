
import '../models/passive_auth_verification_result.dart';
import '../models/parsed_sod_data.dart';
import '../models/csca_data.dart';
import '../models/data_groups.dart';
import 'data_group_verifier.dart';
import 'signature_verifier.dart';
import 'csca_verifier.dart';

class PassiveAuthenticator {
  /// Verifies the entire Passive Authentication chain (Hashes, Signature, CSCA).
  static PassiveAuthVerificationResult verify(
      ParsedSODData parsedSOD, DataGroups dataGroups, CscaData cscaData) {
    
    // Stage 1: Verify Data Group Hashes
    var dgResults = DataGroupVerifier.verifyHashes(parsedSOD, dataGroups);
    
    // Stage 2: Verify SOD Signature against DSC
    var sigResult = SignatureVerifier.verifySignature(parsedSOD);
    
    // Stage 3: Verify DSC Trust Chain against CSCA
    var cscaResult = CscaVerifier.verifyTrustChain(parsedSOD, cscaData);

    return PassiveAuthVerificationResult(
      dgVerification: dgResults,
      signatureVerification: sigResult,
      cscaVerification: cscaResult,
    );
  }
}
