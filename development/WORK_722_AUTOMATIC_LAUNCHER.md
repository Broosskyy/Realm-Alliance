# REALM ALLIANCE 722 – Auto-Launcher

The installed 720 recognized 721 but pressing "Android-App-Update herunterladen" showed no visible transfer on a Galaxy device. Actual runtime root cause is still unverified; the new build makes every failure visible.

- Launcher starts update check in _ready (existing behavior).
- On valid newer Android release, launcher automatically downloads without a button tap. A normal Android installation confirmation is still required by OS.
- Dedicated, preconfigured threaded HTTPRequest for APK; old 8s metadata request independent; 0s timeout for APK; 16 redirects; auto progress in percentage and MiB.
- Safe offline play available; corrupt/partial APK never installed; SHA256, pinned GitHub URL, application ID, version, original certificate retained.
- Android FileProvider additionally accepts Godot user:// directory (files/app_userdata/<project>/realm_apk_updater) while only exposing the dedicated updater area.
- Permission resumes installer on returning from Android system settings.
- CI tests cover separate request node, threads, timeout, redirects, JSON metadata.
- Release 722 may be published, but OTA manifest promotion remains DISABLED pending phone acceptance. No confirmation of device update until tested.
- Distinguish verified PNG/JSON content changes from APK/native changes; not all graphics/types remotely patchable yet.
