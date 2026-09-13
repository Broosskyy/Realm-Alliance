# REALM ALLIANCE V2.09.2 Test

Fixes Android installation failure in V2.09 / V2.09.1 (unsigned APK).

## Root Cause

V2.09.1 APK was exported with `package/signed=false`. Android rejects unsigned APKs:

`INSTALL_PARSE_FAILED_NO_CERTIFICATES`

## Fix

- Re-enabled Godot debug APK signing (same certificate as V2.06–V2.08)
- Identical gameplay and size-optimized export filters from V2.09.1
- Verified: `apksigner verify` PASS, `adb install` Success

## Size

| | V2.09.1 | V2.09.2 |
|---|---:|---:|
| APK | 129,431,076 bytes | 129,652,228 bytes |

## Android

- Package: `com.realmalliance.prototype`
- Version: `2.09.2`
- Build: `2092`
- ABI: `arm64-v8a`

Test build — not a Play Store release.

## SHA-256

`6ab5e07cd7b569ea34842181154a83d8b9e3ab5d1cf70e0ed9ede900ff2f2e98`

## Note

V2.09.1 release remains for audit history but must not be installed — it is unsigned.
