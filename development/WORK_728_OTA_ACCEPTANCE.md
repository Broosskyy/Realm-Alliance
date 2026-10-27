# REALM ALLIANCE 728 – acceptance test installed 727 → OTA 728

## Purpose
User's 720 APK displays an update but pressing the download button does nothing. The 720 code assigns a removed/nonexistent HTTPRequest property `keep_partial_download` before starting a download; 727 omits this access and provides a separate threaded APK downloader, automatic start overlay, progress and visible errors. None of these code changes can be delivered as a data-only asset to the installed 720 package.

## Device protocol
1. Install official signed 727 over 720 **without uninstalling**, then preserve user profile and save files.
2. The signed 728 prerelease is offered by the shared test manifest. Start 727 on Wi-Fi.
3. The loader must automatically initiate 728 without tapping a download button, display percentage and downloaded MiB.
4. After full download, verify SHA256 and certificate match, then open Android's install confirmation. Android user confirms; no silent installation.
5. Launch 728 and verify saved heroes, items, currency and the two live content packs remain.
6. If any stage fails, capture precise error text and Android logs; do not report OTA success merely because CI passes.

## Safety
- Signing key ONLY inside GitHub Actions secret, original signer. No new keystore and no private material in source.
- Code change is intentionally limited to version and test metadata. Gameplay progression, profiles, saves, content packs and gameplay scenes unchanged.
- Public rollout is NOT approved by this test. `distribution/realm-715-test` is a private development test channel, not a public stable update.
