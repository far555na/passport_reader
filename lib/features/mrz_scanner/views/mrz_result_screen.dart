import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'mrz_scanner_screen.dart';
import '../../nfc_scanner/views/nfc_scanner_screen.dart';

import '../widgets/mrz_details_card.dart';
import '../widgets/manual_entry_dialog.dart';
import '../view_models/mrz_state_view_model.dart';
import '../../../core/theme/app_theme.dart';

class MrzResultScreen extends ConsumerWidget {
  const MrzResultScreen({super.key});

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
      appBar: AppBar(
        title: const Text('MRZ Authentication', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: mrzData == null ? _buildEmptyState(context, ref) : _buildResultState(context, ref, mrzData),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.document_scanner_outlined, size: 80, color: AppTheme.primaryColor),
            ),
            const SizedBox(height: 32),
            const Text(
              'No Passport Scanned',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
            ),
            const SizedBox(height: 16),
            const Text(
              'Please scan the Machine Readable Zone (MRZ) of your passport to begin.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openScanner(context, ref),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Scan Passport MRZ'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultState(BuildContext context, WidgetRef ref, dynamic mrzData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.successColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: AppTheme.successColor, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'MRZ Extracted Successfully',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                      ),
                      Text(
                        'Please verify the details below.',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          MrzDetailsCard(mrz: mrzData),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _startNfcReading(context),
            icon: const Icon(Icons.nfc),
            label: const Text('Read Passport via NFC'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => _openScanner(context, ref),
            icon: const Icon(Icons.refresh),
            label: const Text('Rescan MRZ'),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _openScanner(BuildContext context, WidgetRef ref) {
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
  }
}
