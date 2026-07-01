import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/csca_data.dart';
import '../services/csca_service.dart';

part 'csca_state_view_model.g.dart';

/// Provides a loaded map of CSCA certificates for instant trust chain verification.
/// The key is the Base64-encoded Subject, and the value is the Base64-encoded Certificate.
@Riverpod(keepAlive: true)
Future<CscaData> cscaStateViewModel(Ref ref) async {
  final service = ref.watch(cscaServiceProvider);
  return await service.loadCscaData();
}
