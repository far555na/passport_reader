import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dmrtd/dmrtd.dart';
import 'mrz_result.dart';

class NfcScannerScreen extends StatefulWidget {
  final MrzResult mrzResult;

  const NfcScannerScreen({super.key, required this.mrzResult});

  @override
  State<NfcScannerScreen> createState() => _NfcScannerScreenState();
}

class _NfcScannerScreenState extends State<NfcScannerScreen> {
  String _statusMessage = 'Hold your phone against the passport chip.';
  double _progress = 0.0;
  bool _isScanning = false;
  
  Uint8List? _faceImage;
  EfDG1? _dg1;
  EfDG2? _dg2;
  EfSOD? _sod;

  @override
  void initState() {
    super.initState();
    _startNfcScan();
  }

  Future<void> _startNfcScan() async {
    setState(() {
      _isScanning = true;
      _statusMessage = 'Connecting to passport...';
      _progress = 0.1;
    });

    final nfcProvider = NfcProvider();

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

      setState(() {
        _statusMessage = 'Authenticating (BAC/PACE)...';
        _progress = 0.3;
      });

      // 2. Initialize Passport and Authenticate
      final mrz = widget.mrzResult;
      
      // Formatting MRZ dates for BAC (YYMMDD)
      // Note: Assuming MrzResult provides these as strings or we format them.
      // We will use standard strings for now.
      final docNum = mrz.documentNumber;
      final dob = mrz.dateOfBirth; // e.g. "900101"
      final doe = mrz.dateOfExpiry; // e.g. "300101"
      
      setState(() {
        _statusMessage = 'Authenticating (BAC/PACE)...';
        _progress = 0.3;
      });

      // Instantiate the passport object with our NFC wrapper
      final passport = Passport(nfcProvider);
      
      // Attempt BAC Authentication
      
      // Parse YYMMDD strings to DateTime for DBAKey
      DateTime parseDate(String yymmdd, {bool isExpiry = false}) {
        final yy = int.parse(yymmdd.substring(0, 2));
        final mm = int.parse(yymmdd.substring(2, 4));
        final dd = int.parse(yymmdd.substring(4, 6));
        
        final currentYear = DateTime.now().year;
        final currentTwoDigitYear = currentYear % 100;
        
        int prefix;
        if (isExpiry) {
          // Expiry dates are in the future or recent past. For current passports, it's always 20xx.
          prefix = 2000;
        } else {
          // Date of Birth: If the 2-digit year is greater than the current 2-digit year, 
          // it means they were born in the previous century (19xx).
          // Example: In 2024 (24), if yy = 25, it means 1925. If yy = 20, it means 2020.
          prefix = yy > currentTwoDigitYear ? 1900 : 2000;
        }
        
        return DateTime(prefix + yy, mm, dd);
      }
      
      final bacKey = DBAKey(docNum, parseDate(dob), parseDate(doe, isExpiry: true));
      final paceKey = DBAKey(docNum, parseDate(dob), parseDate(doe, isExpiry: true), paceMode: true);

      try {
        // 1. Try PACE first
        // PACE requires reading the EF.CardAccess file unencrypted to get supported algorithms
        final efCardAccess = await passport.readEfCardAccess();
        await passport.startSessionPACE(paceKey, efCardAccess);
      } catch (e) {
        // 2. Fallback to BAC if PACE fails or EF.CardAccess is not found
        await passport.startSession(bacKey);
      }
      
      setState(() {
        _statusMessage = 'Reading Data...';
        _progress = 0.6;
      });

      // 3. Read DG1, DG2, SOD
      final dg1 = await passport.readEfDG1();
      final dg2 = await passport.readEfDG2();
      final sod = await passport.readEfSOD();
      
      // Extract the face image bytes from DG2
      Uint8List? extractedImage = dg2.imageData;
      
      setState(() {
        _statusMessage = 'Done!';
        _progress = 1.0;
        _isScanning = false;
        
        // Save the extracted data to our state so the UI updates
        _faceImage = extractedImage;
        _dg1 = dg1;
        _dg2 = dg2;
        _sod = sod;
      });

    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
        _isScanning = false;
        _progress = 0.0;
      });
    } finally {
      if (_isScanning) {
        await nfcProvider.disconnect();
      } else {
        await nfcProvider.disconnect(iosAlertMessage: "Done!");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NFC Passport Scan')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.nfc,
                size: 100,
                color: _isScanning ? Colors.blue : Colors.grey,
              ),
              const SizedBox(height: 32),
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),
              if (_isScanning)
                LinearProgressIndicator(value: _progress),
              if (!_isScanning && _progress == 1.0) ...[
                const Icon(Icons.check_circle, color: Colors.green, size: 64),
                const SizedBox(height: 16),
                const Text('Passport Read Successfully!', style: TextStyle(fontWeight: FontWeight.bold)),
                if (_faceImage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Image.memory(_faceImage!, height: 200),
                  ),
                const SizedBox(height: 16),
                if (_dg1 != null) ...[
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.badge),
                    title: const Text('DG1 (MRZ Data)'),
                    subtitle: Text('Doc No: ${_dg1!.mrz.documentNumber}\nDOB: ${_dg1!.mrz.dateOfBirth}, DOE: ${_dg1!.mrz.dateOfExpiry}'),
                  ),
                ],
                if (_dg2 != null)
                  ListTile(
                    leading: const Icon(Icons.face),
                    title: const Text('DG2 (Biometric Data)'),
                    subtitle: Text('Facial Image: ${_dg2!.imageWidth}x${_dg2!.imageHeight}\nGender: ${_dg2!.gender}, Eye Color: ${_dg2!.eyeColor}'),
                  ),
                if (_sod != null)
                  ListTile(
                    leading: const Icon(Icons.security),
                    title: const Text('SOD (Security Object Document)'),
                    subtitle: Text('Read successfully (${_sod!.toBytes().length} bytes)'),
                  ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
