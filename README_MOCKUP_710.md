# REALM ALLIANCE · 710 · Flügelentwicklung und Ausrüstung

Fortsetzung des vollständig wiederhergestellten Godot-Stands 709, Basiscommit cfbdf262c2a69bfb459ed944d657a86b85a61854. Der bisherige Stand unter backup/pre-709-main-20261020 und web_build/709 bleibt erhalten.

## Implementiert
- Flügel +0 bis +15 mit echten HP-/DEF-Zuwächsen und begrenzter, bezahlter Aufwertung. Beide bisherigen Flügel-IDs und ihre Erwerbsquellen bleiben gültig.
- Alte Gegenstandsstufen bleiben unverändert gespeichert: bisherige Flügelstufe 1 entspricht +0, Stufe 10 entspricht +9. Keine bezahlte Aufwertung, Währung oder Gegenstandsmetadaten werden gelöscht. Neu erreichbare Stufen reichen bis Gegenstandsstufe 16 / +15.
- Erste Entwicklung auf Basis der vorhandenen Himmelsflügel: zunehmende Spannweite, zusätzliche texturierte Federsegmente, Kristalldetails ab +5, zweiter Fächer ab +8, zurückhaltende Lichtdetails ab +10, Kronendetail ab +12 und Endstufenbewegung bei +15. Laufzeitkomposition aus vorhandener Grafik und Geometrie; keine Behauptung von fünfzehn neu gemalten PNGs.
- Ausrüstung zeigt für eigene Flügel die tatsächlich getragene Form und die nächste Aufwertung nebeneinander. Vorschau verändert weder Besitz noch Werte oder Materialbestände. Inventarkarten und Itemdetails zeigen den Pluswert. Schmale Ausrüstungsfenster zeigen die Figuren untereinander mit mehr Platz; breite Fenster vergleichen nebeneinander. Große Flügel erhalten im Kampf zusätzlichen Platz durch den Figurenanker, ohne den Helden zu verkleinern.
- Vorhandene Sternen-/Eklipsenrüstung erhält an passende Körper-/Kampfposen gebundene Schulter- und Saumdetails. Der Realmwächter behält seine vorhandenen vollständigen Rüstungskörper. Dies ist eine Verbesserung vorhandener Ausrüstung, noch kein vollständig neues Rüstungs-/Kostümpaket.
- Austauschbare Waffen behalten ihren eigenen Handanker und ihre bisherigen Werte. Die sichtbare Veredelung reagiert genauer auf vorhandene Verbesserungen; hohe Stufen ergänzen dezente bewegte Lichtpunkte.
- Die Einstellung für reduzierte/abgeschaltete Effekte gilt für neue Flügel-/Waffendetails. Flügelform und Ausrüstungswerte bleiben bei abgeschalteten Effekten erhalten.
- Optionaler Datenvertrag für spätere männliche/weibliche Basic-Abenteurer, natürliche und besondere Haarfarben, Maske/Augen und getrennte Ausrüstungslayer. Keine neue Charaktererstellung, kein Heldenteam und keine automatische Umstellung bestehender Profile in 710.

## Kompatibilität
Runenpaladin, Schattenjäger und Realmwächter bleiben erhalten. Charakter-XP, Aufstiegsränge, Inventar, Pets, Quests, Spin/Tap, Dungeons, Regionen und Gemeinschaft werden weiterverwendet. Rüstungen behalten Stufe 1–10, Waffen Stufe 1–20 und die bisherige Verzauberungsachse. Eine allgemeine Umstellung aller Ausrüstung auf dieselbe Plusachse wird nicht als fertig behauptet.

Unbekannte Flügelrevisionen oder ungültige Stufen schützen den Spielstand durch Schreibsperre. Alte 709-Clients verstehen die neu erreichbaren Flügelstufen oberhalb ihrer bisherigen Grenze nicht; vor einem Versionsrückwechsel den Spielstand exportieren.

## Bauen und starten
Godot 4.7.2. Das aktuelle Projekt ist godot/realm_alliance/project.godot. Die ältere React-Vorlage und das Backup sind nicht die aktuelle Spielgrundlage.

    python3 development/run_checks.py --godot /pfad/godot --report checks710.json
    python3 backend/test_service708.py backend710.json
    python3 development/build_710.py --godot /pfad/godot --output /absoluter/buildordner

Der Webexport verwendet den unveränderten, in 709 gespeicherten Godot-4.7.2-JavaScript-/WASM-Enginecode mit einem neu exportierten 710-Spielpaket und aktualisierter Größen-/Hashangabe. Der separate QA-Export wird ausschließlich mit --qa erzeugt; die Paketierung lehnt ihn ausdrücklich ab.

Web-ZIP entpacken, Python 3.10+ verwenden und python3 START_WEB.py ausführen. http://127.0.0.1:8765 öffnet Spiel und bestehenden lokalen Realm-Dienst. Ein öffentlicher Realm ist weiterhin nicht vorverbunden.

## Prüfungen und Abgabe
Die 710-Pipeline importiert das echte Projekt, führt alle Godot- und Backend-Suiten aus, exportiert Normal-/QA-Web getrennt und prüft Browser, echte Touchaktionen, Upgradepreise und vier Bildschirmgrößen. Protokolle werden der Abgabe beigefügt; die finalen Zahlen stehen in den tatsächlichen JSON-Berichten.

Beim wiederhergestellten unveränderten 709-Stand bestand ein veralteter Test noch auf vier Inventarspalten, obwohl die tatsächliche 709-Oberfläche drei verwendet. Diese einzelne Erwartung wurde korrigiert. Die bestehende Vorschauprüfung verwendet jetzt die jeweiligen tatsächlichen Slotgrenzen, damit die neue Flügelgrenze geprüft wird und Rüstungen begrenzt bleiben.

Die GitHub-Automation erstellt nach erfolgreichen Prüfungen einen normalen Web-Build im Repository und eine Vorschauveröffentlichung mit Web-ZIP, vollständigen getrackten Quellen, Hashes und Prüfprotokollen. Interne Browseraufnahmen gehören nicht zu den Abgabedateien.

## Android
Keine 710-APK wird mit einer Ersatzidentität erzeugt. Für ein kompatibles Update fehlen in dieser Umgebung der ursprüngliche private Signaturschlüssel und die Android-Signierkonfiguration. Der optionale Android-Build verlangt ausdrücklich den Originalschlüssel; Zugangsdaten und Schlüssel werden nicht öffentlich gespeichert. Kein Android-Gerätetest.

## Offen für 711/712
Vollständige neue Rüstungsfamilien, zwei eigenständige Kostümsets und weitere Flügelgrafikfamilien bleiben ausdrücklich Teil der Folgearbeiten. Die neuen hochgeladenen Basic-/Klassenmockups konnten über die gelieferten lokalen Pfade noch nicht visuell gelesen werden; sie werden nicht als bereits integrierte Produktionsassets ausgegeben.

Ab 711/712 folgt der einfache männliche/weibliche Basic-Abenteurer mit kostenlosen natürlichen Haarfarben und anschließender Entwicklung desselben Charakters zum Schwertkämpfer, Bogenschützen oder Magier. Exakte Levelschwellen und ein mögliches NPC-Partnersystem bleiben offen. Bestehende Helden werden ohne weitere Entscheidung weder gelöscht noch zu NPCs umgewidmet. Siehe development/ROADMAP_710_712.md.
