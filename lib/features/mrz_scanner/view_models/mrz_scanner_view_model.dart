import 'package:camera/camera.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/mrz_result.dart';
import '../repositories/mrz_scanner_repository.dart';
import '../utils/camera_image_converter.dart';

part 'mrz_scanner_view_model.g.dart';

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

@riverpod
class MrzScanner extends _$MrzScanner {
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

    final inputImage = CameraImageConverter.fromCameraImage(image, camera);
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

}

