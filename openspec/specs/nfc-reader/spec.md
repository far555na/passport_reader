# NFC Reader

## Purpose
TBD: Reads and extracts biometric data from ePassport NFC chips.

## Requirements

### Requirement: Establish NFC Session
The system SHALL use the MRZ data (Document Number, DOB, Expiry Date) to authenticate with the ePassport chip via NFC.

#### Scenario: Successful BAC/PACE Authentication
- **WHEN** the user holds the device against a valid ePassport
- **THEN** the system establishes a secure channel using BAC or PACE protocols

#### Scenario: Invalid MRZ Keys
- **WHEN** the MRZ data provided is incorrect
- **THEN** the chip rejects the connection and the system shows an authentication error

### Requirement: Read Elementary Files
The system SHALL read the mandatory data files from the chip after establishing a secure session.

#### Scenario: Extract Face Image
- **WHEN** the secure session is active
- **THEN** the system successfully requests and parses EF.DG2 to extract the JPEG/JP2000 face image

#### Scenario: Extract Chip MRZ
- **WHEN** the secure session is active
- **THEN** the system successfully requests and parses EF.DG1 to verify the MRZ data stored on the chip matches the optically scanned MRZ

#### Scenario: Extract Security Object Document
- **WHEN** the secure session is active
- **THEN** the system successfully requests and parses EF.SOD to retrieve the document signatures
