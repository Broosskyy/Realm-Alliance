# REALM ALLIANCE – 2D-Master-Lock und RPG-Ausbaurichtung (ab 712)
Stand: 21.10.2026 · Designentscheidung / kein implementiertes Feature

## Verbindlicher visueller Lock
- Das Spiel bleibt grundsätzlich ein **vollständiges 2D-Spiel in Godot**. Für neue Charaktere, Monster, Kostüme, Spezialisten, Feen, Pets, Partner, Waffen, Bosse und Umgebungen **keine 3D-Modelle und keine 3D-Modellpipeline** einführen. Ausnahmen nur nach ausdrücklicher separater Entscheidung.
- In der Spielansicht sind 2D-Layer, 2D-Licht, Partikel und Shader erlaubt. 2.5D-Tiefenwirkung entsteht ausschließlich durch 2D-Mittel (Parallax, Ebenen, Schatten), nicht durch verdeckte 3D-Rigs.
- Beibehalten: stilisierte, gut lesbare kompakte Fantasy-Proportionen, dunkle/verschattete Gesichtsfläche mit leuchtenden Augen, gemeinsame Silhouette und Material-/Lichtlogik. **Kein reiner Anime-Stil.**
- Charakter und Waffe **getrennt**; austauschbare Rüstungsteile, Kopf/Haar, Stiefel, Schulter, Kostüm, Flügel, SP-Schicht und VFX mit definierten 2D-Ankern und draw order. Dasselbe Rig muss in Kampf, Inventar, Vorschau und Klassenfenstern übereinstimmen.
- Erst klare Silhouette, dann Materialdetails und sparsame Effekte. Keine überladenen VFX, keine im Sprite fest gebackene Waffe/Flügel. Einstellbare VFX-Stufe; Gameplay auch ohne VFX lesbar.
- Referenzmockups sind **Konzeptbilder**, keine für die Produktion bereits fertig ausgeschnittenen Animationen: vor Nutzung produktionsfähige transparente 2D-Sprites/Layers getrennt erzeugen und Animation/Anker prüfen.
- Mobile first: 320×568 und 390×844, Querformat 960×540; Touch, Scroll, Scrollclipping, Figur und Ausrüstung stets sichtbar. Performance-Ziel 30–60 FPS auf Mittelklasse-Android; wiederverwendbare Texturen statt unnötiger großer Vollbild-Atlanten.

## Grundprinzip der Progression
Ein eigener erstellter Hauptcharakter (Basic-Abenteurer m/w, natürliche Haarfarben) ist die Spieleridentität. Bestehende 709–711-Helden, Inventar, Käufe, Pet-Fortschritt, Familien/Community und Spielstände bleiben erhalten. Keine automatische Migration, die vorhandenen Fortschritt löscht. Keine erzwungene sammelbare Mehrheldenparty.

**Zwei Progressionsspuren:** Charakterlevel (dauerhaft), Joblevel pro Grundklasse. Das in 712 konfigurierte Joblevel 5 bleibt Testbalancing, nicht final. Erste Klassen Schwertkämpfer, Bogenschütze, Magier; dieselbe Figur, neue Skills, Klasse und getrennte Waffen-/Kampflogik.

**Spezialisten (spätere Phasen):** über Quests, Events, Sammel-/Herstellungssysteme erworbene, **eigenständige Karten/Formen innerhalb derselben Charakteridentität**, mit separaten Fertigkeiten, 2D-Aufbau, ggf. Element-/Waffensynergien und kontrollierbaren Upgrades bis +15. Keine 1:1-NosTale-Kopien, Namen, Karten, Designs oder geschützte Assets übernehmen; vollständig eigene IP.

**Ausrüstung (Metin2-inspirierte Wirkung):** Material-/Silhouettenprogression, sichtbare Rüstungsschritte und Waffenupgrades, besondere Varianten, eigener Look jeder Klasse. Ausrüstungssystem entkoppelt von den SP-Karten; Kosmetik ohne Vorteil. Bestehende Levelachsen nicht ohne getestete Migration vereinheitlichen.

**Drei klar getrennte Begleitsysteme:**
1. Pets: vorhandene Sammel-/Level-/Evolutionslogik erweitern.
2. Partner-NPCs: später rekrutierbare Begleiter mit klar begrenzten Kampfrollen, optional Ausrüstung/Skills und persistentem Fortschritt; nicht in die Spielerhelden-Klasse verwandeln.
3. Elementwesen / Feen: eigenes Ausrüstungs-/Begleitsystem mit Feuer, Wasser, Licht, Schatten als Kern; Natur, Blitz, Arkan zunächst Entwurfsoptionen. Klare Resistenz-/Schwäche- und Synergiesysteme; kein elementarer Pay-to-win-Vorteil.

