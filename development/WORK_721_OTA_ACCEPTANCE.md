# REALM ALLIANCE 721 – End-to-end Android update acceptance
- Installed baseline: REALM ALLIANCE 720 on the Android test phone.
- Source: the verified 720 large-download fix, same application ID and original Android certificate.
- Version 721 is a no-save-migration test release to verify OTA: 720 launcher discovers 721, downloads ~132 MB without the old 8-second limit, verifies SHA-256 and APK certificate, opens Android system installer, and updates in place without deleting guest data.
- CI: Godot headless test, Android Gradle export and native bridge DEX check, verify keystore/certificate, sign, publish under realm-721-android, then promote on distribution/realm-715-test with SHA-256 and exact GitHub Release URL.
- Android install always needs user confirmation. Do NOT claim the on-device installer works until the user demonstrates installation.
- If 720 launcher reports a download error, use the new detailed error message to investigate. Do not trigger new manual APK replacement until diagnosing.
