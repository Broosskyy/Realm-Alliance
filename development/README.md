# Public preview signing key

`realm-preview-debug.keystore` is an intentionally public, non-production Android debug signing identity. The standard development alias/password are `androiddebugkey` / `android`. This is NOT a production signing credential and must never sign a Play Store release.

The previous pipeline generated a fresh key for each job. The delivered 6.1 APK certificate differs from the initial 6.2 certificate; its private key is not available from those APKs. For that reason Work 6.2 uses `com.avenor.realmalliance.preview` and installs next to the old `com.avenor.realmalliance.poc` app. Do not uninstall the old app to test the preview: that could remove the only copy of its Android-private saves.

Future preview builds reuse this key and package identity, enabling updates without deleting the preview's saves. The original Android app's private data cannot be read automatically by another package. Transfer an existing exported JSON backup via **Mehr → Stand importieren**. If no backup exists, obtaining the old app's private save requires access to that app/device (for a debuggable install, ADB `run-as` can be used); the agent cannot retrieve it from the APK file.

Web builds keep the existing project name and support V1-to-V2 migration when served from the same browser storage origin. V1 source files remain unmodified. Import/export supports moving V1/V2 JSON backups between accessible environments, with validation and explicit confirmation before replacement.
