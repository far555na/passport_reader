import 'dart:typed_data';
import 'package:pointycastle/asn1.dart';

import '../models/parsed_sod_data.dart';
class PassiveAuthenticationParser {
  /// Parses the raw bytes of EF.SOD
  static ParsedSODData parseSOD(Uint8List sodBytes) {
    var topLevel = ASN1Object.fromBytes(sodBytes);
    
    // The top level should be an Application specific tag 0x77
    if (topLevel.tag != 0x77) {
      throw Exception("Invalid SOD: Expected tag 0x77, got ${topLevel.tag}");
    }
    
    // Inside 0x77 is usually a ContentInfo (Sequence)
    var innerParser = ASN1Parser(topLevel.valueBytes);
    var contentInfo = innerParser.nextObject() as ASN1Sequence;
    
    // ContentInfo = SEQUENCE { contentType ContentType, content [0] EXPLICIT ANY DEFINED BY contentType }
    // contentType should be id-signedData (1.2.840.113549.1.7.2)
    var contentTypeOid = (contentInfo.elements![0] as ASN1ObjectIdentifier).objectIdentifierAsString;
    if (contentTypeOid != '1.2.840.113549.1.7.2') {
      throw Exception("Invalid SOD: Expected SignedData OID, got $contentTypeOid");
    }
    
    // content [0] EXPLICIT SignedData
    var signedDataWrapper = contentInfo.elements![1]; 
    // SignedData is a Sequence inside the explicit [0] tag
    var sdParser = ASN1Parser(signedDataWrapper.valueBytes);
    var signedData = sdParser.nextObject() as ASN1Sequence;
    
    // SignedData ::= SEQUENCE {
    //   version CMSVersion,
    //   digestAlgorithms DigestAlgorithmIdentifiers,
    //   encapContentInfo EncapsulatedContentInfo,
    //   certificates [0] IMPLICIT CertificateSet OPTIONAL,
    //   crls [1] IMPLICIT RevocationInfoChoices OPTIONAL,
    //   signerInfos SignerInfos
    // }
    
    // Navigate SignedData
    var encapContentInfo = signedData.elements![2] as ASN1Sequence;
    // encapContentInfo ::= SEQUENCE { eContentType ContentType, eContent [0] EXPLICIT OCTET STRING OPTIONAL }
    var eContentWrapper = encapContentInfo.elements![1];
    var eContentParser = ASN1Parser(eContentWrapper.valueBytes);
    var eContentOctetString = eContentParser.nextObject() as ASN1OctetString;
    var eContentOctets = eContentOctetString.octets!;
    
    // The eContent contains the LDSSecurityObject
    var ldsParser = ASN1Parser(eContentOctets);
    var ldsSecurityObject = ldsParser.nextObject() as ASN1Sequence;
    
    // LDSSecurityObject ::= SEQUENCE {
    //   version LDSSecurityObjectVersion,
    //   hashAlgorithm DigestAlgorithmIdentifier,
    //   dataGroupHashValues SEQUENCE SIZE (2..MAX) OF DataGroupHash,
    //   ldsVersionInfo LDSVersionInfo OPTIONAL
    // }
    
    var hashAlgIdentifier = ldsSecurityObject.elements![1] as ASN1Sequence;
    var hashAlgOid = (hashAlgIdentifier.elements![0] as ASN1ObjectIdentifier).objectIdentifierAsString!;
    
    var dgHashValuesSeq = ldsSecurityObject.elements![2] as ASN1Sequence;
    Map<int, Uint8List> dgHashes = {};
    
    for (var dgHashObj in dgHashValuesSeq.elements!) {
      var dgHashSeq = dgHashObj as ASN1Sequence;
      var dgNumber = (dgHashSeq.elements![0] as ASN1Integer).integer!.toInt();
      var dgHashValue = (dgHashSeq.elements![1] as ASN1OctetString).octets!;
      dgHashes[dgNumber] = dgHashValue;
    }
    
    // Now extract Certificates and SignerInfos from SignedData
    Uint8List? dsCertificate;
    Uint8List? signature;
    
    for (int i = 3; i < signedData.elements!.length; i++) {
      var element = signedData.elements![i];
      if (element.tag == 0xA0) {
        // certificates [0] IMPLICIT CertificateSet
        // We will just grab the raw bytes of the first certificate.
        // It's a set of certificates, so we parse inside it.
        var certSetParser = ASN1Parser(element.valueBytes);
        if (certSetParser.hasNext()) {
           var cert = certSetParser.nextObject();
           // In PointyCastle, encode() on the raw parsed object usually reconstructs the ASN.1 properly
           // Or we can just capture the original bytes.
           // `cert` is an ASN1Sequence (the X509 certificate)
           dsCertificate = cert.encode();
        }
      } else if (element.tag == 0x31) { // SET, which is SignerInfos
        var signerInfos = element as ASN1Set;
        if (signerInfos.elements!.isNotEmpty) {
          var signerInfo = signerInfos.elements![0] as ASN1Sequence;
          for (var siElement in signerInfo.elements!) {
             if (siElement is ASN1OctetString) {
                signature = siElement.octets;
             }
          }
        }
      }
    }
    
    return ParsedSODData(
      dgHashes: dgHashes,
      hashAlgorithmOid: hashAlgOid,
      signature: signature,
      dsCertificate: dsCertificate,
    );
  }
}
