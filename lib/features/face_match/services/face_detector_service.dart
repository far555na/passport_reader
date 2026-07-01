import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'face_detector_service.g.dart';

@Riverpod(keepAlive: true)
FaceDetectorService faceDetectorService(Ref ref) {
  final service = FaceDetectorService();
  ref.onDispose(() => service.dispose());
  return service;
}

class FaceDetectorService {
  final FaceDetector _faceDetector;

  FaceDetectorService()
      : _faceDetector = FaceDetector(
          options: FaceDetectorOptions(
            enableContours: false,
            enableClassification: false,
            enableLandmarks: false,
            enableTracking: false,
            performanceMode: FaceDetectorMode.fast,
          ),
        );

  /// Detects the face bounding box in a given image.
  /// Works for both NV21 camera frames and static images like DG2 JPEGs.
  Future<Rect?> detectFace(InputImage inputImage) async {
    try {
      final List<Face> faces = await _faceDetector.processImage(inputImage);
      if (faces.isNotEmpty) {
        // Return the bounding box of the first detected face
        return faces.first.boundingBox;
      }
      return null;
    } catch (e) {
      debugPrint('Error detecting face: $e');
      return null;
    }
  }

  void dispose() {
    _faceDetector.close();
  }
}
