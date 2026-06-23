import 'verification_result.dart';

class PassiveAuthVerificationResult {
  final Map<int, VerificationResult> dgVerification;
  final VerificationResult signatureVerification;

  PassiveAuthVerificationResult({
    required this.dgVerification,
    required this.signatureVerification,
  });

  bool get isDataIntegrityVerified => 
      dgVerification.isNotEmpty && dgVerification.values.every((v) => v.isVerified);

  bool get isSignatureVerified => signatureVerification.isVerified;
}
