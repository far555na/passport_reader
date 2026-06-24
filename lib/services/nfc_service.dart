import 'package:dmrtd/dmrtd.dart';

import '../models/mrz_result.dart';
import '../models/csca_data.dart';
import '../models/nfc_result.dart';
import 'passport_reader_service.dart';

class NfcService {
  final PassportReaderService _readerService = PassportReaderService();

  Future<NfcResult> scanPassport({
    required MrzResult mrzResult,
    required CscaData cscaData,
    required Function(String status, double progress) onProgress,
  }) async {
    onProgress('Connecting to passport...', 0.1);
    final nfcProvider = NfcProvider();

    bool hasError = false;

    try {
      // 1. Check NFC Status
      var status = await NfcProvider.nfcStatus;
      if (status != NfcStatus.enabled) {
        throw Exception('NFC is not available on this device.');
      }

      // 2. Connect to NFC Hardware
      await nfcProvider.connect(
        timeout: const Duration(seconds: 10),
        iosAlertMessage: "Hold your iPhone near the passport.",
      );

      final passport = Passport(nfcProvider);

      // 3. Delegate Passport Reading to Reader Service
      return await _readerService.readPassport(
        passport: passport,
        mrzResult: mrzResult,
        cscaData: cscaData,
        onProgress: onProgress,
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
