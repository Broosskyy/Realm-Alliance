# REALM ALLIANCE V2.09.1 Test

Identical V2.09 gameplay and content — **Android package size optimization only**.

## Size

| | V2.09.0 | V2.09.1 | Saved |
|---|---:|---:|---:|
| APK | 1,014,587,634 bytes (~968 MiB) | 129,431,076 bytes (~123 MiB) | **87.25%** |

## Root cause (V2.09 bloat)

QA screenshot folders under `docs/**` were exported via `all_resources` + empty `exclude_filter`, packing ~788 MiB of imported `.ctex` textures into the APK.

## Changes

- Export exclude filters for docs, tools, builds, artifacts, logs, master sheets
- No gameplay, balance, encounter, or UI changes
- Full domain/runtime/regression QA PASS

## Android

- Package: `com.realmalliance.prototype`
- Version: `2.09.1`
- Build: `2091`
- ABI: `arm64-v8a`

Test build — not a Play Store release.

## SHA-256

`2f08a308bf4998f6aa10cb9314bbf4715b4ebdf25b4cbc2bfaa711b39abd0f4a`
