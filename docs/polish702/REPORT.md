# REALM ALLIANCE · 0.7.0-polish.2 (APK 702)

Lokaler Qualitätspatch zu Work 7.0 · 19.10.2026.

## Änderungen

- Touch-Scrollen verarbeitet echte ScreenTouch/ScreenDrag-Ereignisse vor den untergeordneten Buttons. Eine sichtbare innere Liste übernimmt die Geste; Ziehen bricht einen laufenden Buttondruck ab. Wischschwelle, begrenztes Nachlaufen und feste Navigation sind gemeinsam umgesetzt. Mausrad bleibt bedienbar.
- Sammlung, Shop, Schmiede, Dungeons, Reise, Aufgaben, Erfolge und Einstellungen verwenden eine gemeinsame Spielansicht mit eigenem Zurück-Header. Die native verschiebbare Fenstertitelleiste entfällt. Große Ansichten nutzen den verfügbaren Bildschirm, kleinere Details passen ihre Höhe an den Inhalt an.
- Shopkarten erhalten größere Illustrationen. Waffen werden im Inventar diagonal und ohne große transparente Ränder angezeigt. Die Dungeon-Auswahl steht vor den Eventquests.
- Ein Rüstungsslot öffnet die Auswahl von Sternen- und Eklipsenpanzer. Beide Gegenstände bleiben separat im Inventar vorhanden. Kopf und Flügel haben eigene Kategorie-Slots; Eventflügel können dort angezeigt und ausgewählt werden.
- Die Rüstung wird mit angepassten Torsoflächen je Pose dargestellt, das Diadem sitzt näher am Kopf. Körper, Waffe und Ausrüstung bleiben getrennte Ebenen. Der Schattenjäger verwendet seine eigenen Hand-, Torso-, Kopf- und Rückenanker.
- Der zweite Kettenschlag verwendet eine Trefferpose; die Bewegung springt am Trefferzeitpunkt nicht mehr nach vorne oder oben. Trefferfeedback verändert die Simulationsuhr nicht mehr. Die wiederholte Meldung „Angriff vorgemerkt“ entfällt.
- Die gemalte Bodenhöhe wird an die Fußposition der Figuren angepasst, auch in der Herbstabtei. Der Aschenkoloss erhält eine zur Arena passende Größe und Position.
- Neue originale Assets: Steinwächter und Aschenkoloss mit je vier Zuständen; Schattenjäger mit acht Körperposen und Porträt. Er ist ab Accountlevel 8 und Glutkern Stage 3 für 220 Gold / 12 Splitter freischaltbar. Ein Wechsel erhält Stage, Gegner-HP und Fortschritt.
- Der Laternengeist kann mit ausstehendem Angriff gespeichert und ohne Schreibschutz fortgesetzt werden. Die Blockheilung des Runenpaladins wird tatsächlich angewendet.

## Prüfung und Grenzen

25 Godot-Testsuiten, 1.410/1.410 Prüfungen. Zusätzlich mobile Chromium-Tests mit echten CDP-Touchereignissen auf 360×640 und Sichtprüfung auf 360×780. Beim Wischen bleiben Fensterposition, Guthaben, Ausrüstung und Fortschritt unverändert; überlange Seiten/Liste bewegen sich. Bei kurzen Inhalten entsteht kein unnötiger Scrollweg. Die Testdaten und Testadapter sind aus spielbaren Exporten ausgeschlossen.

Die signierte ARM64-APK hat Versioncode 702 und denselben Paketnamen und Preview-Schlüssel wie APK 701. Signatur v2/v3 und ZIP-Ausrichtung wurden geprüft. Als Update über die bisherige APK installieren; eine Deinstallation entfernt lokale Appdaten.

Ein Test auf einem echten Android-Gerät und eine FPS-/Speichermessung stehen weiterhin aus. Die kanonische Angriffsanimation besitzt weiterhin sechs gezeichnete Schlüsselposen; die korrigierte Bewegungsführung ersetzt kein vollständiges neues Animationsset. Die angepassten Rüstungsflächen sind ein erster Sitz-Fix; endgültige passende Outfitsets und die gestalterische Abnahme der neuen Assets bleiben offen. Die vollständige Übereinstimmung mit allen Master-Mockups ist noch kein abgeschlossener Qualitätspunkt.

Familien/Gilden, sichtbarer echter Koop, legendäre Erfolgstitel und PvP bleiben verbindliche Hauptsysteme der Online-Roadmap 7.1–7.6. Dieser Download enthält die lokale Spielfassung. Vor dem Online-Ausbau hat die lokale Bedien- und Darstellungsqualität Vorrang.

## Dateien und Quellen

- APK: REALM_ALLIANCE_0_7_0_Polish_2.apk
- Web: REALM_ALLIANCE_0_7_0_Polish_2_Web.zip (entpacken und serve.py starten)
- Godot-Quellen: REALM_ALLIANCE_0_7_0_Polish_2_Quellen.zip
- Prüfbelege: docs/polish702/VALIDATION.json und ANDROID_BUILD.json
- Neue Assetquellen, Prompts, mechanische Normalisierung und SHA-256-Belege: godot/realm_alliance/production/polish702/

Die Änderungen sind lokal gesichert. Ein GitHub-Push wurde nicht ausgeführt.
