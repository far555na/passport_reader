import 'package:flutter/foundation.dart';
import 'package:dmrtd/dmrtd.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../mrz_scanner/models/mrz_result.dart';
import '../models/csca_data.dart';
import '../models/data_groups.dart';
import '../models/nfc_result.dart';
import '../models/passive_auth_verification_result.dart';
import '../../../core/utils/image_decoder.dart';
import '../../../core/utils/mrz_format_utils.dart';
import '../utils/sod_parser.dart';
import '../utils/passive_authenticator.dart';
import '../services/nfc_service.dart';

part 'nfc_scanner_repository.g.dart';

@Riverpod(keepAlive: true)
NfcScannerRepository nfcScannerRepository(Ref ref) {
  final nfcService = ref.watch(nfcServiceProvider);
  return NfcScannerRepository(nfcService);
}

class NfcScannerRepository {
  final NfcService _nfcService;

  NfcScannerRepository(this._nfcService);

  /// Orchestrates connecting to the NFC, authenticating, and reading data groups.
  Future<NfcResult> scanPassport({
    required MrzResult mrzResult,
    required Future<CscaData> cscaDataFuture,
    required Function(String status, double progress) onProgress,
  }) async {
    bool hasError = false;

    try {
      // 1. Connect to Hardware via Service
      final passport = await _nfcService.connect(onProgress: onProgress);

      // Give the passport chip a moment to harvest RF power and stabilize
      await Future.delayed(const Duration(milliseconds: 500));

      // 2. Perform BAC/PACE Authentication
      onProgress('Authenticating (BAC/PACE)...', 0.3);
      final docNum = mrzResult.documentNumber;
      final dob = mrzResult.dateOfBirth;
      final doe = mrzResult.dateOfExpiry;

      final bacKey = DBAKey(
          docNum, MrzFormatUtils.parseDate(dob), MrzFormatUtils.parseDate(doe, isExpiry: true));
      final paceKey = DBAKey(
          docNum, MrzFormatUtils.parseDate(dob), MrzFormatUtils.parseDate(doe, isExpiry: true),
          paceMode: true);

      try {
        final efCardAccess = await passport.readEfCardAccess();
        await passport.startSessionPACE(paceKey, efCardAccess);
      } catch (e) {
        final errorStr = e.toString();
        if (errorStr.contains('Tag was lost') ||
            errorStr.contains('TagLostException') ||
            errorStr.contains('Communication error')) {
          throw Exception(
              'NFC connection lost. Please hold the phone steadily against the passport and try again without moving.');
        }
        await passport.startSession(bacKey);
      }

      onProgress('Reading Data...', 0.6);

      // 3. Read Data Groups
      final dg1 = await passport.readEfDG1();
      final dg2 = await passport.readEfDG2();
      final sod = await passport.readEfSOD();

      // 4. Perform Passive Authentication (Domain Rules)
      PassiveAuthVerificationResult? paVerification;
      try {
        onProgress('Verifying Passport Authenticity...', 0.8);
        final cscaData = await cscaDataFuture;

        final parsedSod = SODParser.parseSOD(sod.toBytes());
        var dataGroups = DataGroups({
          1: dg1.toBytes(),
          2: dg2.toBytes(),
        });
        paVerification =
            PassiveAuthenticator.verify(parsedSod, dataGroups, cscaData);
      } catch (e) {
        // Silently ignore passive auth errors for now
      }

      // 5. Extract Image
      Uint8List? extractedImage = dg2.imageData;
      if (extractedImage != null) {
        extractedImage = await ImageDecoder.decodeImage(extractedImage);
      }

      onProgress('Done!', 1.0);

      return NfcResult(
        dg1: dg1,
        dg2: dg2,
        faceImage: extractedImage,
        paResult: paVerification,
      );
    } catch (e) {
      hasError = true;
      rethrow;
    } finally {
      // Clean up connection
      await _nfcService.disconnect(hasError: hasError);
    }
  }
}
