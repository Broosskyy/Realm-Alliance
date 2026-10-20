# REALM ALLIANCE · Mockup Test 706

20.10.2026. Erweiterung und Polish auf Basis der zuvor gesicherten 705-Rekonstruktion. Die ursprüngliche verlorene 705-Abgabe wurde dadurch nicht bytegleich wiederhergestellt. Paketkennung und Debugsignatur bleiben kompatibel mit „REALM Mockup Test“ 704/705.

## Neue Inhalte und Verbesserungen

- **Monsterbuch** als dritter Reiter unter Wesen: 15 Einträge für vorhandene Welt- und Eventgegner, Entdeckung durch echte neu vergebene Siege, Fundorte, Basiswerte und Meisterschaft. Nach 5/15/30 Siegen gibt es einmalig 20/60/120 Gold und 1/2/3 Himmelssplitter. Dungeonvarianten zählen zum stabilen Gegnereintrag. Kein nachträgliches Erfinden historischer Einzelgegner-Siege.
- **Sechs neue Gegenstandsillustrationen:** Runenstaub, Glutkern, Erntezeichen, Himmelssplitter, Wächtertruhe und Meisterschaftsmedaille. Transparenter 3×2-Atlas, sechs separate AtlasTexture-Ressourcen, in Inventar, Handwerk und Monsterbuch eingebunden. Die Modulgrenzen zwischen Held, Waffe und Ausrüstung bleiben erhalten.
- **Inventarsuche** mit erhaltenem Tastaturfokus während der Eingabe. Neuer Filter „Besser“ vergleicht tatsächlich vorhandene Gegenstände mit angelegter Ausrüstung. Größere Schrift, begrenzte Kartentitel und Aufwertungspfeile.
- **Heldenvorschau** berechnet Werte für die ausgewählte Figur mit ihrem Level und der aktuellen gemeinsamen Ausrüstung, ohne Heldwechsel oder Änderungen am Kampf. Inaktive Figuren sind als Vorschau gekennzeichnet.
- **Begleiterdetails** zeigen die tatsächliche Salven-/Heilwirkung, das Intervall und den Entwicklungsstatus.
- **Skills** mit kurzen, ungebrochenen Reitern, ausgewählter Aufwertung und erreichbaren Karten für die übrigen drei Skills im selben Scrollfenster.
- **Belohnungen** zeigen die tatsächlich erhaltene Waffe, Rüstung oder Materialillustration statt eines allgemeinen Splittersymbols.
- **Touch und Layout:** größere native Schaltflächen, größere AUTO- und Navigationsflächen. Die Steuerungszone wurde geringfügig vergrößert und die gemeinsame Standlinie so angepasst, dass Schaltflächen nicht über den Füßen liegen. Held/Monster bleiben an derselben Bodenlinie.
- **Meldungen:** Kampfbelohnungen werden beim Wechsel auf Weltkarte und andere Seiten ausgeblendet, damit sie keine Menütexte überlagern.
- **Scrollen:** In Sammlungsdetails erscheint beim Scrollen eine feste Zurück-Leiste. Kopfzeilen und Navigation bleiben erreichbar. Sucheingaben haben das gemeinsame Fantasy-Design.

## Verifikation

- Godot 4.7.2: **29 Suiten, 1.710/1.710 Prüfungen bestanden**. Enthält die bisherigen Kampf-, Speicher-, Wirtschafts-, Layout- und Ausrüstungstests sowie neue Tests für Monsterbuch, einmalige Belohnungen, Speicher-Rundlauf, fehlerhafte Daten und wirkungsfreie Heldenvorschau.
- **65/65 Browser-/Touch-Prüfungen bestanden**, WebGL in Chromium Headless Shell mit Software-Rendering. Größen: 320×568, 390×844, 430×932 und 960×540. Geprüft: echte Browser-Toucheingaben, Monsterdetails und Meisterschaftsbelohnung, Zurück-Aktionen ohne Profil-/Kampfänderung, Erreichbarkeit aller Skills durch Scrollen, Suche mit erhaltenem Fokus, tatsächliche Gegenstandsvergleiche und Zielgrößen für Navigation/AUTO. Telefonziele mindestens 44 px; Desktopziele mindestens 36 px.
- Reguläre Webfassung zusätzlich separat auf Start, Kampfeingaben und Hauptnavigation geprüft. Keine QA-Brücke in der normalen Fassung. Ergebnis: development/normal_web_706.json.
- Android ARM64 exportiert; Versioncode 706, Versionname 0.7.0-mockup.6-polish. APK-Signaturen v2/v3 und 16-KiB-Ausrichtung geprüft. Keine Installation und kein Test auf einem echten Android-Gerät; keine Hardware-FPS-Aussage.
- Beide ZIP-Archive auf Integrität geprüft. Native/Browser-Protokolle sind im Quellpaket. Browseraufnahmen dienen nur der internen Sichtprüfung und sind nicht Bestandteil der Abgabe.

## Speicherstände

Die Anwendung bleibt com.avenor.realmalliance.mockuptest und aktualisiert denselben separaten Testbuild. Bestehende Profile werden um die Monsterbuch-Domäne ergänzt. Unbekannte Felder bleiben erhalten; ungültige oder unbekannte Monsterbuch-Daten sperren das Speichern, statt den Originalstand zu überschreiben. Der Browser-QA-Adapter verwendet ausschließlich ein temporäres Testprofil und wird aus normalen Exporten ausgeschlossen.

## Abgabe und Reproduktion

- REALM_ALLIANCE_706.apk
- REALM_ALLIANCE_706_Web.zip
- REALM_ALLIANCE_706_Quellen.zip
- REALM_ALLIANCE_706_Bericht.md

Aktueller Einstieg: START_HERE.md. Godot-Projekt: godot/realm_alliance/project.godot. Godot 4.7.2 und passende Exportvorlagen installieren, Projekt importieren, Android SDK und Java im Godot-Editor konfigurieren.

    python3 development/run_checks.py --godot /pfad/zu/godot --report checks.json
    python3 development/build_706.py --godot /pfad/zu/godot --output /absoluter/ausgabeordner

Die Webdateien über einen Webserver bereitstellen, nicht per file:// öffnen. Das Web-ZIP enthält START_WEB.py für einen lokalen Testserver. Browser-Regression: development/browser_review706.cjs benötigt Playwright, einen Chromium Headless Shell und einen separaten QA-Webexport der ausgeschlossenen Szene tests/review702.tscn. Diesen QA-Export nicht veröffentlichen.

## Offen

Weitere konsistente Körper-Zwischenbilder für Angriffe, vollständige getragene Outfit-Sets für die übrigen Helden, weitere Annäherung aller Unterfenster an die Master-Mockups und vollständiges Online-7.1–7.5. Es wird keine pixelgenaue Mockup-Übereinstimmung behauptet. Kein GitHub-Push und keine öffentliche Bereitstellung dieser Abgabe ausgeführt. Der enthaltene öffentliche Debugschlüssel dient nur reproduzierbaren Testupdates; keine Zugangsdaten oder persönlichen Spielstände sind enthalten.
