## Context

We have successfully parsed the Machine Readable Zone (MRZ) from the passport, which provides us with the Document Number, Date of Birth, and Expiry Date. To access the chip data (such as the high-resolution photo and passive authentication signatures), we need to establish an NFC connection. The `dmrtd` Dart package implements the complex ICAO 9303 standards necessary to communicate with the chip, but real-world passports often have subtle deviations in their APDU implementations.

## Goals / Non-Goals

**Goals:**
- Read the ePassport via NFC using the BAC or PACE protocols.
- Extract the MRZ data (EF.DG1), Face Image (EF.DG2), and Security Object Document (EF.SOD).
- Establish a local debugging strategy for `dmrtd` using `dependency_overrides`.

**Non-Goals:**
- Complete end-to-end passive authentication verification (focusing first on data extraction and connection).
- Full terminal authentication (EAC) or active authentication (AA).
- Implementation of raw APDU commands from scratch.

## Decisions

1. **Use `dmrtd` package with `dependency_overrides` strategy.**
   - *Rationale:* Hand-rolling the cryptographic and ASN.1 parsing requirements of ICAO 9303 is extremely complex and error-prone. We will rely on `dmrtd` for the heavy lifting. However, because we anticipate obscure APDU errors with certain country chips, we will document and design our codebase to seamlessly switch to a local fork of `dmrtd` (via `pubspec.yaml` `dependency_overrides`) to insert debug logs when necessary.
2. **Dedicated `NfcScannerScreen`.**
   - *Rationale:* NFC scanning requires the user to hold the phone steadily against the passport chip for several seconds. We need a dedicated UX to guide them and show progress, rather than doing it invisibly.

## Risks / Trade-offs

- **Risk:** Some modern ID cards exclusively use PACE and reject BAC. `dmrtd` PACE support can be inconsistent depending on the chip.
  - *Mitigation:* We will try PACE first if the package supports it, then fallback to BAC. If we encounter issues, we will use our local fork to diagnose the specific APDU failure.
- **Risk:** NFC antenna placement varies by device.
  - *Mitigation:* Provide clear, animated UI instructions asking the user to slowly slide the phone over the passport.
