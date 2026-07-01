import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/asn1.dart';
import 'package:basic_utils/basic_utils.dart';

import '../models/parsed_dsc_data.dart';
import 'oid_mapper.dart';

class DSCParser {
  /// Parses the raw bytes of the Document Signer Certificate (DSC)
  static ParsedDSCData parse(Uint8List dsCertificateBytes) {
    // 1. Extract Issuer using basic_utils
    final dsCertBase64 = base64Encode(dsCertificateBytes);
    final dsPem =
        '-----BEGIN CERTIFICATE-----\n${StringUtils.chunk(dsCertBase64, 64).join('\n')}\n-----END CERTIFICATE-----';
    final dsX509 = X509Utils.x509CertificateFromPem(dsPem);

    final issuerStr = dsX509.tbsCertificate?.issuer.toString() ?? '';

    // 2. Parse DS cert to ASN1 for signature verification later
    final parser = ASN1Parser(dsCertificateBytes);
    final certSeq = parser.nextObject() as ASN1Sequence;
    final tbsCertificate = certSeq.elements![0] as ASN1Sequence;

    // 3. Extract signature algorithm
    final dsSignatureAlg = certSeq.elements![1] as ASN1Sequence;
    final dsAlgOid = dsSignatureAlg.elements![0] as ASN1ObjectIdentifier;
    final algorithm = OidMapper.mapOidToSignatureAlgorithm(
      dsAlgOid.objectIdentifierAsString!,
    );

    // 4. Extract signature value and signed data bytes
    final dsSignatureValue = certSeq.elements![2] as ASN1BitString;
    final dsSignedDataBytes = tbsCertificate.encode();

    // Clean up signature bytes (remove unused bits byte if present in BIT STRING)
    var sigBytes = dsSignatureValue.valueBytes!;
    if (sigBytes.isNotEmpty && sigBytes[0] == 0) {
      sigBytes = sigBytes.sublist(1);
    }

    return ParsedDSCData(
      rawCertBytes: dsCertificateBytes,
      issuer: issuerStr,
      signatureAlgorithm: algorithm,
      signedDataBytes: dsSignedDataBytes,
      signatureBytes: sigBytes,
    );
  }
}
