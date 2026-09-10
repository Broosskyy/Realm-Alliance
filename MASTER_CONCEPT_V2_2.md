# REALM ALLIANCE — MASTERKONZEPT V2.2

Status: Verbindliche Erweiterung von V2.1. Bestehende Gameplay-, UI-, Mobile- und Asset-Regeln bleiben gültig.

## Online-Grundsatz
REALM ALLIANCE wird langfristig als Online-/Multiplayer-Spiel betrieben. TAP / SPIN / DORF / MODI bleiben die primären Säulen. Multiplayer erweitert sie, ohne zusätzliche Bedienkomplexität zu erzwingen. Leitregel: **MEHR CONTENT, NICHT MEHR BEDIENUNG.**

## Authority
Produktiv server-authoritativ sind insbesondere Accounts, Währungen, Käufe, Inventar, Belohnungen, Truhen, Progression, SPIN-RNG, Events, Rankings, Gilden, PvP-/Coop-Ergebnisse, Entitlements sowie sensible Zeit-/Cooldown-Logik.

Der Client bleibt zuständig für Input, Darstellung, Animation, Audio/Haptik, lokale Settings, Cache bestätigter Snapshots und ausdrücklich freigegebene Offline-Puffer.

Zielpfad:
UI/Input → Gameplay Intent → Authority Gateway → LocalDevelopmentAuthority oder OnlineAuthority → bestätigtes Result/Snapshot → Domain State → Presentation.

## Accounts & Sessions
Guest/Device-Einstieg, später Google/Apple/E-Mail oder geeignete Plattformidentität. Account-Linking ohne Fortschrittsverlust. Session/Refresh Tokens, Device Registration, serverseitige State-Revisionen und Konfliktauflösung für mehrere Geräte.

## Save / Sync / Reconnect
Lokale Saves bleiben Cache und Development-Fallback. Produktiv ist der Server-Snapshot Quelle der Wahrheit. Lokales Save enthält Server-Revision, letzten Sync und lokale Präsentationszustände. Pending Intents werden nur für ausdrücklich erlaubte Aktionen gepuffert. Unklare wertvolle Transaktionen werden niemals blind wiederholt.

## Serverzeit
Daily Rewards, Goldmine, Tempel, Events, Seasons, Shopangebote und Cooldowns verwenden Serverzeit. Gerätezeit ist nur Development-Fallback.

## Economy / Rewards / SPIN
Spend + Reward werden atomar serverseitig verarbeitet. Kritische Requests sind idempotent. Für SPIN bestimmt produktiv der Server Result/RNG/Reward; der Client animiert exakt das bestätigte Ergebnis. Käufe benötigen Store-Receipt/Token-Validierung und serverseitige Entitlements.

## Multiplayer
Social: Profile, Freunde, Präsenz, Einladungen, Block/Mute/Report.

Gilden/Allianzen: Mitglieder, Rollen, Einladungen/Bewerbungen, Gildenfortschritt, gemeinsame Ziele, Contributions, Gildenbosse, Seasons und Rankings.

Coop PvE: Realm-Bosse, Gildenbosse, Invasionen und gemeinsame Contribution-Ziele; Beiträge serverseitig validiert.

PvP: zuerst mobile-tauglich asynchron mit Angriff gegen Verteidigungs-Snapshot, Ligen/Seasons und serverseitiger Match-/Resultvalidierung. Echtzeit-PvP bleibt spätere Erweiterung.

## Rankings / Seasons / LiveOps
Keine simulierten Fake-Spieler in produktiven Rankings. Leaderboards, Season Settlement und hochwertige Rewards serverseitig. Content, Events, Balance, Rewards, Shopangebote und Unlock-Regeln datengetrieben und versionierbar: Draft → Review → Publish → Rollback.

## Admin / Operations
Granulare Rollen und Audit-Logs für Spieler-/Account-Support, Economy Compensation, Entitlements, Gildenmoderation, Rankings, LiveOps, Shop/Payment, Bans/Suspensions und Incident Response.

## Anti-Cheat
Architektur statt invasive Client-Überwachung: serverseitige Validation, Rate Limits, monotone Revisions, Duplicate-Rejection, impossible-state checks, Economy-Telemetrie und Server-RNG für kritische Rewards.

## Mobile Netzwerk-UX
Spielertexte: ONLINE, VERBINDE…, SYNCHRONISIERE…, OFFLINE · EINGESCHRÄNKT, AKTION WIRD ERNEUT VERSUCHT, AKTION KONNTE NICHT BESTÄTIGT WERDEN. Keine technischen Backend-Texte im normalen UI.

## Source-Migrationsregel
Bis ein echtes Backend verbunden ist, darf eine LocalDevelopmentAuthority dieselben Intent-/Result-Verträge lokal erfüllen. Neue wertvolle Systeme sollen nicht mehr ausschließlich direkt PlayerData/SaveGame als Produktions-Authority voraussetzen.

Priorität:
P0 Auth/Session, Serverzeit, Economy/Rewards, Save/Sync, Purchases, SPIN.
P1 Progression, Village, Heroes, Inventory, Daily/Quests, Events.
P2 Social, Guilds, Leaderboards, Coop, Async PvP.
P3 Realtime Features.

## Definition of Done für neue Online-relevante Features
Authority Owner definiert; Intent + Result Contract vorhanden; Idempotency bedacht; Serverzeit geklärt; Reconnect/Retry geklärt; Save-/Snapshot-Felder klassifiziert; Admin/LiveOps-Bedarf geklärt; keine neue Client-only Economy-Autorität.
