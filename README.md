# SchoolFemboy Runaway

Godot 4.5.1 Android prototype.

## Build without a PC

This repository includes a GitHub Actions workflow at `.github/workflows/android.yml`.

1. Upload the project files to a GitHub repository.
2. Open **Actions**.
3. Select **Build Android APK**.
4. Press **Run workflow** (or push to `main`/`master`).
5. Download the `schoolfemboy-runaway-apk` artifact.

The workflow installs Java 17, Android SDK packages, Godot 4.5.1 export templates, configures Godot's Android SDK/JDK paths, creates a temporary development keystore, and builds an installable ARM64 APK.

The keystore is generated only inside the GitHub runner for test builds; it is not included in the repository.
