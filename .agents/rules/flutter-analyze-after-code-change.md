---
trigger: always_on
---

# Flutter Analyze After Code Changes

Whenever you make any code change in this Flutter project, you must run Flutter analysis before finishing the task.

## Required behavior

After modifying any Dart, Flutter, Android, iOS, pubspec, or build-related file:

1. Run analysis:

   * If the project uses FVM, run:

     ```bash
     fvm flutter analyze
     ```

   * Otherwise, run:

     ```bash
     flutter analyze
     ```

2. If analysis reports errors or warnings caused by your changes, fix them.

3. Re-run the same analyze command after fixing.

4. Do not finish the task until:

   * `flutter analyze` passes, or
   * you clearly explain why it cannot be fixed automatically.

## Important rules

* Do not ignore analyzer errors.
* Do not claim the task is complete if analysis still fails.
* Do not modify unrelated files just to make analysis pass.
* Prefer minimal fixes that directly address the analyzer output.
* If existing analyzer issues were already present before your changes, report them separately and do not mix them with new issues.
