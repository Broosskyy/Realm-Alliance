# V2.09.2 Abschlussreport — Android Install Fix

**Status:** PASS (install gate proven)  
**Version:** 2.09.2 (Build 2092)  
**Date:** 2026-09-13

---

## ROOT CAUSE

V2.09 / V2.09.1 APKs were **unsigned** (`package/signed=false`).  
`apksigner`: `DOES NOT VERIFY — Missing META-INF/MANIFEST.MF`  
`adb install`: **`INSTALL_PARSE_FAILED_NO_CERTIFICATES`**

This matches Samsung real-device **“App not installed”**.

V2.06–V2.08 used Godot debug signing (certificate SHA-256 `249f0a26…`). V2.09+ disabled signing after release keystore failure.

---

## FIX

- `export_presets.cfg`: `package/signed=true`
- Godot debug keystore (same certificate as V2.08)
- Export script validates `apksigner verify` before PASS
- No gameplay changes

---

## SIZE

| Build | Bytes | Notes |
|---|---:|---|
| V2.09.1 (broken) | 129,431,076 | unsigned |
| V2.09.2 (fixed) | 129,652,228 | signed (+221 KB signing overhead) |

Size optimization from V2.09.1 preserved.

---

## INSTALL GATE

| Test | Result |
|---|---|
| apksigner verify | **PASS** (v2 + v3) |
| zipalign | **PASS** |
| adb clean install (final APK) | **Success** |
| adb update V2.08 → V2.09.2 | **Success** |
| App launch (monkey) | **Success** |
| Logcat FATAL | **None** |

---

## QA

| Suite | Result |
|---|---|
| Domain World | 11/11 PASS |
| Domain Inventory | 26/26 PASS |

Gameplay unchanged from V2.09.1 size-optimized export filters.

---

## APK

| Field | Value |
|---|---|
| File | `RealmAlliance_V2_09_2_Test.apk` |
| SHA-256 | `6ab5e07cd7b569ea34842181154a83d8b9e3ab5d1cf70e0ed9ede900ff2f2e98` |
| Package | `com.realmalliance.prototype` |
| Version | 2.09.2 / 2092 |
| ABI | arm64-v8a |

---

## GITHUB

| Field | Value |
|---|---|
| Tag | `v2.09.2-test` |
| Prior releases preserved | `v2.09.0-test`, `v2.09.1-test` |

*(Release URL updated after upload)*

---

## PERMANENT RELEASE RULE

Godot export success ≠ Android release PASS. Required gates: apksigner → zipalign → adb install → launch → regression → GitHub asset hash match.

---

## REPORTS

- `docs/v2092_android_install/ROOT_CAUSE.md`
- `docs/v2092_android_install/signature_matrix.json`
- `docs/v2092_android_install/apk_validation.json`
- `docs/v2092_android_install/adb_install_results.json`
- `docs/v2092_android_install/final_release_validation.json`
