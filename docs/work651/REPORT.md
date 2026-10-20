# Work 6.5.1 — visueller Review-Build

Branch: `feature/work-6-5-1-master-ui`; Runtime: `46b5cc2445686ddc48c857f97a45c22568de68a4`. Roadmap 6.5.1–7.0 steht in `docs/DEVELOPMENT_ROADMAP.md`. Main und Game Factory wurden nicht verändert.

## Integriert

- Sechs zusammengehörige echte SVG-Nine-Slice-Materialien für dunkle, abgerundete Fantasy-Panels, Buttons, Auswahl, Boss-/Reward-Flächen und Slots. Die früheren großen Metallrahmen werden nicht mehr gerendert.
- Zentrales Gegner-HUD, kompakter Toast darunter, stärkere Golem-Komposition auf gemeinsamer Bodenlinie, tatsächliche Gold-/Splitter-/Sternwerte im Header. Die frühere Post-Platzhalteraktion öffnet echte Aufgaben.
- Große illustrierte Region mit fünf bedienbaren Stage-Knoten. Gespeicherte Sterne, Freischaltungen, Bestätigung und tatsächlicher Kampfstart bleiben maßgeblich.
- Offener kanonischer weißhaariger Realmwächter mit separater Waffe, bestehenden Rüstungs-/Kopf-/Flügellayern, Ausrüstung, Talenten, Evolution, Waffenwechsel und Skill-Upgrades.
- Vier Spalten im echten Inventar, Seltenheitsrahmen, Icons, Level/Anzahl und aktiver Ausrüstungsstatus; vorhandene Filter, Vergleich und Upgrade-Regeln erhalten.
- Profilkarte, echte Aufgaben/Erfolge sowie gruppierte Save- und Audio-/Effektfunktionen auf Mehr. Keine funktionslosen Shops/Dungeons/Events hinzugefügt.
- Kurzer begrenzter Menüübergang nur bei voller Effektstufe. Vorschaurig aktualisiert sich bei geänderter Erscheinung; Texturen werden zwischengespeichert. Save-Schema und Gameplay-Regeln bleiben erhalten.

## Nachweise

**877/877 Prüfungen in 17 Suites**, lokal und im erfolgreichen [CI-Lauf 39130584796](https://github.com/Broosskyy/Realm-Alliance/actions/runs/39130584796), Job 117684748925. Die bisherigen 849 Checks und 28 neue UI-/Kartenprüfungen bestehen. Projektimport, echter Szenenstart, Webexport und Android ARM64 Debug APK sind erfolgreich.

Das unveränderte CI-Webartefakt wurde mit Chrome 155.0.8059.84/SwiftShader und echten Touch-Eingaben geprüft: dreimal V1-Import mit sofortigem Neuladen; danach frisches V2-Profil mit nur Stahl Level 1 und null Ressourcen. Wolkgarten und Glutkern einschließlich Elite/Boss abgeschlossen; zehn echte Kills, fünf erbeutete Schwerter, zwei Bosskisten, erste Questbelohnung, eine geöffnete Kiste, Himmelsklinge Rang 2 und ein verdienter Vitalitätspunkt. Reload erhielt Region, Sterne, Kisten, Quest, Skill und Talent. Keine Scriptfehler. Desktop-Maus und alle fünf Bereiche in 360×800, 720×1280, 720×1560 und 1280×720 wurden zusätzlich im gleichen CI-Webbuild bedient und aufgenommen.

Die unten verlinkten WebP-Vorschauen stammen aus tatsächlichen nativen Godot-Szenen. Für die Layerprüfung war ausdrücklich ein QA-Profil mit vorab gesetztem Equipment/XP aktiv. Diese Bilder sind **kein Beleg für erspielte Bestände**; dafür dient der getrennte frische Browserlauf oben. Fünf Ansichten: 360×800; Boss: aus 720×1560 auf 360×780 verkleinert.

[Kampf](screenshots/kampf.webp) · [Boss](screenshots/boss.webp) · [Abenteuer](screenshots/abenteuer.webp) · [Wesen](screenshots/wesen.webp) · [Beute](screenshots/beute.webp) · [Mehr](screenshots/mehr.webp)

Ein zwischenzeitlicher Reset des temporären Arbeitsordners hat die ausführlichen früheren lokalen Rohaufnahmen und Browserlogs entfernt. Die bereits auf GitHub gespeicherten Screenshot-Blobs, der Source-Stand und die CI-Artefakte sind erhalten. Das bereitgestellte QA-Paket enthält die erhaltenen Vorschauen, den erneut abgerufenen CI-Log und die unten genannten Prüfergebnisse; es behauptet nicht, sämtliche früheren Rohaufnahmen zu enthalten.

## Performancegrenze

Zehn Sekunden echter Kampf im CI-Webexport, 720×1560, volle Effekte, AUTO und manuelle Skills, tatsächlich erspieltes Profil: 141 Browser-rAF-Intervalle in 10,012 s, Median 66,7 ms, P95 133,4 ms; Modellzeit 10,683 s, Kills 10→11 und alle vier Skills angenommen. Dies ist langsames gehostetes Software-Rendering, **kein bestandener 60-FPS-Nachweis** und keine Android-Messung. Der frühere 6.5-Wert lag bei Median 66,6/P95 116,6 ms; ein Performancegewinn ist daraus nicht belegt.

## Builds

Godot 4.7.2. Android-Version 0.6.5.1 / Code 651, Paket `com.avenor.realmalliance.preview`, vorhandener Entwicklungsschlüssel.

| Datei | Bytes | SHA-256 |
|---|---:|---|
| Web-ZIP, Artifact 12137947219 | 27331292 | `986ca0c67394ba77d3b35df762f4d30dae8e11df21f9de6c00cd4f3934a6908f` |
| Android-ZIP, Artifact 12137917367 | 45185539 | `6fff36a70d6f0c4fea864ba2bbe7a46bfc0ce3f78cf27f22d0c8720bff184faf` |
| APK | 45483591 | `c83755dabab0dda3526b168efb1cd057e3804a16d133695eb01ffd9d17410fb3` |

Die Original-ZIPs wurden nach erneutem Abruf auf diese Hashes geprüft. GitHub-Artefakte laufen am 2027-01-16 ab und benötigen ggf. Anmeldung. Direkte Downloads enthalten dieselben Bytes.

## Noch offen

Visuelle Freigabe gegenüber den Masterbildern, weitere Lesbarkeitspolitur auf echten Geräten, Android-Installation/Video/Performance und das mobile Renderbudget. Der APK-Export ersetzt keinen Gerätetest. Dieser Review-Build ist keine pixelgenaue Reproduktion der generierten Master.

6.6–7.0 bleiben nächste Meilensteine, keine Fertigmeldungen. x2/x4 muss vor Implementierung konkret spezifiziert werden. Keine Online-/Multiplayer-/serverautoritative Economy-Behauptung. Kein automatischer Merge.
