import 'dart:typed_data';
import 'package:pointycastle/asn1.dart';

import '../../models/parsed_sod_data.dart';
import '../../models/parsed_dsc_data.dart';
import 'dsc_parser.dart';
class SODParser {
  /// Parses the raw bytes of EF.SOD
  static ParsedSODData parseSOD(Uint8List sodBytes) {
    var topLevel = ASN1Object.fromBytes(sodBytes);
    
    if (topLevel.tag != 0x77) {
      throw Exception("Invalid SOD: Expected tag 0x77, got ${topLevel.tag}");
    }
    
    var innerParser = ASN1Parser(topLevel.valueBytes);
    var contentInfo = innerParser.nextObject() as ASN1Sequence;
    
    var contentTypeOid = (contentInfo.elements![0] as ASN1ObjectIdentifier).objectIdentifierAsString;
    if (contentTypeOid != '1.2.840.113549.1.7.2') {
      throw Exception("Invalid SOD: Expected SignedData OID, got $contentTypeOid");
    }
    
    var signedDataWrapper = contentInfo.elements![1]; 
    var sdParser = ASN1Parser(signedDataWrapper.valueBytes);
    var signedData = sdParser.nextObject() as ASN1Sequence;
    
    var encapContentInfo = signedData.elements![2] as ASN1Sequence;
    var eContentWrapper = encapContentInfo.elements![1];
    var eContentParser = ASN1Parser(eContentWrapper.valueBytes);
    var eContentOctetString = eContentParser.nextObject() as ASN1OctetString;
    var eContentOctets = eContentOctetString.octets!;
    
    var ldsParser = ASN1Parser(eContentOctets);
    var ldsSecurityObject = ldsParser.nextObject() as ASN1Sequence;
    
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
    
    Uint8List? dsCertificate;
    Uint8List? signature;
    Uint8List? signedDataBytes;
    String? signatureAlgorithmOid;
    
    for (int i = 3; i < signedData.elements!.length; i++) {
      var element = signedData.elements![i];
      if (element.tag == 0xA0) {
        var certSetParser = ASN1Parser(element.valueBytes);
        int certCount = 0;
        while (certSetParser.hasNext()) {
           var cert = certSetParser.nextObject();
           if (certCount == 0) dsCertificate = cert.encode();
           certCount++;
        }
      } else if (element.tag == 0x31) { 
        var signerInfos = element as ASN1Set;
        if (signerInfos.elements!.isNotEmpty) {
          var signerInfo = signerInfos.elements![0] as ASN1Sequence;
          
          for (var siElement in signerInfo.elements!) {
             if (siElement.tag == 0xA0) {
                var rawBytes = siElement.encodedBytes;
                if (rawBytes != null) {
                  var totalLength = siElement.totalEncodedByteLength;
                  var copyBytes = Uint8List.fromList(rawBytes.sublist(0, totalLength));
                  copyBytes[0] = 0x31; 
                  signedDataBytes = copyBytes;
                } else {
                  var signedAttrsBytes = siElement.encode();
                  signedAttrsBytes[0] = 0x31; 
                  signedDataBytes = signedAttrsBytes;
                }
             } else if (siElement is ASN1OctetString) {
                signature = siElement.octets;
             }
          }
          
          signedDataBytes ??= eContentOctets;
          
          int sigIndex = signerInfo.elements!.indexWhere((e) => e is ASN1OctetString);
          if (sigIndex > 0) {
            var sigAlgSeq = signerInfo.elements![sigIndex - 1] as ASN1Sequence;
            signatureAlgorithmOid = (sigAlgSeq.elements![0] as ASN1ObjectIdentifier).objectIdentifierAsString;
          }
        }
      }
    }
    
    ParsedDSCData? parsedDSCData;
    if (dsCertificate != null) {
      try {
        parsedDSCData = DSCParser.parse(dsCertificate);
      } catch (e) {
        // Handle parsing error if needed
      }
    }

    return ParsedSODData(
      dgHashes: dgHashes,
      hashAlgorithmOid: hashAlgOid,
      signature: signature,
      parsedDSCData: parsedDSCData,
      signedDataBytes: signedDataBytes,
      signatureAlgorithmOid: signatureAlgorithmOid,
    );
  }
}
