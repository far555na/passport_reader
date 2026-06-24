import 'dart:io';
import 'dart:convert';
import 'package:pointycastle/asn1.dart';
import 'package:basic_utils/basic_utils.dart';

void main() {
  print('Generating CSCA Index...');
  final mlFile = File('assets/ICAO_ML_20260609095649.ml');
  if (!mlFile.existsSync()) {
    print('Error: Could not find Master List file.');
    exit(1);
  }

  final bytes = mlFile.readAsBytesSync();
  final parser = ASN1Parser(bytes);
  final root = parser.nextObject() as ASN1Sequence;
  
  final signedDataWrapper = root.elements![1] as ASN1Object;
  final signedData = ASN1Parser(signedDataWrapper.valueBytes!).nextObject() as ASN1Sequence;
  
  final encapContentInfo = signedData.elements![2] as ASN1Sequence;
  final eContentWrapper = encapContentInfo.elements![1] as ASN1Object;
  final octetString = ASN1Parser(eContentWrapper.valueBytes!).nextObject() as ASN1OctetString;
  
  final cscaMasterListBytes = octetString.valueBytes!;
  final cscaParser = ASN1Parser(cscaMasterListBytes);
  final cscaMasterList = cscaParser.nextObject() as ASN1Sequence;
  
  final certList = cscaMasterList.elements![1] as ASN1Set;
  final int totalCerts = certList.elements!.length;
  print('Found $totalCerts certificates in Master List.');

  final Map<String, List<String>> cscaIndex = {};
  int successCount = 0;

  for (int i = 0; i < totalCerts; i++) {
    try {
      final certSeq = certList.elements![i] as ASN1Sequence;
      final certBase64 = base64Encode(certSeq.encode());
      final pem = '-----BEGIN CERTIFICATE-----\n${StringUtils.chunk(certBase64, 64).join('\n')}\n-----END CERTIFICATE-----';
      final x509 = X509Utils.x509CertificateFromPem(pem);
      
      if (x509.tbsCertificate?.subject != null) {
        final subjectStr = x509.tbsCertificate!.subject.toString();
        cscaIndex.putIfAbsent(subjectStr, () => []).add(certBase64);
        successCount++;
      }
    } catch (e) {
      print('Warning: Failed to process certificate $i - $e');
    }
  }

  print('Successfully processed $successCount certificates.');
  
  final jsonFile = File('assets/csca_index.json');
  jsonFile.writeAsStringSync(jsonEncode(cscaIndex));
  
  print('Saved index to assets/csca_index.json');
}
