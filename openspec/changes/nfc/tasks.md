## 1. Environment Setup

- [x] 1.1 Add `dmrtd` and `flutter_nfc_kit` dependencies to `pubspec.yaml`
- [x] 1.2 Configure `dependency_overrides` in `pubspec.yaml` for `dmrtd` to allow for local debugging
- [x] 1.3 Add iOS NFC entitlements (`NFCReaderUsageDescription`) and Android NFC permissions

## 2. UI Implementation

- [x] 2.1 Create `NfcScannerScreen` with instructions to hold the phone against the passport
- [x] 2.2 Add progress indicators for connection states (Connecting, Authenticating, Reading)

## 3. NFC Logic Implementation

- [x] 3.1 Initialize the `dmrtd` `Passport` session using the parsed `MrzResult` data
- [x] 3.2 Implement BAC/PACE authentication logic
- [x] 3.3 Request and parse `EF.DG1` (MRZ Data) from the passport chip
- [x] 3.4 Request and parse `EF.DG2` (Face Image) from the passport chip
- [x] 3.5 Request and parse `EF.SOD` (Security Object Document) from the passport chip

## 4. Integration

- [x] 4.1 Update optical MRZ scanning flow to navigate to `NfcScannerScreen` upon success
- [x] 4.2 Display the extracted face image and verified MRZ data to the user

## 5. Testing

- [x] 5.1 Write unit and widget tests for `nfc_scanner.dart` and `FlutterNfcProvider`
