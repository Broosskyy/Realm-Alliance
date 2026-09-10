# V1.81 Multiplayer Gameplay Contracts

## REALM SPIN
Local Development keeps local RNG for prototype playability.
Online mode never chooses RNG locally. It submits a spin request and waits for a server result containing authoritative revision, server time, reel stops, reward result and economy-after snapshot.

## Combat
Tap/visual damage may remain client-predicted for responsiveness. Once the monster reaches defeat locally, online mode sends the defeat observation to the server. Gold, boss bonus, progression and next monster are not committed until the authoritative response arrives.

## Guild Boss
The server owns boss HP, phase, event end time, player contribution, guild contribution and reward eligibility. Client attacks are intents only.

## Async PvP
The server selects opponents and resolves attacks against server-held defense/loadout snapshots. This avoids realtime networking as the first competitive multiplayer layer while still supporting leagues, history and season rewards.

No real backend is connected in this build; these contracts become active only when online mode, authentication and transport are configured.
