# V1.78 Remote Sync Contract

V1.78 prepares the transport boundary but does not invent a backend.

Client request:
- client build
- known authoritative revision
- local snapshot fingerprint
- pending intents
- local snapshot for development/reconciliation diagnostics

Remote envelope minimum:
- revision
- server_unix
- snapshot

Rules:
- stale remote revisions are rejected
- server time is mandatory
- metadata is accepted before domain state application
- remote state application remains a separate future step so unvalidated server-shaped data cannot overwrite local state
- no locally fabricated 'server success' in online mode
