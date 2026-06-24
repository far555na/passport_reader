## Context

The app currently reads ePassport Data Groups (specifically DG2, which contains the biometric facial image) via NFC. The next logical step is to verify that the person physically presenting the passport matches this securely stored facial image. This needs to be done completely locally on the device to ensure privacy, reduce costs (no API calls), and allow offline verification.

## Goals / Non-Goals

**Goals:**
- Implement a local AI pipeline for active liveness detection (blink, smile, head turn).
- Implement passive liveness (anti-spoofing) using local TFLite models.
- Implement 1:1 facial recognition to match a live selfie with the DG2 reference image using a local TFLite model.
- Provide a smooth UI transition from NFC reading to the camera-based verification flow.

**Non-Goals:**
- Cloud-based face verification or any biometric data transmission.
- Support for extremely low-end devices that cannot run TFLite inference within reasonable time constraints.
- Advanced 3D face map generation (like FaceID).

## Decisions

**1. ML Kit for Active Liveness & Face Detection**
- *Rationale*: Google's ML Kit `face_detection` provides highly optimized, real-time bounding box detection and probability scores for facial expressions (eyes open, smile) and head pose (Euler angles).
- *Alternatives*: Doing this with custom TFLite models would require significantly more work (tracking facial landmarks manually) and would likely be less performant.

**2. TensorFlow Lite for Passive Liveness & Matching**
- *Rationale*: To avoid cloud APIs, we must use local ML models. `tflite_flutter` allows us to run standard `.tflite` models (like MobileFaceNet for embeddings, and an Anti-Spoofing model).
- *Alternatives*: Commercial local SDKs (Innovatrics, Regula). Rejected due to the goal to build a custom, free pipeline.

**3. State Machine for Active Liveness**
- *Rationale*: A simple state machine (e.g., `PromptingBlink` -> `VerifyingBlink` -> `PromptingSmile` -> `VerifyingSmile`) manages the user interaction intuitively and provides clear feedback.

**4. Sequential Processing**
- *Rationale*: To maintain high UI framerates, the heavy TFLite models (matching and passive liveness) will only run *after* the active liveness state machine completes successfully, rather than running on every frame.

## Risks / Trade-offs

- **[Risk] Increased App Size**
  - *Trade-off*: Bundling TFLite models (`.tflite` files) will increase the APK/IPA size.
  - *Mitigation*: We will use quantized models (e.g., INT8) where possible to reduce size while maintaining acceptable accuracy.
- **[Risk] Accuracy of Open-Source Models**
  - *Trade-off*: Open-source face recognition models may have higher False Acceptance/Rejection Rates compared to enterprise commercial solutions.
  - *Mitigation*: Implement configurable thresholds for Cosine Similarity matching so we can tune the security vs. convenience balance.
- **[Risk] NDK/C++ Configuration Issues**
  - *Trade-off*: `tflite_flutter` often requires custom build configurations and can be tricky to set up across platforms.
  - *Mitigation*: Address the infrastructure setup as a dedicated early task before building the UI.
