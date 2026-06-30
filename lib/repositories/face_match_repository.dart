import 'dart:io' as io;
import 'dart:typed_data';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../services/face_detector_service.dart';
import '../services/face_inference_service.dart';
import '../utils/image_preprocessor.dart';
import '../utils/face_match_utils.dart';

class FaceMatchResult {
  final bool isMatch;
  final double score;

  FaceMatchResult(this.isMatch, this.score);
}

class FaceMatchRepository {
  final FaceDetectorService _detector;
  final FaceInferenceService _inference;

  FaceMatchRepository(this._detector, this._inference);

  /// Initializes required ML models (like TFLite)
  Future<void> initialize() async {
    await _inference.initialize();
  }

  /// Compares DG2 bytes with a selfie from camera path
  Future<FaceMatchResult> compareFaces(Uint8List dg2Bytes, String selfiePath) async {
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
      throw Exception('Could not detect face in one or both images.');
    }

    // 3. Read image bytes for image package
    final selfieBytes = await io.File(selfiePath).readAsBytes();

    // 4. Preprocess images
    final dg2Tensor = ImagePreprocessor.preprocessImage(dg2Bytes, dg2Rect);
    final selfieTensor = ImagePreprocessor.preprocessImage(selfieBytes, selfieRect);

    // 5. Run inference
    final dg2Embedding = _inference.runInference(dg2Tensor);
    final selfieEmbedding = _inference.runInference(selfieTensor);

    // 6. Compare embeddings
    final distance = FaceMatchUtils.calculateEuclideanDistance(dg2Embedding, selfieEmbedding);
    
    // Threshold for MobileFaceNet (usually < 1.0 for Euclidean)
    final bool isMatch = distance < 1.0;

    return FaceMatchResult(isMatch, distance);
  }
}
