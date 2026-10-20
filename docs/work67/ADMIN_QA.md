# REALM ALLIANCE — Local QA Admin Testlabor (Work 6.7)

## Zweck

Das QA-Testlabor erleichtert das Prüfen neuer Helden, Begleiter, Evolutionen und Bosskämpfe. Es ist **kein Online-Admin-Backend** und verleiht keine Rechte auf zukünftigen Multiplayer-Servern.

## Öffnen

1. **Godot-Debug-Build** der Admin-QA-Feature-Branch starten.
2. Unter **Mehr** auf **QA-Testlabor öffnen** tippen.
3. Im Testlabor Testressourcen, Account-/Heldenlevel, Stage-Freischaltung, Kaela, Begleiter und Evolution ausprobieren.
4. Für den direkt sichtbaren 6.7-Showcase **SHOWCASE: Kaela + Himmelsfuchs aktivieren** wählen.
5. Dialog mit **Im Testspiel weitermachen** schließen, dann im Bereich **Wesen** die Sammlung ansehen und im **Kampf** die geänderten Spielfiguren beobachten.
6. Zurück nach **Mehr → QA-Testlabor → QA verlassen**: Der Originalspielstand wird in-memory wiederhergestellt.

Das QA-Menü ist nur in Godot-Debug-Builds sichtbar. Exportierte Release-Builds dürfen das Menü nicht anbieten. **Ein Debug-Build ist nicht für öffentliche Online-Distribution bestimmt.**

## Strikte Datenisolation

- Vor dem Start wird der originale lokale Spielstand gesichert. Wenn dies nicht gelingt, wird QA nicht aktiviert.
- Während QA läuft, ist die aktive CombatSession eine **separate Kopie**. Die normale automatische Speicherung ist unterdrückt.
- Ein Import/Export des Testspielstands über die Oberfläche ist während QA gesperrt.
- Beim Verlassen wird die *originale CombatSession* inklusive ursprünglichem Fortschritt wiederhergestellt.
- Beim unerwarteten Abbruch wird QA nicht gespeichert: Ein normaler Neustart lädt den zuletzt gesicherten Originalstand.
- Gold, Splitter, Helden und Weltfreischaltungen in QA sind ausschließlich Tests. **Für normale Spieler bleiben Freischalt- und Kostenregeln unverändert.**

## Schnellaktionen

| Aktion | QA-Effekt |
|---|---|
| +10.000 Gold / +500 Himmelssplitter | Temporärer Ressourcenzuwachs |
| Level 12 | Account und aktiver Held erreichen mindestens Level 12 |
| Regionen freischalten | Wolkgarten und Glutkern jeweils fünf Stages / drei Sterne |
| Kaela / Begleiter | Schaltet den vorhandenen Katalog für Testzwecke frei |
| Himmelsfuchs entwickeln | Setzt nötige Voraussetzungen in QA und löst die **echte** Evolutionsfunktion aus |
| Showcase | Kaela und Himmelsfuchs werden für einen neuen Run ausgewählt |
| Wolkgarten-Boss | Startet das vorhandene Boss-Encounter (keine simulierte Bossfigur) |

## Verifizierung

`godot --headless --path godot/realm_alliance --script res://tests/test_admin_qa.gd`

GitHub Actions führt diese Prüfung zusätzlich zu den bisherigen Work-6.7-Regressionen aus.

## Spätere Online-Administration

Ein späteres **echtes Server-Admin-System** benötigt Nutzerrollen, serverseitige Berechtigungsprüfungen, Audit-Logs, Moderationsworkflows, Trennung von Produktion/Staging, sichere Freigaben und eine eigene serverseitige API. Niemals diese lokalen QA-Aktionen als Online-Verwaltungsbefehle übernehmen.
