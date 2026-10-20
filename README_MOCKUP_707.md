# REALM ALLIANCE · Mockup Test 707

20.10.2026. Weiterentwicklung der gesicherten 706 auf Basis der 705-Rekonstruktion. Kein Wiederherstellen der verlorenen ursprünglichen 705 und kein fertiges Online-7.1–7.5.

## Neu in 707

- **Abspielbare Heldenvorschau:** „Angriff ansehen“ zeigt einen Angriff mit der ausgewählten Figur und ihrer getrennten Waffe. Die Vorschau ändert weder den aktiven Helden noch Gegner-HP, Ressourcen, Kampfzeit oder Spielstand.
- **Animierte Begleiterdetails:** Alle drei Begleiter zeigen vorhandene Idle-/Bereit-/Fähigkeitsbilder. „Fähigkeit ansehen“ spielt die Vorschau ab. Basisform und entwickelte Form lassen sich auch vor Freischaltung ansehen. Die Ansicht ist ausdrücklich als Vorschau gekennzeichnet; Freischalten, Ausrüsten und Entwickeln bleiben eigenständige, geprüfte Spielaktionen. „Begleiter ablegen“ erscheint nur beim tatsächlich aktiven Begleiter.
- **Schmiede mit nächsten Werten:** Waffen zeigen den aktuellen und nächsten Angriff. Rüstung, Kopf und Flügel zeigen die nächsten HP-/DEF-Werte. Kosten und fehlende Ressourcen stammen aus den tatsächlichen Aufwertungsregeln. Maximalstufen bleiben gesperrt. Waffenpreisberechnung wird von Vorschau und Aufwertung gemeinsam verwendet. Die Scrollposition bleibt nach einer Aufwertung erhalten.
- **Lesbare Mehrfachtreffer:** Untertreffer derselben Kombo werden zu einer laufenden Schadenssumme mit Trefferzahl zusammengefasst. Verschiedene Angriffe bleiben getrennt. Es werden die bereits vom Kampfmodell berechneten tatsächlichen Schadenswerte verwendet; die Anzeige verändert keine Berechnung oder Trefferzeit.
- **Neuer Treffereffekt:** Transparenter blau-silberner Vier-Frame-Atlas für Klingen- und Kombotreffer sowie Sternenfall. Gemeinsame 512×512-Atlasfenster erhalten Maßstab und Ausrichtung. Lebensdauer und Framewahl sind zeitbasiert; die bestehende Effektbegrenzung und Einstellung für reduzierte Effekte gelten weiter.
- **Weitere Sichtkorrekturen:** Einzeilige Beschriftungen in der schmalen Werkzeugleiste; nächste Aufwertungswerte vor den Aktionsbuttons. Arena, Bodenlinie, Navigation und Touchflächen aus 706 bleiben erhalten.

## Geprüft

- Godot 4.7.2: **30 Suiten, 1.880 Prüfungen bestanden**. Bestehende Kampf-, Speicher-, Wirtschafts- und Layouttests plus 170 Prüfungen für 707. Neue Prüfungen decken unter anderem Preisgrenzen, Stufengrenzen, Vergleich mit tatsächlich ausgeführten Aufwertungen, wirkungsfreie Vorschauen aller Begleiter, Effektframes, Mehrfachtreffersummen und Scrollposition ab.
- Browser: **109/109 Prüfungen bestanden**: 92 Touch-/Funktionsprüfungen bei 320×568, 390×844, 430×932 und 960×540 bestanden. 17 zusätzliche Prüfungen nach den letzten Beschriftungs-/Reihenfolgekorrekturen. Protokolle unter development/browser_final_707.json und development/browser_focus_707.json. Erreichbarkeit, Formwechsel, wirkungsfreie Vorschauen, echte Aufwertung, Zurück-Navigation und Touchziele geprüft. Interne Aufnahmen wurden visuell kontrolliert.
- Regulärer Webexport separat gestartet: keine QA-Brücke, zwölf echte Toucheingaben, Hauptnavigation und Sichtprüfung; keine Skript- oder Browserfehler. Vier Phasen des neuen Treffereffekts zusätzlich im separaten QA-Export gerendert und geprüft.
- Android ARM64, Paket com.avenor.realmalliance.mockuptest, Versioncode 707, Versionname 0.7.0-mockup.7-preview. v2-/v3-Signatur und 16-KiB-Ausrichtung geprüft. Kein Test auf einem echten Android-Gerät und keine Hardware-FPS-Aussage.
- APK, Web-ZIP und Quellen-ZIP sind getrennte Abgaben. Archive auf Integrität geprüft. Entwicklungsprotokolle und Buildskripte liegen im Quellpaket. Interne Browseraufnahmen sind keine Abgabedateien.

## Bewusst offen

Der versuchte neue Körperstreifen wurde wegen einer falschen Hand-/Bewegungsfolge verworfen. Er liegt nur als dokumentierter Produktionskandidat unter production/707; das Spiel lädt und exportiert ihn nicht. Vollständige konsistente Körper-Zwischenbilder und getragene Outfit-Sets für die übrigen Helden bleiben offen. Keine Behauptung pixelgenauer Übereinstimmung aller Unterfenster mit den Master-Mockups. Online-7.1–7.5 bleibt ein eigener offener Arbeitsblock.

## Starten und bauen

Android: REALM_ALLIANCE_707.apk aktualisiert denselben separaten „REALM Mockup Test“ wie 704–706. Paketkennung und öffentlicher Testschlüssel bleiben gleich. Persönliche Spielstände und Zugangsdaten sind nicht enthalten.

Web: REALM_ALLIANCE_707_Web.zip entpacken und START_WEB.py starten. Die Webfassung über HTTP öffnen; direktes Öffnen der HTML-Datei reicht nicht.

Quellen: Godot-Projekt godot/realm_alliance/project.godot mit Godot 4.7.2 öffnen und importieren. Passende Exportvorlagen, Android SDK und Java konfigurieren.

    python3 development/run_checks.py --godot /pfad/zu/godot --report checks.json
    python3 development/build_707.py --godot /pfad/zu/godot --output /absoluter/ausgabeordner

Separater Browser-QA-Export, niemals als normale Fassung verteilen:

    python3 development/export_review707.py --godot /pfad/zu/godot --output /absoluter/qa-ordner
    node development/browser_review707.cjs --web-root /absoluter/qa-ordner --browser /pfad/zu/chrome-headless-shell --report browser_checks.json

Normaler Web-Smoke: development/normal_web707.cjs. Browserprüfungen benötigen Playwright und Chromium Headless Shell. Produktionsprompts, Ablehnungsgrund und genaue Atlasfenster: production/707/asset_manifest707.json. Keine öffentliche Veröffentlichung und kein GitHub-Push ausgeführt.
