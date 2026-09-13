# V2.09.1 Android Installation Failure — Root Cause

**Date:** 2026-09-13  
**APK:** `RealmAlliance_V2_09_1_Test.apk`  
**SHA-256:** `2f08a308bf4998f6aa10cb9314bbf4715b4ebdf25b4cbc2bfaa711b39abd0f4a`  
**GitHub asset hash:** **MATCH** (verified against release download)

---

## Root Cause (proven)

**The V2.09.1 APK is not signed.**

`apksigner verify --verbose --print-certs` output:

```
DOES NOT VERIFY
ERROR: Missing META-INF/MANIFEST.MF
```

The APK contains AndroidX `META-INF/*.version` metadata but **no JAR signing block** (`META-INF/MANIFEST.MF`, `.SF`, `.RSA`/`.DSA`).

Android (including Samsung) **rejects unsigned APKs** for installation. This is not a size-filter regression, not ABI, not manifest package mismatch.

### Cause in build pipeline

`export_presets.cfg` had:

```
package/signed=false
```

V2.09 / V2.09.1 exports used `--export-debug` after a release keystore failure, with signing explicitly disabled. Godot produced a valid zip/APK structure but **never applied APK signing**.

---

## Signature comparison (installable vs broken)

| APK | versionCode | apksigner | Certificate SHA-256 |
|---|---:|---|---|
| V2.06 Test | 2060 | **VERIFIED** | `249f0a26200821bb2a30fb1f3ec22b4b264da1d7b0742617dcab9de7bedb6dc2` |
| V2.07 Test | 2070 | **VERIFIED** | `249f0a26200821bb2a30fb1f3ec22b4b264da1d7b0742617dcab9de7bedb6dc2` |
| V2.08 Test | 2080 | **VERIFIED** | `249f0a26200821bb2a30fb1f3ec22b4b264da1d7b0742617dcab9de7bedb6dc2` |
| V2.09 Test | 2090 | **FAIL** (unsigned) | — |
| V2.09.1 Test | 2091 | **FAIL** (unsigned) | — |

Certificate DN (V2.06–V2.08): `CN=Godot, OU=Godot Engine, O=Stichting Godot, C=NL`

**Signing key did not change** — V2.09+ stopped signing entirely.

---

## Manifest (V2.09.1 — valid except unsigned)

| Field | Actual |
|---|---|
| package | `com.realmalliance.prototype` |
| versionName | `2.09.1` |
| versionCode | `2091` |
| minSdk | `24` |
| targetSdk | `36` |
| native-code | `arm64-v8a` |
| debuggable | `true` (debug export) |

---

## ZIP / alignment

`zipalign -c -v 4` → **Verification successful**

No malformed archive, corrupt central directory, or alignment failure.

---

## Native libraries (present)

| File | compressed | uncompressed |
|---|---:|---:|
| `lib/arm64-v8a/libgodot_android.so` | 25,465,279 | 76,181,608 |
| `lib/arm64-v8a/libc++_shared.so` | 454,850 | 1,374,336 |

Export size filters did **not** strip required native libs.

---

## Samsung / device impact

Unsigned APKs fail installation on modern Android before app code runs. Expected user-visible result: **App not installed** (exact `INSTALL_FAILED_*` code requires `adb install` on device — see `adb_install_results.json`).

---

## Fix (V2.09.2)

1. Set `package/signed=true` in `export_presets.cfg`
2. Export with Godot debug keystore (same Godot CN certificate as V2.06–V2.08)
3. **Mandatory gate:** `apksigner verify` must PASS before release
4. **Mandatory gate:** `adb install` Success on test device/emulator
5. Never treat Godot export exit code alone as install PASS

No gameplay changes. No package ID change.
