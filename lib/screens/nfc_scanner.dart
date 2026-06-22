import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dmrtd/dmrtd.dart';
import '../models/mrz_result.dart';
import '../services/nfc_service.dart';
import '../services/passive_authenticator.dart';
import '../widgets/passport_details_card.dart';
import '../widgets/data_match_card.dart';
import '../widgets/chip_technical_details_card.dart';

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
  final NfcService _nfcService = NfcService();

  @override
  void initState() {
    super.initState();
    _startNfcScan();
  }

  Future<void> _startNfcScan() async {
    setState(() {
      _isScanning = true;
    });

    try {
      final nfcData = await _nfcService.scanPassport(
        mrzResult: widget.mrzResult,
        onProgress: (status, progress) {
          setState(() {
            _statusMessage = status;
            _progress = progress;
          });
        },
      );
      
      setState(() {
        _isScanning = false;
        _faceImage = nfcData.faceImage;
        _dg1 = nfcData.dg1;
        _dg2 = nfcData.dg2;
        _paResult = nfcData.paResult;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
        _isScanning = false;
        _progress = 0.0;
      });
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
              PassportDetailsCard(
                mrzResult: widget.mrzResult,
                faceImage: _faceImage,
                dg1: _dg1,
              ),
              const SizedBox(height: 24),
              DataMatchCard(
                mrzResult: widget.mrzResult,
                dg1: _dg1,
              ),
              const SizedBox(height: 24),
              ChipTechnicalDetailsCard(
                dg2: _dg2,
                paResult: _paResult,
              ),
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
}
