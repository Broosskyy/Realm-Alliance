# Realm-Dienst · mitgeliefert in 709

Die API und die Datenbanknamen aus 708 bleiben für bestehende Konten und Sitzungen kompatibel.

Python 3.10+, nur Standardbibliothek. Beispiel aus dem Quellenordner:

    python3 backend/realm_service.py --web-root /pfad/zum/webexport --port 8765

Im Browser `http://127.0.0.1:8765` öffnen. Gleiches Origin verbindet das Spiel automatisch. Konten, gemeinsame Familien, asynchrone Arena, Rangliste, Titel, Präsenz, täglicher gemeinsamer Himmelstitan und private versionierte PvE-Sicherungen sind echte SQLite-Daten. Standarddatenbank: `~/.realm-alliance/online708.sqlite3`; mit `--database` änderbar. Die Quelldateien und die Datenbank sind keine öffentlichen Webassets. Das Webpaket enthält weder private Konten noch vorgefertigte Spieler.

Für einen entfernten Realm den Dienst hinter einem HTTPS-Reverse-Proxy betreiben, z.B. an `127.0.0.1:8765`; dabei Host und X-Forwarded-Proto korrekt setzen. Spiel und API am selben HTTPS-Origin ausliefern. Bei getrenntem Web-Origin diesen explizit mit `--allow-origin https://spiel.example` freigeben. In der APK die HTTPS-Adresse unter Mehr → Gemeinschaft → Konto eintragen. Die APK erlaubt HTTP nur für localhost. Es ist noch kein öffentlicher Server eingerichtet.

Datenbank einschließlich WAL/SHM konsistent sichern (SQLite-Backup-API oder Dienst vor Dateikopie stoppen). Keine echten Produktionszugänge in Quellpakete aufnehmen. PBKDF2-SHA256 mit individuellem Salt und 600.000 Runden, gehashte Sitzungstoken, zeitlich begrenzte Sitzungen und API-Cooldowns sind implementiert. Ein öffentliches Produkt braucht zusätzlich Passwortwiederherstellung, Moderation, Betrieb/Monitoring und eine geprüfte HTTPS-/Proxy-Konfiguration.

Online-Level entsteht aus Arena-Siegen/Raidpunkten. Die lokalen Abenteuerwerte werden nur als private Sicherung gespeichert und nicht als Arena-Autorität übernommen. Cloud-Sicherungen ersetzen den lokalen Stand erst nach ausdrücklicher Bestätigung im Spiel. Nach Gast-Upgrade bleiben Konto-ID, Familie und Wertung erhalten. Beim Verlassen einer Familie überträgt sich die Führung an ein verbleibendes Mitglied; leere Familien werden entfernt.

HTTP-Prüfungen starten:

    python3 backend/test_service708.py development/backend_checks_709.json
