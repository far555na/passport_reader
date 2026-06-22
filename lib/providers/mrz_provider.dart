import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mrz_result.dart';

class MrzNotifier extends Notifier<MrzResult?> {
  @override
  MrzResult? build() {
    return null;
  }

  void setMrz(MrzResult? mrz) {
    state = mrz;
  }
}

final mrzProvider = NotifierProvider<MrzNotifier, MrzResult?>(() {
  return MrzNotifier();
});
