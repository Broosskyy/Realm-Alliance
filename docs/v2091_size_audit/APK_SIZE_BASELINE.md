# APK Size Baseline — V2.09

Generated: 2026-09-13T18:33:29.399335+00:00
Git HEAD: (see audit run)

## Current APK

- Path: `builds/android/RealmAlliance_V2_09_Test.apk`
- Compressed bytes: **1,013,997,818**
- Uncompressed bytes: 1,072,671,636
- MB (decimal): **1014.00 MB**
- MiB: **967.02 MiB**
- File count: 2,851

## APK Breakdown by Type (compressed)

| Type | Files | Compressed | % |
|---|---:|---:|---:|
| other | 1173 | 986,316,844 | 97.27% |
| native library | 2 | 25,920,129 | 2.56% |
| compiled script | 155 | 773,644 | 0.08% |
| WebP | 26 | 385,616 | 0.04% |
| JSON/data | 255 | 374,431 | 0.04% |
| import meta | 1058 | 179,443 | 0.02% |
| PNG | 16 | 38,981 | 0.00% |
| remap | 166 | 8,730 | 0.00% |

## APK Breakdown by Top Directory (compressed)

| Dir | Files | Compressed | % |
|---|---:|---:|---:|
| `assets` | 2729 | 985,465,555 | 97.19% |
| `lib` | 2 | 25,920,129 | 2.56% |
| `classes.dex` | 1 | 1,960,045 | 0.19% |
| `res` | 69 | 398,123 | 0.04% |
| `classes7.dex` | 1 | 58,427 | 0.01% |
| `resources.arsc` | 1 | 39,736 | 0.00% |
| `classes4.dex` | 1 | 27,734 | 0.00% |
| `classes11.dex` | 1 | 21,053 | 0.00% |
| `classes6.dex` | 1 | 20,779 | 0.00% |
| `classes3.dex` | 1 | 19,690 | 0.00% |
| `classes10.dex` | 1 | 13,236 | 0.00% |
| `classes12.dex` | 1 | 11,585 | 0.00% |
| `kotlin` | 8 | 11,134 | 0.00% |
| `classes5.dex` | 1 | 9,884 | 0.00% |
| `classes8.dex` | 1 | 9,648 | 0.00% |
| `classes9.dex` | 1 | 3,872 | 0.00% |
| `classes13.dex` | 1 | 2,268 | 0.00% |
| `AndroidManifest.xml` | 1 | 2,219 | 0.00% |
| `classes2.dex` | 1 | 1,152 | 0.00% |
| `DebugProbesKt.bin` | 1 | 782 | 0.00% |

## Source Breakdown (top directories)

| Directory | Files | Bytes | MB |
|---|---:|---:|---:|
| `docs` | 698 | 1,750,232,044 | 1750.23 |
| `docs/v205_visual_runtime_qa` | 75 | 672,001,425 | 672.00 |
| `build` | 19 | 378,762,168 | 378.76 |
| `tools` | 82 | 267,257,554 | 267.26 |
| `docs/v209_visual_runtime_qa` | 100 | 206,101,599 | 206.10 |
| `docs/v2061_visual_runtime_qa` | 96 | 179,410,207 | 179.41 |
| `assets` | 1452 | 174,883,537 | 174.88 |
| `docs/v206_visual_runtime_qa` | 88 | 166,218,554 | 166.22 |
| `docs/v208_visual_runtime_qa` | 65 | 129,523,405 | 129.52 |
| `docs/v207_visual_runtime_qa` | 63 | 104,876,267 | 104.88 |
| `docs/v204_visual_runtime_qa` | 55 | 100,830,419 | 100.83 |
| `docs/v203_visual_runtime_qa` | 38 | 64,560,199 | 64.56 |
| `docs/v2021_visual_runtime_qa` | 29 | 50,633,039 | 50.63 |
| `docs/v2022_visual_runtime_qa` | 28 | 49,765,759 | 49.77 |
| `docs/v202_runtime_qa` | 13 | 22,478,519 | 22.48 |
| `artifacts` | 12 | 20,930,515 | 20.93 |
| `docs/visual_reference` | 2 | 3,099,828 | 3.10 |
| `data` | 207 | 2,083,633 | 2.08 |
| `docs/V1_58_SCREEN_CALIBRATION_BOARD.png` | 1 | 522,949 | 0.52 |
| `MainGame.gd` | 1 | 172,282 | 0.17 |
| `MainGame.tscn` | 1 | 118,138 | 0.12 |
| `qa_v208_run.log` | 1 | 73,578 | 0.07 |
| `docs/v209_final_qa` | 1 | 68,904 | 0.07 |
| `ScreenUiAssemblyService.gd` | 1 | 55,471 | 0.06 |
| `V2021VisualRuntimeQa.gd` | 1 | 47,216 | 0.05 |

## Root Cause Summary

- **Export mode:** `all_resources` with **empty `exclude_filter`** — entire project resource graph exported into APK.
- **Primary waste (~788 MiB imported ctex):** QA screenshot PNGs under `docs/**` have Godot `.import` sidecars; their `.godot/imported/*.ctex` compressed textures dominate the APK.
- **Secondary waste (~56 MiB ctex):** `artifacts/**`, `build/**`, and `*_source_sheet.png` production master sheets (runtime uses cropped state sprites).
- **Actual production runtime ctex:** ~88 MiB (monsters + production UI/world assets).
- **Godot engine:** `libgodot_android.so` ~25 MiB (required).
- **Duplicate asset waste (source, >100KB groups):** see `duplicate_assets.json`.

Expected Tier-1 savings: **~800+ MiB** by excluding docs/QA artifacts/build outputs and master sheets from export.

## Safe Optimization Candidates (Tier 1)

- Exclude `docs/**` from Android export
- Exclude QA runtime screenshot folders
- Exclude `tools/**`, `builds/**`
- Exclude `*_source_sheet*` / production master sheets if runtime uses cropped states
- Keep `arm64-v8a` only (already set)

## Risky Optimization Candidates (Tier 2+)

- Texture compression tuning per asset class
- Background resolution reduction
- Runtime derivative generation for oversized PNGs
