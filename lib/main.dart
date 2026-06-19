import 'package:flutter/material.dart';
import 'mrz_scanner.dart';

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
  Map<String, String>? _mrzData;

  void _startNfcReading() {
    // This is where dmrtd NFC session establishment would go.
    // Example:
    // final String docNum = _mrzData!['documentNumber']!;
    // final String dob = _mrzData!['dateOfBirth']!;
    // final String doe = _mrzData!['dateOfExpiry']!;
    // await establishSecureSession(docNum, dob, doe);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('NFC Reading'),
        content: Text('Starting BAC/PACE session with:\n\n'
            'DocNum: ${_mrzData!['documentNumber']}\n'
            'DOB: ${_mrzData!['dateOfBirth']}\n'
            'DOE: ${_mrzData!['dateOfExpiry']}'),
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
                _mrzData = {
                  'documentNumber': docNumController.text,
                  'dateOfBirth': dobController.text,
                  'dateOfExpiry': doeController.text,
                };
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_mrzData != null) ...[
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 16),
              const Text('MRZ Data Extracted', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text('Document: ${_mrzData!['documentNumber']}'),
              Text('DOB: ${_mrzData!['dateOfBirth']}'),
              Text('Expiry: ${_mrzData!['dateOfExpiry']}'),
              const SizedBox(height: 32),
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
    );
  }
}
