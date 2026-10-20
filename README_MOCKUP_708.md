# REALM ALLIANCE · Testversion 708

20.10.2026. Fortsetzung der gesicherten 707. Godot-Spiel mit Android- und Webexport sowie eigenem startbarem Realm-Dienst.

## Änderungen

- Gemeinsame Fantasy-Oberfläche: dunkle Metall-/Glasflächen, feine Goldrahmen, Seltenheitsfarben, dezente Lichtbewegung und Partikel in Fenstern. Die Einstellung für reduzierte/abgeschaltete Effekte gilt auch hier.
- Sechs neue transparente Illustrationen: geschlossene/geöffnete Truhe, Aufstiegsmedaillon, Trainingskodex, Titelwappen und Familienbanner. Truhen zeigen das tatsächlich gewährte Ergebnis mit überspringbarer Öffnungsanimation; Levelaufstiege erscheinen als nicht blockierende Meldung.
- Sammlung in der Reihenfolge Runenpaladin → Schattenjäger → Realmwächter. Bestehende Spielstände behalten ihre Helden und den bisherigen Starter. Waldläufer und Sternmagier sind sichtbar als „In Vorbereitung“ gekennzeichnet, noch nicht spielbar.
- **Wesen → Held → Level & Aufstiegsrang**: eigenes Training, eigene Kampf-XP und fünf bezahlte Aufstiegsränge pro Held mit Voraussetzungen, echten Attributboni und zunehmend sichtbarer Veredelung. Eine separate optische Rangvorschau verändert keinen Spielstand. Alte kontoweite Evolutionsboni und bereits erworbene Vermächtnisformen bleiben kompatibel.
- **Mehr → Gemeinschaft** führt sichtbar zu Konto, Familie/Gilde, Arena/PvP, Titeln, Rangliste und gemeinsamem Raid. Verdiente lokale Titel funktionieren auch ohne Verbindung.
- Der mitgelieferte Dienst speichert echte Konten, Familien, Wertungen, Online-Titel, Bossbeiträge und private Spielstandsicherungen in SQLite. Zwei Sitzungen auf demselben Realm sehen dieselben Mitglieder und Boss-HP. Arena-Duelle sind asynchron, automatisiert und serverseitig berechnet. Keine erfundenen Ranglistenspieler. Online-Level und lokale PvE-Entwicklung sind getrennt; manipulierte lokale Kampfwerte bestimmen keine Arena-Ergebnisse.

## Start

**Android:** REALM_ALLIANCE_708.apk aktualisiert den separaten „REALM Mockup Test“ mit derselben Paketkennung und demselben öffentlichen Testschlüssel wie 704–707. Offline-Abenteuer benötigt kein Konto. Unter Gemeinschaft kann ein eigener HTTPS-Realm verbunden werden.

**Web:** Web-ZIP entpacken, Python 3.10 oder neuer installieren, `python3 START_WEB.py` ausführen und `http://127.0.0.1:8765` öffnen. Spiel und Realm-Dienst laufen gemeinsam; Konten und Cloud-Sicherungen liegen dauerhaft unter dem Benutzerverzeichnis in `.realm-alliance/online708.sqlite3`. Für eine zweite unabhängige Spielsitzung ein anderes Browserprofil benutzen. Zum öffentlichen Betrieb siehe `backend/README.md`.

**Quellen:** Godot 4.7.2 mit passenden Exportvorlagen verwenden. Projekt: `godot/realm_alliance/project.godot`. Android benötigt Java 17 und Android SDK.

    python3 development/run_checks.py --godot /pfad/zu/godot --report checks.json
    python3 backend/test_service708.py development/backend_checks_708.json
    python3 development/build_708.py --godot /pfad/zu/godot --output /absoluter/buildordner

Der Browser-QA-Adapter ist aus den normalen Exporten ausgeschlossen. Er wird ausschließlich mit `development/export_review708.py` exportiert. Prüfskripte und Protokolle liegen unter `development`. Interne Screenshots sind keine Abgabedateien.

## Prüfstand

- 31 Godot-Suiten / 2.009 Prüfungen: Kampf, Save-/Import-Schutz, Wirtschaft, Inventar, eigene Helden-XP/-Ränge und wirkungsfreie Vorschauen. Neue Tests sichern den stabilen Raid-Touchbutton und die Warteschlange während Online-Abfragen ab.
- 48 HTTP-Prüfungen mit zwei getrennten Konten: Anmeldung, Familien, serverseitige Arena, gemeinsame Boss-HP, idempotente Belohnungen, private Sicherungen mit Versionskonflikten und Speicherung über Dienstneustart.
- Regulärer Webexport separat gestartet: kein QA-Adapter, echte Toucheingaben und fünf Hauptbereiche, keine Browser-/Skriptfehler.
- Android ARM64: Versioncode 708, v2-/v3-Signatur, Internet-Berechtigung und 16-KiB-Ausrichtung geprüft.
- 34/34 abschließende Browser-/Touch-Prüfungen aus den gezielten Läufen zusammengeführt, zusätzlich 2/2 Prüfungen des normalen Webexports. 320×568, 390×844, 430×932 und 960×540: wirkungsfreie Rangvorschau, echtes Training, echte Aufstiege und mobile Gemeinschaftsfläche. Echte Konten/Familien/Arena/Cloud-Sicherung im Browser; gemeinsame Raid-HP und beide Beiträge nach tatsächlicher Serveraktualisierung geprüft. Truhenöffnung und einmalige Vergabe geprüft. Keine Godot-/Browser-Skriptfehler. Interne Aufnahmen visuell kontrolliert; Protokoll: development/browser_final_708.json.

## Grenzen dieses Stands

Es ist **kein öffentlicher Realm vorverbunden oder veröffentlicht**. Der Dienst ist eine lauffähige Grundlage für einen selbst betriebenen Realm, kein fertiger MMO-Produktionsbetrieb: Passwortwiederherstellung, E-Mail-Verifizierung, Moderation, Live-PvP, Gildenchat/-kriege und skalierter Betrieb fehlen noch. Familien und Gilden sind in diesem Stand dieselbe Gemeinschaft mit bis zu 30 Mitgliedern. Der gemeinsame Raid ist realmweit.

Neue komplette Outfit-Sets, Körper-Zwischenbilder, weitere spielbare Klassen, Flügel-Evolutionen und zusätzliche Monster-/Shop-Systeme bleiben weitere Ausbauschritte. Rangoptik nutzt Palette, Licht, Ring und Rangzeichen auf den bestehenden modularen Helden. Keine Behauptung, dass die früher besprochenen gesamten Meilensteine 7.1–7.5 wiedergefunden oder fertiggestellt wurden.

Android wurde exportiert und technisch auf Signatur, Paketinformationen und Ausrichtung geprüft; kein Test auf einem echten Android-Gerät und keine Hardware-FPS-Aussage. Kein GitHub-Push und keine öffentliche Veröffentlichung in diesem Arbeitsschritt.
