## MODIFIED Requirements

### Requirement: Read Elementary Files
The system SHALL read the mandatory data files from the chip after establishing a secure session, and SHALL perform Passive Authentication to verify the integrity and authenticity of the extracted data.

#### Scenario: Extract Face Image
- **WHEN** the secure session is active
- **THEN** the system successfully requests and parses EF.DG2 to extract the JPEG/JP2000 face image

#### Scenario: Extract Chip MRZ
- **WHEN** the secure session is active
- **THEN** the system successfully requests and parses EF.DG1 to verify the MRZ data stored on the chip matches the optically scanned MRZ

#### Scenario: Extract Security Object Document
- **WHEN** the secure session is active
- **THEN** the system successfully requests and parses EF.SOD to retrieve the document signatures

#### Scenario: Passive Authentication Verification
- **WHEN** EF.DG1, EF.DG2, and EF.SOD have been successfully extracted
- **THEN** the system uses the EF.SOD to cryptographically verify the integrity of EF.DG1 and EF.DG2 data.
