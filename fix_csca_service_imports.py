import os

def replace_in_file(filepath, replacements):
    try:
        with open(filepath, "r") as f:
            content = f.read()
    except Exception:
        return
    new_content = content
    for old, new in replacements:
        new_content = new_content.replace(old, new)
    if new_content != content:
        with open(filepath, "w") as f:
            f.write(new_content)
        print(f"Updated {filepath}")

replace_in_file("lib/features/nfc_scanner/view_models/csca_state_view_model.dart", [
    ("import '../utils/csca_service.dart';", "import '../services/csca_service.dart';")
])
