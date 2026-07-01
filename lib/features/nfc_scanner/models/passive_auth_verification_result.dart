import 'verification_result.dart';

class PassiveAuthVerificationResult {
  final Map<int, VerificationResult> dgVerification;
  final VerificationResult signatureVerification;
  final VerificationResult cscaVerification;

  PassiveAuthVerificationResult({
    required this.dgVerification,
    required this.signatureVerification,
    required this.cscaVerification,
  });

  bool get isDataIntegrityVerified => 
      dgVerification.isNotEmpty && dgVerification.values.every((v) => v.isVerified);

  bool get isSignatureVerified => signatureVerification.isVerified;

  bool get isCscaVerified => cscaVerification.isVerified;

  bool get isFullyVerified => isDataIntegrityVerified && isSignatureVerified && isCscaVerified;
}
