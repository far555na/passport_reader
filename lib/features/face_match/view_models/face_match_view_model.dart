import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../repositories/face_match_repository.dart';

part 'face_match_view_model.g.dart';

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

@riverpod
class FaceMatchViewModel extends _$FaceMatchViewModel {
  late final FaceMatchRepository _repository;

  @override
  FaceMatchState build() {
    _repository = ref.watch(faceMatchRepositoryProvider);
    _initInference();
    return FaceMatchState();
  }

  Future<void> _initInference() async {
    try {
      await _repository.initialize();
    } catch (e) {
      state = state.copyWith(error: 'Failed to initialize face matching model.');
    }
  }

  /// Compares DG2 bytes with a selfie from camera path
  Future<void> compareFaces(Uint8List dg2Bytes, String selfiePath) async {
    state = FaceMatchState(isLoading: true);

    try {
      final result = await _repository.compareFaces(dg2Bytes, selfiePath);

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
