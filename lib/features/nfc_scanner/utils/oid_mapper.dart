class OidMapper {
  /// Maps a signature algorithm OID to its string representation.
  static String mapOidToSignatureAlgorithm(String? oid) {
    // Common OIDs for Document Signer Signatures
    switch (oid) {
      case '1.2.840.113549.1.1.11': return 'SHA-256/RSA';
      case '1.2.840.113549.1.1.12': return 'SHA-384/RSA';
      case '1.2.840.113549.1.1.13': return 'SHA-512/RSA';
      case '1.2.840.113549.1.1.5': return 'SHA-1/RSA';
      case '1.2.840.10045.4.3.2': return 'SHA-256/ECDSA';
      case '1.2.840.10045.4.3.3': return 'SHA-384/ECDSA';
      case '1.2.840.10045.4.3.4': return 'SHA-512/ECDSA';
      default:
        // Defaulting to SHA-256/RSA if unknown
        return 'SHA-256/RSA';
    }
  }

  /// Maps a digest algorithm OID to its string representation.
  static String? mapOidToDigestName(String? oid) {
    // Digest Algorithm OIDs (pure hash algorithms)
    switch (oid) {
      case '1.3.14.3.2.26': return 'SHA-1';
      case '2.16.840.1.101.3.4.2.4': return 'SHA-224';
      case '2.16.840.1.101.3.4.2.1': return 'SHA-256';
      case '2.16.840.1.101.3.4.2.2': return 'SHA-384';
      case '2.16.840.1.101.3.4.2.3': return 'SHA-512';
      default: return null;
    }
  }
}
