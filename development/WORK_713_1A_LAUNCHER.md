# Work 713.1A – sicherer Starter / Update Gate
Quelle aus Work 712 gesichert und isoliert; Live-Produktionsspiel 710/712 bleibt unverändert.

**Implementiert:** Startszene statt direktem Kampfstart, HTTPS-Testmanifest mit 8 Sekunden Timeout, Version- und Kanalprüfung, Retry, Offline/Gast-Zugang, Zugang zum vorhandenen Konto-Menü bei alten Spielständen, mobile Scroll-/Hochformat-/Querformat-UI. Android-Versionscode 713, Signatur und Paketname weiterhin unverändert.

**Wichtig:** Dies ist **713.1A**, kein fertiger Patch-Downloader. Die Progressbar ist während einer **echten Netzprüfung** unbestimmt, zeigt keine erfundenen Byte-Fortschritte. Das Manifest enthält bewusst keine Inhalts-Pakete und es wird kein Code nachgeladen. Die signierte 713-APK ist nicht erstellt; dazu braucht es den privaten Original-Android-Schlüssel. `main` und 712 wurden nicht überschrieben.

**Später 713.1B:** verifizierte Daten-/Grafikpakete per SHA-256, temporärer Download, atomare Aktivierung, Rollback, tatsächliche Verwendung im 2D-Spiel. **713.1C:** Android-Store-/APK-Systeminstallation, iOS-Store und Desktop-Updater (keine lautlosen Installationen). **713.1D:** optionaler Launcher-Login nach erreichbarem Backend. Ohne Server weiterhin Gast-/Offline-Spiel.

Quellen: `scenes/launcher713.tscn`, `scripts/launcher/{launcher713,update_gate713}.gd`, `data/update713_config.json` und `update713_manifest.json`, Test `tests/test_launcher713.gd`; `development/build_web713.py` für echte Exporte.

## Work 713.1B – echter erster Datenpatch
Separate getestete Quelle `feature/work-713-1b-content`. Die öffentliche HTTPS-Testmanifestquelle beschreibt **ein** neues JSON-Nachrichtenpaket. Der Launcher lädt die Datei bei Bedarf tatsächlich herunter (191 Bytes), zeigt echten Byte-Fortschritt, prüft SHA-256 und Datenformat, schreibt zunächst in eine temporäre Datei und schaltet nach Prüfung um. Ein fehlerhafter Patch wird verworfen; der vorherige Cache bleibt bestehen. Die Meldung wird aus dem persistenten Cache angezeigt und beim nächsten Start ohne erneuten Download wiederverwendet.

Scope ausdrücklich beschränkt auf **nicht-ausführbare Patch-News**. Noch **keine Live-2D-Assets** im eigentlichen Kampf und **keine App-Installation**, kein Produktions-Update-Service. Nächster Schritt: dieselben sicheren Inhaltspakete auch für 2D-PNG/Audio/Kataloge mit einem tatsächlich im Spiel konsumierenden Loader, plus Android-Gerätetest mit signiertem 713 APK. Während 713.1B wird weder aktueller Character712-Code noch der lokale SaveStore angerührt.
