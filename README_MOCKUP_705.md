# REALM ALLIANCE · 705 Rekonstruktion

Stand: 20.10.2026. Neu aus den gesicherten 704-Quellen aufgebaut. Die ursprüngliche 705-Abgabe war nicht mehr verfügbar. Dies ist keine bytegleiche Wiederherstellung und kein vollständiger Online-7.1–7.5-Stand.

## Änderungen gegenüber dem gesicherten 704

- Neuer gemalter Ruinenhof mit zentralem Steinpodest in der Helden- und Begleiterdetailansicht; vorhandene modulare Figuren bleiben erhalten.
- Heldenansicht mit getrennten Anzeigen für Kraft, HP, Angriff und Verteidigung. Zahlen stammen vom aktiven Helden; für inaktive Helden werden keine Werte erfunden.
- Die vier Ausrüstungsslots zeigen die tatsächlich angelegten Gegenstände. Leere Slots sind als leer markiert. Antippen öffnet die passende Kategorie; Ausrüsten und Ablegen aktualisieren die Anzeige.
- Skills mit bebilderter Detailkarte, vier auswählbaren Skills, tatsächlicher Skillstufe und Fortschrittsbalken. Aufwertung nutzt weiterhin echte Kosten und Freischaltbedingungen.
- Aufgaben und Erfolge als bebilderte Karten mit tatsächlichem Fortschritt, Belohnungen und gesicherten Abholbedingungen.
- Talente mit Bild, Rangbalken, freien Punkten und tatsächlichen Auswirkungen auf die Werte.
- Dungeons mit passenden Illustrationen; Abschlüsse, Bestzeiten, Freischaltung und Eintritt bleiben an den vorhandenen Spielstand gebunden.
- Zurück-Schaltflächen auf 96×88 logische Pixel vergrößert. Ein beim Öffnen zu hoch berechnetes Skillfenster wurde behoben und erneut geprüft.

## Verifikation dieses neuen Standes

- Godot 4.7.2: 28 Testsuiten, **1.659/1.659 Prüfungen bestanden**. Protokolle: development/checks_705.json.
- Darin 104 neue Prüfungen: leere/belegte/geänderte Ausrüstungsslots; Aufgaben, Talente, Dungeons, Skills und Ausrüstung bei 320×568, 390×844, 430×932 und 1280×720; Fenstergrenzen, Zurück-Aktionen und unveränderte Ressourcen/Kampfzustände.
- Web- und Android-Debugexport erfolgreich. Die normale Webfassung startet die reguläre Spielszene; der QA-Adapter und Tests sind aus beiden Abgaben ausgeschlossen.
- Android: Paketkennung com.avenor.realmalliance.mockuptest, Versioncode 705, Versionname 0.7.0-mockup.5-reconstructed, ARM64, signiert mit demselben mitgelieferten öffentlichen Testschlüssel wie 704. APK-Signatur v2/v3 und 16-KiB-Ausrichtung geprüft.
- **Keine erfolgreiche neue Browser-Sicht- oder Touchprüfung:** Der lokale Browserstart wird durch die Ausführungsumgebung bei socket() blockiert. Frühere 704/705-Browserzahlen wurden nicht als neue Ergebnisse übernommen.
- Kein Test auf einem echten Android-Gerät, keine Geräte-FPS-Messung. Keine pixelgenaue Übereinstimmung mit den Master-Mockups bestätigt.

## Abgaben

- REALM_ALLIANCE_705_Rekonstruktion.apk
- REALM_ALLIANCE_705_Rekonstruktion_Web.zip
- REALM_ALLIANCE_705_Rekonstruktion_Quellen.zip
- REALM_ALLIANCE_705_Rekonstruktion_Bericht.md

Die APK aktualisiert die separate Anwendung „REALM Mockup Test“ 704. Eine andere REALM-Anwendung wird dadurch nicht ersetzt. Vorhandene Speicherlogik wurde nicht umgestellt. Die Quellen enthalten den öffentlichen Debugschlüssel für reproduzierbare Testupdates, keine persönlichen Spielstände oder Zugangsdaten.

## Weiter offen

Zusätzliche konsistente Angriffs-Zwischenbilder, vollständige Outfit-Sets für andere Helden, weitere Angleichung der Unterfenster an die Master-Mockups und vollständiges Online-7.1–7.5. Kein GitHub-Push und keine öffentliche Bereitstellung dieser Rekonstruktion ausgeführt.

## Selbst bauen

Godot 4.7.2 und passende Exportvorlagen installieren. Projekt godot/realm_alliance/project.godot öffnen und importieren. Android SDK/Java im Godot-Editor konfigurieren. Danach:

    python3 development/run_checks.py --godot /pfad/zu/godot --report checks.json
    python3 development/build_705.py --godot /pfad/zu/godot --output /absoluter/ausgabeordner

Die Webdateien müssen über einen Webserver ausgeliefert werden. Das Web-ZIP enthält START_WEB.py für einen lokalen Testserver. Tests und der Browser-QA-Adapter gehören nur zum Quellpaket.
