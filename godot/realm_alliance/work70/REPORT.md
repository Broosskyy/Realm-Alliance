# REALM ALLIANCE – Work 6.8 bis 7.0, integrierter Entwicklungsstand

Basis: `feature/work-6-7-1-hero-art-direction` (`3ca48b45a3b7e58b1883c5d31905cffd1198129b`).
Entwicklungsbranch: `feature/work-6-8-rpg-economy`. Godot 4.7.2, Web-first, Android ARM64 als zusätzlicher Build.

## Spielbarer Umfang

- **Helden:** Realmwächter bleibt Hauptheld; Kaela bleibt archivierte NPC. Der Runenpaladin hat ein eigenes waffenfreies Set mit Idle/Ready/Windup/Kontakt/Erholung/Treffer/Tod/Lauf, Portrait, poseabhängigen Händen und Ausrüstungssockets. Seine defensiven Skillvarianten und goldenen Runeneffekte nutzen die vorhandene getestete Kampfarchitektur. Helden- und Begleiterwechsel erhalten Stage, Gegner-HP, Beute und Fortschritt. Der neue Held wird regulär ab Level 6 und Gartenkoloss für 150 Gold/8 Splitter freigeschaltet, ohne automatische Gratisfreischaltung alter Saves.
- **6.8:** Garantierte Gold-/Material-/Ausrüstungs-/Eventkäufe; echte Rezepte; Waffenverzauberungen mit gespeichertem Rang und sichtbarer Waffenwirkung; Verwertung ungetragener Gegenstände mit ausdrücklichem Bestätigungsdialog; Runenstaub und Glutkerne aus Kämpfen. Sechs Seltenheitsregeln für Daten/Farben, zunächst auf bestehende tatsächlich illustrierte Gegenstände angewendet. Sternenwacht-Set: zwei Teile +10 HP/+2 DEF, drei Teile zusätzlich +6 Angriff. Transaktionen prüfen Besitz, Level, Kosten und einen persistenten, monotonen Beleg.
- **6.9:** Schatzgewölbe (drei Wellen, Gold), Aschenschmiede (fünf Wellen, Materialien) und die ausdrücklich lokale Kolossprüfung (60 Sekunden; Bronze/Silber/Gold bei Sieg/40/25 Sekunden). Vor dem Eintritt wird der Hauptkampf vollständig angehalten. Bei Rückkehr werden derselbe Lauf, HP, Uhr, ausstehende Attacke und Belohnungsbelege fortgesetzt; verdiente Gegenstände bleiben erhalten. Die vorhandenen Bossphasen, Telegraphe und Rüstungsbruch-Regeln gelten auch hier.
- **Halloween-Paket:** Wiederholbare Herbstabtei mit eigenem Hintergrund, Kürbisgegner, Kristallschatten und Erntekönig. Jedes Monster besitzt ein eigenes transparentes 2×2-Produktionssheet und vier normalisierte Laufzeitposen. Fünf echte Begegnungen, Erntezeichen, drei aufeinander aufbauende Quests, Eventtruhen, Ernteschwingen und kauf-/trainier-/entwickelbarer Laternengeist. Paketdefinition und Questkette liegen unter `data/events69.json`, nicht in UI-Screenshots.
- **7.0:** Nächstes-Ziel-Hilfe, tägliche Anmeldung/10 Gegner und wöchentliche fünf Bosse, UTC-Tageswechsel und Montag-Woche mit Rückwärtsschutz und Wiederholschutz; zwei echte Spezialisierungen ab Level 8; verdienbare und auswählbare Titel; vier sichtbare Formen I–IV. Form IV benötigt Level 12, Aschenkoloss und Bossprüfung sowie echte Materialien. Frühere erwachte Figuren behalten ihren Fortschritt. Optischer Formwechsel verändert keine permanent verdienten Werte und heilt nicht.
- **UI:** Zwei echte Sammlungstabs mit großer ausgerüsteter Figur und Portraitkarten; illustrierte Shop-/Rezeptkarten; scrollbare Aktivitäten-/Reiseansicht; gemeinsame Navy-/Gold-/Violett-Familie. Native Tabs besitzen mindestens 88 logische Pixel Höhe und Breite für 44-Pixel-Ziele bei halber Skalierung. Ein neues kanonisches App-Icon ersetzt das fehlende Projekticon.

