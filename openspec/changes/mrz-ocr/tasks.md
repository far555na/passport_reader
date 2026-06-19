## 1. Setup and Dependencies

- [x] 1.1 Research and add the chosen OCR library (e.g., `google_mlkit_text_recognition`) to `pubspec.yaml`
- [x] 1.2 Add necessary camera plugin dependency (e.g., `camera`) to `pubspec.yaml`
- [x] 1.3 Add necessary camera permissions to Android (`AndroidManifest.xml`) and iOS (`Info.plist`)

## 2. UI Implementation

- [x] 2.1 Create a new Flutter widget for the MRZ scanner screen
- [x] 2.2 Implement the camera preview and scanning overlay with an alignment guide
- [x] 2.3 Implement a manual fallback screen or dialog for users to enter data if scanning fails

## 3. Parsing Logic

- [x] 3.1 Implement a parser to extract Document Number, Date of Birth, and Date of Expiry from raw OCR text
- [x] 3.2 Add MRZ checksum validation logic to ensure the extracted data is accurate before proceeding

## 4. Integration

- [x] 4.1 Update the authentication workflow (e.g., in `main.dart`) to present the MRZ scanner before NFC reading
- [x] 4.2 Map the parsed MRZ data to the input format required by the `dmrtd` PACE/BAC session methods
- [x] 4.3 Test the complete end-to-end flow from MRZ scanning to successful NFC reading
