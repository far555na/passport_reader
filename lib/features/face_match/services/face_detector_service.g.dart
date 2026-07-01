// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'face_detector_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(faceDetectorService)
final faceDetectorServiceProvider = FaceDetectorServiceProvider._();

final class FaceDetectorServiceProvider
    extends
        $FunctionalProvider<
          FaceDetectorService,
          FaceDetectorService,
          FaceDetectorService
        >
    with $Provider<FaceDetectorService> {
  FaceDetectorServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'faceDetectorServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$faceDetectorServiceHash();

  @$internal
  @override
  $ProviderElement<FaceDetectorService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FaceDetectorService create(Ref ref) {
    return faceDetectorService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FaceDetectorService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FaceDetectorService>(value),
    );
  }
}

String _$faceDetectorServiceHash() =>
    r'05629f25792fa1e41e088f19e29228f64817bc79';
