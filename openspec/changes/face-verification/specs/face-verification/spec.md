## ADDED Requirements

### Requirement: Capture Live Camera Feed
The system SHALL display a real-time camera feed to the user to capture their live selfie.

#### Scenario: Camera Preview Active
- **WHEN** the user enters the face verification flow
- **THEN** the system requests camera permissions and displays the live video preview

### Requirement: Active Liveness Detection
The system SHALL evaluate the live camera feed for active liveness indicators (blinking, smiling, turning head) to ensure the user is present and cooperative.

#### Scenario: User Blinks Successfully
- **WHEN** the system prompts the user to blink and the user blinks
- **THEN** the system registers the active liveness step as successful and moves to the next verification stage

#### Scenario: User Smiles Successfully
- **WHEN** the system prompts the user to smile and the user smiles
- **THEN** the system registers the active liveness step as successful and moves to the next verification stage

### Requirement: Passive Liveness (Anti-Spoofing)
The system SHALL evaluate the captured image using an anti-spoofing model to detect presentation attacks (e.g., photos, screens).

#### Scenario: Presentation Attack Detected
- **WHEN** the user holds up a photograph to the camera
- **THEN** the anti-spoofing model returns a spoof score and the verification fails

#### Scenario: Genuine Face Detected
- **WHEN** a real, live user looks at the camera
- **THEN** the anti-spoofing model returns a genuine score and the verification proceeds

### Requirement: 1:1 Face Matching
The system SHALL compare the captured live image with the reference image obtained from the passport's DG2 file and calculate a similarity score.

#### Scenario: Faces Match
- **WHEN** the captured selfie matches the DG2 reference image above the predefined similarity threshold
- **THEN** the face verification process succeeds

#### Scenario: Faces Do Not Match
- **WHEN** the captured selfie does not match the DG2 reference image
- **THEN** the face verification process fails and alerts the user
