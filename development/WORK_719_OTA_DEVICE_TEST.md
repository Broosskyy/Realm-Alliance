# REALM ALLIANCE 719 – OTA device acceptance

- Version 718 is installed on test phone. Version 719 is a signed same-app small release; preserve saved guest data and content packs.
- Release automation on `feature/work-719-ota-test`: original signing cert check, Godot 4.7.2, Android Gradle build, Java installer bridge presence, signed APK, GitHub prerelease `realm-719-android`, then content manifest OTA promotion.
- Android 718 launcher must see `app_update.version_code=719` with numeric JSON parsing, show an app download button, download the GitHub asset, validate size+SHA256, then invoke Android's installer. No silent installation.
- Device validation is still required: update button appears, 719 downloads, install permissions, Android upgrade, app data and content saved.
- NEVER push the private keystore to GitHub. Secrets remain only in GitHub Actions.
- If the 718 native FileProvider path check rejects Godot's user:// path, fix in a subsequent version and document the manual migration instead of claiming OTA succeeded.
