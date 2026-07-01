import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/mrz_result.dart';

part 'mrz_state_view_model.g.dart';

@Riverpod(keepAlive: true)
class Mrz extends _$Mrz {
  @override
  MrzResult? build() {
    return null;
  }

  void setMrz(MrzResult? mrz) {
    state = mrz;
  }
}
