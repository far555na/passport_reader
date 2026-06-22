import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dmrtd/dmrtd.dart';
import '../models/mrz_result.dart';
import '../services/nfc_service.dart';
import '../services/passive_authenticator.dart';

class NfcState {
  final String statusMessage;
  final double progress;
  final bool isScanning;
  final Uint8List? faceImage;
  final EfDG1? dg1;
  final EfDG2? dg2;
  final PassiveAuthVerificationResult? paResult;

  NfcState({
    required this.statusMessage,
    required this.progress,
    required this.isScanning,
    this.faceImage,
    this.dg1,
    this.dg2,
    this.paResult,
  });

  NfcState copyWith({
    String? statusMessage,
    double? progress,
    bool? isScanning,
    Uint8List? faceImage,
    EfDG1? dg1,
    EfDG2? dg2,
    PassiveAuthVerificationResult? paResult,
  }) {
    return NfcState(
      statusMessage: statusMessage ?? this.statusMessage,
      progress: progress ?? this.progress,
      isScanning: isScanning ?? this.isScanning,
      faceImage: faceImage ?? this.faceImage,
      dg1: dg1 ?? this.dg1,
      dg2: dg2 ?? this.dg2,
      paResult: paResult ?? this.paResult,
    );
  }

  factory NfcState.initial() {
    return NfcState(
      statusMessage: 'Hold your phone against the passport chip.',
      progress: 0.0,
      isScanning: false,
    );
  }
}

class NfcNotifier extends Notifier<NfcState> {
  final NfcService _nfcService = NfcService();

  @override
  NfcState build() {
    return NfcState.initial();
  }

  Future<void> startScan(MrzResult mrzResult) async {
    state = state.copyWith(isScanning: true, progress: 0.0);

    try {
      final nfcData = await _nfcService.scanPassport(
        mrzResult: mrzResult,
        onProgress: (status, progress) {
          state = state.copyWith(statusMessage: status, progress: progress);
        },
      );
      
      state = state.copyWith(
        isScanning: false,
        faceImage: nfcData.faceImage,
        dg1: nfcData.dg1,
        dg2: nfcData.dg2,
        paResult: nfcData.paResult,
      );
    } catch (e) {
      state = state.copyWith(
        statusMessage: 'Error: $e',
        isScanning: false,
        progress: 0.0,
      );
    }
  }

  void reset() {
    state = NfcState.initial();
  }
}

final nfcProvider = NotifierProvider<NfcNotifier, NfcState>(() {
  return NfcNotifier();
});
