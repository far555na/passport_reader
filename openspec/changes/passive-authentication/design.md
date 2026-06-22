## Context

Currently, the passport reader extracts the MRZ data and uses BAC/PACE to establish a secure channel to the NFC chip. It successfully reads Data Groups (e.g., DG1, DG2) and the Document Security Object (EF.SOD). However, it stops there. It does not perform Passive Authentication (PA) to verify that the EF.SOD is signed by a valid Country Signing Certificate Authority (CSCA) and that the hashes in the EF.SOD match the data read from the DGs.

## Goals / Non-Goals

**Goals:**
- Parse the ASN.1 and CMS structure of the EF.SOD file.
- Extract the LDSSecurityObject to retrieve DG hashes.
- Extract the Document Signer (DS) certificate and verify the digital signature of the EF.SOD.
- Compare computed hashes of DG1/DG2 against the extracted hashes from EF.SOD.

**Non-Goals:**
- Implementing an automated CSCA Master List download and sync mechanism. For now, we will focus on extracting and verifying the DS signature and the hashes. We may bundle a static CSCA certificate or just verify the signature against the extracted DS cert (to prove integrity, even if full trust chain isn't established yet).
- Active Authentication (AA) or Chip Authentication (CA) are out of scope for this specific change.

## Decisions

**1. ASN.1 / CMS Parsing Strategy**
- *Decision*: We will implement a custom Dart-based ASN.1 parsing utility specifically for the ICAO SOD CMS structure using the existing `pointycastle` dependency.
- *Rationale*: While native bridges (iOS Security / Android BouncyCastle) are more robust, staying in Dart keeps the project architecture simpler and cross-platform without needing complex MethodChannels for this specific data structure. We only need a subset of CMS parsing (specifically `SignedData`, `SignerInfo`, `EncapsulatedContentInfo`, and `Certificate`).

**2. Hash Algorithms**
- *Decision*: We will dynamically support SHA-1, SHA-224, SHA-256, SHA-384, and SHA-512 based on the OID found in the LDSSecurityObject.
- *Rationale*: Different countries use different hashing algorithms for their DGs. `pointycastle` provides all these digest algorithms.

## Risks / Trade-offs

- **[Risk] Dart ASN.1 Parsing Complexity** → ASN.1 DER parsing is notoriously strict and complex. *Mitigation*: We will write extensive unit tests for the SOD parser using sample SOD files or mock data to ensure we correctly navigate the ASN.1 tags (Sequence, Set, Octet String, OID).
- **[Risk] Missing CSCA Master List** → If we only verify the DS signature without chaining to a CSCA, we cannot be 100% sure the passport isn't a complete clone (though we know the data matches the SOD). *Mitigation*: Clearly indicate the level of verification in the UI (e.g., "Data Integrity Verified" vs "Issuer Trusted").
