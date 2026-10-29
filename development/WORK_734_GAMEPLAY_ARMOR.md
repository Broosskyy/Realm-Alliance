# REALM ALLIANCE 734 – Mobile equipment & visual polish

Base: signed background-downloader source 733, without reworking its updater.

## Gameplay changes
- Remove canonical Realmwächter torso fallback for Paladin, Shadow Hunter and Basic Adventurer. Body- and pose-specific armor polygons now follow their authored 640x512 fitting data.
- Restore a separate polygon forearm occluder for actual armor, using the respective base sprite alpha and forearm UV contour. Do not render the old rectangular arm simultaneously.
- Costumes suppress the underlying chest plate/arm, without changing defensive stats or item ownership.
- Equipment menu shows selected category and first selects currently equipped or owned items, rather than defaulting to locked ones.
- Larger full-body equipment comparison with deferred first-layout fit; responsive scroll remains.
- Add a dedicated Godot 734 regression test for each body and pose, plus existing weapon-track and content tests in Android CI.

## Constraints
No new hero class, inventory/save schema, paid items, or remote script content.
Same Android package and signing certificate. Release only after signed GitHub CI succeeds. Native APK installation still requires Android confirmation. Device screenshots needed for visual alignment acceptance.
