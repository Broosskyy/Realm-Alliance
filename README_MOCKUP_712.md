# REALM ALLIANCE · Work 712

Basis: gesicherter 711.1-Stand. Neue Spielstände beginnen mit der Erstellung eines männlichen oder weiblichen Basic-Abenteurers. Auf bestehenden Spielständen ist die Erstellung freiwillig unter Wesen → Charakter erreichbar. Runenpaladin, Schattenjäger, Realmwächter, Währungen, Inventar, Ränge und Begleiter bleiben erhalten.

Blond, Schwarz, Braun und Kupfer sind kostenlose Haarfarben ohne Kampfbonus. Schwarze Gesichtsfläche und leuchtende Augen bleiben erhalten. Besondere Haarfarben sind vorbereitet und bei der Erstellung gesperrt. Waffen sind getrennte Sprites. Beide Körper haben sechs Posen und eigene Hand-, Kopf-, Brust-, Rücken- und Kostümanker.

Siege vergeben zusätzlich unabhängige Charakter- und Job-EP. Klassenwahl entwickelt dieselbe Figur zu Schwertkämpfer, Bogenschütze oder Magier; das Charakterlevel bleibt erhalten, der neue Job startet auf Level 1. Die erste Klassenwahl ist derzeit dauerhaft und wird im Spiel bestätigt. **Abenteurer-Joblevel 5 ist ein vorläufiger Testwert**, keine endgültige Designentscheidung. Konfiguration: `godot/realm_alliance/data/character712.json`.

Bestehende Helden können weiter verwendet werden. Beim Wechsel bleiben Gegner-HP, Stage, Belohnungskennungen, erhaltene Charakter-EP und Jobs bestehen; der Wechsel heilt nicht. Zukünftige oder beschädigte Charakterdaten sperren das Speichern und bleiben unverändert erhalten.

Bogen und Stab haben separate Grafiken und Geschosse. Ihre Werte und Upgrades stammen zunächst von der vorhandenen ausgerüsteten Waffe. Klassen teilen noch die sechs Basic-Körperposen; eigene vollständige Bogenspann-/Zauber-Animationssätze und ein eigenes Klassenwaffen-Inventar sind offen. Die Haarfarbe wird auf der vorhandenen Haarfläche per Shader gefärbt. Keine neue sammelbare Heldenparty, keine Festlegung zu NPC-Partnern.

Die 711.1-Anpassungen an Rüstungen/Kostümen und den mobilen Vorschauen bleiben erhalten. Die neuen Körper verwenden eigene Fitting-Daten. Die generierten Originalatlanten sind im Projekt enthalten; `development/work712/prepare_assets.py` erzeugt daraus reproduzierbar Posen, Porträts, Waffen und die gemessenen Anker.

Build: Godot 4.7.2; `development/build_web712.py`, `.github/scripts/build_android712.py`, `development/package_712.py`. Android benötigt den privaten Originalschlüssel; er gehört nicht in Git oder das Quellenpaket. Normaler Webexport schließt den Testadapter aus. Öffentlicher Realm-Betrieb und Android-Gerätetest sind separate offene Prüfungen.
