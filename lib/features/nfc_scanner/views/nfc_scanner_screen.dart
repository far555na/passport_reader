import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_models/nfc_scanner_view_model.dart';
import '../../mrz_scanner/view_models/mrz_state_view_model.dart';
import '../widgets/passport_details_card.dart';
import '../widgets/data_match_card.dart';
import '../widgets/chip_technical_details_card.dart';
import '../../face_match/views/face_match_screen.dart';

class NfcScannerScreen extends ConsumerStatefulWidget {
  const NfcScannerScreen({super.key});

  @override
  ConsumerState<NfcScannerScreen> createState() => _NfcScannerScreenState();
}

class _NfcScannerScreenState extends ConsumerState<NfcScannerScreen> {
  @override
  void initState() {
    super.initState();
    // Start scan on initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mrzResult = ref.read(mrzProvider);
      if (mrzResult != null) {
        ref.read(nfcScannerViewModelProvider.notifier).startScan(mrzResult);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: No MRZ data available')),
        );
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    // Reset provider state when leaving the screen if needed,
    // or you can leave the data cached if you want it to persist.
    // For now, we'll let it stay. If you want to reset:
    // ref.read(nfcScannerViewModelProvider.notifier).reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nfcState = ref.watch(nfcScannerViewModelProvider);
    final mrzResult = ref.read(mrzProvider);

    if (mrzResult == null) {
      return const Scaffold(
        body: Center(child: Text('Error: MRZ Data missing')),
      );
    }

    if (!nfcState.isScanning && nfcState.progress == 1.0) {
      return Scaffold(
        appBar: AppBar(title: const Text('Verified Passport Data')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PassportDetailsCard(
                mrzResult: mrzResult,
                faceImage: nfcState.faceImage,
                dg1: nfcState.dg1,
              ),
              const SizedBox(height: 24),
              DataMatchCard(mrzResult: mrzResult, dg1: nfcState.dg1),
              const SizedBox(height: 24),
              ChipTechnicalDetailsCard(
                dg2: nfcState.dg2,
                paResult: nfcState.paResult,
              ),
              const SizedBox(height: 32),
              if (nfcState.faceImage != null)
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FaceMatchScreen(
                          dg2Image: nfcState.faceImage!,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.face),
                  label: const Text(
                    'Match Face',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
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
                color: nfcState.isScanning ? Colors.blue : Colors.grey,
              ),
              const SizedBox(height: 32),
              Text(
                nfcState.statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),
              if (nfcState.isScanning)
                LinearProgressIndicator(value: nfcState.progress),
            ],
          ),
        ),
      ),
    );
  }
}
