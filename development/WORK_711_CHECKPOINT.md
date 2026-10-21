# Work 711 – geprüfter Arbeitsstand, noch keine fertige Veröffentlichung

Basis: main `b603918857911cc62b314eb46f529a386db95de9` (710 samt original signierter APK). Hauptprojekt bleibt Godot, Backup und historische Webexports unverändert.

## Tatsächlich im lokalen 711-Arbeitsstand implementiert

- Zwei eigenständig generierte modulare Rüstungsfamilien: Wanderleder (normal, ab Level 1, 15 Gold, 0 Splitter, 8 HP/1 DEF) und Silberwacht (selten, ab Level 3, 85 Gold/3 Splitter, 28 HP/3 DEF).
- Zwei rein kosmetische Kostüme: Waldpfad nach 25 besiegten Gegnern, Sandwanderer ab erreichter Kampfstufe 15. Kostenlos dauerhaft abholen, anlegen und ablegen. Keine Änderungen an Kampfwerten, Lebenspunkten, Währung oder Waffenfortschritt.
- Vier unterschiedliche Grafik-Atlanten mit je sechs Zellen, daraus 28 separate RGBA-Komponenten: Brust, linke/rechte Schulter, Hüftteile, linker/rechter Stiefel und Mantel. Die beiden Rüstungs-Brustteile dienen zusätzlich als Inventargrafik. Originalatlanten sind erhalten.
- Modularer Renderer für Runenpaladin, Schattenjäger und Realmwächter mit sechs Kampfposen. Waffen bleiben an ihrem separaten Handanker. Stiefelanker aus den vorhandenen Körperbildern ermittelt; Gesichter/Haare/Heldenidentität bleiben erhalten.
- Eigene Mantelbewegung, Zurückhaltung bei Veredelungsdetails; Effekte-aus-Darstellung vorgesehen und direkt am Rig geprüft.
- Neuer Kostümreiter der Ausrüstung; Freischaltungsfortschritt und echte Vorschau; Rüstungsvorschau zeigt die Rüstung ohne das sie überdeckende Kostüm. Auf schmalen Displays fünf Reiter in zwei Reihen, Kostüme zusätzlich in der Sammlung erreichbar.
- Aktualisierungsfehler beim Kampfhelden behoben: Haupt- und HUD-Vorschauschlüssel berücksichtigen den Kostümbereich.
- Vorhandener Detaildialog verwendet tatsächliche Ausrüstungsgrenzen und Splitterpreise, statt Flügel bei 10 zu sperren.
- Android-Preset 711 / `0.7.0-mockup.11-modular-wardrobe`, Paket unverändert. 711-Web-, Android- und Paketierungswerkzeuge sowie separate Workflows vorbereitet. Historischer 710-Webworkflow auf seinen 710-Featurebranch begrenzt, damit er keine 711-Inhalte in web_build/710 schreibt.

## Tatsächlich ausgeführte Prüfungen

- Ein vollständiger lokaler Durchlauf: **34 Godot-Suiten / 3.487 Checks bestanden**. Dieser Durchlauf fand vor den letzten Cache-/Shader-/Layoutkorrekturen statt; er ersetzt keinen abschließenden vollständigen Durchlauf.
- Danach zusätzliche Cache-Regressionstests im neuen Wardrobe-Test ergänzt; gezielter Wardrobe-Lauf bestanden.
- Letzter 711-Browserlauf nach Cache-, Layout- und Shaderkorrekturen: **26/26 Checks, keine Skript-, Browser- oder Shaderfehler**. Echte Touchaktionen für Freischalten, Anlegen, Ablegen, Kauf und Scrollen; 320×568, 390×844, 430×932, 960×540.
- Echte Renderer-Kontaktbögen für vier Familien × drei Helden × sechs Posen erzeugt. Mobile Kampf- und Ausrüstungsaufnahmen visuell kontrolliert.
- Backend-HTTP-Suite: **48/48 Checks bestanden**.
- **Noch ausstehend:** abschließender vollständiger nativer Durchlauf nach allen letzten Änderungen, bestehende 710-Browserregression, normaler 711-Webexport-Smoke-Test, 711-APK-Signierung und finale Abgabe.
- **Kein Android-Gerätetest. Keine fertige 711-APK oder fertige 711-Veröffentlichung behaupten.**

## Unterbrechung und Wiederaufnahme

Die lokale Umgebung wurde am 20.10.2026 während der GitHub-Sicherung als nicht verfügbar gemeldet. Der Stand wurde lokal gestaged, aber noch nicht als vollständiger 711-Commit veröffentlicht.

Arbeitsverzeichnis:
`/workspace/scratch/5432da847347/realm-alliance-710`

Lokaler Branch:
`feature/work-711-wardrobe`

Lokaler Git-Index enthält **67 gestagte Dateien**. Dateiliste:
`/workspace/scratch/5432da847347/711-staged-files.json`

Alle **34 PNG-Dateien** wurden vor der Unterbrechung bereits als Git-Blobs an GitHub übertragen. Die zugehörigen Blob-SHAs sind im lokalen Git-Index (`git ls-files --stage`) auslesbar. Sie wurden noch nicht durch einen veröffentlichten 711-Baum/Commit referenziert. Dieser Checkpoint dokumentiert die Arbeit und ist ausdrücklich kein Ersatz für den vollständigen Quellstand.

