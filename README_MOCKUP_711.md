# REALM ALLIANCE 711 – geprüfte Wiederherstellung

Stand: 21.10.2026. Basis ist die vollständige Version 710 (`b603918857911cc62b314eb46f529a386db95de9`). Weiterarbeit erfolgt auf `recovery/work-711-source`.

## Was enthalten ist

- Wanderleder und Silberwacht als kaufbare, aufwertbare Rüstungen mit sieben getrennten Grafikkomponenten.
- Waldpfad nach 25 besiegten Gegnern und Sandwanderer ab erreichter Kampfstufe 15: kostenlos dauerhaft freischaltbare Kostüme ohne Kampfboni.
- Anpassung an Runenpaladin, Schattenjäger und Realmwächter sowie sechs Kampfposen. Die Waffe bleibt separat austauschbar.
- Fußanker auch im exportierten Spiel, Mantelbewegung und sofortige Aktualisierung bei Änderung der Effekteinstellung.
- Kostümreiter, wirkungsfreie Vorschau, Touchscrollen sowie Aktualisierung des tatsächlichen Kampfhelden beim An- und Ablegen.
- Vollständige Grafikquellen, Komponenten, Tests, Buildwerkzeuge und Backendquellen im Quellarchiv.

## Herkunft der Grafiken

Die 34 verlorenen PNG-Originaldateien konnten nicht bytegenau zurückgewonnen werden. Die vier Atlanten, 28 Komponenten und zwei Inventarbilder wurden durch neu generierte Varianten ersetzt. Die verwendeten Bytes und ihre Herkunft sind im Grafikmanifest dokumentiert. Diese Abgabe ist eine vollständige, erneut geprüfte Wiederherstellung mit Ersatzgrafiken; sie ist keine byteidentische Kopie des verlorenen ursprünglichen Arbeitsstands.

## Nutzung

Android: `REALM_ALLIANCE_711.apk` installieren. Paketkennung `com.avenor.realmalliance.mockuptest`, Versionscode 711. Das ursprüngliche Signaturzertifikat bleibt erhalten und wurde geprüft. Ein echter Android-Gerätetest wurde nicht durchgeführt.

Web: `REALM_ALLIANCE_711_Web.zip` entpacken; mit Python 3.10+ `python3 START_WEB.py` ausführen und `http://127.0.0.1:8765` öffnen. Das ZIP enthält den normalen Spielbuild ohne QA-Adapter sowie den lokalen Backendserver. Es wird kein öffentlicher Online-Realm vorgegeben.

Quellen: `REALM_ALLIANCE_711_Quellen.zip` entpacken und `Source/godot/realm_alliance/project.godot` mit Godot 4.7.2 öffnen. `Source/SOURCE_MANIFEST_711.json` enthält Commit, Dateiliste und SHA-256 je Datei. Private Signaturschlüssel sind ausgeschlossen.

## Aktuelle Prüfungen

34 Godot-Suiten mit 3.513 Checks, 26 neue Browser-/Touch-Checks, 61 Browser-Regressionchecks, zwei normale Web-Smoke-Checks und 48 Backend-HTTP-Checks bestanden. Vier mobile/querformatige Größen geprüft: 320×568, 390×844, 430×932 und 960×540. Vier Familien × drei Helden × sechs Posen im tatsächlichen Renderer visuell geprüft. Kein Android-Gerätetest.

## Grenzen und Folgearbeit

Die vorhandenen Helden bleiben erhalten. Basic-Abenteurer m/w, Haarwahl und Charaktererstellung mit späterer Klassenwahl gehören weiterhin zu 712. Eine neue Sammelhelden-Party ist nicht Bestandteil dieses Stands.

Rüstungsstufen 1–10, Waffenstufen 1–20 und separate Verzauberung 0–5 sind erhalten; ihre vollständige Vereinheitlichung ist offen. Die sechs vorhandenen Kampfposen sind geprüft, zusätzliche Angriffs-Zwischenbilder sind nicht als erledigt ausgewiesen. Die neuen Kleidungsteile liegen auf den vorhandenen Körpergrafiken; sie ersetzen diese nicht durch einen schlichten Basic-Abenteurer.

Historische Exporte unter `web_build/709` und `web_build/710` bleiben historische Versionen. Frühere Angaben im Checkpoint beschreiben den unterbrochenen Arbeitslauf; aktuelle Ergebnisse liegen unter `development/reports/*711.json`.
