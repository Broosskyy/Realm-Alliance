# REALM ALLIANCE 726 – OTA validation after the 720 downloader bug

- Latest test build 725 includes boot-time update check, automatic large-file streaming with separate HTTPRequest and loading screen, offline skip and native installer.
- Version 726 is only a minimal code-version increment for on-device automatic transition 725 → 726.
- Keep all game saves and content packs unmodified.
- CI requires original keystore and validates certificate, package and version code; only after signed GitHub Release exists it activates OTA manifest 726.
- Do not claim Android 725 → 726 has been tested before receiving the device confirmation.
- Known limit: installed 720 has invalid `HTTPRequest.keep_partial_download` setting, so user must replace 720 once with official signed 725 APK without uninstalling.
