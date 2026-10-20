# Android-APK 710

## Erfolgreicher Build vom 20.10.2026

Die APK wurde aus Quellcommit `495580737cdc59efd1dfcd5e3e5de0ea69d0cd34` mit dem Originalschlüssel des privaten 709-Quellpakets erstellt. Größe: 73325736 Bytes. SHA-256: `77b618e03bc83e8428c92f52f544cd49ddc10773f27e1495a5d3b6f3413c31d3`. Signatur, Paketkennung/Versionscode, ARM64, ZIP-Integrität und Ausrichtung geprüft; 33 Godot-Suiten / 2.655 Checks erneut bestanden. Kein Android-Gerätetest. Der gebaute Download wird separat bereitgestellt; die private Schlüsseldatei wird nicht committed. Für zukünftige unbeaufsichtigte GitHub-Builds muss weiterhin das unten genannte Actions-Secret eingerichtet werden.

Der Workflow [REALM 710 Android update APK](https://github.com/Broosskyy/Realm-Alliance/actions/workflows/realm-710-android.yml) erstellt einen eigenständigen Android-Build aus dem Godot-Projekt. Er läuft bei Änderungen am Android-Buildablauf und lässt sich über **Run workflow** erneut starten.

## Private Signierung

Die ursprüngliche Datei `development/realm-preview-debug.keystore` aus dem privaten 709-Quellpaket ist erforderlich. Sie darf nicht in das Repository hochgeladen werden.

Unter **Settings → Secrets and variables → Actions → New repository secret**:
- `REALM_ANDROID_KEYSTORE_BASE64`: Base64-Inhalt der ursprünglichen Schlüsseldatei.
- Optional `REALM_ANDROID_KEY_ALIAS` und `REALM_ANDROID_KEYSTORE_PASSWORD`, falls abweichend von der bisherigen Vorschaukonfiguration.

Eine bereits vorhandene `ANDROID_KEYSTORE_BASE64` wird ebenfalls akzeptiert. Der Build prüft ausschließlich, ob die Signatur zum ursprünglichen 709-Zertifikat passt; ein neuer Schlüssel wird niemals erzeugt. Base64 ist nur eine Kodierung und gehört ausschließlich in ein privates Actions-Secret.

Beispiel für die lokale Kodierung (Ergebnis privat als Secret eintragen, nicht committen):

```sh
python3 -c 'import base64; from pathlib import Path; print(base64.b64encode(Path("realm-preview-debug.keystore").read_bytes()).decode())'
```

Anschließend den Workflow ausführen oder einen wegen fehlender Schlüsselkonfiguration gestoppten Lauf vollständig erneut starten.

## Ergebnis und Prüfungen

Nach erfolgreichem Build erscheint eine eigene GitHub-Vorabveröffentlichung mit:
- `REALM_ALLIANCE_710.apk`
- `APK_710.json`: tatsächlicher Quellcommit, Dateigröße, SHA-256, Signatur- und Strukturprüfungen
- `SHA256_APK_710.txt`

Godot 4.7.2 und seine Exportvorlagen werden mit den offiziellen SHA-256-Prüfsummen geprüft. Die APK muss die bisherige Paketkennung `com.avenor.realmalliance.mockuptest`, Versionscode 710 und ARM64-Bibliotheken enthalten. APK-Signatur und ZIP-Ausrichtung werden vor Veröffentlichung geprüft. Der private Schlüssel wird auch bei Fehlern aus dem temporären Buildverzeichnis entfernt und niemals als Artefakt gespeichert.

Ein Android-Gerätetest ist damit noch nicht erfolgt. Der Buildbericht kennzeichnet dies ausdrücklich. Ein fehlender Schlüssel führt zu einem Fehler und erzeugt keine angeblich fertige APK. Die bereits geprüften 710-Webdateien und die bisherigen Spielstände werden durch diesen Buildablauf nicht verändert.
