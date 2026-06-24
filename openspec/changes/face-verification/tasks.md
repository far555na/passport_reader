## 1. Setup & Configuration

- [ ] 1.1 Add `camera`, `google_mlkit_face_detection`, and `tflite_flutter` dependencies to `pubspec.yaml`
- [ ] 1.2 Configure iOS `Info.plist` for Camera permissions
- [ ] 1.3 Configure Android `AndroidManifest.xml` for Camera permissions
- [ ] 1.4 Setup required NDK and C++ build configurations for `tflite_flutter`

## 2. Active Liveness (ML Kit)

- [ ] 2.1 Create a new `FaceVerificationScreen` with a Camera preview
- [ ] 2.2 Initialize ML Kit `FaceDetector` and process camera image frames
- [ ] 2.3 Implement the `LivenessStateMachine` (e.g., Prompt Blink -> Verify Blink -> Prompt Smile -> Verify Smile)
- [ ] 2.4 Build UI overlays to instruct the user during the active liveness flow

## 3. Passive Liveness & Matching (TFLite)

- [ ] 3.1 Acquire and add face recognition (`MobileFaceNet.tflite`) and anti-spoofing (`FAS.tflite`) models to the `assets` folder
- [ ] 3.2 Create an image pre-processing utility to convert Flutter camera frames and DG2 images into TFLite Tensors
- [ ] 3.3 Implement `AntiSpoofingService` to run inference on the live frame and calculate the spoof score
- [ ] 3.4 Implement `FaceMatchingService` to extract 128D embeddings from the DG2 reference image and live image, and calculate their Cosine Similarity

## 4. Integration & UX

- [ ] 4.1 Extract the DG2 facial image (handling potential JPEG/JPEG2000 formats) to be used as the reference image
- [ ] 4.2 Update the NFC scanning flow to navigate to `FaceVerificationScreen` upon successful passive authentication
- [ ] 4.3 Orchestrate the full pipeline: Active Liveness -> Passive Liveness -> Face Match
- [ ] 4.4 Display the final Face Verification result in the UI (Match Success/Failure)
