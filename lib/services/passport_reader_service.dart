import 'dart:typed_data';
import 'package:dmrtd/dmrtd.dart';

import '../models/mrz_result.dart';
import '../models/csca_data.dart';
import '../models/data_groups.dart';
import '../models/nfc_result.dart';
import '../models/passive_auth_verification_result.dart';
import '../utils/image_decoder.dart';
import '../utils/mrz_format_utils.dart';
import 'passive_auth/sod_parser.dart';
import 'passive_auth/passive_authenticator.dart';

class PassportReaderService {
  /// Authenticates with the passport and reads the necessary data groups.
  Future<NfcResult> readPassport({
    required Passport passport,
    required MrzResult mrzResult,
    required CscaData cscaData,
    required Function(String status, double progress) onProgress,
  }) async {
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
      if (e.toString().contains('Tag was lost') ||
          e.toString().contains('TagLostException')) {
        throw Exception(
            'NFC connection lost. Please hold the phone steadily against the passport and try again.');
      }
      await passport.startSession(bacKey);
    }

    onProgress('Reading Data...', 0.6);

    // Read DG1, DG2, SOD
    final dg1 = await passport.readEfDG1();
    final dg2 = await passport.readEfDG2();
    final sod = await passport.readEfSOD();

    PassiveAuthVerificationResult? paVerification;
    try {
      final parsedSod = SODParser.parseSOD(sod.toBytes());
      var dataGroups = DataGroups({
        1: dg1.toBytes(),
        2: dg2.toBytes(),
      });
      paVerification =
          PassiveAuthenticator.verify(parsedSod, dataGroups, cscaData);
    } catch (e) {
      // Handle passive authentication error
    }

    // Extract the face image bytes from DG2
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
  }
}
