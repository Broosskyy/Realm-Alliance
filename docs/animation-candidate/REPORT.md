# REALM ALLIANCE · Animationskandidat nach APK 702

Stand: 19.10.2026. Die neueste installierbare APK bleibt 702. Dieser Kandidat enthält einen zusätzlichen getesteten Fix in der Webfassung und den vollständigen Quellen.

## Konkreter Befund

Beim Ausholen wurde der bereits berechnete Schwertwinkel unmittelbar danach durch einen festen Winkel aus der aktuellen Körperpose überschrieben. Beim Wechsel zur Treffer- oder Rückholpose wechselte außerdem die Winkelbasis abrupt.

Die Waffe folgt jetzt einer durchgehenden Bahn von der Ruheposition über Ausholen und Schlag zur Ruheposition zurück. Die Winkel werden aus der jeweiligen Heldenkalibrierung aufgelöst. Die Darstellung setzt diese Bahn um, ohne den Winkel anschließend zurückzusetzen. Schwert, Körper und Ausrüstung bleiben getrennt; Handanker und Spielstandformate bleiben unverändert.

Der Fix betrifft Standardangriffe, die drei Kettenschläge einschließlich Mehrfachtreffern und die offensiven Skills. Schaden, Trefferzeitpunkte, Abklingzeiten und Kosten wurden nicht geändert.

## Prüfung

- 26 Suiten mit 1.503/1.503 Prüfungen bestanden.
- Neue Regression: 93 Prüfungen für drei Helden, zehn Angriffsvarianten und die Phasenübergänge. Auf dem unveränderten Ausgangscode bestanden davon 10/93; mit Fix 93/93.
- 48 tatsächliche Godot-Browseraufnahmen für vorher/nachher, drei Kettenschläge und acht Zeitpunkte bei 360×780. Keine Browser-Scriptfehler. Die kontrollierte Animationsprüfung verwendet einen ausgeschlossenen Testadapter und ist keine FPS-Messung.

## Was offen bleibt

Die Körperanimation hat weiterhin ihre bisherigen gezeichneten Schlüsselposen. Für flüssigere Körperbewegungen braucht sie zusätzliche konsistente Zwischenbilder; eine kontinuierliche Schwertrotation ersetzt diese nicht. Die endgültigen Outfit-Sets, die vollständige Angleichung an die Master-Mockups und die Prüfung des Spielgefühls auf einem echten Android-Gerät bleiben offen. Im normalen mobilen Browserlauf wurde zusätzlich ein Darstellungsfehler sichtbar: Der Steinwächter wird am rechten Rand teilweise abgeschnitten. Seine Größe/Platzierung ist als nächster Korrekturpunkt offen.

Die nächste Android-Exportkonfiguration ist als Versioncode 703 / 0.7.0-animation.3-test vorbereitet. Es wurde noch keine APK 703 erzeugt. Ein GitHub-Push wurde nicht ausgeführt.

## Dateien

- REALM_ALLIANCE_Animationskandidat_Web.zip: entpacken, mit Python 3 `serve.py` starten und die angezeigte lokale URL öffnen.
- REALM_ALLIANCE_Animationskandidat_Quellen.zip: vollständiges Godot-Projekt und bisherige Quellen, einschließlich der neuen Regression. In Godot 4.7.2 `Source/godot/realm_alliance/project.godot` öffnen.

Quellengrundlage ist der gesicherte Stand 811786352bc562fe0a3e79b76d571096e294cc73 (APK 702). Der Kandidat wurde daraus lokal weiterbearbeitet.
