// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mrz_scanner_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MrzScanner)
final mrzScannerProvider = MrzScannerProvider._();

final class MrzScannerProvider
    extends $NotifierProvider<MrzScanner, MrzScannerState> {
  MrzScannerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mrzScannerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mrzScannerHash();

  @$internal
  @override
  MrzScanner create() => MrzScanner();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MrzScannerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MrzScannerState>(value),
    );
  }
}

String _$mrzScannerHash() => r'4f8eb90322c5c436dce76759c1bce2ae4be72d7d';

abstract class _$MrzScanner extends $Notifier<MrzScannerState> {
  MrzScannerState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<MrzScannerState, MrzScannerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MrzScannerState, MrzScannerState>,
              MrzScannerState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
