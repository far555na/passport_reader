## Why

We need to verify that the person holding the passport physically matches the facial image stored securely within Data Group 2 (DG2) on the ePassport chip. This is required for identity verification, ensuring the document presenter is the legitimate document holder. An on-device approach offers maximum privacy by keeping biometric data localized without needing expensive third-party APIs.

## What Changes

- Integrate camera functionality to capture live face images and video streams.
- Implement an active liveness state machine using Google ML Kit (detecting blinks, smiles, head turns).
- Implement passive liveness (anti-spoofing) using a custom TensorFlow Lite model.
- Implement 1:1 Face Matching using a TensorFlow Lite face recognition model to compare the live face to the DG2 face.
- Add a Face Verification UI flow following the successful NFC scan of the passport.

## Capabilities

### New Capabilities
- `face-verification`: The end-to-end local capability to match a live selfie to a DG2 photo, including active liveness checks via ML Kit and passive liveness/matching via TFLite.

### Modified Capabilities

## Impact

- **Dependencies**: New dependencies `camera`, `google_mlkit_face_detection`, `tflite_flutter` will be added to `pubspec.yaml`.
- **Assets**: Addition of TFLite model files (e.g., `MobileFaceNet.tflite`, `FAS.tflite`) into the `assets` folder, which will increase the app bundle size.
- **UI**: New screens for camera preview and liveness instructions.
- **State Management**: Modifications to routing and state to handle the transition from NFC reading to Face Verification.
