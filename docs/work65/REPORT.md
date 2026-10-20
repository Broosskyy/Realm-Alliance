# REALM ALLIANCE — Work 6.5 / Abschluss der Meilensteine A–D

Prüfstand für die visuelle und spielerische Abnahme. Godot 4.7.2, Web-first, Android ARM64 Debug, Version 0.6.5 / Code 650. Der Feature-Branch ist `feature/work-6-2-1-full-game-experience`. Main und Game Factory wurden nicht verändert oder zusammengeführt.

Finaler Runtime-Commit: `8827f0e10be17d736f9cb174e93ec917c7ce436d`.

## Tatsächlich implementiert

- **Abenteuer:** illustrierte Karte mit zwei spielbaren Regionen, je fünf Kämpfen und eigenen Normal-/Elite-/Boss-Begegnungen. Wolkgarten bleibt erhalten; sein Boss schaltet Glutkern frei. Stage-Auswahl und Wiederholung starten einen neuen, eindeutig identifizierten Lauf. Sterne werden aus echten Siegen und verbleibenden HP vergeben; schlechtere Wiederholungen überschreiben keine Bestwerte.
- **Neue Gegner:** Glutkeiler mit vier getrennten RGBA-Zuständen, Aschenhauer als Elite mit Doppelschlag, Basaltwächter und Aschenkoloss mit separater Ember-Palette. Der Boss kündigt Eruption und Nachbeben getrennt an. Die Warnfläche folgt dem Simulationszeitpunkt und trifft erst bei tatsächlichen EnemyBehavior-Ereignissen.
- **Beute:** echtes Inventarraster aus gespeicherten Waffen, Rüstung, Kopf-/Flügelteilen, Splittern und Boss-Truhen. Filter und Seltenheitssortierung; Details, Wertevergleich, Anlegen/Ablegen von Ausrüstung und gezielte Waffen-/Rüstungsaufwertung. Ein Upgrade einer ausgewählten Waffe legt sie nicht heimlich an. Fundhistorie stammt aus tatsächlichen Rewards.
- **Belohnungen:** Boss-Siege erzeugen jeweils eine Truhe mit stabiler UID. Öffnen verbraucht genau eine Truhe, vergibt deterministisch Gold/Splitter/Ausrüstung und zeigt das tatsächliche Ergebnis. Duplikate werden in zusätzliche Splitter umgewandelt. Geöffnete UIDs bleiben gespeichert und können nicht erneut vergütet werden.
- **Progression:** vier Skills bis Rang 5 mit echten stärkeren direkten Treffern, Markierungen, Brennticks beziehungsweise Schild/Konter. Kosten und Cooldowns bleiben bei dieser ersten Ausbaustufe konstant. Zwei Talente mit je drei Rängen: Stärke (+2 Angriff/Rang) und Vitalität (+8 HP/Rang), insgesamt maximal sechs tatsächlich durch XP verdiente Punkte. HP-Upgrades erhalten fehlende Gesundheit und beleben keinen besiegten Hero wieder.
- **Aufgaben/Erfolge:** drei permanente Aufgaben und drei Erfolge mit echten Fortschrittsbedingungen und einmaligen Gold-/Splitter-Belohnungen. Akzeptierte Skills zählen; abgewiesene oder nur vorgemerkte Eingaben zählen nicht. Keine simulierten Online-Dailies oder Uhrzeitbelohnungen.
- **Wesen/UI:** bestehende Fantasy-Komponenten, kanonischer Realmwächter, fünf separate Schwerter, vier Ausrüstungslayer und Evolution aus 6.4 bleiben erhalten. Native Skill-, Talent-, Equipment- und Reward-Dialoge sind bedienbar. Seiten sind scrollbar; feste Navigation bleibt frei. Talent-/Equipment-Ziele überlappen nicht. Lange Dialogtexte umbrechen; Reward-Fenster bleiben im Viewport.

Gameplay-Regeln liegen in WorldProgress, SkillProgress, QuestSystem, ChestRewards, InventoryView und den erhaltenen CombatSession-/Equipment-/Reward-Modulen. Darstellung und Eingabe verwenden eigene Komponenten. Neue Save-Bereiche besitzen Schema 1 innerhalb der bestehenden V2-Hülle. Alte Saves werden additiv übernommen; unbekannte oder ungültige Bereiche bleiben erhalten und sperren automatisches Zurückschreiben. Reale Disk-, Backup- und Migrationsprüfungen sind enthalten.

## Produktionsassets

Vier normalisierte, transparente Keilerzustände, eine Glutkern-Kampfplatte und eine illustrierte Weltkarte sind im laufenden Spiel integriert. Gleiche Skalierung und Fuß-Pivots für alle Keilerposen; VFX bleiben getrennt. Manifest, Hashes, Quellen und vollständige Generierungs-Prompts stehen in [ASSETS.md](ASSETS.md) und `assets/world65/manifest.json`. Die kanonischen Hero-/Golem-/Waffenassets wurden erhalten.

## Tests und echte Renderings

