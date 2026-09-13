# V2.09.1 Abschlussreport — APK Size Optimization

**Status:** PASS  
**Version:** 2.09.1 (Build 2091)  
**Date:** 2026-09-13  
**Base:** V2.09 Greenvale production pass (gameplay unchanged)

---

## ROOT CAUSE

The V2.09 APK (~968 MiB) used `export_filter="all_resources"` with **no `exclude_filter`**. Godot exported QA screenshot PNGs from `docs/**` (with `.import` sidecars) as compressed `.ctex` textures — **~788 MiB** of the import cache. Additional waste: `artifacts/`, `build/`, and `*_source_sheet.png` master sheets (~56 MiB ctex).

Actual production runtime content: **~88 MiB** textures + **~25 MiB** Godot native lib.

---

## SIZE RESULT

| Metric | V2.09.0 | V2.09.1 | Delta |
|---|---:|---:|---|
| Bytes | 1,014,587,634 | 129,431,076 | −885,156,558 |
| MB | 1014.59 | 129.43 | −885.16 |
| Reduction | — | — | **87.25%** |

Tier-2 texture downsampling was **not applied** (unnecessary).

---

## OPTIMIZATION (Tier 1)

`export_presets.cfg` exclude_filter for: `docs/**`, `tools/**`, `builds/**`, `build/**`, `artifacts/**`, `*_source_sheet.png`, logs.

Files remain in Git — excluded from Android export only.

---

## QA

| Gate | Result |
|---|---|
| Domain World | 11/11 PASS |
| Domain Inventory | 26/26 PASS |
| Runtime World | PASS |
| Runtime Inventory | PASS |
| Hero Unlock | PASS |
| Boss / Region | PASS |
| Visual / Viewport | PASS |
| Save/Reload | PASS |

Report: `docs/v2091_final_qa/final_acceptance_report.json`

---

## APK

| Field | Value |
|---|---|
| Path | `builds/android/RealmAlliance_V2_09_1_Test.apk` |
| Size | 129,431,076 bytes |
| Package | `com.realmalliance.prototype` |
| versionName | `2.09.1` |
| versionCode | `2091` |
| ABI | `arm64-v8a` |
| SHA-256 | `2f08a308bf4998f6aa10cb9314bbf4715b4ebdf25b4cbc2bfaa711b39abd0f4a` |

V2.09.0 release **`v2.09.0-test`** preserved as baseline.

---

## AUDIT REPORTS

- `docs/v2091_size_audit/APK_SIZE_BASELINE.md`
- `docs/v2091_size_audit/top_size_offenders.json` / `.md`
- `docs/v2091_size_audit/duplicate_assets.json`
- `docs/v2091_size_audit/optimization_results.md`

---

## GIT / GITHUB

*(Updated after push)*

---

## DEFERRED

- Tier-2 per-texture mobile compression (only if further size reduction needed)
- Monster attack state / Player HP
- Godot QA quit() hang (non-blocking)

---

## NEXT

V2.09.1 gate closed. No V2.10 features in this delivery.
