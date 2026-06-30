import 'package:basic_utils/basic_utils.dart';
import 'package:pointycastle/export.dart' as pc;
import '../../models/verification_result.dart';
import '../../models/parsed_sod_data.dart';
import '../../utils/certificate_utils.dart';
import '../../utils/oid_mapper.dart';

class SignatureVerifier {
  /// Verifies the digital signature of the EF.SOD using the Document Signer Certificate.
  static VerificationResult verifySignature(ParsedSODData parsedSOD) {
    if (parsedSOD.signature == null || parsedSOD.parsedDSCData == null || parsedSOD.signedDataBytes == null) {
      return VerificationResult(
          false, 'Missing signature, certificate, or signed data in SOD');
    }

    try {
      // Determine signature algorithm
      String sigAlg = OidMapper.mapOidToSignatureAlgorithm(parsedSOD.signatureAlgorithmOid ?? '');
      
      final publicKey = CertificateUtils.extractPublicKey(parsedSOD.parsedDSCData!.rawCertBytes, sigAlg);
      
      bool isVerified = false;
      if (sigAlg.contains('RSA')) {
        isVerified = CryptoUtils.rsaVerify(
            publicKey as pc.RSAPublicKey, parsedSOD.signedDataBytes!, parsedSOD.signature!,
            algorithm: sigAlg);
      } else if (sigAlg.contains('ECDSA') || sigAlg.contains('EC')) {
        final ecSignature = CryptoUtils.ecSignatureFromDerBytes(parsedSOD.signature!);
        isVerified = CryptoUtils.ecVerify(
            publicKey as pc.ECPublicKey, parsedSOD.signedDataBytes!, ecSignature,
            algorithm: sigAlg);
      } else {
         return VerificationResult(false, 'Unsupported signature algorithm: $sigAlg');
      }

      if (isVerified) {
        return VerificationResult(true, 'Signature successfully verified');
      } else {
        return VerificationResult(false, 'Signature verification failed (hash mismatch)');
      }
    } catch (e) {
      return VerificationResult(false, 'Error during signature verification: $e');
    }
  }
}
