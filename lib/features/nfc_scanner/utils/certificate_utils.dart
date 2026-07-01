import 'dart:typed_data';
import 'package:basic_utils/basic_utils.dart';
import 'package:pointycastle/export.dart' as pc;
import 'package:pointycastle/asn1.dart';

import 'ec_crypto_helper.dart';

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
          return EcCryptoHelper.ecPublicKeyFromSpkiWithExplicitParams(spkiBytes);
        }
        throw Exception("Failed to parse public key from SPKI: $e");
      }
    }

    throw Exception('Unsupported public key OID: $oid');
  }
}
