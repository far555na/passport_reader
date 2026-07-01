import 'dart:typed_data';
import 'package:dmrtd/dmrtd.dart';
import 'passive_auth_verification_result.dart';

class NfcResult {
  final EfDG1? dg1;
  final EfDG2? dg2;
  final Uint8List? faceImage;
  final PassiveAuthVerificationResult? paResult;

  NfcResult({
    this.dg1,
    this.dg2,
    this.faceImage,
    this.paResult,
  });
}