Nach Wiederverfügbarkeit zuerst Arbeitsbaum/Index und aktuellen Remote-Stand prüfen; lokale 711-Dateien nicht durch einen frischen 710-Checkout überschreiben. Anschließend vollständig committen/pushen und Tests/Builds fortsetzen.

### Wichtige neue Quelldateien

- `godot/realm_alliance/scripts/systems/wardrobe711.gd`
- `godot/realm_alliance/scripts/presentation/wardrobe_visual711.gd`
- `godot/realm_alliance/assets/work711/wardrobe/{manifest.json,foot_anchors.json,cloth711.gdshader}`
- `godot/realm_alliance/assets/work711/wardrobe/{wander_leather,silver_guard,forest_path,sand_traveler}/`
- `godot/realm_alliance/production/work711/*_atlas.png`
- `godot/realm_alliance/tests/{test_wardrobe711.gd,outfit_gallery711.gd}`
- `development/{browser_review711.cjs,normal_web711.cjs,build_web711.py,build_711.py,package_711.py}`
- `.github/scripts/build_android711.py`
- `.github/workflows/{realm-711.yml,realm-711-android.yml}`

Geändert wurden außerdem die vorhandenen Helden-, Ausrüstungs-, Mantel-, Shader-, Sammlungs-, Session-, Haupt-/HUD- und QA-Adapterdateien. Der gestagte Index ist maßgeblich.

### Originalgrafiken

Unter `/workspace/scratch/5432da847347/generated_images/`:

- Wanderleder: `exec-d77fbe41-d87c-439b-a7b3-3ccc04a4b02b.png`
- Silberwacht: `exec-7b3269d6-5172-449e-a756-e46db8e4b66d.png`
- Waldpfad: `exec-d56731e1-93cf-43bd-9e57-4925093778d4.png`
- Sandwanderer: `exec-d4be374d-35b0-4a3a-928c-f62b6a94503e.png`

Vier getrennte Atlasgenerierungen mit dem kanonischen waffenfreien Realmwächter als Stilreferenz. Raster 1536×1024, drei Spalten/zwei Zeilen: Brust, linke Schulter, rechte Schulter / Hüfte, Stiefelpaar, Mantel. Stiefelpaar beim Normalisieren in zwei Teile aufgeteilt. Alpha >128 für sinnvolle Boundingbox, vier Pixel Rand, proportional auf transparentes Zielcanvas gesetzt; Originalalpha erhalten. Keine neue vollständige Heldenfigur oder fest integrierte Waffe erzeugt.

### Lokale Prüfdateien und Werkzeuge

- `/workspace/scratch/5432da847347/711-{native,feature-checks,browser,backend}.json`
- `/workspace/scratch/5432da847347/build711/qa/` (ausschließlich QA, nicht ausliefern)
- `/workspace/scratch/5432da847347/review711/` (interne Aufnahmen, nicht als Nutzerartefakte publizieren)
- Godot: `/tmp/realm710-tools/Godot_v4.7.2-stable_linux.x86_64`
- Android SDK: `/tmp/realm710-tools/android-sdk`
- Browser: `/tmp/realm711-browser/chrome-headless-shell-linux64/chrome-headless-shell`

Das normale Chrome scheiterte im lokalen Container an verbotenen Unix-Sockets; der Headless-Shell-Browser lief erfolgreich. Einfacher Git-Push über die Shell hatte keine Anmeldedaten; GitHub-Connector-Gitobjekte verwenden. Bilddateien wurden in 65.535-Byte-Blöcken gelesen und anschließend als Base64-Blobs gespeichert.

## Private Signierung

Der korrekte ursprüngliche Schlüssel wurde bereits im privaten 709-Quell-ZIP gefunden und für die fertige 710-APK verwendet. Sein öffentliches Zertifikat: SHA-256 `317eb8e2e5bf1c8a5bd8b0433a7536bcc903da97d5ba437c20e9474cdd4af219`.

Das unveränderte Originalarchiv ist privat vorhanden; Schlüssel niemals ins Repository oder die Abgabe übernehmen. Für die 711-APK aus dem privaten Originalarchiv wiederherstellen, temporär verwenden und entfernen. Keine Ersatzidentität erzeugen. Unbeaufsichtigte GitHub-Android-Builds benötigen weiterhin das private Actions-Secret.

## Nächster technischer Prüfpunkt

FX-Einstellungswechsel am tatsächlich laufenden Kampfhelden prüfen: Der direkte Rig-Test setzt Effekte aus und ruft set_gear auf. Noch sicherstellen, dass auch der reale Einstellungsweg die neue Mantelbewegung/Veredelungsdarstellung sofort aktualisiert. Bei Bedarf einen kleinen set_effects-Hook im vorhandenen set_upgrade_tier-Pfad ergänzen und gezielt testen.

## Bewusst unverändert / Folgearbeit

- Kein automatischer Austausch bestehender Spielstände oder bestehender Helden.
- Keine neue Sammelhelden-Party.
- Basic-Abenteurer m/w, Haarfarben und echte Charaktererstellung/Klassenwahl weiterhin 712; dafür fehlen noch geprüfte passende Körper-/Haar-Produktionsassets.
- Bestehende Rüstungsstufen 1–10, Waffenstufen 1–20 und separate Verzauberung 0–5 erhalten; eine komplette Vereinheitlichung dieser Achsen ist noch nicht implementiert.