**Welt-/Langzeitbindung:** Regionen, NPCs, Quests, Instanzen, Dungeons, Weltbosse, Monsterbuch, Ruf/Titel, Handel/Inventar, Familie/Gilde, Familienquests, Raids, begrenzte asynchrone/soziale Elemente; Systeme so verzahnen, dass jede Aktivität einen nachvollziehbaren Teil der Progression bedient. Live-Backend nur behaupten, wenn tatsächlich verbunden/getestet.

## Idle-/Tap-Kern statt NosTale-1:1
- Sofort verständlicher Tap-Kampf und automatische Angriffe als Kern; aktive Skills, Zielen/Timing, Interrupts, Loot-Auswahl, Bossphasen und Talent-/Klassenentscheidungen schaffen Tiefgang.
- Optionaler kontrollierter Auto-/Idle-Fortschritt mit Grenzen und nachvollziehbaren Offline-Erträgen; aktive Entscheidungen müssen relevant bleiben.
- Keine unkontrollierte Anzahl gleichzeitig kämpfender Figuren. Übersichtlichkeit auf Smartphone zuerst.
- Neuer Content über Datenkataloge statt fest verdrahtete UI: Klassen, SP-Karten, Elemente, Pets, NPC-Partner, Quests, Items, Events, Regionen.

## Technische Reihenfolge – nach tatsächlichem 712-Build
1. **712 abnehmen:** prüfen, welcher Branch/Commit den echten Quellstand enthält, unabhängigen QA-/normalen Webexport, Testberichte und APK-Hash überprüfen. Separate Vercel-Preview vom Produktions-URL unterscheiden. Keine falschen Live-Behauptungen.
2. **712 visuell prüfen:** männlich/weiblich × vier Haarfarben; jeweils Idle/Ready/Windup/Contact/Hit/Recovery; Schwert/Bogen/Stab, Kopf/Hand/Fußanker, 711-Rüstung/Kostüm in allen relevanten Posen; 320×568/390×844/430×932/960×540.
3. **Master-Mockup-Abgleich:** ausgewählte 10 Konzeptbilder nach Erscheinungsbild, Perspektive, Proportionen und UI bewerten; Referenzen festlegen; 2D-Produktionssprites transparent und mit Abstand pro Layer separat erstellen. Keine direkte Zerlegung vollflächiger Poster in Spielsprites als fertiges Ergebnis ausgeben.
4. **Stabilisierung vor Ausbau:** Save-Compatibility, FX-Aus, Tap, Scroll, Neu-/Altprofile, Klassenwahl, echtes Login-/Backend-Verhalten, Builds.
5. **Danach vertikal erweitern:** erst eine Klasse und eine Spezialistenform als 2D-End-to-End-Prototyp; dann Elemente und Fairy; dann Partner-NPC und Familien-/Rufvertiefung. Neue Systeme nur mit Spielenutzen, UI, Save-Schema, Tests und klarer Migrationsstrategie.

## Lieferstandard
GitHub-Branch pro Phase, kleine reproduzierbare Commits, vorhandene Builds nicht überschreiben, signiertes Android nur mit Originalschlüssel; keine privaten Schlüssel in Repository/Artefakten. Für jeden Meilenstein: Quellcode, exportierter normaler Web-Build, realer Android-APK-Build falls verfügbar, Screenshots/Touch-Tests, Save-/Regressionstests, konkreter offener Reststand. Git-Commit/Artifact-Hash müssen zur veröffentlichten Version passen.


## Zusätzliche Plattform- und Layout-Locks (21.10.2026)
**Kein Rebuild des Hauptspiels.** Die bisherige REALM-ALLIANCE-Erfahrung ist das Produkt: Tap-/Idle-Kampf, Bosse, Loot, Inventar, Klassen/Joblevel, Flügel, Pets, Rüstungen, Progression und Menüs. Diese Systeme werden verbessert, nicht durch eine neue Open World ersetzt oder umgestellt. **Open World = späteres, optionales Zusatzmodul.** Keine Implementierung einer Open World ohne separaten Scope-/Performance-Prototyp und ausdrückliche Freigabe.

