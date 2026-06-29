import 'dart:io' as io;
import 'dart:math';
import 'dart:typed_data';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'face_detector_service.dart';
import 'face_inference_service.dart';
import '../../utils/image_preprocessor.dart';

class FaceMatchResult {
  final bool isMatch;
  final double score;

  FaceMatchResult(this.isMatch, this.score);
}

class FaceMatchService {
  final FaceDetectorService _detector;
  final FaceInferenceService _inference;

  FaceMatchService(this._detector, this._inference);

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
    final distance = calculateEuclideanDistance(dg2Embedding, selfieEmbedding);
    
    // Threshold for MobileFaceNet (usually < 1.0 for Euclidean)
    final bool isMatch = distance < 1.0;

    return FaceMatchResult(isMatch, distance);
  }

  /// Calculates the Euclidean distance between two embeddings (vectors).
  /// A common threshold for MobileFaceNet is < 1.0 for a match.
  static double calculateEuclideanDistance(List<double> embedding1, List<double> embedding2) {
    if (embedding1.length != embedding2.length) {
      throw Exception('Embeddings must have the same length');
    }
    double sum = 0.0;
    for (int i = 0; i < embedding1.length; i++) {
      double diff = embedding1[i] - embedding2[i];
      sum += diff * diff;
    }
    return sqrt(sum);
  }

  /// Calculates the Cosine Similarity between two embeddings.
  /// Result is between -1.0 and 1.0. Higher is more similar.
  /// A common threshold for MobileFaceNet is > 0.4 for a match.
  static double calculateCosineSimilarity(List<double> embedding1, List<double> embedding2) {
    if (embedding1.length != embedding2.length) {
      throw Exception('Embeddings must have the same length');
    }
    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;
    for (int i = 0; i < embedding1.length; i++) {
      dotProduct += embedding1[i] * embedding2[i];
      normA += embedding1[i] * embedding1[i];
      normB += embedding2[i] * embedding2[i];
    }
    
    if (normA == 0.0 || normB == 0.0) return 0.0;
    
    return dotProduct / (sqrt(normA) * sqrt(normB));
  }
}
