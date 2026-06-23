import 'package:flutter/foundation.dart';
import 'package:dmrtd/dmrtd.dart';
import '../models/mrz_result.dart';
import '../utils/image_decoder.dart';
import 'sod_parser.dart';
import 'passive_authenticator.dart';
import '../models/passive_auth_verification_result.dart';

class PassportNfcData {
  final EfDG1? dg1;
  final EfDG2? dg2;
  final Uint8List? faceImage;
  final PassiveAuthVerificationResult? paResult;

  PassportNfcData({
    this.dg1,
    this.dg2,
    this.faceImage,
    this.paResult,
  });
}

class NfcService {
  Future<PassportNfcData> scanPassport({
    required MrzResult mrzResult,
    required Function(String status, double progress) onProgress,
  }) async {
    onProgress('Connecting to passport...', 0.1);
    final nfcProvider = NfcProvider();

    bool hasError = false;

    try {
      // 1. Start NFC session
      var status = await NfcProvider.nfcStatus;
      if (status != NfcStatus.enabled) {
        throw Exception('NFC is not available on this device.');
      }

      await nfcProvider.connect(
        timeout: const Duration(seconds: 10),
        iosAlertMessage: "Hold your iPhone near the passport.",
      );

      onProgress('Authenticating (BAC/PACE)...', 0.3);

      // 2. Initialize Passport and Authenticate
      final docNum = mrzResult.documentNumber;
      final dob = mrzResult.dateOfBirth; // e.g. "900101"
      final doe = mrzResult.dateOfExpiry; // e.g. "300101"
      
      final passport = Passport(nfcProvider);
      
      DateTime parseDate(String yymmdd, {bool isExpiry = false}) {
        final yy = int.parse(yymmdd.substring(0, 2));
        final mm = int.parse(yymmdd.substring(2, 4));
        final dd = int.parse(yymmdd.substring(4, 6));
        
        final currentYear = DateTime.now().year;
        final currentTwoDigitYear = currentYear % 100;
        
        int prefix;
        if (isExpiry) {
          prefix = 2000;
        } else {
          prefix = yy > currentTwoDigitYear ? 1900 : 2000;
        }
        
        return DateTime(prefix + yy, mm, dd);
      }
      
      final bacKey = DBAKey(docNum, parseDate(dob), parseDate(doe, isExpiry: true));
      final paceKey = DBAKey(docNum, parseDate(dob), parseDate(doe, isExpiry: true), paceMode: true);

      try {
        final efCardAccess = await passport.readEfCardAccess();
        await passport.startSessionPACE(paceKey, efCardAccess);
      } catch (e) {
        if (e.toString().contains('Tag was lost') || e.toString().contains('TagLostException')) {
          throw Exception('NFC connection lost. Please hold the phone steadily against the passport and try again.');
        }
        await passport.startSession(bacKey);
      }
      
      onProgress('Reading Data...', 0.6);

      // 3. Read DG1, DG2, SOD
      final dg1 = await passport.readEfDG1();
      final dg2 = await passport.readEfDG2();
      final sod = await passport.readEfSOD();
      
      PassiveAuthVerificationResult? paVerification;
      try {
        final parsedSod = SODParser.parseSOD(sod.toBytes());
        Map<int, Uint8List> dataGroups = {
          1: dg1.toBytes(),
          2: dg2.toBytes(),
        };
        paVerification = PassiveAuthenticator.verify(parsedSod, dataGroups);
        
        paVerification.dgVerification.forEach((dg, result) {
          debugPrint('DG$dg Verification: ${result.isVerified} - ${result.message}');
        });
      } catch (e) {
        debugPrint('Passive Authentication Error: $e');
      }
      
      // Extract the face image bytes from DG2
      Uint8List? extractedImage = dg2.imageData;
      
      if (extractedImage != null) {
        extractedImage = await ImageDecoder.decodeImage(extractedImage);
      }
      
      onProgress('Done!', 1.0);
      
      return PassportNfcData(
        dg1: dg1,
        dg2: dg2,
        faceImage: extractedImage,
        paResult: paVerification,
      );
    } catch (e) {
      hasError = true;
      rethrow;
    } finally {
      if (hasError) {
        await nfcProvider.disconnect();
      } else {
        await nfcProvider.disconnect(iosAlertMessage: "Done!");
      }
    }
  }
}
