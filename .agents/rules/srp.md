---
trigger: always_on
---

# SRP / Single Responsibility Principle Rule

You MUST follow the Single Responsibility Principle when creating, editing, or refactoring code.

## Core Rule

Each file, class, function, widget, provider, service, controller, repository, or utility MUST have one clear responsibility.

A component should have only one main reason to change.

## Before Writing Code

Before creating or modifying code, identify the responsibility of the component.

Ask internally:

- What is this component responsible for?
- What reason would make this component change?
- Is it handling more than one concern?
- Can this logic be split into smaller parts?

## Separation Rules

Do NOT mix unrelated responsibilities in the same file or class.

Avoid mixing:

- UI rendering and business logic
- API/NFC/camera access and UI code
- Parsing logic and screen widgets
- Validation logic and navigation logic
- Storage logic and domain logic
- Logging/debugging logic and core feature logic
- Face matching logic and passport chip reading logic
- MRZ OCR logic and MRZ parsing logic
- Passive Authentication logic and UI display logic

## Flutter-Specific Rule

For Flutter code:

- Widgets should mainly build UI and handle simple UI state.
- Providers/controllers should coordinate state and feature flow.
- Services should handle external systems such as camera, NFC, ML Kit, storage, or network.
- Repositories should handle data access.
- Parsers should only parse data.
- Validators should only validate data.
- Models should only represent data.

## Passport Reader Project Rule

For passport / MRZ / NFC features, keep these responsibilities separate:

- `mrz_scanner_screen.dart`  
  UI for scanning MRZ only.

- `mrz_ocr_service.dart`  
  Runs OCR using ML Kit only.

- `mrz_parser.dart`  
  Parses MRZ text only.

- `mrz_validator.dart`  
  Validates MRZ format and check digits only.

- `passport_nfc_service.dart`  
  Reads passport chip data only.

- `bac_service.dart` or `pace_service.dart`  
  Handles BAC/PACE key establishment only.

- `dg_reader_service.dart`  
  Reads DG1, DG2, SOD files only.

- `passive_auth_service.dart`  
  Verifies hashes, SOD signature, and certificate chain only.

- `face_match_service.dart`  
  Compares DG2 face image with selfie only.

- `passport_repository.dart`  
  Coordinates data access between services only.

Do not put all passport logic inside one screen, one provider, or one service.

## Refactoring Rule

When a file becomes too large or has multiple reasons to change, refactor it.

Signs that refactoring is needed:

- The file handles UI, parsing, validation, and API/device calls together.
- A class has many unrelated methods.
- A function does more than one thing.
- A widget contains complex business logic.
- Changing one feature risks breaking another unrelated feature.
- The name of the file/class contains vague words like `helper`, `manager`, `utils`, or `handler` without a clear single purpose.

## Naming Rule

Names must clearly describe one responsibility.

Good examples:

- `MrzParser`
- `MrzValidator`
- `PassportNfcService`
- `PassiveAuthService`
- `FaceMatchService`
- `PassportReaderController`

Bad examples:

- `PassportHelper`
- `MainService`
- `DataManager`
- `Utils`
- `EverythingController`
- `PassportProcessor` if it does OCR, NFC, parsing, validation, and UI logic together

## Function Rule

Each function should do one thing.

Prefer small functions such as:

- `extractMrzLines()`
- `parseMrz()`
- `validateCheckDigit()`
- `readDg1()`
- `readDg2()`
- `verifySodSignature()`
- `compareFaces()`

Avoid functions like:

- `scanParseValidateReadPassportAndMatchFace()`
- `processEverything()`
- `handlePassportFlow()`

unless they only coordinate calls to smaller services.

## Agent Behavior

When generating code, you MUST:

1. Create small focused files.
2. Keep each class responsible for one concern.
3. Move reusable logic out of widgets.
4. Avoid placing business logic directly inside Flutter screens.
5. Suggest refactoring when existing code violates SRP.
6. Explain briefly why a new file/class exists.
7. Prefer readable structure over fewer files.

## When Editing Existing Code

Before editing, check whether the target file already violates SRP.

If it does, prefer this order:

1. Make the smallest safe change.
2. Extract unrelated logic into a new class/file.
3. Keep public behavior the same.
4. Avoid large rewrites unless needed.
5. Explain what responsibility was separated.

## Final Check

Before finishing any code task, verify:

- Each file has one clear purpose.
- Each class has one clear responsibility.
- Each function does one main thing.
- UI code does not contain heavy business logic.
- Device/API logic is inside services.
- Parsing and validation are separate.
- The code is easier to test after the change.