## ADDED Requirements

### Requirement: Verify Document Integrity
The system SHALL extract the data group hashes from the EF.SOD and compare them to the calculated hashes of the extracted data groups.

#### Scenario: Hashes Match
- **WHEN** the calculated hash of EF.DG1 and EF.DG2 matches the hashes stored in the LDSSecurityObject of the EF.SOD
- **THEN** the system considers the document integrity verified

#### Scenario: Hashes Mismatch
- **WHEN** the calculated hash of EF.DG1 or EF.DG2 does not match the corresponding hash in the LDSSecurityObject
- **THEN** the system flags the document as potentially tampered

### Requirement: Verify Document Authenticity
The system SHALL extract the Document Signer (DS) certificate from the EF.SOD and verify the digital signature of the EF.SOD content.

#### Scenario: Valid Signature
- **WHEN** the digital signature on the EF.SOD is cryptographically verified using the public key from the extracted DS certificate
- **THEN** the system considers the document authenticity verified

#### Scenario: Invalid Signature
- **WHEN** the digital signature verification fails
- **THEN** the system flags the document as inauthentic
