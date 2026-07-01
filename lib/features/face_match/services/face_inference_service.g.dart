// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'face_inference_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(faceInferenceService)
final faceInferenceServiceProvider = FaceInferenceServiceProvider._();

final class FaceInferenceServiceProvider
    extends
        $FunctionalProvider<
          FaceInferenceService,
          FaceInferenceService,
          FaceInferenceService
        >
    with $Provider<FaceInferenceService> {
  FaceInferenceServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'faceInferenceServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$faceInferenceServiceHash();

  @$internal
  @override
  $ProviderElement<FaceInferenceService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FaceInferenceService create(Ref ref) {
    return faceInferenceService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FaceInferenceService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FaceInferenceService>(value),
    );
  }
}

String _$faceInferenceServiceHash() =>
    r'043d80f28e62ecd884a993df5f92d131a362b081';
