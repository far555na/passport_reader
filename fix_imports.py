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

# csca_state_view_model.dart
replace_in_file("lib/features/nfc_scanner/view_models/csca_state_view_model.dart", [
    ("import '../utils/passive_auth/csca_service.dart';", "import '../utils/csca_service.dart';"),
    ("import '../models/csca_data.dart';", "import '../models/csca_data.dart';")
])

# nfc_scanner_view_model.dart
replace_in_file("lib/features/nfc_scanner/view_models/nfc_scanner_view_model.dart", [
    ("import '../features/mrz_scanner/models/mrz_result.dart';", "import '../../mrz_scanner/models/mrz_result.dart';"),
    ("import '../repositories/nfc_passport_repository.dart';", "import '../repositories/nfc_scanner_repository.dart';"),
    ("import '../models/passive_auth_verification_result.dart';", "import '../models/passive_auth_verification_result.dart';"),
    ("import 'csca_provider.dart';", "import 'csca_state_view_model.dart';"),
    ("NfcPassportRepository _repository = NfcPassportRepository();", "NfcScannerRepository _repository = NfcScannerRepository();"),
    ("final cscaData = await ref.read(cscaIndexProvider.future);", "final cscaData = await ref.read(cscaStateViewModelProvider.future);"),
])

# nfc_scanner_screen.dart
replace_in_file("lib/features/nfc_scanner/views/nfc_scanner_screen.dart", [
    ("import '../providers/nfc_provider.dart';", "import '../view_models/nfc_scanner_view_model.dart';"),
    ("import '../features/mrz_scanner/view_models/mrz_state_view_model.dart';", "import '../../mrz_scanner/view_models/mrz_state_view_model.dart';"),
    ("import 'face_match_screen.dart';", "import '../../../screens/face_match_screen.dart';"),
    ("ref.read(nfcProvider.notifier)", "ref.read(nfcScannerViewModelProvider.notifier)"),
    ("ref.watch(nfcProvider)", "ref.watch(nfcScannerViewModelProvider)"),
])

# widgets
replace_in_file("lib/features/nfc_scanner/widgets/data_match_card.dart", [
    ("import '../features/mrz_scanner/models/mrz_result.dart';", "import '../../mrz_scanner/models/mrz_result.dart';"),
])
replace_in_file("lib/features/nfc_scanner/widgets/passport_details_card.dart", [
    ("import '../features/mrz_scanner/models/mrz_result.dart';", "import '../../mrz_scanner/models/mrz_result.dart';"),
])

# face_match_repository.dart
replace_in_file("lib/repositories/face_match_repository.dart", [
    ("import '../utils/image_preprocessor.dart';", "import '../core/utils/image_preprocessor.dart';"),
    ("import '../utils/face_match_utils.dart';", "import '../core/utils/face_match_utils.dart';"),
])

# authentication_screen.dart
replace_in_file("lib/screens/authentication_screen.dart", [
    ("import 'nfc_scanner.dart';", "import '../features/nfc_scanner/views/nfc_scanner_screen.dart';"),
    ("NfcScanner()", "NfcScannerScreen()"),
])

# face_match_screen.dart
replace_in_file("lib/screens/face_match_screen.dart", [
    ("import '../providers/nfc_provider.dart';", "import '../features/nfc_scanner/view_models/nfc_scanner_view_model.dart';"),
    ("ref.watch(nfcProvider)", "ref.watch(nfcScannerViewModelProvider)"),
])

