# REALM ALLIANCE 709 – Wiederherstellung

Nur die fünf Dateien `REALM_709_Quellen_GitHub_sicher.part01-of-05` bis `part05-of-05` in **diesen Ordner** hochladen. Jede Datei ist kleiner als 25 MB. Nachdem alle Teile vorliegen, setzt GitHub Actions die ZIP anhand ihrer SHA-256-Prüfsumme zusammen und erstellt den separaten Branch `review/realm-709` mit dem Godot-Quellstand.

Der Branch `main` wird nicht geändert. Der Android-Signaturschlüssel wurde vor der Aufteilung aus der GitHub-Variante entfernt. Den vollständigen ursprünglichen Quellcode mitsamt Signaturschlüssel unbedingt privat aufbewahren.

Wichtig: Dies funktioniert nur, wenn GitHub Actions mit Schreibberechtigung für dieses Repository aktiviert ist. Ein Push kann fehlschlagen, falls die Repository-Einstellungen Actions-Schreibzugriff untersagen. Den Review-Branch erst nach Prüfung in `main` übernehmen.
