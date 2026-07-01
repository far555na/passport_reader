// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nfc_scanner_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(nfcScannerRepository)
final nfcScannerRepositoryProvider = NfcScannerRepositoryProvider._();

final class NfcScannerRepositoryProvider
    extends
        $FunctionalProvider<
          NfcScannerRepository,
          NfcScannerRepository,
          NfcScannerRepository
        >
    with $Provider<NfcScannerRepository> {
  NfcScannerRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nfcScannerRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nfcScannerRepositoryHash();

  @$internal
  @override
  $ProviderElement<NfcScannerRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NfcScannerRepository create(Ref ref) {
    return nfcScannerRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NfcScannerRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NfcScannerRepository>(value),
    );
  }
}

String _$nfcScannerRepositoryHash() =>
    r'380a9c193f2c417b8f7b42e74673aee4a631e6ce';
