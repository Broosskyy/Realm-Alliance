# V1.75 Online Authority Foundation

V1.75 verbindet noch keinen Fake-Backend-Server. Es schafft austauschbare Verträge:
UI → Intent → Authority → Result → Domain/Presentation.

Neu:
- OnlineAuthorityService mit request_id, expected_revision und Result-Revision.
- ServerClockService mit Device-Time nur als Development-Fallback.
- OnlineSessionState für Online/Connecting/Syncing/Offline-Limited.
- Save v21 speichert Sync-Metadaten.
- Daily/Village-Zeitpfade laufen über ServerClockService.
- Monster Defeat, Event Reward und Realm Chest erzeugen Authority-Intents.
- Purchases erzeugen einen Authority-Intent und bleiben ohne echte Store-/Servervalidierung gesperrt.

`local_result()` ist Development-Scaffolding und wird später durch echte Serverantworten ersetzt.