**849/849 Prüfungen in 16 Suiten**, inklusive vorhandener Regressionen. [Finaler erfolgreicher CI-Lauf](https://github.com/Broosskyy/Realm-Alliance/actions/runs/39128193178): Import, realer Szenenstart, Webexport und Android-Debug-APK sind erfolgreich.

Der vollständige exportierte Browserdurchlauf auf `fa9888562d314b38631ab272a60486b7f2b55d11` startete mit einem neuen V2-Profil: nur Wächterstahl, 0 Gold/XP/Splitter/Kills. Ergebnis: beide Regionen mit zehn Kämpfen und beiden Bossen geschafft; alle fünf Schwerter tatsächlich erhalten; erste Quest exakt einmal abgeholt; echte Boss-Truhe geöffnet; Skillrang 2 und ein durch XP verdienter Vitalitätspunkt gekauft. Weltsterne, Claim, Truhe und Fortschritt überleben Reload. Drei zusätzliche V1-Importe mit sofortigem Reload behalten ihre exakten Währungs-/Waffenwerte. Keine Browser- oder GDScript-Fehler; Touch und Desktop/Querformat sind geprüft.

Der finale Commit `8827f0e10be17d736f9cb174e93ec917c7ce436d` verschiebt ausschließlich die gezeichnete Hero-Wertezeile aus den Seitenslots. Diese finale Exportfassung wurde zusätzlich gestartet, auf Hero/Inventar/Talent-Dialog geprüft, mit dem echten erspielten Save geladen und in Glutkern aktiv weitergespielt. Die gesamte CI läuft auch auf diesem finalen Commit grün.

Native Godot-Compatibility-Screenshots wurden in **360×800, 720×1280, 720×1560 und 1280×720** gerendert. Sie zeigen die tatsächlichen Szenen, einschließlich neuer Gegnerzustände, Bosswarnung, Equipment, Talent-, Skill- und Reward-Fenstern. Die native Grafikprüfung nutzt ausdrücklich ein isoliertes Level-8-Ausrüstungsfixture; dies wird nicht als natürlich erspielter Fortschritt ausgegeben. Browserbilder stammen aus dem tatsächlichen Starter-Durchlauf. Vollständige PNGs liegen im QA-Paket, kompakte WebP-Prüfbilder unter screenshots/.

## Gemessene Performance und offene Grenzen

Finaler aktiver Glutkern-Test: Chromium 155.0.8059.84, 720×1560, Linux/SwiftShader, volle Effekte, AUTO-Standardangriffe und manuelle Skills. **158 rAF-Samples in 10,0146 s; Median 66,6 ms, p95 116,6 ms.** Die Simulation lief tatsächlich weiter, Kills stiegen von 10 auf 12, drei unterschiedliche manuelle Skills wurden akzeptiert. Dies ist Browser-rAF-Telemetrie auf einem Software-Renderer, keine zertifizierte Godot-FPS- oder Android-Messung. **60 FPS sind damit nicht nachgewiesen.** Eine Geräteprüfung und weitere Optimierung auf geeigneter Android-Hardware bleiben offen. Effekte und Audio sind einstellbar beziehungsweise abschaltbar.

Die APK wurde erfolgreich exportiert und auf ZIP-Integrität/ARM64-Bibliothek geprüft; ein physischer Android-Geräte- oder Video-Test wurde nicht durchgeführt. Preview-Paket und Entwicklungsschlüssel bleiben unverändert. Keine automatische Zusammenführung nach Main.

Bewusst begrenzt: zwei Regionen/zehn Begegnungen, vier vorhandene Skills, zwei Talente, sechs permanente Ziele und die vier tatsächlich mit Assets unterstützten Ausrüstungsgegenstände. Größere Talentbäume, zusätzliche Outfit-Pose-Sets, Set-Boni, Crafting, weitere Verbrauchsgegenstände, Online-Accounts, Shops/LiveOps, Gilden und PvP sind nicht implementiert. Der Post-Utility-Button bleibt ein vorhandener Hinweisplatzhalter; dafür wird kein funktionierendes Postsystem behauptet.

## Downloads

- [Android-Archiv mit APK](https://github.com/Broosskyy/Realm-Alliance/actions/runs/39128193178/artifacts/12137405304)
- [Webexport-ZIP](https://github.com/Broosskyy/Realm-Alliance/actions/runs/39128193178/artifacts/12137111065)
- [Exakter Runtime-Source als ZIP](https://github.com/Broosskyy/Realm-Alliance/archive/8827f0e10be17d736f9cb174e93ec917c7ce436d.zip)
- [Feature-Branch](https://github.com/Broosskyy/Realm-Alliance/tree/feature/work-6-2-1-full-game-experience)

GitHub-Artefakte benötigen eine Anmeldung und laufen am 16.01.2027 ab. Zusätzlich werden APK, Web-ZIP und QA-ZIP im Chat bereitgestellt. Der Webexport benötigt einen HTTP-Server; die index.html direkt aus einem ZIP oder file:// zu öffnen ist kein Web-Hosting. Für einen lokalen Test: ZIP entpacken, im Exportordner `python3 -m http.server 8000` starten und localhost:8000 im Browser öffnen.

## Nachvollziehbarkeit

Die Meilensteine 6.2.1, 6.3 und 6.4 besitzen eigene Implementierungs-/Testberichte. 6.5 wurde über `6a7e475` (RPG-Kern), `ffda343` (echte Boss-/Skillanzeigen), `6f62c56` (mobile Dialoge), `fa98885` (getrennte Touch-Slots) und `8827f0e` (Wertezeile) gesichert. Finale Artefaktgrößen/Hashes, CI-Checkübersicht, Browser-Harness, Ergebnisdateien, Capture-Script und aktive Messung stehen unter tests/.
