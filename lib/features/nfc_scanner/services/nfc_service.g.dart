// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nfc_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(nfcService)
final nfcServiceProvider = NfcServiceProvider._();

final class NfcServiceProvider
    extends $FunctionalProvider<NfcService, NfcService, NfcService>
    with $Provider<NfcService> {
  NfcServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nfcServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nfcServiceHash();

  @$internal
  @override
  $ProviderElement<NfcService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NfcService create(Ref ref) {
    return nfcService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NfcService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NfcService>(value),
    );
  }
}

String _$nfcServiceHash() => r'10d7eaeaf6d890a77679720a9d1cf7f95a9ebd3b';
