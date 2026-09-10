# V1.79 Backend Adapter Contract

V1.79 is provider-neutral. It does not choose Supabase, Firebase, Nakama, PlayFab or a custom server.

Expected HTTPS routes:
- POST /v1/session/guest
- POST /v1/session/refresh
- POST /v1/player/sync
- POST /v1/game/intent

Authentication:
Authorization: Bearer <runtime access token>

Security:
- no access/refresh tokens in SaveGame
- no API secret in client source
- HTTPS required by default
- stale revisions rejected
- snapshot state is staged and validated before mutation
- server revision/time commit happens only after snapshot apply succeeds

Remote sync envelope:
{
  revision,
  server_unix,
  snapshot
}

This milestone creates the real transport seams but intentionally leaves base_url empty and transport disabled until an actual backend exists.
