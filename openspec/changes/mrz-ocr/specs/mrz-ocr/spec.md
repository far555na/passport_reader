## ADDED Requirements

### Requirement: Camera MRZ Scanning
The system SHALL provide a camera interface allowing the user to scan the Machine Readable Zone (MRZ) of a passport.

#### Scenario: Successful MRZ capture
- **WHEN** the user aligns the passport MRZ within the camera view
- **THEN** the system successfully detects and extracts the raw MRZ text

### Requirement: MRZ Data Parsing
The system SHALL parse the extracted raw MRZ text to obtain the Document Number, Date of Birth, and Date of Expiry.

#### Scenario: Valid MRZ string parsed
- **WHEN** a valid MRZ string is captured
- **THEN** the system extracts the correct Document Number, Date of Birth, and Date of Expiry, validating the MRZ checksums

#### Scenario: Invalid MRZ checksum
- **WHEN** the MRZ string has incorrect checksums due to OCR errors
- **THEN** the system prompts the user to rescan or correct the data

### Requirement: Manual Fallback
The system SHALL provide a manual entry fallback if MRZ scanning fails or is unavailable.

#### Scenario: User opts for manual entry
- **WHEN** the user is unable to scan the MRZ
- **THEN** the user can manually input their Document Number, Date of Birth, and Date of Expiry to proceed
