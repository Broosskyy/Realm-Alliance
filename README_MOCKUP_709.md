# REALM ALLIANCE · Testversion 709

20.10.2026. Fortsetzung der vollständigen Version 708. Diese Fassung korrigiert den tatsächlichen Einstieg, die unsichtbaren Flügel in Vorschauen und den Übergang nach dem ersten Weltboss. Enthalten sind Android, Web, der lokale Realm-Dienst und vollständige Quellen.

## Änderungen

- **Runenpaladin ist jetzt der echte Starter.** Neue Spielstände besitzen zunächst nur ihn, mit normaler Seltenheit. Es folgt der seltene Schattenjäger; der legendäre Realmwächter gehört zur späteren Sammlung. Modell, Kampfkunst, Porträt und Heldenauswahl stimmen beim ersten Start überein.
- **Alte Spielstände bleiben erhalten.** In der Sammlung bietet ein eigener, bestätigter Wechsel den Runenpaladin kostenlos an. Der bisherige Realmwächter, seine verdienten XP, Gegenstände, Ränge und Währungen bleiben erhalten; der Runenpaladin übernimmt für den Wechsel den vorhandenen XP-Stand. Der Wechsel heilt den Helden nicht und setzt den Gegner nicht zurück. Bereits früher gekaufte epische Runenpaladine und Schattenjäger behalten ihre bisherige Seltenheit.
- **Flügel sind in Helden- und Aufstiegsansicht sichtbar.** Die rückwärtige Flügelschicht lag unter dem Fensterhintergrund; die Figurenansichten zeichnen sie nun korrekt davor. Die vorhandenen Flügelgrafiken werden verwendet.
- **Ausrüstung zeigt „Aktuell“ und „Mit diesem Gegenstand“ nebeneinander.** Die zweite Figur ist eine reine Erscheinungsvorschau; sie kauft, verbessert oder verändert nichts. Auch nicht erworbene Kandidaten können betrachtet werden. Die bisherigen Werte und echten Kauf-/Aufwertungsaktionen bleiben daneben erreichbar.
- **Inventar mit drei Spalten und besser lesbaren Namen.** Gegenstandskarten haben mehr Platz und zweizeilige Namen. Vorschauen und Touchbedienung wurden auf kleinen Hochformaten und im Querformat geprüft.
- **Klarerer Bossabschluss.** Der Siegabschluss hat Vorrang vor gleichzeitig eintreffenden Aufstiegsmeldungen. Belohnungen werden weiterhin verbucht. Nach dem ersten Weltsieg führt „Weiter nach Glutkern“ tatsächlich in die freigeschaltete zweite Region; es wird keine zweite Wächtertruhe vergeben. Der Hinweis auf der Weltkarte berücksichtigt die Freischaltung.

Die Systeme aus 708 bleiben enthalten: eigene Heldenlevel und fünf Aufstiegsränge, Truhenöffnung, Seltenheitsfarben und Fantasy-Fenster sowie **Mehr → Gemeinschaft** mit Konto, Familie/Gilde, asynchroner Arena/PvP, Titeln, Rangliste, gemeinschaftlichem Raid und privaten Spielstandsicherungen. Der mitgelieferte Python-/SQLite-Dienst verarbeitet echte Konten und gemeinsame Realm-Daten. Ein öffentlicher Server ist weiterhin nicht vorverbunden.

## Start

**Android:** `REALM_ALLIANCE_709.apk` aktualisiert „REALM Mockup Test“ mit derselben Paketkennung und demselben öffentlichen Testschlüssel wie 708. Eine Deinstallation ist für das Update nicht vorgesehen; sie würde lokale Daten entfernen. Offline-Abenteuer benötigt kein Konto. Ein eigener HTTPS-Realm lässt sich unter Mehr → Gemeinschaft → Konto eintragen.

**Web:** `REALM_ALLIANCE_709_Web.zip` entpacken, Python 3.10 oder neuer verwenden und im entpackten Ordner ausführen:

    python3 START_WEB.py

