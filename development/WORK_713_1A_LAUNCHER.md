# Work 713.1A – sicherer Starter / Update Gate
Quelle aus Work 712 gesichert und isoliert; Live-Produktionsspiel 710/712 bleibt unverändert.

**Implementiert:** Startszene statt direktem Kampfstart, HTTPS-Testmanifest mit 8 Sekunden Timeout, Version- und Kanalprüfung, Retry, Offline/Gast-Zugang, Zugang zum vorhandenen Konto-Menü bei alten Spielständen, mobile Scroll-/Hochformat-/Querformat-UI. Android-Versionscode 713, Signatur und Paketname weiterhin unverändert.

**Wichtig:** Dies ist **713.1A**, kein fertiger Patch-Downloader. Die Progressbar ist während einer **echten Netzprüfung** unbestimmt, zeigt keine erfundenen Byte-Fortschritte. Das Manifest enthält bewusst keine Inhalts-Pakete und es wird kein Code nachgeladen. Die signierte 713-APK ist nicht erstellt; dazu braucht es den privaten Original-Android-Schlüssel. `main` und 712 wurden nicht überschrieben.

**Später 713.1B:** verifizierte Daten-/Grafikpakete per SHA-256, temporärer Download, atomare Aktivierung, Rollback, tatsächliche Verwendung im 2D-Spiel. **713.1C:** Android-Store-/APK-Systeminstallation, iOS-Store und Desktop-Updater (keine lautlosen Installationen). **713.1D:** optionaler Launcher-Login nach erreichbarem Backend. Ohne Server weiterhin Gast-/Offline-Spiel.

Quellen: `scenes/launcher713.tscn`, `scripts/launcher/{launcher713,update_gate713}.gd`, `data/update713_config.json` und `update713_manifest.json`, Test `tests/test_launcher713.gd`; `development/build_web713.py` für echte Exporte.
