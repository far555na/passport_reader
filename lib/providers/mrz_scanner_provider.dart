import 'dart:io';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../models/mrz_result.dart';
import '../repositories/mrz_scanner_repository.dart';

enum ScannerStatus {
  idle,
  processing,
  success,
  error,
}

class MrzScannerState {
  final ScannerStatus status;
  final MrzResult? result;

  const MrzScannerState({
    this.status = ScannerStatus.idle,
    this.result,
  });

  MrzScannerState copyWith({
    ScannerStatus? status,
    MrzResult? result,
  }) {
    return MrzScannerState(
      status: status ?? this.status,
      result: result ?? this.result,
    );
  }
}

class MrzScannerNotifier extends Notifier<MrzScannerState> {
  @override
  MrzScannerState build() {
    return const MrzScannerState();
  }

  /// Processes a camera frame and attempts to extract MRZ data.
  Future<void> processCameraImage(CameraImage image, CameraDescription camera) async {
    // Prevent overlapping processing or processing after success
    if (state.status == ScannerStatus.processing || state.status == ScannerStatus.success) {
      return;
    }

    final inputImage = _inputImageFromCameraImage(image, camera);
    if (inputImage == null) return;

    state = state.copyWith(status: ScannerStatus.processing);

    final repository = ref.read(mrzScannerRepositoryProvider);
    final result = await repository.processImage(inputImage);

    if (result != null) {
      state = state.copyWith(status: ScannerStatus.success, result: result);
    } else {
      // If parsing fails, revert to idle to immediately process the next frame
      state = state.copyWith(status: ScannerStatus.idle);
    }
  }

  InputImage? _inputImageFromCameraImage(CameraImage image, CameraDescription camera) {
    final sensorOrientation = camera.sensorOrientation;
    
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation = 0;
      if (camera.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        rotationCompensation = (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }

    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null || (Platform.isAndroid && format != InputImageFormat.nv21) || (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

    if (image.planes.isEmpty) return null;

    return InputImage.fromBytes(
      bytes: image.planes[0].bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }
}

final mrzScannerProvider = NotifierProvider.autoDispose<MrzScannerNotifier, MrzScannerState>(() {
  return MrzScannerNotifier();
});
