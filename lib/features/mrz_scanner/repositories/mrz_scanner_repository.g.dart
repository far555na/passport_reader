// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mrz_scanner_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(mrzScannerRepository)
final mrzScannerRepositoryProvider = MrzScannerRepositoryProvider._();

final class MrzScannerRepositoryProvider
    extends
        $FunctionalProvider<
          MrzScannerRepository,
          MrzScannerRepository,
          MrzScannerRepository
        >
    with $Provider<MrzScannerRepository> {
  MrzScannerRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mrzScannerRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mrzScannerRepositoryHash();

  @$internal
  @override
  $ProviderElement<MrzScannerRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MrzScannerRepository create(Ref ref) {
    return mrzScannerRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MrzScannerRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MrzScannerRepository>(value),
    );
  }
}

String _$mrzScannerRepositoryHash() =>
    r'83318538d1cb382d5443b0a2a7d6eac1f24d002f';