### Cross-Platform und Crossplay
- Zielplattformen langfristig: Android, iOS, Browser, Windows und macOS, jeweils dasselbe Spielerprofil, Inhalte und Fortschritt. Der aktuelle Stand belegt noch **keine** fertige Crossplay-/Cross-Save-Funktion zwischen diesen Plattformen.
- **Cross-Save/Cross-Progression** (ein Spielstand/Gerätewechsel) von **Crossplay** (gemeinsame Online-Aktivitäten auf verschiedenen Geräten) technisch unterscheiden. Bestehenden lokalen Gastspielstand behalten; freiwillige, sichere Konto-Verknüpfung und später servergestützte Synchronisierung. Save-/Item-/Währungsduplikation, Versionskonflikte und Offline-Synchronisierung gesondert testen.
- Gemeinsames Godot-2D-Spiel und gemeinsames Datenmodell beibehalten, aber Eingabe, Layout, Export und Leistungsoptionen je Gerät anpassen. Android und Browser zuerst testen; Windows/macOS später; iOS nur mit geeigneter macOS-/Xcode-/Signierumgebung und realem Gerät. Kein unbelegtes „unterstützt iOS“ vor einem Build.
- Online-Familien, Raids, Handel, Gilden oder gemeinsames Bewegen verlangen eine erreichbare, getestete Serverarchitektur. Den vorhandenen lokalen Realm-Dienst nicht als vollständig produktiven Crossplay-Server bezeichnen.

### Portrait first, Landscape wirklich adaptiv
- **Hochformat ist die primäre Designansicht**, Godot-Baseline derzeit 720×1280. Im Hochformat sollen alle Kernaktionen, Kampf, Dialoge und Ausrüstungsfenster mit dem Daumen bequem erreichbar sein.
- **Querformat bleibt voll spielbar**, aber bekommt eine eigene responsive Panel-Anordnung. Keine bloße Rotation, Stretch-Verzerrung oder abgeschnittene Figur. Beispiel: Landscape Kampf/Welt in der Mitte, Status links und Skills rechts; Portrait übersichtlicher vertikaler Aufbau mit Menüs als Sheets.
- Vorhandene UI nicht blind neu gestalten: zuerst echte Breakpoint-/Touch-/Scroll-Probleme feststellen, dann kleine überprüfbare Anpassungen. Rotation/Resize auch während Gameplay/Modal mit erhaltenem Zustand; Notches, Safe Areas, Tablet-/Desktop-Größen und Tastatur/Mouse berücksichtigen.
- Testmatrix mindestens: 320×568, 390×844, 430×932, 960×540, 1280×720 sowie Desktop. Bestehende Animationen und Spielstände müssen unverändert funktionieren.

### Open World: bewusst ein optionaler späterer Spielmodus
- **Nicht Teil der ersten 712-Optimierung und nicht Voraussetzung für Charaktererstellung, Klassen, Pets oder Idle-Bosse.** Das Hauptspiel bleibt auch ohne Open World vollständig spielbar.
- Prototyp als **kleine separate 2D-Region** mit einer `Camera2D`: Figur folgen, Kamera-Pan per Touchziehen/Mausziehen, Zoom per Zwei-Finger-Pinch/Mausrad, „Zur Figur“-Button, Zoomgrenzen, Randbegrenzung und Minimap.
- Weltausrichtung als 2D-Top-down oder leicht schräge 2D-Spriteansicht. 2.5D-Look über Layer/Parallax/Shadows, **keine 3D-Modelle oder 3D-Kameras**.
- Im optionalen Weltmodus: Fingerziehen = Kamera oder Bewegung nach klarer Gestenkonvention; kurzer Tap = Interaktion bzw. Bewegungsziel. **Im bestehenden Hauptkampf bleiben Tap-Angriffe wie bisher.** Keine mehrdeutigen Gesten, ungewollte Käufe oder Angriffe bei Pinch/Scroll.
- Welt in kleine Zonen aufteilen, Assets bedarfsorientiert laden, ohne riesige offene Karte auf einmal im RAM zu halten. Gleicher Charakter und Inventar; Open World soll zusätzliche Erkundung/Quests/NPCs bieten, keinen Zwang zur täglichen Bedienung.
- **Gate vor Umsetzung:** 1 Region, 1 NPC, 1 Quest, frei bewegliche Kamera, Portrait-/Landscape-Performance und zurück ins Kernspiel. Erst nach überzeugendem Mobile-Test weitere Regionen planen.

### Disziplinierte Feature-Priorisierung und Beratung
Neue Wünsche vor Umsetzung nach Aufwand, Nutzen für das vorhandene Spiel, Mobil-UX, Daten-/Backend-Folgen und Risiken bewerten. Bei Scope-Ausweitung ausdrücklich alternative kleinere Versionen empfehlen und nicht alles zugleich starten. Empfohlene Reihenfolge: **712 sichern & abnehmen → Charakter/2D-Mockup-Passform und Bedienung verbessern → Portrait/Landscape sauber testen → Cross-Save-Grundlagen → Spezialisten/Elemente als einzeln testbare Vertikalschnitte → erst danach optionale Weltregion.** Kein unfertiges Open-World-/Crossplay-System darf die aktuelle 712-Spielschleife destabilisieren.
