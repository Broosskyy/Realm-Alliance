# REALM ALLIANCE · Mockup Test 704

Separater Teststand vom 20.10.2026 auf Basis des gesicherten 702-Animationskandidaten. Die ungesicherten 7.5-Quellen waren nach einem Umgebungsreset nicht mehr verfügbar. Dieser Quellstand enthält deshalb ausdrücklich keine vollständige 7.1–7.5-Online-Implementierung und ersetzt keine neuere APK.

Android: Anwendung `REALM Mockup Test`, Paket `com.avenor.realmalliance.mockuptest`, Versioncode 704, Versionname `0.7.0-mockup.4-test`. Durch die eigene Paketkennung bleibt die bestehende Preview samt Spielstand separat erhalten. Der Test startet mit einem eigenen frischen Spielstand.

## Änderungen

- Monstergröße aus der tatsächlichen stehenden Silhouette statt aus breiten Angriffs-/Todesbildern; große Bosse füllen die rechte Arenaseite. Hero-Skalierung auf langen Displays begrenzt. Kein GPU-Auslesen beim Layout.
- AUTO-Standardangriffe mit 0,92 s Mindestabstand statt 0,46 s; kürzere Vorwärtsschritte der Kombokette. Kontinuierliche getrennte Schwertbahn bleibt erhalten. Manuelle Trefferzeiten und Skillkosten bleiben unverändert.
- Wesen als eigene Sammlung mit zwei Spalten, echten Besitz-/Levelanzeigen und seitlichen Werkzeugen; eigene Helden-/Begleiterdetails mit modularen Figuren. Wechsel erhält den Kampfzustand.
- Eigene Ausrüstungsseite mit Kategorien, großer Illustration, echten Werten und Anlegen/Ablegen/Verbessern.
- Vollständiges getragenes Realmwächter-Outfit für die Brustpanzer mit sechs Posen und eigenen Hand-/Kopfankern; keine Brustpanzer-Inventarminiatur am Realmwächter. Diadem verkleinert und auf die Stirn versetzt. Andere Helden behalten ihre bisherigen Rüstungsschichten.
- Mehr-Menü mit neun bebilderten funktionalen Kacheln; Shop/Schmiede als größere Spielseiten mit zwei Angebotsspalten; kompakteres Inventar; Weltkarte mit verbundenen Etappenknoten.
- Sechs neue Golem-Posen, sechs Menüillustrationen, sechs Outfit-Posen; vollständige Fonts gegen fehlende Glyphen.

## Prüfen und bauen

Godot 4.7.2: `godot/realm_alliance/project.godot` öffnen. Nach einmaligem Editor-Import:

`python3 development/run_checks.py --godot /pfad/zu/godot --report checks.json`

27 Suiten / 1.555 Prüfungen bestanden. Browserprüfung mit tatsächlich laufendem Godot bei 390×844 sowie Ansichten bei 320×568, 360×800 und 430×932; elf zusätzliche Touch-/Browserprüfungen bestanden. APK-Signatur und ZIP-Ausrichtung geprüft. Kein Test auf einem echten Android-Gerät und keine Geräte-FPS-Messung.

Der normale Web-/Android-Export schließt `tests/*`, `production/*` und `work70/*` aus. `tests/review702.gd` ist nur ein ausgeschlossener Browser-QA-Adapter. Keine Testdatenbank und keine persönlichen Spielstände sind enthalten.

Über Mehr → QA-Testlabor lassen sich im Debugbuild die Inhalte mit einem temporären Profil ansehen; diese Testaktionen überschreiben den normalen Spielstand nicht.

Die Angriffe verwenden weiter diskrete Körperposen. Weitere konsistente Zwischenbilder und vollständige Outfit-Sets für die übrigen Helden sowie die vollständige Angleichung aller Unterfenster bleiben offen. Die Mockups wurden als Layout-/Art-Referenz benutzt; es wird keine pixelgenaue oder vollständige Übereinstimmung behauptet.
