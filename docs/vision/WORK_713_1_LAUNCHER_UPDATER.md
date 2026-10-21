# REALM ALLIANCE – Work 713.1: In-Game Launcher & Update Bootstrap
Stand: 21.10.2026 · **geplant, noch nicht implementiert**
Basis: `feature/work-712-character` (Godot 4.7.2), 2D, Hochformat zuerst / Querformat adaptiv.
**Unveränderter Kern:** heutiges Idle-/Tap-/Boss-/Loot-Spiel. Der Updater ist nur ein vorgeschalteter Startablauf und darf Combat, vorhandene lokale Spielstände oder den 712-Charakter nicht ersetzen.

## Spielerlebnis
1. Sofort sichtbarer und zugänglicher 2D-Startbildschirm, kein schwarzer Screen.
2. Installierte App-/Inhaltsversion ermitteln und erreichbaren HTTPS-Release-Manifest-Endpunkt prüfen.
3. Falls Inhaltsupdates bestehen: Downloadgröße anzeigen, Nutzerinformation, Fortschritt (echte Bytes), Abbruch-/Retry-/Offline-Option. Neue Dateien in temporären lokalen Cache herunterladen; **erst nach erfolgreicher Integritätsprüfung atomar aktivieren**.
4. Bei inkompatibler alter App die Store-/Android-Systeminstallation anbieten. Android-APK-Updates **nicht stillschweigend installieren**, nicht das Betriebssystem umgehen; für Play-Store-Vertrieb die offizielle Play-In-App-Update-API verwenden. Für iOS App-Code nur über App Store. Web neue Bundle-Version über normalen Deploy/Reload.
5. Wenn Version kompatibel: optional Realm-Verbindungsstatus anzeigen und **Anmelden / Registrieren / Als Gast spielen / Offline fortsetzen** bereitstellen. Der bestehende `scripts/online/realm_client708.gd` und `scripts/ui/community708.gd` bieten bereits manuelle Authentifizierung; im MVP nicht erfinden, dass der öffentliche Realm schon angeschlossen ist.
6. Bestehenden Save unverändert laden und zum jetzigen Hauptspiel übergeben. Kein Neustart des Fortschritts, kein neuer Pflichtaccount, keine Unterbrechung bei Netzproblemen.

## Was OHNE neue App-Datei updatefähig wird
- Neue und geänderte **Datenkataloge, Texte, Event-Termine, Monster-/Item-Konfigurationen** innerhalb einer kompatiblen Schema-Version.
- **2D-Bilder/Sprites, Audio, nicht-exekutive optionale Assets** in versionierten Content-Paketen. Godot unterstützt Laderoutinen für Inhaltsdateien und grundsätzlich PCK/ZIP; für iOS ausdrücklich keine ausführbaren oder neue Features einführenden Programmpatches per Download.
- Ein neuer Boss, eine Klasse oder UI-Funktion, die **neuen Code** benötigt, erfordert auf Store-Plattformen einen neuen App-Build. Die Bezeichnung „Contentupdate“ bedeutet nicht beliebig neue Spielmechanik ohne APK/iOS-Update.

## Manifest- und Sicherheitsvertrag (Entwurf)
JSON unter eigenem vertrauenswürdigen HTTPS-Endpunkt, z.B. `/api/game/manifest?channel=test&platform=android` (nur Beispiel; URL noch nicht eingerichtet). Nicht bei jedem Start gesamte Repository/ZIP laden.
```json
{
  "schema": 1,
  "channel": "test",
  "min_app_version_code": 712,
  "latest_app_version_code": 713,
  "content_revision": "2026-10-21-a",
  "packs": [
    {
      "id": "core-art-01",
      "kind": "data",
      "min_app_version_code": 712,
      "bytes": 123456,
      "sha256": "<64-hex-hash>",
      "url": "https://example.invalid/realm-content/core-art-01.zip"
    }
  ],
  "release_notes": "Neue Inhalte",
  "maintenance": false
}
```
BEISPIELDATEN sind keine produktiven URLs/Downloads. Release-Manifest gegen Manipulation authentifizieren (z.B. vertrauenswürdige signierte Metadaten); jede heruntergeladene Datei mit Länge + SHA-256 prüfen, keine beliebigen oder fremden externen URLs/HTTP-Ziele akzeptieren. Optional: Signatur-/Key-Rotation und HTTPS-Pinning mit realistischer Betriebsstrategie. Updates nur in `user://`-Zwischenspeicher, Pfad-Traversal und ZIP-Bomben abwehren, Speicherplatz prüfen, Backup/letzten guten Content-Satz behalten. Keine fremden ausführbaren Skripte aus remote ZIP/PCK laden.

