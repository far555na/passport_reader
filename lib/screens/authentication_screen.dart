import 'package:flutter/material.dart';
import 'mrz_scanner.dart';
import 'nfc_scanner.dart';
import '../models/mrz_result.dart';
import '../widgets/mrz_details_card.dart';
import '../widgets/manual_entry_dialog.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  MrzResult? _mrzData;

  void _startNfcReading() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NfcScannerScreen(
          mrzResult: _mrzData!,
        ),
      ),
    );
  }

  void _showManualEntryDialog() {
    showDialog(
      context: context,
      builder: (context) => ManualEntryDialog(
        onSubmit: (mrzData) {
          setState(() {
            _mrzData = mrzData;
          });
        },
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
                MrzDetailsCard(mrz: _mrzData!),
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
}
