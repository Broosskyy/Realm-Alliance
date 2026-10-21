# REALM ALLIANCE 711 – gesicherter Quellstand, unvollständig

Am 21.10.2026 wurde der tatsächlich auf GitHub gesicherte 711-Code wieder lokal geladen. Die frühere lokale Arbeitsumgebung enthält die Originaldateien nicht mehr. Der Branch enthält daher eine partielle Code-Rekonstruktion auf Basis des vollständigen 710-Stands `b603918857911cc62b314eb46f529a386db95de9`.

## Enthalten

- Zwei Rüstungsdefinitionen: Wanderleder und Silberwacht.
- Kostümdomäne mit Waldpfad und Sandwanderer, dauerhaften kostenlosen Fortschrittsfreischaltungen und kosmetischer Auswahl.
- Modulare Darstellung mit sieben Teilen, Fußankern und Mantelshader für die bestehenden Helden.
- Integration in Ausrüstung, Sammlung, Session, Hauptszene und HUD einschließlich Erscheinungs-Cache.
- 711-Android-Versionspreset bei unveränderter Paketkennung.

## Fehlend und ungeprüft

Es fehlen 34 PNG-Dateien: 28 Komponenten, zwei Inventarbilder und vier Quellatlanten. Exakte Pfade und weitere fehlende Test-/Builddateien stehen in `development/RECOVERY_711.json`. Auch die zuletzt bearbeiteten QA-Adapter und Workflow-Anpassungen sind nicht vollständig wiederhergestellt.

Dieser Stand wurde nach der Rekonstruktion nicht durch Godot-, Browser- oder Android-Tests freigegeben. Historische Testergebnisse im beigefügten Checkpoint betreffen den früheren lokalen Stand. Sie dürfen nicht als aktuelle Ergebnisse übernommen werden.

Es gibt keine fertige 711-APK und keinen normalen 711-Webexport in diesem Paket. Die Exporte unter `web_build/709` und `web_build/710` und deren Prüfberichte bleiben ausdrücklich historische Versionen.

## Fortsetzung

1. Fehlende Originalgrafiken und Test-/Builddateien wiederherstellen; neu erzeugte Ersatzgrafiken gegebenenfalls ausdrücklich als neue Varianten dokumentieren.
2. Den realen Einstellungsweg für Effekte-aus am Kampfhelden prüfen und den Mantel nötigenfalls sofort aktualisieren.
3. Native Regressionen, mobilen Browserlauf, normalen Webexport und Backend erneut prüfen.
4. Erst anschließend 711-APK mit dem privaten ursprünglichen Signaturschlüssel erstellen und prüfen. Kein Ersatzschlüssel, kein Schlüssel im Repository oder Quellpaket.

Der vollständige stabile 710-Stand auf `main` und das alte Backup bleiben erhalten.
