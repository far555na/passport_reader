import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/mrz_scanner/views/mrz_scanner_screen.dart';
import 'nfc_scanner.dart';

import '../features/mrz_scanner/widgets/mrz_details_card.dart';
import '../features/mrz_scanner/widgets/manual_entry_dialog.dart';
import '../features/mrz_scanner/view_models/mrz_state_view_model.dart';

class AuthenticationScreen extends ConsumerWidget {
  const AuthenticationScreen({super.key});

  void _startNfcReading(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NfcScannerScreen(),
      ),
    );
  }

  void _showManualEntryDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => ManualEntryDialog(
        onSubmit: (mrzData) {
          ref.read(mrzProvider.notifier).setMrz(mrzData);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mrzData = ref.watch(mrzProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('ePassport Authentication')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (mrzData != null) ...[
                const Icon(Icons.check_circle, color: Colors.green, size: 64),
                const SizedBox(height: 16),
                const Text('MRZ Data Extracted', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                MrzDetailsCard(mrz: mrzData),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _startNfcReading(context),
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
                          ref.read(mrzProvider.notifier).setMrz(data);
                        },
                        onManualEntry: () {
                          Navigator.pop(context);
                          _showManualEntryDialog(context, ref);
                        },
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.camera_alt),
                label: Text(mrzData == null ? 'Scan MRZ' : 'Rescan MRZ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
