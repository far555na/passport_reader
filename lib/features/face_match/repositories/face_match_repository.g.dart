// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'face_match_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(faceMatchRepository)
final faceMatchRepositoryProvider = FaceMatchRepositoryProvider._();

final class FaceMatchRepositoryProvider
    extends
        $FunctionalProvider<
          FaceMatchRepository,
          FaceMatchRepository,
          FaceMatchRepository
        >
    with $Provider<FaceMatchRepository> {
  FaceMatchRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'faceMatchRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$faceMatchRepositoryHash();

  @$internal
  @override
  $ProviderElement<FaceMatchRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FaceMatchRepository create(Ref ref) {
    return faceMatchRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FaceMatchRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FaceMatchRepository>(value),
    );
  }
}

String _$faceMatchRepositoryHash() =>
    r'933f0641aab0bc80347ade3a845002234be3fe79';
