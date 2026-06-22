## Why

While the application can successfully read data from the passport chip via NFC (BAC/PACE), it currently does not perform any validation to prove the data is authentic and hasn't been tampered with. Implementing Passive Authentication (PA) allows the application to verify the digital signatures on the Document Security Object (EF.SOD) and ensure the integrity and authenticity of the extracted passport data.

## What Changes

- Implement parsing of the EF.SOD file structure (ASN.1 / CMS).
- Extract data group hashes from the LDSSecurityObject.
- Extract the Document Signer (DS) certificate and the digital signature.
- Verify the hashes of the read Data Groups (e.g., DG1, DG2) against the hashes stored in the EF.SOD.
- Verify the digital signature of the EF.SOD using the extracted DS certificate.
- (Optional/Future) Verify the DS certificate against a trusted CSCA Master List.

## Capabilities

### New Capabilities
- `passive-authentication`: Passive Authentication (PA) verification for verifying data integrity and authenticity of ePassport data via EF.SOD.

### Modified Capabilities
- `nfc-reader`: The NFC reading flow will be updated to include the PA verification step after reading the Data Groups and SOD.

## Impact

- Adds new cryptographic and ASN.1 parsing logic (potentially requiring native iOS/Android bridges or new Dart packages).
- Modifies the NFC scanning flow in `nfc_scanner.dart` to perform the verification.
- Will impact the `MrzResult` or `NfcResult` data structures to report the trust/verification status of the passport data.
