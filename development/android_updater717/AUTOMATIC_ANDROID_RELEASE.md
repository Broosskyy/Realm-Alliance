# Einmalige Einrichtung – danach GitHub baut und veröffentlicht automatisch

GitHub-Build ist unter
[REALM Android Auto Release](https://github.com/Broosskyy/Realm-Alliance/actions/workflows/realm-android-auto-release.yml)
vorbereitet. **Aktuell fehlt nur das private GitHub-Actions-Secret**
`REALM_ANDROID_KEYSTORE_BASE64`. Ohne Secret bricht die Pipeline absichtlich ab.

## Einmaliger Vorgang auf deinem eigenen PC
1. Das ursprüngliche Quellarchiv `REALM_ALLIANCE_709_Quellen.zip` (oder entsprechend benannte Quelle 709 mit dem ursprünglichen Keystore) lokal behalten. Der Private Key wird NICHT in den öffentlichen GitHub-Code übertragen.
2. Installiere [GitHub CLI](https://cli.github.com/) und Java JDK 17 (für `keytool`), falls nicht vorhanden. Melde dich im Terminal einmal mit `gh auth login` an.
3. Lade aus dem eigenen GitHub-Repository die Datei `development/android_updater717/setup_signing_secret.py` herunter.
4. Starte im Terminal:
   `python setup_signing_secret.py "Pfad/zur/REALM_ALLIANCE_709_Quellen.zip"`
   Der Helfer prüft den Original-Fingerprint und überträgt den Keystore als **verschlüsseltes GitHub-Actions-Secret**, ohne ihn anzuzeigen oder ins Repository zu schreiben.
5. Öffne [Actions: Android Auto Release](https://github.com/Broosskyy/Realm-Alliance/actions/workflows/realm-android-auto-release.yml) und starte einmal **Run workflow**, Branch **release/android-test**. Für spätere App-Versionen löst ein VersionCode-Anstieg im Release-Branch den Prozess automatisch aus.

## Automatik danach
- Android-Versionscode erhöhen und den neuen Code auf `release/android-test` pushen.
- GitHub lädt die geprüfte Godot-Android-Vorlage und baut die APK einschließlich Installer-Bridge.
- GitHub prüft Paketname und nativen Installer, signiert mit dem richtigen **Originalschlüssel**, prüft die APK-Signatur und legt eine GitHub-Release-Datei an.
- **Nur nach erfolgreichem Release** erhöht ein eigener Schritt die Versionsnummer und SHA256 im bereits von 717 verwendeten Update-Manifest `distribution/realm-715-test`.
- Die installierte Version 717 lädt das neuere APK herunter; Android fordert die Bestätigung der Installation. Keine stille Installation ohne Systemdialog.
- Keine APK nötig für kompatible PNG-/JSON-Inhaltsänderungen; diese gehen weiterhin über den Content-Updater.

## Sicherheit / Fehler
- Schlägt Build/Signatur/Release fehl oder fehlt das Secret, wird kein neues Android-Update beworben.
- Den originalen privaten Schlüssel separat sicher offline sichern. GitHub Secrets ist ein Mechanismus zur sicheren Speicherung innerhalb der CI, ersetzt aber ein Offline-Backup nicht.
- Das erste Ende-zu-Ende-Update 717 → 718 **muss auf dem Android-Gerät geprüft werden**, bevor wir den Installationsablauf als verifiziert bezeichnen.
