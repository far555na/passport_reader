import os, glob

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

for root, dirs, files in os.walk("lib"):
    for file in files:
        if file.endswith(".dart"):
            filepath = os.path.join(root, file)
            # Find the relative path depth to core/utils/mrz_format_utils.dart
            
            # Simple replacements, since it was previously at `lib/features/mrz_scanner/utils/mrz_format_utils.dart`
            # For MRZ Scanner files:
            replace_in_file(filepath, [
                ("import '../utils/mrz_format_utils.dart';", "import '../../../core/utils/mrz_format_utils.dart';"),
                ("import '../../mrz_scanner/utils/mrz_format_utils.dart';", "import '../../../core/utils/mrz_format_utils.dart';"),
            ])
