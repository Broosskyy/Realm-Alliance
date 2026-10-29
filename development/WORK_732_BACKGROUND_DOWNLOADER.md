# REALM ALLIANCE 732 – Android background APK downloads

The Godot HTTPRequest transfer was interrupted when Android paused the game upon app switching.
732 delegates APK downloads to Android DownloadManager, which is operated by the system independently of the game's frame loop. It can retry through network changes and shows an Android download notification.

## Behaviour
- Launcher validates pinned GitHub URL, SHA-256, version and expected file size before invoking native enqueueBackgroundApk.
- Java enqueues DownloadManager with app-private external destination realm_apk_updater/update-VERSION.apk; request ID, version, hash and size persist via app-private SharedPreferences.
- When game resumes or restarts, it reconnects to the existing request; it NEVER starts a duplicate for the same version and metadata.
- The UI polls only while the game is foreground; Android continues downloading while backgrounded; if the user starts offline gameplay, native transfer isn't cancelled.
- On download completion: verify exact length and SHA-256 in Godot, then Android native verifies matching package name, version and original signing certificate; only then opens system installer with user permission.
- No silent APK installation. No use of Android broad storage permissions or remote executable scripts. If user moves to a different application, the native system handles pause/retry.
- This requires one native APK 732 (delivered through existing automatic OTA). Subsequent releases are downloaded in background using the same system.
- Battery saver, Android restrictions, storage availability, and network policies may delay/pause system downloads. This cannot guarantee uninterrupted download in every Android environment.
- Real-device background switch, network drop, relaunch, install and save continuity tests remain to be confirmed.
