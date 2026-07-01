import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ocr_service.g.dart';

@Riverpod(keepAlive: true)
OcrService ocrService(Ref ref) {
  final service = OcrService();
  ref.onDispose(() => service.dispose());
  return service;
}

class OcrService {
  final TextRecognizer _textRecognizer;

  OcrService() : _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  /// Processes an [InputImage] and returns the recognized text.
  Future<String> processImage(InputImage inputImage) async {
    final recognizedText = await _textRecognizer.processImage(inputImage);
    return recognizedText.text;
  }

  /// Closes the underlying text recognizer to release resources.
  void dispose() {
    _textRecognizer.close();
  }
}