## App-/Kanalstrategie
- Release-Kanäle `test`, später `stable` getrennt. Play Store, direkt installierte APK und iOS separat behandeln.
- Android bestehendes Paket `com.avenor.realmalliance.mockuptest` und Version 712: künftig versionCode monoton steigend, **gleicher privater Original-Signierschlüssel** bei direkt installierten Updates, niemals in Git committen.
- Bei direkter APK-Verteilung: ein verifizierter neuer APK-Download kann angeboten werden; Android verlangt grundsätzlich eine Benutzeraktion bzw. Berechtigungen. Keine lautlose Systeminstallation versprechen. Für Play-Store-Build die API `Play Core In-App Updates` nur bei Play-Distribution.
- iOS-App- und Code-Updates ausschließlich über autorisierten App-Update-Kanal; keine remote GDScript/Engine-Binary-Updates. Windows/macOS später eigener signierter Installer/Updater, dabei OS-Sicherheitsmodelle beachten.
- Browser: versionsbasierter Cache + kontrolliertes Reload, niemals Spielstand durch Cache-Clearing verlieren.
- Auf realen Geräten Offline-/Netzfehler, Download-Abbruch, wiederholtes Öffnen, extrem langsames Netz, Speicher voll, fehlerhafte Hashes, alte App-Version und signierte APKs testen.

## Umsetzung in risikoarmen Milestones
**713.1A – Testmodus ohne Live-Zwang:** Eigenständige Launcher-Szene vor `res://scenes/main.tscn`; responsive Portrait/Landscape-Safe-Area-UI mit Logo, Version, Patchstatus und `Offline spielen`. Nur eine *lokale Fixture* eines update-manifest.json simulieren und testen; nicht „Live-Updater fertig“ melden. Gestaffelter Einstieg ins bestehende Spiel, vollständige Save-/712-Regressionstests.

**713.1B – Echte Datenupdates:** HTTPS-Endpunkt, content manifest, byteweiser Download, verifizierter und atomarer Cache, Fortschritt, Resume/Retry/Offline, Testpack mit EINEM 2D-Asset/Datenkatalog. Cache-/Schema-/Rollback- und Touch-Tests. Nachweis, dass beim nächsten Content-Release keine Android-APK nötig ist.

**713.1C – App-Versionswarnung:** APK/Play/iOS/Web-Erkennung; sichere Updateanzeige, je Plattform korrekter Flow. Native Installation mit expliziter Nutzerbestätigung / Store-Flows erst nach realen Gerätetests. Kein heimliches Installieren.

**713.1D – Login/Realm-Integration:** Bestehendes optionales Konto/Gast-Modul hinter Startscreen zugänglich machen. Cross-Save erst nach realer, gesicherter Backend-Deploy-/Sync-Implementierung und Konflikt-/Offline-Regeln. Server-Ausfall darf Gast-/Offline-Zugang nicht blockieren.

## Technische Abnahme
- Vor/mit 712 gibt es **noch keinen funktionierenden Auto-Updater**.
- Automatische/native Checks, zwei echte Android-Gerätedurchläufe (Update-Install und Content-only), Web-Portrait/Landscape/Resize, Save-Compat 709–712, 2D-Asset-Fit, Regression Tap/Bosse/Inventar/Klassen.
- Lieferbar: überprüfte Quelle + Build + reale Bildschirmaufnahmen/Logs + genauer SHA + veröffentlichte Test-Manifest-URL. Ohne einen erreichbaren Inhaltsserver darf nicht „Content-Update erfolgreich getestet“ behauptet werden.
- Nur den **Updater** hinzufügen; bestehende Kern-Spielmechaniken bleiben unverändert. Weitere MMO/Open-World-Systeme gehören **nicht** in Work 713.1.

Quellen / technische Regeln:
- https://docs.godotengine.org/en/stable/tutorials/io/runtime_file_loading_and_saving.html
- https://developer.android.com/guide/playcore/in-app-updates
- https://developer.android.com/reference/android/content/pm/PackageInstaller
- https://developer.apple.com/app-store/review/guidelines/
