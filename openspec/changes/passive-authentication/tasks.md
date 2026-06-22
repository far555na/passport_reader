## 1. ASN.1 and CMS Parsing Utilities

- [x] 1.1 Add `pointycastle` dependency if not already present or verify version.
- [x] 1.2 Create `PassiveAuthenticationParser` class to handle ASN.1 parsing of EF.SOD.
- [x] 1.3 Implement `LDSSecurityObject` parsing to extract the map of Data Group hashes.
- [x] 1.4 Implement parsing of `SignedData` and `SignerInfo` to extract the digital signature.
- [x] 1.5 Implement extraction of the Document Signer (DS) X.509 certificate from the CMS Certificates field.

## 2. Cryptographic Verification

- [x] 2.1 Implement hashing of the extracted EF.DG1 and EF.DG2 raw bytes using the correct algorithm specified in EF.SOD.
- [x] 2.2 Implement comparison logic between calculated hashes and hashes stored in `LDSSecurityObject`.
- [x] 2.3 Implement signature verification logic using the extracted DS public key against the EF.SOD signature.
- [x] 2.4 Create a `PassiveAuthResult` class to encapsulate the verification status (e.g., Hashes Match, Signature Valid).

## 3. Integration into NFC Scanner Flow

- [x] 3.1 Update `nfc_scanner.dart` to perform the passive authentication checks after reading DG1, DG2, and SOD.
- [x] 3.2 Handle verification failures and edge cases (e.g., missing SOD, unsupported hash algorithms).
- [x] 3.3 Update the UI or the resulting output state to reflect the Passive Authentication status (verified vs. unverified/tampered).
