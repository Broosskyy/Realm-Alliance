# V1.80 Online Service Contracts

## Routing
HTTP responses are routed by configured endpoint into Auth, Sync, Authority, Social, Guild or Ranking services. Unknown or invalid responses are rejected rather than guessed.

## Resilience
- max retries: 2 by default
- retry backoff: 1s, 3s
- retryable: timeout/408/429/5xx/network failure
- repeated failures enter OFFLINE_LIMITED
- 401 marks the auth session REFRESH_REQUIRED
- no infinite retry loop

## Social
Server-authoritative friend list plus incoming/outgoing friend requests. The client only displays sanitized server snapshots and sends intents.

## Guild
Server-authoritative guild identity, level, XP, members, roles, contributions and season score. Create/join/leave are server requests only.

## Rankings
Daily/weekly/event boards are server snapshots. Reward claimability is server-provided and reward claiming uses a dedicated server route.

No hosted backend is configured in this source. These are production contracts and client adapters only.
