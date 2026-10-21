# REALM ALLIANCE — Design-Master 713+ (NosTale-/Metin2-Inspiration, eigene IP)
**Status:** Designvorschlag, keine fertige Feature-Implementierung. Basierend auf **712** in `feature/work-712-character` (Commit `b2015bd8068f9181312bb59d84b33ccf4e03412a`), mit den zuvor wiederhergestellten 711.1-Grafiken. Keine Änderung an bestehenden Spielständen durch dieses Dokument.

## Produktidentität
Ein mobiles/webbasiertes **2D/2.5D Fantasy-Idle-/Tap-Action-RPG** mit *einem selbst erstellten Hauptcharakter*, eigener Welt, Erkundung, direktem Tap-Kampf, langfristiger Klassen-/Jobentwicklung, gut sichtbarem Loot, stylisierten Rüstungen und starken sozialen/kooperativen Spielsystemen. **NosTale** dient als Referenz für Jobentwicklung, Spezialistenkarten, Pets, NPC-Partner, Elemente/Feen und Familien. **Metin2** dient als Referenz für sichtbare Waffen-/Rüstungsprogression, Aufwertungen, Materialjagd und Ausrüstungswirkung. Keine Übernahme fremder Namen, Designs, Maps, Figuren, SP-Karten, Icons, Musik oder unverwechselbarer Assets.

## Tatsächliche 712-Basis
- Männlicher/weiblicher Basic-Abenteurer, schwarz-maskiertes Gesicht + leuchtende Augen, vier kostenlose natürliche Haarfarben, gesperrte Fantasy-Haarfarben.
- Getrennte Charakter-/Job-EP; Wahl von Schwertkämpfer, Bogenschütze oder Magier am vorläufigen Abenteurer-Joblevel 5 (**nur Test-Balancing**, finale Schwelle offen).
- Getrennte Bogen-/Stab-Sprites und erste Geschosse; bislang teilen die Klassen die Basic-Posen und die Waffenwerte ihrer bisherigen Ausrüstung.
- Bestehende Pets, Inventar/Ausrüstung, Gilde/Familien-Backend, Titel, Raid, Spin, Tap, Quests und Bossfortschritt existieren in verschiedener Reife.
- Keine fertigen Spezialistenkarten, eigenständigen NPC-Partner oder entwickelten Feen-/Elementarsysteme. Kein verifizierter öffentlicher Godot-712-Spiel-Deploy: Vercel baut bisher den erhaltenen React-/Vite-Prototyp aus dem Repo-Root. Ein Vercel-READY-Status allein bedeutet **nicht**, dass 712 als Godot-Webspiel live ist.
- 712-Bericht: 35 native Suiten/3938 Checks, 70 Browserchecks, normaler Web-Smoke-Test, kein physischer Android-Gerätetest. `development/releases/712.json` dokumentiert Builds/Hashes; dies ersetzt keinen öffentlich erreichbaren Download.

## Spieler-Loop
**0–60 Sekunden:** Gastmodus, Figur erstellen, in weniger als fünf Sekunden Tap-Ziel erkennen, 30–60-Sekunden-Kampf-/Loot-Schleife.
**1–10 Minuten:** Kampfstufen, Ausrüstung anlegen, erste Quest, Pet verstehen, Material und Upgrade sichtbar verdienen.
**Frühe Meilensteine:** Joblevel → Klassenmeister-Quest → *derselbe* Charakter mit eigenem Klassenkampf; kein automatisch erzeugtes Heldenteam.
**Langfristig:** Klassen-Skills, Spezialistenkarten, Charakteraufwertung, regionale Bosse, Partner-NPC, Elementwesen, Familienmissionen/Raids, Ruf, Titel, Sammlungen.
Idle ist eine Ergänzung: automatischer Grundangriff/optionale Auto-Fortschritte und begrenzter Offline-Ertrag; aktives Tap, Timing, Skills, Ausweichen und Bossmechaniken sollen sich lohnen. Noch keine feste Monetarisierung oder endgültige Offline-Cap ohne Balancetest.

## Verbindliche Systemgrenzen
1. **Hauptcharakter:** Ein persönlicher Avatar. Körper/Haar/Maskenidentität bleiben beim Klassen- und Spezialistenwechsel erhalten.
2. **Basis-/Joblevel:** Getrennte, save-sichere Werte. Klassenwechsel/-wahl nur nach nachvollziehbarer Quest; Joblevel 5 ist aktuell nur Provisorium.
3. **Spezialistenkarten (SP):** Im Originalspielprinzip *Gameplay-Formen*, keine bloßen Kostüm-Skins. Eigene Skills, visuelle Rüstung/Insignien, ggf. eigener Spezialistenfortschritt, Aufwertung **+0 bis +15 als Ziel**, Aktivierungsregeln und Elementbindung. Cosmetics bleiben ausdrücklich separat. Erste SPs erst nach Klassenidentität und Balance festlegen.
4. **Ausrüstung:** Waffen, Rüstung, Helm, Stiefel, Handschuhe, Flügel, Kostüm und SP-Layer modular. Vor allem deutlich unterschiedliche 2D-Silhouetten und Upgradestufen; Waffe bleibt ein austauschbarer Handanker. Keine fertigen Posterbilder als freigestellte Spielfiguren verwenden.
5. **Pets:** Vorhandenes `companion_progress.gd` weiterverwenden; sammelt, levelt, entwickelt.
6. **Partner-NPCs:** Eigenständiges Begleiterdomänenmodell (Rekrutierung durch Quest, eigenes Level/Equip/Skills), ausdrücklich *nicht* zweite Spielerhelden. Aktive Slotanzahl zunächst offen.
7. **Feen/Elementbegleiter:** Start mit **Feuer, Wasser, Licht, Schatten** als Referenz-Menge. Zusätzliche **Natur, Blitz, Arkan** nur als Kandidaten, wenn Elementmatrix, Effekte, UI und Balance schlüssig sind. Eigener Fortschritt/Visual/Elementbindung; kein pauschal überlegenes Pflicht-Element, keine Pay-to-win-Elemente.
8. **Familien und Ruf:** Bereits vorhandene Familien-/Gilden- und Raid-Struktur nutzen, später Rollen, gemeinschaftliche Missionen, Bossbeiträge, Familienlevel, Ruf/Titel sowie UI für Fortschritt. Ruf ist eine eigenständige Progressionsachse; keine Strafmechanik ohne Designprüfung.
9. **Inventar & Loot:** verständliche Filter für Waffen/Rüstung/SP-Karten/Materialien/Pets/Questitems; Quelle und Einsatz jedes Items anzeigen; selbsterklärende Upgrade- und Seltenheitsschritte.
10. **Kooperative & Idle-Gerechtigkeit:** ohne Account sofort spielbar; Server-authoritative Ressourcen/Transaktionen bei Online-/Handelssystemen; keine doppelten offline Rewards, Save-Migration statt Reset.

