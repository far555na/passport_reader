import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/face_match/face_detector_service.dart';
import '../services/face_match/face_inference_service.dart';
import '../services/face_match/face_match_service.dart';

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
  late final FaceMatchService _matchService;
  late final FaceInferenceService _inference;

  @override
  FaceMatchState build() {
    _matchService = ref.watch(faceMatchServiceProvider);
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
      final result = await _matchService.compareFaces(dg2Bytes, selfiePath);

      state = FaceMatchState(
        isLoading: false,
        isMatch: result.isMatch,
        score: result.score,
      );

    } catch (e) {
      debugPrint(e.toString());
      state = state.copyWith(isLoading: false, error: e.toString());
    }
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

final faceMatchServiceProvider = Provider<FaceMatchService>((ref) {
  final detector = ref.watch(faceDetectorProvider);
  final inference = ref.watch(faceInferenceProvider);
  return FaceMatchService(detector, inference);
});

final faceMatchProvider = NotifierProvider<FaceMatchNotifier, FaceMatchState>(() {
  return FaceMatchNotifier();
});
