// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'csca_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(cscaService)
final cscaServiceProvider = CscaServiceProvider._();

final class CscaServiceProvider
    extends $FunctionalProvider<CscaService, CscaService, CscaService>
    with $Provider<CscaService> {
  CscaServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cscaServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cscaServiceHash();

  @$internal
  @override
  $ProviderElement<CscaService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CscaService create(Ref ref) {
    return cscaService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CscaService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CscaService>(value),
    );
  }
}

String _$cscaServiceHash() => r'2e49d393ff7937d4500e4289f11bc3be5021708b';