## Master-Mockups – zehn visuelle Referenzen
Die separat bereitgestellten zehn Bilder werden als **Art Direction**, nicht als fertig ausgeschnittene Sprite-Atlanten verwendet:
01 `fantasy_charakterauswahl_im_ruinenreich.png` – Charakterauswahl und Farbfelder;
02 `basisabenteurer_im_ruinenreich.png` – männlicher Level-1-Abenteurer;
03 `basic_abenteurerin_in_ruinen.png` – weiblicher Level-1-Abenteurer;
04 `swordsman_im_ruinenreich.png` – männlicher Schwertkämpfer;
05 `realmschwertkämpferin_im_ruinenreich.png` – weibliche Schwertkämpferin;
06 `fantasy_archer_im_ruinenreich.png` – männlicher Bogenschütze;
07 `fantasy_archerin_im_ruinenreich.png` – weibliche Bogenschützin;
08 `chibi_magier_im_reichsbündnis_712.png` – männlicher Magier;
09 `fantasy_magierin_im_ruinenreich.png` – weibliche Magierin;
10 `realm_alliance_712_wähle_deine_klasse.png` – spätere Klassenwahl, **nicht** direkt bei Figurenerstellung.
Art-LOCK: maskenhaft schwarzes Gesicht/leuchtende Augen, stylized Western Fantasy mit leichter Anime-Lesbarkeit (nicht reiner Anime), gleiche Proportionen und isometrische Perspektive, klares UI für Portrait/Mobile; Anfänger schlicht, höhere Klassen sichtbarer. Keine übertriebene VFX-Fläche auf der Spielfigur. Technische Produktionsassets getrennt für Grundkörper, Haar, Kopf, Rüstungsteile, Handanker/Waffen, Flügel, SP-Layer, Effekte und animationskompatible Posen; transparent mit großzügigem Schnittabstand.

## Umsetzungsvorschlag; Versionen vorbehaltlich bereits gestarteter Work-Arbeit
**713: 712-Stabilisierung & Live-Klarheit.** 712 normal/QA-Builds erneut bestätigen; echte Godot-Web-Preview separat bereitstellen (nicht die ältere Vite-App als Godot ausgeben), Touch/Scroll/Pose/Kostüm-/Waffenanker/Shader- und FX-Regressionsprüfungen 320–430px. Haarfarbe, Charakterwahl, Klasse, unveränderte alte Saves, Spielstandexport überprüfen. Zehn Mockups als Masterdesign freigeben, danach schrittweise echte Sprite-Atlanten produzieren.
**714: Klassen wirklich unterschiedlich spielbar.** Bogen-Spann-/Schussposen, Magie-Antizipation/Zaubereffekte, Schwert-Kombos; echte Klassenwaffen/-skills und Balance ohne Bestehendes zu verlieren.
**715: Elemente & Begleitergrundlage.** Elementmatrix/Feenprototyp, UI, Tests, getrenntes NPC-Partner-Model; bestehende Pets nicht ersetzen.
**716: Spezialistenkarten-Vertical-Slice.** Zunächst eine SP-Form pro ausgewählter Klasse als Designziel, nur nach Freigabe; Kartenerwerb, Wechsel, Skillset, +0…+15 als Ziel, save-sichere IDs.
**717+: Familien-/Ruf-/Raidsysteme & Welterweiterung.** Langfristige regionale Quests, Weltkarte/NPC-Hubs, Spezialistenbosse, Materialquellen, Titel. Prioritäten später an echten Spielerfeedbacks ausrichten.

## Unmittelbare Qualitätsregeln
- Keine Änderung an `main`, Produktionsdomain oder laufendem Work-Branch ohne getesteten PR-/Deploy-Pfad.
- Jede neue Mechanik über versionierte Datenverträge, Migration, echte Unit-/Browser-/Androidchecks absichern. Keine Testzahlen ohne Ausführung.
- Große Mockups niemals 1:1 als fertige Gameplay-Sprites ausgeben: realer modularer Renderer mit gemessenen Ankern ist maßgeblich.
- Mobile Lesbarkeit/Scrollbarkeit, zügige Interaktion, geringe Ladegröße und hoher Spielwert haben Vorrang vor bloßer Effektdichte.
- Keine Credits oder andere Fortschritte verlieren; vorhandene Käufe/Währung/Inventar und Profile bleiben erhalten.
- Nutzer hat weitere eigene Gameplay-Ideen angekündigt: **Neue grundlegende Entscheidungen als Entwurf markieren, nicht voreilig endgültig implementieren**.
