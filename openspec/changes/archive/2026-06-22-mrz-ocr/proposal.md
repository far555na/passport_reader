## Why

To automate data extraction from passports by parsing the MRZ (Machine Readable Zone). This is a prerequisite for establishing a secure PACE/BAC session and subsequent biometric authentication, eliminating the need for manual data entry and improving user experience and reliability.

## What Changes

- Integrate a mobile-friendly OCR library suitable for reading passport MRZ data.
- Implement camera scanning capabilities to capture the MRZ area.
- Develop parsing logic to extract passport number, date of birth, and expiry date from the OCR text.
- Integrate the extracted MRZ data seamlessly with the existing `dmrtd` architecture to initiate BAC/PACE authentication.

## Capabilities

### New Capabilities
- `mrz-ocr`: Mobile-friendly MRZ scanning and parsing to extract required fields for ePassport authentication.

### Modified Capabilities
- 

## Impact

- **UI/UX**: New camera interface for scanning the passport MRZ.
- **Dependencies**: New OCR library dependency added to the Flutter project.
- **Core Logic**: Existing ePassport authentication workflow (`main.dart` or related service) will be updated to consume MRZ data from the OCR scanner instead of manual input or hardcoded values.
