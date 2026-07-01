import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'face_inference_service.g.dart';

@Riverpod(keepAlive: true)
FaceInferenceService faceInferenceService(Ref ref) {
  final service = FaceInferenceService();
  ref.onDispose(() => service.dispose());
  return service;
}

class FaceInferenceService {
  Interpreter? _interpreter;
  bool _isInitialized = false;

  /// Initializes the TFLite interpreter with the MobileFaceNet model.
  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      _interpreter = await Interpreter.fromAsset('assets/mobilefacenet.tflite');
      _isInitialized = true;
      debugPrint('MobileFaceNet model loaded successfully.');
    } catch (e) {
      debugPrint('Error loading model: $e');
      throw Exception('Failed to load MobileFaceNet model.');
    }
  }

  /// Runs inference on a normalized 112x112x3 Float32 tensor.
  /// Returns a 192-dimensional embedding vector.
  List<double> runInference(Float32List normalizedImage) {
    if (!_isInitialized || _interpreter == null) {
      throw Exception('FaceInferenceService not initialized. Call initialize() first.');
    }

    // Input shape: [1, 112, 112, 3]
    final input = normalizedImage.reshape([1, 112, 112, 3]);
    
    // Output shape: [1, 192]
    final output = List.generate(1, (_) => List<double>.filled(192, 0.0));

    try {
      _interpreter!.run(input, output);
      return output[0]; // Return the 192d vector for this image
    } catch (e) {
      debugPrint('Error during inference: $e');
      throw Exception('Failed to run face inference.');
    }
  }

  void dispose() {
    _interpreter?.close();
  }
}
