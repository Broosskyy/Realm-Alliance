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


## Nachgewiesener Stand / reproduzierter 717-Bug

- Godot-Real-JSON-Test zunächst 7/8: JSON-Zahlen aus `JSON.parse_string` sind `float` statt `int`; der auf dem Gerät installierte 717-Updater `AppUpdate717.check()` verwirft dadurch korrekte Remote-App-Metadaten. **Der vorhandene 717-Binary kann nicht durch Inhaltsdateien gepatcht werden.**
- Fix Commit `d2a5dfbabe6dc773bcadcf37f1444f561e99bec2`: strenge `_whole_number`-Validierung für `version_code` und `bytes` (finite, keine Bruchteile), in 718 kompiliert.
- CI `39864350465`: **8/8 Godot-OTA-Tests erfolgreich**, Android Gradle kompiliert und Bridge im DEX geprüft, versionCode 718 und Paket-ID bestätigt.
- APK wurde am 22.10.2026 lokal mit originalem 709-Keystore signiert. SHA256: `22ed986efdc2fb66cb52b5781756805a77e99193a4357b1cde06a2dce5bb6867`, 131748445 Bytes, cert SHA256 `317eb8e2e5bf1c8a5bd8b0433a7536bcc903da97d5ba437c20e9474cdd4af219`.
- **RELEASE NICHT VERÖFFENTLICHT**. Die GitHub-Actions-Signing-Pipeline ist korrekt fail-closed, weil Secret `REALM_ANDROID_KEYSTORE_BASE64` nicht eingerichtet ist. Keine Update-Version im `distribution/realm-715-test` Manifest ankündigen, solange kein geprüftes Release-Asset unter `realm-718-android` existiert.
- Zur Laufzeit befindet sich bereits 717 auf dem Android-Gerät. 717→718 benötigt einmalig wieder manuelles Installieren; danach 718→719 über Launcher testen, **erst wenn 719 auf den gepinnten Release-URL veröffentlicht ist**. Kein Android-OTA-Gerätetest wurde bisher bestanden.
