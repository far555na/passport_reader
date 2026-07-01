// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'face_match_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FaceMatchViewModel)
final faceMatchViewModelProvider = FaceMatchViewModelProvider._();

final class FaceMatchViewModelProvider
    extends $NotifierProvider<FaceMatchViewModel, FaceMatchState> {
  FaceMatchViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'faceMatchViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$faceMatchViewModelHash();

  @$internal
  @override
  FaceMatchViewModel create() => FaceMatchViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FaceMatchState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FaceMatchState>(value),
    );
  }
}

String _$faceMatchViewModelHash() =>
    r'5f9baa0286be1df4e4f512227fe2fd5aa36aafad';

abstract class _$FaceMatchViewModel extends $Notifier<FaceMatchState> {
  FaceMatchState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<FaceMatchState, FaceMatchState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FaceMatchState, FaceMatchState>,
              FaceMatchState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
