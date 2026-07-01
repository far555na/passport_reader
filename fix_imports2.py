import os, glob

def replace_in_file(filepath, replacements):
    with open(filepath, "r") as f:
        content = f.read()
    new_content = content
    for old, new in replacements:
        new_content = new_content.replace(old, new)
    if new_content != content:
        with open(filepath, "w") as f:
            f.write(new_content)
        print(f"Updated {filepath}")

# utils files that were in passive_auth/
for file in glob.glob("lib/features/nfc_scanner/utils/*.dart"):
    replace_in_file(file, [
        ("../../models/", "../models/"),
        ("../../utils/certificate_utils.dart", "certificate_utils.dart"),
        ("../../utils/oid_mapper.dart", "oid_mapper.dart"),
        ("../../utils/ec_crypto_helper.dart", "ec_crypto_helper.dart"),
    ])

# nfc_scanner_repository.dart
replace_in_file("lib/features/nfc_scanner/repositories/nfc_scanner_repository.dart", [
    ("import '../models/", "import '../models/"), # wait this might be okay
    ("import '../utils/passive_auth/passive_authenticator.dart';", "import '../utils/passive_authenticator.dart';"),
    ("import '../services/nfc_service.dart';", "import '../services/nfc_service.dart';"),
])

# nfc_service.dart
replace_in_file("lib/features/nfc_scanner/services/nfc_service.dart", [
    ("import '../models/", "import '../models/"),
    ("import '../utils/image_decoder.dart';", "import '../../../core/utils/image_decoder.dart';"),
])

# nfc_result.dart and other models
for file in glob.glob("lib/features/nfc_scanner/models/*.dart"):
    replace_in_file(file, [
        ("import '../utils/image_preprocessor.dart';", "import '../../../core/utils/image_preprocessor.dart';"),
    ])

# screens/face_match_screen.dart (missed one replace?)
replace_in_file("lib/screens/face_match_screen.dart", [
    ("nfcProvider", "nfcScannerViewModelProvider"),
])

