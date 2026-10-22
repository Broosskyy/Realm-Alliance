# REALM ALLIANCE 715 – Content-first und Gast-Neustart

## Umfang
- 714 bleibt installierbar; 715 als notwendiges **einmaliges Runtime-Upgrade** für neue Asset-Typen.
- HTTPS Manifest v3 mit max. zehn typisierten Packs; strikte ID-/URL-/Schema-/SHA256-/Dateigrößen-/PNG-Dekoder-Prüfung.
- Zwei getrennte Testinhalte auf `distribution/realm-715-test`: ein transparentes PNG-Kristall-Szenenobjekt und ein JSON-Katalog für Reise.
- Beide Inhalte werden in `user://realm_content715` verifiziert und gecacht. Vorherige gültige Version bleibt als Fallback; unvollständiges Paket wird nie als gültig dargestellt. Spielstände bleiben unabhängig.
- Remote-PNG ersetzt nur ein vorhandenes, dekoratives Kampfszenenobjekt (keine Kampfwerte/Save-Daten). Remote-Katalog erscheint unter Reise.
- Keine Remote-Ausführung von GDScript, keine automatisch installierten APKs; Offline-Spiel bleibt erhalten.
- Gast-Spielstand zurücksetzen unter `Mehr`, bestätigen erforderlich. Konto/Online-Token sperrt Gastreset, aktives QA-Testlabor ebenfalls. Tombstone blockiert Wiederbelebung durch Webjournal/Backup und verhindert Auto-Speichern des alten Modells beim Scene-Wechsel.
- Nicht behaupten, dass alle Sprite-/Audio-/Questformate schon universell unterstützt werden: 715 deckt **PNG+JSON als erweiterbare sichere Grundlage** ab. Audio und Animationen anschließend als zusätzliche geprüfte Formate ergänzen.

## Test
- Native Godot Tests: Versionsprüfung, PNG-Dekodierung, JSON-Katalog, ungültige Hashes, Cache-Neustart, Speicherreset/Journal, Gast-Button und optional Engine-Scene-Laden.
- GitHub Actions exportiert Web und **unsignierte** Android-APK. Die aus dem originalen 709-Keystore lokal signierte APK ist erforderlich, um alte Version ohne Datenverlust zu aktualisieren.
- Live-End-to-End-Update nach Installation separat auf Android bestätigen. GitHub-Verfügbarkeit allein ersetzt diesen Test nicht.
