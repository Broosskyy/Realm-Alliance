# REALM 727 – OTA-End-to-End-Prüfung für installierte Version 726

Verifizierter Status aus GitHub (nicht vom Gerät): Version 726 hat einen separaten HTTPS-Download mit unbefristetem APK-Timeout, Fortschrittsanzeige, automatischem Download und optionalem Offline-Start. Der 720-Updater reagiert auf dem Nutzergerät nicht zuverlässig; Änderungen an 720 lassen sich nicht allein mit Remote-JSON aktualisieren. Daher ist eine direkte Installation der bereits signierten Version 726 über 720 nötig, ohne Deinstallation.

In 727 werden nur Versionsnummer und Testmetadaten angepasst; Spielstände, Charaktere und Inhaltsupdates bleiben unverändert. CI baut Android, überprüft den Originalsignierschlüssel und veröffentlicht 727 nur mit korrekter Signatur, danach schaltet es das Manifest frei.

**Gerätetest noch offen**: (1) 726 über 720 installieren, (2) 726 starten, (3) 727 muss beim Start selbst heruntergeladen werden, (4) Fortschrittsanzeige und SHA-256/Android-Zertifikat prüfen, (5) Android-Installationsdialog bestätigen, (6) 727 starten und lokale Daten prüfen. Weder GitHub Actions noch Godot Headless allein belegen die Android-Installation.

UI-Prinzip: Inhalte automatisch beim Start prüfen/aktualisieren. Vollständige APK nur für neuen Code; für Android verlangt die Installation eine Systembestätigung.
