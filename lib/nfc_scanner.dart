import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dmrtd/dmrtd.dart';
import 'mrz_result.dart';
import 'utils/image_decoder.dart';
import 'utils/passive_auth_parser.dart';
import 'utils/passive_authenticator.dart';
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
  PassiveAuthVerificationResult? _paResult;

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
        // If the physical connection was lost, don't even try BAC.
        if (e.toString().contains('Tag was lost') || e.toString().contains('TagLostException')) {
          throw Exception('NFC connection lost. Please hold the phone steadily against the passport and try again.');
        }
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
      
      PassiveAuthVerificationResult? paVerification;
      try {
        final parsedSod = PassiveAuthenticationParser.parseSOD(sod.toBytes());
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
      
      setState(() {
        _statusMessage = 'Done!';
        _progress = 1.0;
        _isScanning = false;
        
        // Save the extracted data to our state so the UI updates
        _faceImage = extractedImage;
        _dg1 = dg1;
        _dg2 = dg2;
        _paResult = paVerification;
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
    if (!_isScanning && _progress == 1.0) {
      return Scaffold(
        appBar: AppBar(title: const Text('Verified Passport Data')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPassportCard(),
              const SizedBox(height: 24),
              _buildDataMatchVerification(),
              const SizedBox(height: 24),
              _buildChipTechnicalDetails(),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Done', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      );
    }

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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPassportCard() {
    final mrz = widget.mrzResult;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.public, color: Colors.blue, size: 32),
                Text(
                  'ePASSPORT',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: Colors.blue.shade900,
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Face Image
                Container(
                  width: 120,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _faceImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(_faceImage!, fit: BoxFit.cover),
                        )
                      : const Center(child: Icon(Icons.person, size: 64, color: Colors.grey)),
                ),
                const SizedBox(width: 16),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('SURNAME'),
                      _buildFieldValue(mrz.surname),
                      const SizedBox(height: 8),
                      _buildFieldLabel('GIVEN NAMES'),
                      _buildFieldValue(mrz.givenNames),
                      const SizedBox(height: 8),
                      _buildFieldLabel('NATIONALITY'),
                      _buildFieldValue(mrz.nationality),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFieldLabel('DATE OF BIRTH'),
                                _buildFieldValue(_dg1?.mrz.dateOfBirth != null ? _formatDateYymmdd(_dg1!.mrz.dateOfBirth) : mrz.dateOfBirth),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFieldLabel('SEX'),
                                _buildFieldValue(mrz.sex),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFieldLabel('DOCUMENT NO.'),
                                _buildFieldValue(_dg1?.mrz.documentNumber ?? mrz.documentNumber),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFieldLabel('DATE OF EXPIRY'),
                                _buildFieldValue(_dg1?.mrz.dateOfExpiry != null ? _formatDateYymmdd(_dg1!.mrz.dateOfExpiry) : mrz.dateOfExpiry),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateYymmdd(DateTime? date) {
    if (date == null) return "";
    final yy = (date.year % 100).toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '$yy$mm$dd';
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade600,
      ),
    );
  }

  Widget _buildFieldValue(String value) {
    return Text(
      value,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildDataMatchVerification() {
    final ocr = widget.mrzResult;
    final nfc = _dg1?.mrz;

    final nfcDob = _formatDateYymmdd(nfc?.dateOfBirth);
    final nfcDoe = _formatDateYymmdd(nfc?.dateOfExpiry);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data Match Verification',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Comparing OCR camera data with verified NFC chip data.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const Divider(height: 24),
            _buildMatchRow('Document Code', ocr.documentCode, nfc?.documentCode),
            const Divider(),
            _buildMatchRow('Issuing State', ocr.issuingState, nfc?.country),
            const Divider(),
            _buildMatchRow('Document No.', ocr.documentNumber, nfc?.documentNumber),
            const Divider(),
            _buildMatchRow('Surname', ocr.surname, nfc?.lastName),
            const Divider(),
            _buildMatchRow('Given Names', ocr.givenNames, nfc?.firstName),
            const Divider(),
            _buildMatchRow('Nationality', ocr.nationality, nfc?.nationality),
            const Divider(),
            _buildMatchRow('Sex', ocr.sex, nfc?.gender),
            const Divider(),
            _buildMatchRow('Date of Birth', ocr.dateOfBirth, nfcDob.isNotEmpty ? nfcDob : null),
            const Divider(),
            _buildMatchRow('Date of Expiry', ocr.dateOfExpiry, nfcDoe.isNotEmpty ? nfcDoe : null),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchRow(String field, String ocrValue, String? nfcValue) {
    final isMatch = ocrValue == nfcValue;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(field, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('OCR: $ocrValue', style: const TextStyle(fontSize: 12)),
                Text('NFC: ${nfcValue ?? "N/A"}', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          Icon(
            isMatch ? Icons.check_circle : Icons.error,
            color: isMatch ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildChipTechnicalDetails() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chip Technical Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.face, color: Colors.blue),
              title: const Text('DG2 (Biometrics)'),
              subtitle: _dg2 != null
                  ? Text('Image: ${_dg2!.imageWidth}x${_dg2!.imageHeight}\nGender: ${_dg2!.gender}, Eye Color: ${_dg2!.eyeColor}')
                  : const Text('Not available'),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                _paResult?.isDataIntegrityVerified == true ? Icons.verified_user : Icons.warning,
                color: _paResult?.isDataIntegrityVerified == true ? Colors.green : Colors.orange,
              ),
              title: const Text('Passive Authentication'),
              subtitle: _paResult != null
                  ? Text('Data Integrity: ${_paResult!.isDataIntegrityVerified ? "Verified (Hashes Match)" : "Unverified/Tampered"}\nSignature: ${_paResult!.isSignatureVerified ? "Verified" : "Unverified (X.509 stub)"}')
                  : const Text('Not available'),
            ),
          ],
        ),
      ),
    );
  }
}
