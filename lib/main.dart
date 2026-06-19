import 'package:flutter/material.dart';
import 'mrz_scanner.dart';
import 'mrz_result.dart';

void main() {
  runApp(const PassportReaderApp());
}

class PassportReaderApp extends StatelessWidget {
  const PassportReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Passport Reader',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AuthenticationScreen(),
    );
  }
}

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  MrzResult? _mrzData;

  void _startNfcReading() {
    // This is where dmrtd NFC session establishment would go.
    // Example:
    // final String docNum = _mrzData!.documentNumber;
    // final String dob = _mrzData!.dateOfBirth;
    // final String doe = _mrzData!.dateOfExpiry;
    // await establishSecureSession(docNum, dob, doe);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('NFC Reading'),
        content: Text('Starting BAC/PACE session with:\n\n'
            'DocNum: ${_mrzData!.documentNumber}\n'
            'DOB: ${_mrzData!.dateOfBirth}\n'
            'DOE: ${_mrzData!.dateOfExpiry}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  void _showManualEntryDialog() {
    final docNumController = TextEditingController();
    final dobController = TextEditingController();
    final doeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manual Entry'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: docNumController, decoration: const InputDecoration(labelText: 'Document Number')),
            TextField(controller: dobController, decoration: const InputDecoration(labelText: 'Date of Birth (YYMMDD)')),
            TextField(controller: doeController, decoration: const InputDecoration(labelText: 'Date of Expiry (YYMMDD)')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _mrzData = MrzResult(
                  format: MrzFormat.td3,
                  documentCode: 'P',
                  issuingState: '',
                  surname: '',
                  givenNames: '',
                  documentNumber: docNumController.text,
                  nationality: '',
                  dateOfBirth: dobController.text,
                  sex: '',
                  dateOfExpiry: doeController.text,
                  isCompositeValid: false,
                  rawLines: [],
                );
              });
            },
            child: const Text('Submit'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ePassport Authentication')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_mrzData != null) ...[
                const Icon(Icons.check_circle, color: Colors.green, size: 64),
                const SizedBox(height: 16),
                const Text('MRZ Data Extracted', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildMrzDetails(_mrzData!),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _startNfcReading,
                  icon: const Icon(Icons.nfc),
                  label: const Text('Read Passport via NFC'),
                ),
                const SizedBox(height: 16),
              ],
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MrzScannerScreen(
                        onParsed: (data) {
                          Navigator.pop(context);
                          setState(() {
                            _mrzData = data;
                          });
                        },
                        onManualEntry: () {
                          Navigator.pop(context);
                          _showManualEntryDialog();
                        },
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.camera_alt),
                label: Text(_mrzData == null ? 'Scan MRZ' : 'Rescan MRZ'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a card displaying all extracted MRZ fields.
  Widget _buildMrzDetails(MrzResult mrz) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Format badge + composite status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    mrz.formatLabel,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                Icon(
                  mrz.isCompositeValid ? Icons.verified : Icons.warning,
                  color: mrz.isCompositeValid ? Colors.green : Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  mrz.isCompositeValid ? 'Valid' : 'Check failed',
                  style: TextStyle(
                    color: mrz.isCompositeValid ? Colors.green : Colors.orange,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Common fields
            _fieldRow('Document Code', mrz.documentCode),
            _fieldRow('Issuing State', mrz.issuingState),
            _fieldRow('Surname', mrz.surname),
            _fieldRow('Given Names', mrz.givenNames),
            _fieldRow('Document Number', mrz.documentNumber),
            _fieldRow('Nationality', mrz.nationality),
            _fieldRow('Date of Birth', mrz.dateOfBirth),
            _fieldRow('Sex', mrz.sex),
            _fieldRow('Date of Expiry', mrz.dateOfExpiry),

            // Optional fields (only show if non-empty)
            if (mrz.personalNumber.isNotEmpty)
              _fieldRow('Personal Number', mrz.personalNumber),
            if (mrz.optionalData1.isNotEmpty)
              _fieldRow('Optional Data 1', mrz.optionalData1),
            if (mrz.optionalData2.isNotEmpty)
              _fieldRow('Optional Data 2', mrz.optionalData2),
          ],
        ),
      ),
    );
  }

  Widget _fieldRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
