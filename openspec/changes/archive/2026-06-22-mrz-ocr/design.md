## Context

The current `dmrtd` authentication workflow relies on providing passport details (Document Number, Date of Birth, Date of Expiry) to establish a secure PACE/BAC session. Currently, this might require manual input. To improve user experience and reduce friction, we need to implement an OCR (Optical Character Recognition) solution that automatically scans and parses the Machine Readable Zone (MRZ) on the passport using the mobile device's camera.

## Goals / Non-Goals

**Goals:**
- Implement a robust mobile camera scanning interface to capture the passport MRZ.
- Accurately parse the MRZ text into structured data (Document Number, Date of Birth, Date of Expiry).
- Integrate the parsed data seamlessly with the existing `dmrtd` authentication workflow.

**Non-Goals:**
- Validating the authenticity of the passport via OCR (only data extraction).
- Developing a custom OCR engine from scratch. We will use existing libraries.
- Scanning other parts of the passport beyond the MRZ (e.g., facial image extraction from the data page).

## Decisions

- **OCR Engine**: We will evaluate and use a robust Flutter plugin for text recognition. Candidates include `google_mlkit_text_recognition` (highly accurate and runs on-device) or specialized MRZ parsing libraries like `mrz_scanner` if they meet our requirements. On-device processing is crucial for privacy and security.
- **Integration Point**: The OCR scanner will act as the data provider before the NFC reading phase begins in `main.dart` or a dedicated scanning screen. The user will scan the MRZ, the data will be parsed, and then the user will be prompted to tap the passport to the phone for NFC reading.
- **Data Structure**: The parsed MRZ data will be mapped to the `MRTDData` or equivalent structure expected by the `dmrtd` session establishment methods.

## Risks / Trade-offs

- **Risk: Poor OCR Accuracy** -> *Mitigation*: Ensure the camera UI provides clear visual guides (bounding boxes) for the user to align the MRZ. Implement checksum validation on the parsed MRZ to detect read errors before attempting NFC authentication.
- **Risk: Device Compatibility** -> *Mitigation*: Test the camera and OCR functionality across various Android and iOS devices, handling camera permissions and lifecycle events gracefully. Provide a manual entry fallback if the camera or OCR fails.
