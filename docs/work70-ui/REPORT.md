# Work 6.8–7.0: recovered source and scrolling repair

The previously delivered source bundle restores commits through `e29e08f49c400c012b696e9ee844f005fd24ca0a`, based on `3ca48b45a3b7e58b1883c5d31905cffd1198129b`. At recovery, `feature/work-6-8-rpg-economy` did not exist on GitHub. No implementation from the earlier source delivery was discarded.

## Changes

- Wesen and Mehr use a native ScrollContainer, including the painted cards, real buttons, equipped hero and companion. Paint and input scroll together and clip below the fixed header. Bottom navigation and return action stay outside the scroll viewport.
- Each page retains its scroll position. Keyboard focus follows content. The existing native touch-drag and wheel behavior is enabled. Hero progression is reachable on short windows as well as tall phones.
- Mehr headings no longer overlap the journey and save actions.
- Dialog text and secondary operations scroll vertically. Confirm and cancel remain outside that content. Existing roster/shop tabs and quest scroll containers adapt their minimum height to the viewport; resizing and roster rebuilds apply the same bounds.
- Opening the hub no longer creates empty event progress while reading quest eligibility.

## Validation

Godot 4.7.2: **23 suites, 1,357/1,357 checks**, including the 101-check scroll/dialog regression. The two save-writing suites use their required `/tmp/realm62-test-*` data locations. Full results: `VALIDATION.json`.

The new regression covers 360×800, 720×1280, 720×1560 and 1280×720 window sizes; bottom actions remain reachable, navigation remains fixed, weapon/roster/talent/AUTO/reise dialogs fit, and navigation preserves the profile.

The updated PCK was exported and run using the previously delivered matching Godot Web engine. Chromium 153 / SwiftShader at 360×640: combat boots, Wesen and Mehr open and wheel-scroll; actual screenshots were inspected. No JavaScript or Godot script errors were observed in this pass. This is a local browser check, not a claim about a public deployment or a physical Android device.

The canonical hero direction, separate weapons and existing 6.8–7.0 content remain in force. Online 7.1–7.6 remains a separate roadmap; this UI patch adds no multiplayer or server authority.
