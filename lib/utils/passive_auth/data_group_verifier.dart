import 'dart:typed_data';
import 'package:pointycastle/export.dart';
import 'package:collection/collection.dart';

import '../../models/verification_result.dart';
import '../../models/parsed_sod_data.dart';
import '../../models/data_groups.dart';
import '../../utils/oid_mapper.dart';

class DataGroupVerifier {
  /// Verifies the integrity of the Data Groups against the hashes in the SOD.
  static Map<int, VerificationResult> verifyHashes(
      ParsedSODData parsedSOD, DataGroups dataGroups) {
    Map<int, VerificationResult> dgVerifications = {};

    String? digestName = OidMapper.mapOidToDigestName(parsedSOD.hashAlgorithmOid);
    if (digestName == null) {
      // If we don't support the hash algorithm, we can't verify any DG
      for (var entry in dataGroups.entries) {
        dgVerifications[entry.key] = VerificationResult(
            false, 'Unsupported hash algorithm OID: ${parsedSOD.hashAlgorithmOid}');
      }
      return dgVerifications;
    }

    Digest digest;
    try {
      digest = Digest(digestName);
    } catch (e) {
      for (var entry in dataGroups.entries) {
        dgVerifications[entry.key] = VerificationResult(
            false, 'Failed to initialize digest: $digestName');
      }
      return dgVerifications;
    }

    // Verify each provided DG
    for (var entry in dataGroups.entries) {
      int dgNum = entry.key;
      Uint8List dgData = entry.value;

      if (!parsedSOD.dgHashes.containsKey(dgNum)) {
        dgVerifications[dgNum] =
            VerificationResult(false, 'DG$dgNum not found in SOD');
        continue;
      }

      Uint8List expectedHash = parsedSOD.dgHashes[dgNum]!;
      digest.reset();
      Uint8List computedHash = digest.process(dgData);

      if (ListEquality().equals(computedHash, expectedHash)) {
        dgVerifications[dgNum] = VerificationResult(true, 'Hash matches');
      } else {
        dgVerifications[dgNum] = VerificationResult(false, 'Hash mismatch');
      }
    }

    return dgVerifications;
  }
}
