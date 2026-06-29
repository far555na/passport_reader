import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/csca_data.dart';
import '../services/passive_auth/csca_service.dart';

final cscaServiceProvider = Provider<CscaService>((ref) {
  return CscaService();
});

/// Provides a loaded map of CSCA certificates for instant trust chain verification.
/// The key is the Base64-encoded Subject, and the value is the Base64-encoded Certificate.
final cscaIndexProvider = FutureProvider<CscaData>((ref) async {
  final service = ref.watch(cscaServiceProvider);
  return await service.loadCscaData();
});
