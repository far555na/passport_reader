## Why

We have successfully implemented MRZ optical scanning, which gives us the required cryptographic keys (Document Number, DOB, Expiry Date) to access the passport's chip. We now need to integrate NFC reading with BAC (Basic Access Control) and PACE (Password Authenticated Connection Establishment) to securely retrieve the passport's full data, including the high-resolution face image and passive authentication signatures.

## What Changes

- Add the `dmrtd` package to `pubspec.yaml` to handle ICAO 9303 NFC protocols (BAC, PACE, Secure Messaging).
- Implement a dual-strategy integration: use the upstream `dmrtd` package by default, but configure `dependency_overrides` to allow seamless switching to a local fork (`../dmrtd_fork`) for debugging obscure APDU and signature errors.
- Create an `NfcScannerScreen` to guide the user to hold the phone against the passport chip.
- Pass the MRZ data obtained from the `mrz_parser` to the `dmrtd` `Passport` class to establish the NFC session.
- Extract `EF.DG1` (MRZ data), `EF.DG2` (Face image), and `EF.SOD` (Security Object Document) from the chip.

## Capabilities

### New Capabilities
- `nfc-reader`: The capability to establish a secure NFC connection with an ePassport chip using BAC or PACE, and retrieve its elementary files (DG1, DG2, SOD).

### Modified Capabilities
None

## Impact

- **UI/UX**: New NFC scanning screen with visual guidance.
- **Dependencies**: Adds `dmrtd` (and its transitively required `flutter_nfc_kit`).
- **Permissions**: Requires adding NFC permissions (`NFCReaderUsageDescription` for iOS, and `<uses-permission android:name="android.permission.NFC" />` for Android).
