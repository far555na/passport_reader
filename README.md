# Passport Reader

A Flutter application for reading and verifying electronic passports (ePassports). This app leverages the device's camera for MRZ scanning and its NFC capabilities to read the passport chip, authenticate the data, and perform biometric verification.

## Features

- **MRZ Scanning & Parsing**: Uses the device camera to scan the Machine Readable Zone (MRZ). The parser is specifically optimized for **TD3** format (standard passport booklets).
- **NFC Chip Reading**: Communicates with the ePassport's NFC chip using Basic Access Control (BAC) or Password Authenticated Connection Establishment (PACE) using the MRZ data.
- **Passive Authentication**: Verifies the authenticity and integrity of the data read from the passport chip:
  - Validates Data Groups against the Document Security Object (SOD) hashes.
  - Verifies the SOD signature using the Document Signer Certificate (DSC).
  - Validates the DSC against a trusted Country Signing Certification Authority (CSCA) root certificate.
- **Biometric Face Matching**: Compares the passport holder's photo (Data Group 2) with a live camera feed using **MobileFaceNet** (via TensorFlow Lite) to verify identity.

## Architecture 

- **`lib/screens/`**: UI components that handle rendering and user interactions.
- **`lib/providers/`**: State management that coordinates data flow between the UI and services (e.g., `face_match_provider.dart`, `nfc_provider.dart`).
- **`lib/services/`**: Focused domain logic, device interactions, and external integrations:
  - **`mrz_parser.dart`**: Parses raw MRZ text into structured data.
  - **`nfc_service.dart`**: Handles reading the passport chip.
  - **`passive_auth/`**: Domain-specific services handling certificate verification, signature validation, and SOD parsing.
  - **`face_match/`**: Handles facial detection, embedding extraction, and similarity comparison.
- **`lib/models/`**: Pure data classes without business logic.

## Getting Started

1. Ensure you have Flutter installed.
2. Clone the repository and install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app on a physical device with NFC capabilities:
   ```bash
   flutter run
   ```
*(Note: iOS requires an Apple Developer account to configure NFC entitlements. Android requires NFC permissions in the `AndroidManifest.xml`.)*
