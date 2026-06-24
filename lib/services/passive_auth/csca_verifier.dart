import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:pointycastle/asn1.dart';
import 'package:pointycastle/export.dart' as pc;
import 'package:basic_utils/basic_utils.dart';

import '../../models/verification_result.dart';
import '../../models/parsed_sod_data.dart';
import '../../utils/certificate_utils.dart';

class CscaVerifier {
  /// Verifies the Document Signer Certificate against a trusted CSCA Master List.
  static VerificationResult verifyTrustChain(ParsedSODData parsedSOD, Map<String, List<String>> cscaIndex) {
    if (parsedSOD.dsCertificate == null) {
      return VerificationResult(false, 'Missing Document Signer Certificate in SOD for CSCA check');
    }

    if (cscaIndex.isEmpty) {
      debugPrint('CSCA Verifier: The provided cscaIndex map is empty.');
      return VerificationResult(false, 'CSCA Master List index is empty or not loaded');
    }

    try {
      // 1. Extract Issuer from DS Certificate using basic_utils for exact OID string mapping
      final dsCertBase64 = base64Encode(parsedSOD.dsCertificate!);
      final dsPem = '-----BEGIN CERTIFICATE-----\n${StringUtils.chunk(dsCertBase64, 64).join('\n')}\n-----END CERTIFICATE-----';
      final dsX509 = X509Utils.x509CertificateFromPem(dsPem);
      
      final issuerStr = dsX509.tbsCertificate?.issuer.toString() ?? '';
      debugPrint('CSCA Verifier: Looking for DS Issuer string: $issuerStr');

      // Parse DS cert to ASN1 for signature verification later
      final parser = ASN1Parser(parsedSOD.dsCertificate!);
      final certSeq = parser.nextObject() as ASN1Sequence;
      final tbsCertificate = certSeq.elements![0] as ASN1Sequence;

      // 2. Look up the Issuer in the CSCA Index
      final matchedCscaBase64List = cscaIndex[issuerStr];
      if (matchedCscaBase64List == null || matchedCscaBase64List.isEmpty) {
        return VerificationResult(false, 'Document Signer Certificate issuer not found in trusted Master List');
      }

      final dsSignatureAlg = certSeq.elements![1] as ASN1Sequence;
      final dsAlgOid = dsSignatureAlg.elements![0] as ASN1ObjectIdentifier;
      final algorithm = CertificateUtils.mapOidToAlgorithm(dsAlgOid.objectIdentifierAsString!);
      
      final dsSignatureValue = certSeq.elements![2] as ASN1BitString;
      final dsSignedDataBytes = tbsCertificate.encode();
      
      // Clean up signature bytes (remove unused bits byte if present in BIT STRING)
      var sigBytes = dsSignatureValue.valueBytes!;
      if (sigBytes.isNotEmpty && sigBytes[0] == 0) {
        sigBytes = sigBytes.sublist(1);
      }

      // Loop through all candidate CSCA certificates for this issuer
      for (int i = 0; i < matchedCscaBase64List.length; i++) {
        final matchedCscaBase64 = matchedCscaBase64List[i];
        try {
          // 3. Extract CSCA Public Key
          final cscaBytes = base64Decode(matchedCscaBase64);
          
          // Extract CSCA public key
          final cscaPublicKey = CertificateUtils.extractPublicKey(cscaBytes, algorithm);
          
          bool isVerified = false;
          if (algorithm.contains('RSA') && cscaPublicKey is pc.RSAPublicKey) {
            isVerified = CryptoUtils.rsaVerify(
                cscaPublicKey, dsSignedDataBytes, sigBytes,
                algorithm: algorithm);
          } else if ((algorithm.contains('ECDSA') || algorithm.contains('EC')) && cscaPublicKey is pc.ECPublicKey) {
            final ecSignature = CryptoUtils.ecSignatureFromDerBytes(sigBytes);
            isVerified = CryptoUtils.ecVerify(
                cscaPublicKey, dsSignedDataBytes, ecSignature,
                algorithm: algorithm);
          }
          
          if (isVerified) {
            return VerificationResult(true, 'Trust Chain successfully verified against CSCA Master List');
          }
        } catch (e) {
          // Ignore and try next candidate
        }
      }

      return VerificationResult(false, 'Trust Chain verification failed (no matching valid CSCA certificate found for issuer)');
      
    } catch (e) {
      return VerificationResult(false, 'Error during CSCA verification: $e');
    }
  }
}
