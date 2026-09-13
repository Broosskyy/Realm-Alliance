# V2.09.1 Size Optimization Results

**Date:** 2026-09-13  
**Git baseline:** `913cb4eb6a52357f0530176b8aa02b031c140472` (V2.09 release)

## Summary

| Build | Bytes | MB | Files (APK zip) |
|---|---:|---:|---:|
| V2.09.0 baseline | 1,014,587,634 | 1014.59 | 2,851 |
| V2.09.1 Tier-1 | 129,431,076 | 129.43 | 2,137 |
| **Saved** | **885,156,558** | **885.16** | **714 fewer** |
| **Reduction** | — | — | **87.25%** |

Tier-2 texture optimization was **not required** — Tier-1 export exclusions achieved a production-sized APK without visual changes.

## Root Cause (968 MB baseline)

1. **`export_filter="all_resources"`** with empty **`exclude_filter`** exported the entire Godot resource graph.
2. **~788 MiB** imported `.ctex` from **`docs/**` QA screenshots** (Godot `.import` sidecars).
3. **~56 MiB** from **`artifacts/**`, `build/**`, and `*_source_sheet.png`** master sheets.
4. **~88 MiB** actual production runtime textures (monsters, UI, world).
5. **~25 MiB** `libgodot_android.so` (required).

## Tier-1 Changes (safe)

`export_presets.cfg` → `exclude_filter`:

- `docs/**` (QA screenshots, reports, logs)
- `tools/**`, `builds/**`, `build/**`, `artifacts/**`
- `*_source_sheet.png` (production master sheets; runtime uses cropped states)
- `*.log`, `qa_*.log`

Version metadata updated to **2.09.1 / 2091**. No gameplay, balance, or content changes.

## Optimized APK Breakdown

| Component | Compressed | % |
|---|---:|---:|
| `assets/` (runtime PCK resources) | ~100.5 MB | 77.9% |
| `lib/arm64-v8a` | ~25.9 MB | 20.1% |
| DEX / Android metadata | ~2.4 MB | 1.9% |

## QA (post-optimization)

| Suite | Result |
|---|---|
| Domain World | 11/11 PASS |
| Domain Inventory | 26/26 PASS |
| Runtime World (15 encounters) | PASS (~70 s) |
| Runtime Inventory | PASS |
| Visual / Viewport | PASS |
| Missing textures | None observed |

## Deferred (non-blocking)

- Further reduction below ~129 MB would require texture compression tuning (Tier-2) with visual comparison — not needed for V2.09.1 gate.
- Godot QA `quit()` hang after PASS reports.
- `.godot/imported` cache still contains doc ctex locally (not exported).

## APK Files

- Tier-1 test: `builds/android/RealmAlliance_V2_09_1_SizeTest_Tier1.apk`
- Final: `builds/android/RealmAlliance_V2_09_1_Test.apk`
