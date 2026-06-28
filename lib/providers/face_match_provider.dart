import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../services/face_detector_service.dart';
import '../services/face_inference_service.dart';
import '../services/face_match_service.dart';
import '../utils/image_preprocessor.dart';

class FaceMatchState {
  final bool isLoading;
  final bool? isMatch;
  final double? score;
  final String? error;

  FaceMatchState({
    this.isLoading = false,
    this.isMatch,
    this.score,
    this.error,
  });

  FaceMatchState copyWith({
    bool? isLoading,
    bool? isMatch,
    double? score,
    String? error,
  }) {
    return FaceMatchState(
      isLoading: isLoading ?? this.isLoading,
      isMatch: isMatch ?? this.isMatch,
      score: score ?? this.score,
      error: error ?? this.error,
    );
  }
}

class FaceMatchNotifier extends Notifier<FaceMatchState> {
  late final FaceDetectorService _detector;
  late final FaceInferenceService _inference;

  @override
  FaceMatchState build() {
    _detector = ref.watch(faceDetectorProvider);
    _inference = ref.watch(faceInferenceProvider);
    _initInference();
    return FaceMatchState();
  }

  Future<void> _initInference() async {
    try {
      await _inference.initialize();
    } catch (e) {
      state = state.copyWith(error: 'Failed to initialize face matching model.');
    }
  }

  /// Compares DG2 bytes with a selfie from camera path
  Future<void> compareFaces(Uint8List dg2Bytes, String selfiePath) async {
    state = FaceMatchState(isLoading: true);

    try {
      // 1. Write DG2 bytes to a temp file for ML Kit
      final tempDir = await io.Directory.systemTemp.createTemp('face_match');
      final dg2File = io.File('${tempDir.path}/dg2.jpg');
      await dg2File.writeAsBytes(dg2Bytes);

      // 2. Create InputImage for ML Kit
      final dg2Input = InputImage.fromFilePath(dg2File.path);
      final selfieInput = InputImage.fromFilePath(selfiePath);

      // 2. Detect Faces
      final dg2Rect = await _detector.detectFace(dg2Input);
      final selfieRect = await _detector.detectFace(selfieInput);

      if (dg2Rect == null || selfieRect == null) {
        state = state.copyWith(isLoading: false, error: 'Could not detect face in one or both images.');
        return;
      }

      // 3. Read image bytes for image package
      final selfieBytes = await _readFileBytes(selfiePath);

      // 4. Preprocess images
      final dg2Tensor = ImagePreprocessor.preprocessImage(dg2Bytes, dg2Rect);
      final selfieTensor = ImagePreprocessor.preprocessImage(selfieBytes, selfieRect);

      // 5. Run inference
      final dg2Embedding = _inference.runInference(dg2Tensor);
      final selfieEmbedding = _inference.runInference(selfieTensor);

      // 6. Compare embeddings
      final distance = FaceMatchService.calculateEuclideanDistance(dg2Embedding, selfieEmbedding);
      
      // Threshold for MobileFaceNet (usually < 1.0 for Euclidean)
      final bool isMatch = distance < 1.0;

      state = FaceMatchState(
        isLoading: false,
        isMatch: isMatch,
        score: distance,
      );

    } catch (e) {
      debugPrint(e.toString());
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
  
  Future<Uint8List> _readFileBytes(String path) async {
    return await io.File(path).readAsBytes();
  }
}

final faceDetectorProvider = Provider<FaceDetectorService>((ref) {
  final service = FaceDetectorService();
  ref.onDispose(() => service.dispose());
  return service;
});

final faceInferenceProvider = Provider<FaceInferenceService>((ref) {
  final service = FaceInferenceService();
  ref.onDispose(() => service.dispose());
  return service;
});

final faceMatchProvider = NotifierProvider<FaceMatchNotifier, FaceMatchState>(() {
  return FaceMatchNotifier();
});
