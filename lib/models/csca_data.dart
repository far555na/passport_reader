class CscaData {
  final Map<String, List<String>> certificates;

  CscaData(this.certificates);

  bool get isEmpty => certificates.isEmpty;

  List<String>? getCertificatesForIssuer(String issuer) {
    return certificates[issuer];
  }
}
