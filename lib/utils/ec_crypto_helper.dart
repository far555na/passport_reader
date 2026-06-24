import 'dart:typed_data';
import 'package:pointycastle/export.dart' as pc;
import 'package:pointycastle/asn1.dart';

class EcCryptoHelper {
  /// Attempts to reconstruct an [ECPublicKey] from a SubjectPublicKeyInfo DER
  /// that uses explicit domain parameters (common in some ePassport DSCs).
  /// Extracts the public key point from the BIT STRING and tries a set of
  /// well-known ePassport curves: P-256, P-384, P-521, and brainpool variants.
  static pc.ECPublicKey ecPublicKeyFromSpkiWithExplicitParams(Uint8List spkiDer) {
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
}
