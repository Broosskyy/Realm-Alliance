# V1.79 CHANGELOG — Transport / Auth / Remote Reconciliation

- Added provider-neutral OnlineTransportService based on Godot HTTPRequest.
- Transport is disabled until a real HTTPS backend endpoint is configured.
- Added AuthSessionService with guest/authenticated/refresh-required states.
- Access and refresh tokens are runtime-only and never written to SaveGame.
- AccountState now supports an online_account descriptor with server player ID/provider.
- Player snapshot upgraded to v3 with fuller core progression state.
- Added RemoteStateApplyService for validated remote snapshot application.
- Reconciliation upgraded to v2: inspect → stage → apply → commit revision/server time.
- Fixed V1.78 architectural risk where metadata could advance authority revision before domain state application.
- Added remote authority-intent submission and authenticated player-sync transport request boundaries.
- Save schema advanced to v25 and persists only non-secret auth session descriptor.
- project.godot application version aligned to 1.79.
- No backend URL, API key, fake token, fake player or fake success response is included.
