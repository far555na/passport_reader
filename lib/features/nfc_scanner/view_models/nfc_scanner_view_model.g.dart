// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nfc_scanner_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NfcScannerViewModel)
final nfcScannerViewModelProvider = NfcScannerViewModelProvider._();

final class NfcScannerViewModelProvider
    extends $NotifierProvider<NfcScannerViewModel, NfcState> {
  NfcScannerViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nfcScannerViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nfcScannerViewModelHash();

  @$internal
  @override
  NfcScannerViewModel create() => NfcScannerViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NfcState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NfcState>(value),
    );
  }
}

String _$nfcScannerViewModelHash() =>
    r'1e621a017c1dbd8827ff28b122431e8773e8a1ae';

abstract class _$NfcScannerViewModel extends $Notifier<NfcState> {
  NfcState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<NfcState, NfcState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NfcState, NfcState>,
              NfcState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
