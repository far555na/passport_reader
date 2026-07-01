// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mrz_state_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Mrz)
final mrzProvider = MrzProvider._();

final class MrzProvider extends $NotifierProvider<Mrz, MrzResult?> {
  MrzProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mrzProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mrzHash();

  @$internal
  @override
  Mrz create() => Mrz();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MrzResult? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MrzResult?>(value),
    );
  }
}

String _$mrzHash() => r'0bc7a6e46167fde38f99929e1718e86961aeb1df';

abstract class _$Mrz extends $Notifier<MrzResult?> {
  MrzResult? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<MrzResult?, MrzResult?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MrzResult?, MrzResult?>,
              MrzResult?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