## Prüfung

**22 Suiten, 1.256/1.256 Prüfungen bestanden.** `VALIDATION.json` enthält die einzelnen Summen. Die bestehenden Tests wurden beibehalten; eine Verteidigungs-Erwartung wurde gezielt um den neuen Setbonus ergänzt, ein UI-Test überspringt nur den ausdrücklich anders erworbenen Eventgegenstand.

Die neuen Tests spielen beide Dungeons und drei komplette Halloween-Durchläufe, prüfen Boss-Timer, tatsächliche Material-/Goldkosten, wiederholte Transaktionsaufrufe, Save/Load nach Siegen, ausgesetzte Story-Angriffe, Questketten, Eventbegleiter-Schaden, Original-Alpha, modulare Waffen, vier Entwicklungen, Tageswechsel und zurückgestellte Uhr.

Echte Godot-Aufnahmen: 360×800, 720×1280, 720×1560 und 1280×720, Mesa llvmpipe/OpenGL. Beispielaufnahmen in `evidence/`. Browser: Chromium Headless Shell 151/SwiftShader bei 360×800, echter exportierter Webbuild; Start, Tap-Angriffe, Navigation zu Beute/Shop sowie Reload und vorhandener Fortschritt geprüft. Keine JavaScript- oder Godot-Scriptfehler beobachtet.

Web- und Android-Debug-Export werden lokal erzeugt; Android erhält die bestehende öffentliche Preview-Debugsignatur. Die aktualisierte GitHub-Workflowdefinition enthält beide neuen Tests und neue Artefaktnamen; ein neuer CI-Lauf kann erst nach dem ausdrücklich freizugebenden öffentlichen Push entstehen.

## Grenzen und offene Abnahme

Dies ist ein **integrierter Entwicklungsstand**, keine Behauptung, alle Inhalte der langfristigen Roadmap seien produktionsfertig. Noch offen sind vor allem persönliche Freigabe des neuen Helden und der neuen Art, echte Android-Bedienungs-/Performanceprüfung, längerfristiges Balancing und weitere visuelle Annäherung aller alten Detaildialoge an die Master-Mockups. Android-Export oder Software-Rendering belegen keine stabilen 60 FPS auf einem Handy.

Gegenstandstypen werden entsprechend der Roadmap schrittweise erweitert; nicht jeder zukünftige Handschuh-/Stiefel-/Set-/Mythic-Typ wird durch ein leeres Menü vorgetäuscht. Die Paladinanimation verwendet eigene gemalte Schlüsselposen und die vorhandene Interpolation, kein vollständig gezeichnetes Frame-für-Frame-Bewegungsset. Die vier Formen verwenden getrennte Runen-/Effekt-/Materialebenen und bestehende modulare Ausrüstung; sie sind keine vier vollständig neu gezeichneten Körpersets.

Alle Aktivitäten und Uhrregeln sind lokal. Es gibt keine echte Online-Zeitautorität, keinen gemeinsamen World Boss, keine Zahlung, keine echte Gilde, keinen Accountserver und keinen Multiplayer. Online 7.1–7.6 bleibt verbindlich nach diesem lokalen Ausbau. `main` und Game Factory wurden nicht verändert.

## Assets und Reproduzierbarkeit

Eigene Grafiken wurden mit dem eingebauten Imagegen erstellt. Originale, SHA-256-Manifeste, Zuschnittdaten, Hand-/Ausrüstungspunkte und Produktionsprompts liegen unter `production/`. Die Originale werden nicht in Web/APK mitgepackt. Vorhandene Realmwächter-Assets und separat austauschbare Waffen bleiben erhalten. Kein hochgeladenes privates Handyvideo oder Benutzer-Mockup wird in den Quellbranch kopiert.

Import und Tests aus dem Repository: `godot --headless --path godot/realm_alliance --import`, anschließend die einzelnen `tests/test_*.gd` mit isoliertem `XDG_DATA_HOME=/tmp/realm62-test-<suite>`. Die kanonischen Basisassets zuvor wie im bestehenden CI-Workflow aus dem bereits committeden Integrations-ZIP extrahieren. `tests/capture_rpg70.gd` erstellt reproduzierbare native Szenenaufnahmen unter `/tmp/realm70-captures`.
