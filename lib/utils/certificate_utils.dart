import 'dart:typed_data';
import 'package:basic_utils/basic_utils.dart';
import 'package:pointycastle/export.dart' as pc;
import 'package:pointycastle/asn1.dart';

class CertificateUtils {
  static pc.PublicKey extractPublicKey(Uint8List certBytes, String algorithm) {
    var asn1Parser = ASN1Parser(certBytes);
    var certSeq = asn1Parser.nextObject() as ASN1Sequence;
    var tbsCertSeq = certSeq.elements![0] as ASN1Sequence;
    
    ASN1Sequence? spki;
    for (var i = tbsCertSeq.elements!.length - 1; i >= 0; i--) {
      var e = tbsCertSeq.elements![i];
      if (e is ASN1Sequence && e.elements!.length == 2 && e.elements![1] is ASN1BitString) {
         if (e.elements![0] is ASN1Sequence) {
            spki = e;
            break;
         }
      }
    }
    
    if (spki == null) {
      throw Exception('Could not find SubjectPublicKeyInfo in certificate');
    }
    
    var algIdSeq = spki.elements![0] as ASN1Sequence;
    var oid = (algIdSeq.elements![0] as ASN1ObjectIdentifier).objectIdentifierAsString;

    var spkiBytes = spki.encode();
    
    if (oid == '1.2.840.113549.1.1.1' || oid == '1.2.840.113549.1.1.10') {
      return CryptoUtils.rsaPublicKeyFromDERBytes(spkiBytes);
    } else if (oid == '1.2.840.10045.2.1') {
      try {
        return CryptoUtils.ecPublicKeyFromDerBytes(spkiBytes);
      } catch (e) {
        if (algorithm.contains('ECDSA')) {
          // Named curve extraction failed. Trying explicit curve parameters fallback...
          return _ecPublicKeyFromSpkiWithExplicitParams(spkiBytes);
        }
        throw Exception("Failed to parse public key from SPKI: $e");
      }
    }

    throw Exception('Unsupported public key OID: $oid');
  }

  /// Attempts to reconstruct an [ECPublicKey] from a SubjectPublicKeyInfo DER
  /// that uses explicit domain parameters (common in some ePassport DSCs).
  /// Extracts the public key point from the BIT STRING and tries a set of
  /// well-known ePassport curves: P-256, P-384, P-521, and brainpool variants.
  static pc.ECPublicKey _ecPublicKeyFromSpkiWithExplicitParams(Uint8List spkiDer) {
    final spkiParser = ASN1Parser(spkiDer);
    final spkiSeq = spkiParser.nextObject() as ASN1Sequence;
    final pubBitString = spkiSeq.elements![1] as ASN1BitString;

    var pubBytes = pubBitString.valueBytes!;
    if (pubBytes.isNotEmpty && pubBytes[0] == 0) {
      pubBytes = pubBytes.sublist(1);
    }

    final candidates = <String>[];
    switch (pubBytes.length) {
      case 65:
        candidates.addAll(['prime256v1', 'brainpoolp256r1']);
        break;
      case 97:
        candidates.addAll(['secp384r1', 'brainpoolp384r1']);
        break;
      case 133:
        candidates.add('secp521r1');
        break;
      case 129:
        candidates.add('brainpoolp512r1');
        break;
      default:
        throw Exception('Cannot infer EC curve from public key length ${pubBytes.length}');
    }

    for (final curveName in candidates) {
      try {
        final params = pc.ECDomainParameters(curveName);
        if (pubBytes[0] != 4) {
          throw Exception('Compressed EC points are not supported');
        }
        final coordLen = (pubBytes.length - 1) ~/ 2;
        final x = _decodeBigInt(pubBytes.sublist(1, 1 + coordLen));
        final y = _decodeBigInt(pubBytes.sublist(1 + coordLen));
        
        final xElem = params.curve.fromBigInteger(x);
        final yElem = params.curve.fromBigInteger(y);
        final lhs = yElem * yElem;
        final rhs = (xElem * xElem * xElem) + (params.curve.a! * xElem) + params.curve.b!;
        if (lhs != rhs) {
          throw Exception('Point does not satisfy curve equation for $curveName');
        }
        
        final point = params.curve.createPoint(x, y);
        return pc.ECPublicKey(point, params);
      } catch (_) {
        continue;
      }
    }
    throw Exception('Could not reconstruct ECPublicKey from explicit params');
  }

  static BigInt _decodeBigInt(Uint8List bytes) {
    BigInt result = BigInt.zero;
    for (final byte in bytes) {
      result = (result << 8) | BigInt.from(byte);
    }
    return result;
  }

  static String mapOidToAlgorithm(String? oid) {
    // Common OIDs for Document Signer Signatures
    switch (oid) {
      case '1.2.840.113549.1.1.11': return 'SHA-256/RSA';
      case '1.2.840.113549.1.1.12': return 'SHA-384/RSA';
      case '1.2.840.113549.1.1.13': return 'SHA-512/RSA';
      case '1.2.840.113549.1.1.5': return 'SHA-1/RSA';
      case '1.2.840.10045.4.3.2': return 'SHA-256/ECDSA';
      case '1.2.840.10045.4.3.3': return 'SHA-384/ECDSA';
      case '1.2.840.10045.4.3.4': return 'SHA-512/ECDSA';
      default:
        // Defaulting to SHA-256/RSA if unknown
        return 'SHA-256/RSA';
    }
  }
}