Dann `http://127.0.0.1:8765` öffnen. Spiel und lokaler Realm-Dienst starten gemeinsam. Ein anderes Browserprofil ermöglicht eine zweite unabhängige Sitzung. Die bestehende Datenbank `.realm-alliance/online708.sqlite3` wird aus Kompatibilitätsgründen weiterverwendet. Hinweise zum Dienst: `backend/README.md`.

**Quellen:** `REALM_ALLIANCE_709_Quellen.zip` enthält das gesamte Projekt, nicht nur Änderungen. Godot 4.7.2 und passende Exportvorlagen verwenden; Projekt: `godot/realm_alliance/project.godot`. Android benötigt Java 17 und Android SDK.

    python3 development/run_checks.py --godot /pfad/zu/godot --report checks.json
    python3 backend/test_service708.py development/backend_checks_709.json
    python3 development/build_709.py --godot /pfad/zu/godot --output /absoluter/buildordner
    python3 development/package_709.py --build /absoluter/buildordner --output /absoluter/paketordner

Normale Exporte enthalten keinen Browser-QA-Adapter. Für gezielte UI-Prüfungen gibt es `development/export_review709.py` und `development/browser_review709.cjs`.

## Prüfstand

- **32 Godot-Suiten / 2.037 Prüfungen bestanden.** Neue 709-Prüfungen decken echten Erststart, Speichern/Laden, Starterwechsel ohne Fortschrittsverlust oder Heilung, unbekannte Revisionsdaten, ersten Weltboss samt Fortsetzung und die Flügelschichten ab. Historische Kampfreferenztests verwenden ausdrücklich einen alten Realmwächter-Spielstand; der neue Starter besitzt eigene Erststarttests.
- **23/23 Browserprüfungen bestanden**, ohne Browser-/Godot-Skriptfehler. Vier Ansichten: 320×568, 390×844, 430×932 und 960×540. Geprüft sind echter Runenpaladin-Start, wirkungsfreie Ausrüstungsvorschau, tatsächliches Erwerben/Anlegen von Flügeln per Touch, Sammlung, bestätigter Altstand-Wechsel sowie Siegabschluss und Fortsetzung. Interne Aufnahmen wurden visuell kontrolliert.
- **2/2 Prüfungen des normalen Webexports bestanden:** kein QA-Adapter, zwölf Kampftouches und Navigation durch fünf Hauptbereiche ohne Skriptfehler.
- **48/48 HTTP-Prüfungen des bestehenden Realm-Dienstes bestanden**, unter anderem Kontentrennung, Familien, serverseitige Arena, gemeinsame Boss-HP, einmalige Belohnungen und private versionierte Sicherungen.
- Android ARM64: Versioncode **709**, v2-/v3-Signatur mit unverändertem Testzertifikat, Paketkennung, Internet-Berechtigung und **16-KiB-Ausrichtung** geprüft. **Kein Test auf einem Android-Gerät.**

Prüfprotokolle liegen unter `development`. Die Web-ZIP enthält den normalen Export und den startbaren Dienst, keine QA-Testfassung und keine Kontodaten. Der Launcher wurde außerdem direkt aus der entpackten Abgabe gestartet; Spielseite und echte Health-API antworten erfolgreich.

## Nächste Ausbauschritte und Grenzen

Die Videoanalyse und der gesonderte Ausbauplan bleiben maßgeblich für die nächsten Inhalte: Flügel **+1 bis +15** mit wachsender Silhouette, eigene deutlich unterscheidbare Rüstungs-/Kostümgrafiken, sichtbare Waffenveredelung und weitere spielbare Klassen. Diese Inhalte sind **in 709 noch nicht umgesetzt**. Die jetzige Aufwertung vorhandener Flügel ist keine neue fünfzehnstufige Flügelevolution. Es wurden für 709 keine neuen Bitmap-Grafiken erzeugt.

Waldläufer und Sternmagier sind weiter als „In Vorbereitung“ sichtbar. Der Dienst ist eine startbare Grundlage, kein fertig betriebener öffentlicher MMO-Realm. Live-PvP, Gildenchat/-kriege, Passwortwiederherstellung und Produktionsbetrieb bleiben offen. Familien und Gilden bilden aktuell dieselbe Gemeinschaft. Kein GitHub-Push und keine öffentliche Veröffentlichung.
