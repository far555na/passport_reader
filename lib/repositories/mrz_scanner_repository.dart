import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../models/mrz_result.dart';
import '../services/ocr_service.dart';
import '../utils/mrz_parser.dart';

// Provide the OcrService globally
final ocrServiceProvider = Provider<OcrService>((ref) {
  final service = OcrService();
  ref.onDispose(() => service.dispose());
  return service;
});

// Provide the MrzScannerRepository
final mrzScannerRepositoryProvider = Provider<MrzScannerRepository>((ref) {
  final ocrService = ref.watch(ocrServiceProvider);
  return MrzScannerRepository(ocrService);
});

class MrzScannerRepository {
  final OcrService _ocrService;

  MrzScannerRepository(this._ocrService);

  /// Processes an [InputImage] through OCR and attempts to parse an [MrzResult].
  Future<MrzResult?> processImage(InputImage inputImage) async {
    try {
      final recognizedText = await _ocrService.processImage(inputImage);
      return MrzParser.parse(recognizedText);
    } catch (e) {
      // If OCR fails or throws an exception, return null
      return null;
    }
  }
}
