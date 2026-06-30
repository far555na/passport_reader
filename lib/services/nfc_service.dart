import 'package:dmrtd/dmrtd.dart';

class NfcService {
  final NfcProvider _nfcProvider = NfcProvider();

  /// Checks NFC availability and connects to the passport.
  Future<Passport> connect({
    required Function(String status, double progress) onProgress,
  }) async {
    onProgress('Connecting to passport...', 0.1);
    
    var status = await NfcProvider.nfcStatus;
    if (status != NfcStatus.enabled) {
      throw Exception('NFC is not available on this device.');
    }

    await _nfcProvider.connect(
      timeout: const Duration(seconds: 10),
      iosAlertMessage: "Hold your iPhone near the passport.",
    );

    return Passport(_nfcProvider);
  }

  /// Disconnects the NFC session.
  Future<void> disconnect({bool hasError = false}) async {
    if (hasError) {
      await _nfcProvider.disconnect();
    } else {
      await _nfcProvider.disconnect(iosAlertMessage: "Done!");
    }
  }
}
