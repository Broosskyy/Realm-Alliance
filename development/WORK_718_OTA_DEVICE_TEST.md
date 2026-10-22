# REALM ALLIANCE 718 – On-device 717 → 718 Updateprobe

## Scope
- App-Versioncode 718, gleicher Package-Name `com.avenor.realmalliance.mockuptest`, dieselbe Signatur wie 709–717.
- Keine Änderung an Speicherformat, Save-Rücksetzung oder dem JSON/PNG-Contentkanal.
- Version 718 ist absichtlich ein kleines Runtime-Release zum Nachweis der 717-Android-Updaterfunktion.
- Eine Veröffentlichung auf `realm-718-android` ist nur erlaubt, wenn der vorher lokal oder als GitHub Action erstellte Build mit der ORIGINALEN Signatur SHA256 `317eb8e2e5bf1c8a5bd8b0433a7536bcc903da97d5ba437c20e9474cdd4af219` signiert ist.
- GitHub Actions darf KEINE Ersatzkeystore generieren. Signing-Key nur durch private GitHub-Actions-Secret `REALM_ANDROID_KEYSTORE_BASE64` beziehen. Falls Secret fehlt, nicht veröffentlichen und keine Manifest-Änderung ausführen.
- Nach erfolgreichem Release wird im Manifest auf `distribution/realm-715-test` `latest_app_version_code=718` und `app_update` (Pin-URL, bytes, SHA-256, Package, Cert, Versionscode) gesetzt. DAVOR muss das Manifest auf 715 bleiben, um keinen falschen Download zu bewerben.
- Auf installiertem 717: „Updateprüfung wiederholen“ → „Android-App-Update herunterladen“ → Fortschritt → nach Validierung Android-Systeminstaller → Bestätigen → Version 718. Die alte APK darf NICHT deinstalliert werden.
- Prüfen: Spielstand, Gast, 2 Contentpakete, realer Versionscode. Ein erfolgreicher CI-Build allein beweist noch keine erfolgreiche Geräteinstallation.
