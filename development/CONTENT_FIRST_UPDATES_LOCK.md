# REALM ALLIANCE – Verbindlicher Content-first-Updater-Lock

Datum: 21.10.2026 · Produktentscheidung, **keine Behauptung über bereits implementierte Features**

## Oberste Regel
**Neue komplette Android-/iOS-/Desktop-App-Builds nur, wenn neuer App-/Engine-/Programmcode technisch erforderlich ist.** Reine kompatible Spielinhalte sollen als kleine, überprüfte Daten- und Asset-Pakete über den bestehenden Launcher ausgeliefert werden. Hochformat zuerst, vollwertiges Querformat; alle Grafiken weiterhin in 2D. Das bestehende Tap-/Idle-RPG bleibt das Hauptspiel; keine ungeplante Umstellung auf Open World.

## Update-Kategorien
**Content-only, keine neue APK nötig – sobald die jeweiligen Datenkataloge/Loader dafür gebaut und getestet sind:**
- 2D-Sprites/Bilder für neue Monster, Items, Waffen, Rüstungen, Kostüme, Pets, Spezialistenoptiken, Launcher- und Eventgrafiken;
- kompatible Animationsatlanten/Sounds, Texte, Balancingwerte, Loot-Konfigurationen, Event-Daten, Quests aus bereits unterstützten Questbausteinen;
- neue Regionen/Kartenassets, sofern die vorhandene Welt-/Kampfengine diese durch Daten laden kann.
Ein komplett neues Monster kann nur dann content-only sein, wenn seine KI, Fähigkeiten, Animationstypen und Item-/Lootlogik bereits datengetrieben unterstützt werden. Sonst zunächst einmaliger App-Code-Release.

**Native App-/Code-Update erforderlich:**
- neue Spielmechaniken, die neue oder geänderte GDScript-/Engine-/Plugincode voraussetzen (z. B. erster Partner-NPC-Kampfmodus, neue Spezialistenlogik, Open-World-Kamera, neues Login-/Netzwerkprotokoll);
- Änderungen an fest einprogrammierten UI-Layouts, nativen Permissions, Save-Migrationen und Plattformintegration, soweit nicht schon durch vorhandene Datenkataloge unterstützt;
- Sicherheitsupdates der App. iOS-Appcode nach App-Store-Regeln nur über den Store; auf Android muss eine APK/Systeminstallation normalerweise ausdrücklich bestätigt werden. Kein Versprechen stiller App-Updates.

## Ablauf beim Spielstart (Zielarchitektur)
1. Installierte App-Version und aktiven Content-Kanal erkennen.
2. Vertrauenswürdiges HTTPS-Manifest mit Mindest-App-Version, Inhaltsrevision, kompatibler Content-Schema-Version und Updategröße abrufen. Sicherheitskritische Manifestmetadaten authentifizieren/signieren.
3. **Wenn App kompatibel:** Nur geänderte/fehlende reine Content-Dateien herunterladen; Größe/Hash/Signatur prüfen; temporär speichern; nach vollständiger Validierung atomar aktivieren; laufendes Gameplay und persistierte Spielstände nicht verändern.
4. **Wenn App inkompatibel:** Nutzer transparent über neue App-Version informieren; Android-Systeminstaller/Play-Core oder iOS-/Desktop-Updatekanal verwenden und Zustimmung respektieren.
5. Danach optional Server/Login/Gastzugang; wenn Offline/Netzausfall, letzte gültige Inhalte verwenden, Spielstand schützen. Nie Remote-Skripte als versteckte App-Patches ausführen.

## Aktueller Realitätsabgleich
- 713.1B: HTTPS-Update für kleine News-/Textdatei auf Android durch Nutzer-Screenshot bestätigt.
- 714: SVG/JSON-2D-Banner-Contentloader und atomarer Cache wurden im Godot-CI geprüft; die konkrete Bannerinstallation auf einem realen Android-Gerät noch nicht bestätigt.
- **Noch nicht umgesetzt:** universelle Sprite-/Monster-/Rüstungs-/Soundpakete, regulärer CDN-Kanal, signierte Update-Metadaten, Resumable-Downloads, native integrierte APK-Updater-Flows, vollständiges Cross-Save/Crossplay.
- Eine App-Version mit neuem Loader ist nur **einmal** erforderlich, wenn die vorhandene App diesen Inhaltstyp noch nicht nachladen kann. Danach neue Varianten dieses bereits unterstützten Inhaltstyps ohne neue APK.
- Nicht "jede Version = APK". Die Versionsnummern von Content-Paketen laufen unabhängig vom nativen App-Versioncode.

## Priorität
P0: stabile bestehende 714-2D-Banner-Downloads auf echtem Gerät belegen;
P1: allgemeiner sicherer 2D-Asset-Registry-Loader für PNG/WebP + JSON-Item/Monster-Katalog, Offline-/Rollback- und Mobiltests;
P2: kleinere Patchpakete, Differenzdownloads, Resume, Größenanzeige und dynamische In-Game-Referenzen statt eingebetteter Sprites;
P3: native Updateführung für seltene Code-Upgrades, Cross-Save/Backend-Verbindung und iOS-/Desktop-Anpassungen.

**Abnahme:** Nach dem Installieren einer App-Version darf ein neu veröffentlichtes 2D-Grafik-/Katalog-Content-Paket ohne APK-Download im Launcher UND in einer realen Spielansicht erscheinen, mit gleicher installierter App-Version, erhaltener Spielstandsdatei und dokumentiertem SHA-256. Vor diesem echten Nachweis keine pauschale "automatische Spielinhalt-Updates funktionieren"-Behauptung.
