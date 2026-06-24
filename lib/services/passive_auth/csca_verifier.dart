import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:pointycastle/export.dart' as pc;

import '../../models/verification_result.dart';
import '../../models/parsed_sod_data.dart';
import '../../models/csca_data.dart';
import '../../utils/certificate_utils.dart';

class CscaVerifier {
  /// Verifies the Document Signer Certificate against a trusted CSCA Master List.
  static VerificationResult verifyTrustChain(
    ParsedSODData parsedSOD,
    CscaData cscaData,
  ) {
    if (parsedSOD.parsedDSCData == null) {
      return VerificationResult(
        false,
        'Missing parsed Document Signer Certificate in SOD for CSCA check',
      );
    }

    if (cscaData.isEmpty) {
      debugPrint('CSCA Verifier: The provided cscaData map is empty.');
      return VerificationResult(
        false,
        'CSCA Master List index is empty or not loaded',
      );
    }

    try {
      final parsedDSC = parsedSOD.parsedDSCData!;
      final issuerStr = parsedDSC.issuer;
      debugPrint('CSCA Verifier: Looking for DS Issuer string: $issuerStr');

      // 1. Look up the Issuer in the CSCA Index
      final matchedCscaBase64List = cscaData.getCertificatesForIssuer(issuerStr);
      if (matchedCscaBase64List == null || matchedCscaBase64List.isEmpty) {
        return VerificationResult(
          false,
          'Document Signer Certificate issuer not found in trusted Master List',
        );
      }

      final algorithm = parsedDSC.signatureAlgorithm;
      final dsSignedDataBytes = parsedDSC.signedDataBytes;
      final sigBytes = parsedDSC.signatureBytes;

      // Loop through all candidate CSCA certificates for this issuer
      for (int i = 0; i < matchedCscaBase64List.length; i++) {
        final matchedCscaBase64 = matchedCscaBase64List[i];
        try {
          // 2. Extract CSCA Public Key
          final cscaBytes = base64Decode(matchedCscaBase64);

          // Extract CSCA public key
          final cscaPublicKey = CertificateUtils.extractPublicKey(
            cscaBytes,
            algorithm,
          );

          bool isVerified = false;
          if (algorithm.contains('RSA') && cscaPublicKey is pc.RSAPublicKey) {
            isVerified = CryptoUtils.rsaVerify(
              cscaPublicKey,
              dsSignedDataBytes,
              sigBytes,
              algorithm: algorithm,
            );
          } else if ((algorithm.contains('ECDSA') ||
                  algorithm.contains('EC')) &&
              cscaPublicKey is pc.ECPublicKey) {
            final ecSignature = CryptoUtils.ecSignatureFromDerBytes(sigBytes);
            isVerified = CryptoUtils.ecVerify(
              cscaPublicKey,
              dsSignedDataBytes,
              ecSignature,
              algorithm: algorithm,
            );
          }

          if (isVerified) {
            return VerificationResult(
              true,
              'Trust Chain successfully verified against CSCA Master List',
            );
          }
        } catch (e) {
          // Ignore and try next candidate
        }
      }

      return VerificationResult(
        false,
        'Trust Chain verification failed (no matching valid CSCA certificate found for issuer)',
      );
    } catch (e) {
      return VerificationResult(false, 'Error during CSCA verification: $e');
    }
  }
}
