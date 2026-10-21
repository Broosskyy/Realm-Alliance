# REALM ALLIANCE 714 · echter 2D-Inhaltsupdate-Pilot

Basis: 713.1B, der aktuelle Tap-/Idle-Kampf bleibt unverändert. Der neue Code liegt im separaten Entwicklungsbranch `feature/work-714-asset-updater`. Der Release-Kanal `distribution/realm-714-test` ist ein **separater** mutabler Veröffentlichungsbranch, auf den der Launcher per HTTPS zeigt.

## Umgesetzt
- Nach Start HTTPS-Manifest 2 laden, nur einen streng definierten `svg_announcement`-Assettyp akzeptieren.
- Download des echten, ca. 1 kB großen SVG-Bildpakets (JSON mit SVG 480×128), SHA-256 und Größen-/Schema-/Formatprüfung; keine Remote-GDScripts, keine APK-Injektion.
- Versionsabhängig aktivieren, im `user://`-Cache atomar ablegen, vorheriges gültiges Paket als Backup behalten, bei Fehler Offline-Fallback.
- Das heruntergeladene **2D-Bild wird real als TextureRect im Launcher und auf der Seite Reise im vorhandenen Spiel angezeigt**. Die Nachricht daneben stammt aus dem selben geladenen Datenpaket.
- Wechsel von `graphics-v1` nach `graphics-v2` kann **allein durch Manifeständerung auf dem Distribution-Branch** stattfinden. Das App-Binary, die Questlogik und Savefiles bleiben unverändert. Versioncode 714 ist einmalig für die neue Loader-Engine erforderlich.

## Sicherheit / Testumfang
- Nur Testkanal, fester URL-Prefix auf GitHub Raw, SHA-256-Manifest, keine beliebigen Remote-URLs, maximal 16 kB pro Paket, kleine whitelist-ähnliche SVG-Form und Bilddecoder.
- Paketkontrolle vor und nach Schreiben auf temporäre Datei; Rollback auf letzte gültige Version.
- Keine automatisierte APK-Installation; kein Contentupdate neuer Klassen-/Combat-Code. Nur Grafik/News testbar.
- Ein reales installierbares Android-Update **muss denselben Original-709-Signierschlüssel verwenden**. Private Schlüssel keinesfalls nach GitHub.
- Für eine vollständige Live-Patchplattform später signierte Manifest-Metadaten, skalierbares CDN, echte PNG-/Audio-Packs, asset-bewusste Kataloge, Versionskompatibilität und Android-/iOS-Gerätetests ergänzen.

## Nachweisplan
1. Einmalig Godot 714 Web/APK mit `graphics-v1` kompilieren; SHA des Binärstands notieren.
2. App auf Android starten und 2D-Banner v1 laden und in Reise anzeigen; Offline-Test.
3. Ohne Code-Commit/Build/Neue APK: **nur** `data/update714_manifest.json` auf dem Distribution-Branch auf `graphics-v2` ändern.
4. App erneut starten: Manifest und v2-Paket werden geladen, neue Grafik + Text erscheinen im Launcher und in Reise, alter Save bleibt erhalten. Online- und Realgerät-Nachweise getrennt protokollieren.
