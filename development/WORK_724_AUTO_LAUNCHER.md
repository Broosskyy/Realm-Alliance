# WORK 724 – Native loading screen / automatic updates
- Startup automatically checks signed release metadata and downloads compatible APK when needed (Java Android system installer still requires user approval).
- Godot's 720 use of nonexistent HTTPRequest.keep_partial_download caused the 720 button to end early with no status. Newer 722+ branch no longer assigns that property.
- A separate threaded HTTPRequest has no total timeout for large APKs; progress is shown in MiB and %. Signed APK metadata and Android certificate validation remain enforced.
- During update check and download, Play/Account buttons are hidden; an explicit "Offline weiterspielen" skip is visible for players unable to download.
- Once JSON/PNG content packs are current, launch directly into saved game instead of remaining on the menu.
- Download failures keep a visible retry control and human-readable error.
- 724 remains a **signed prerelease without automatic manifest promotion** until the test phone is upgraded from buggy 720 to working 723.
- Future work: chunked downloads and asset bundles for events/characters/audio; the current content updater supports bounded PNG/JSON only, not arbitrary remote engine code.
