// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'csca_state_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides a loaded map of CSCA certificates for instant trust chain verification.
/// The key is the Base64-encoded Subject, and the value is the Base64-encoded Certificate.

@ProviderFor(cscaStateViewModel)
final cscaStateViewModelProvider = CscaStateViewModelProvider._();

/// Provides a loaded map of CSCA certificates for instant trust chain verification.
/// The key is the Base64-encoded Subject, and the value is the Base64-encoded Certificate.

final class CscaStateViewModelProvider
    extends
        $FunctionalProvider<AsyncValue<CscaData>, CscaData, FutureOr<CscaData>>
    with $FutureModifier<CscaData>, $FutureProvider<CscaData> {
  /// Provides a loaded map of CSCA certificates for instant trust chain verification.
  /// The key is the Base64-encoded Subject, and the value is the Base64-encoded Certificate.
  CscaStateViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cscaStateViewModelProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cscaStateViewModelHash();

  @$internal
  @override
  $FutureProviderElement<CscaData> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<CscaData> create(Ref ref) {
    return cscaStateViewModel(ref);
  }
}

String _$cscaStateViewModelHash() =>
    r'7424ac0cbf2a756233eb99c15762bd83d9d4afef';
