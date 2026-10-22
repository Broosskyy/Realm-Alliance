# REALM ALLIANCE 717 – Android APK Update direkt aus dem Launcher

## Verbindliches Verhalten
- Primär den sicheren, vorhandenen 715/716 PNG-/JSON-Content-Updater verwenden, ohne APK.
- Bei `latest_app_version_code > 717` und passendem `app_update`-Metadatenobjekt eine neue Android-Binary von einer **festen offiziellen GitHub-Releases-URL** herunterladen (nicht von einem frei wählbaren Host).
- Metadaten: `version_code`, `bytes`, `sha256`, `url`, `package`, `certificate_sha256`. Max. 350 MB, Streaming-Hashing, gespeicherte Partials nicht als fertige APK behandeln.
- GDScript lädt nur bei einem expliziten Installationswunsch herunter und zeigt den Fortschritt. Vor Übergabe SHA-256 und exakte Größe überprüfen.
- **Der native Android-Bridge-Code muss zusätzlich (!) Paketname, Versionscode und den tatsächlichen Android-Signaturzertifikats-Fingerprint vor dem Installer prüfen.** Der SHA256 in einem mutablen JSON-Manifest allein reicht NICHT als Authentisierung einer APK.
- Installation erfordert Android-Systemdialog und gegebenenfalls Erlaubnis für Installationen aus dieser Quelle. Keine stille Installation, keine Deinstallation, keine Änderung der package-ID oder des Zertifikats.
- Auf Web/PC nur Hinweis; keine apk-Installation über OS.shell_open/von Web.
- Versions- und Patch-Testkanal von der Live-Vercel-Seite getrennt halten.
- Es braucht EINMAL eine neue signierte 717-APK, weil die vorhandene installierte 716 die native Installer-Bridge noch nicht mitbringt.
- Android-Geräte-End-to-End (installiert 717 -> erhält tatsächlich signiertes 718 von GitHub Release und Android bestätigt, Save bleibt erhalten) ist ein eigener Akzeptanztest; CI und Quellcode allein dürfen ihn nicht als bestanden ausgeben.

## Releasevertrag
Der signierte Release `realm-718-android` enthält die Datei `REALM_ALLIANCE_718.apk`. Die distributierte Update-Datei wird **erst nach Upload und Signaturprüfung** im Manifest veröffentlicht. Private Keystores werden NIE ins Repository kopiert. Für Produktionssicherheit später signiertes Update-Manifest oder unabhängiger Vertrauensanker zusätzlich zur strengen Android-Zertifikatsprüfung.
