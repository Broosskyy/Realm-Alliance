# Work 6.2 asset provenance

Canonical Realmwächter body poses, all five sword models, stone golem and Wolkgarten background are retained from the repository's canonical production integration package. No placeholder replacement.

New Wolkgarten slime: generated with OpenAI image generation using the supplied master visual reference, then extracted to four transparent RGBA pose assets: idle/ready, attack, hit, defeated. Runtime files are in `godot/realm_alliance/assets/expansion/slime/`. Common canvas 640x512, common foot anchor (320,488), common source scale 0.74. Pose/hash metadata accompanies the assets. Generation source is asset work; delivered scene screenshots are engine output.

Blue/purple/fire/shield/counter effects and the evolution aura are separate runtime drawing layers. The emerald cape is a textile-selective shader applied consistently across existing poses, not a replacement hero image. Per-pose sockets and the same ProductionHero rig are used by combat and Hero preview.

No new third-party asset pack was added. Generated artwork should receive the project's usual visual/IP review before commercial release.
