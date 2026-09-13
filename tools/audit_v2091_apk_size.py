#!/usr/bin/env python3
"""V2.09.1 APK and source size audit."""
from __future__ import annotations

import hashlib
import json
import os
import struct
import sys
import zipfile
from collections import defaultdict
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "docs" / "v2091_size_audit"
APK = ROOT / "builds" / "android" / "RealmAlliance_V2_09_Test.apk"

EXT_TYPES = {
    ".png": "PNG",
    ".webp": "WebP",
    ".jpg": "JPG",
    ".jpeg": "JPEG",
    ".svg": "SVG",
    ".ogg": "OGG",
    ".wav": "WAV",
    ".mp3": "MP3",
    ".ttf": "font",
    ".otf": "font",
    ".pck": "Godot PCK",
    ".so": "native library",
    ".json": "JSON/data",
    ".tscn": "scene",
    ".tres": "resource",
    ".gd": "script",
    ".import": "import meta",
    ".remap": "remap",
    ".gdc": "compiled script",
}


def file_type(path: str) -> str:
    ext = Path(path).suffix.lower()
    if ext in EXT_TYPES:
        return EXT_TYPES[ext]
    if path.endswith(".so") or "/lib/" in path:
        return "native library"
    return "other"


def pct(n: int, total: int) -> float:
    return round(100.0 * n / total, 4) if total else 0.0


def audit_apk(apk_path: Path) -> dict:
    if not apk_path.is_file():
        raise FileNotFoundError(apk_path)

    entries = []
    by_type = defaultdict(lambda: {"compressed": 0, "uncompressed": 0, "count": 0})
    by_dir = defaultdict(lambda: {"compressed": 0, "uncompressed": 0, "count": 0})

    with zipfile.ZipFile(apk_path, "r") as zf:
        for info in zf.infolist():
            if info.is_dir():
                continue
            ft = file_type(info.filename)
            top = info.filename.split("/")[0] if "/" in info.filename else info.filename
            by_type[ft]["compressed"] += info.compress_size
            by_type[ft]["uncompressed"] += info.file_size
            by_type[ft]["count"] += 1
            by_dir[top]["compressed"] += info.compress_size
            by_dir[top]["uncompressed"] += info.file_size
            by_dir[top]["count"] += 1
            entries.append(
                {
                    "path": info.filename,
                    "file_type": ft,
                    "compressed_bytes": info.compress_size,
                    "uncompressed_bytes": info.file_size,
                    "compression_ratio": round(info.compress_size / info.file_size, 4)
                    if info.file_size
                    else 0.0,
                }
            )

    total_compressed = sum(e["compressed_bytes"] for e in entries)
    total_uncompressed = sum(e["uncompressed_bytes"] for e in entries)
    entries.sort(key=lambda e: e["compressed_bytes"], reverse=True)

    for e in entries:
        e["percentage_of_apk"] = pct(e["compressed_bytes"], total_compressed)

    pck_entries = [e for e in entries if e["path"].endswith(".pck")]
    return {
        "apk_path": str(apk_path.relative_to(ROOT)).replace("\\", "/"),
        "total_compressed_bytes": total_compressed,
        "total_uncompressed_bytes": total_uncompressed,
        "file_count": len(entries),
        "by_type": dict(by_type),
        "by_top_directory": dict(by_dir),
        "pck_files": pck_entries,
        "top_100": entries[:100],
        "all_entries_count": len(entries),
    }


def map_apk_to_source(apk_path: str) -> str | None:
    # Godot APK assets often res:// path inside pck; zip listing shows assets/...
    candidates = [
        apk_path.replace("assets/", "assets/"),
        apk_path,
    ]
    for c in candidates:
        p = ROOT / c.replace("/", os.sep)
        if p.is_file():
            return str(p.relative_to(ROOT)).replace("\\", "/")
    # docs in pck appear as res://docs/...
    for prefix in ("res://", "assets/"):
        rel = apk_path
        if rel.startswith(prefix):
            rel = rel[len(prefix) :]
        p = ROOT / rel.replace("/", os.sep)
        if p.is_file():
            return str(p.relative_to(ROOT)).replace("\\", "/")
    p = ROOT / apk_path.replace("/", os.sep)
    if p.is_file():
        return str(p.relative_to(ROOT)).replace("\\", "/")
    return None


def classify_entry(path: str, source: str | None) -> dict:
    p = (source or path).replace("\\", "/").lower()
    decision = "KEEP"
    required = True
    safe_exclude = False
    category = "UNKNOWN"

    if p.startswith("docs/"):
        category = "DOC_ONLY"
        required = False
        safe_exclude = True
        decision = "EXCLUDE_EXPORT"
    elif "/v20" in p and "_visual_runtime_qa/" in p:
        category = "QA_ONLY"
        required = False
        safe_exclude = True
        decision = "EXCLUDE_EXPORT"
    elif p.endswith(".log"):
        category = "QA_ONLY"
        required = False
        safe_exclude = True
        decision = "EXCLUDE_EXPORT"
    elif "_source_sheet" in p or "master_sheet" in p or "/raw/" in p:
        category = "PRODUCTION_SOURCE_ONLY"
        required = False
        safe_exclude = True
        decision = "EXCLUDE_EXPORT"
    elif p.startswith("tools/"):
        category = "DOC_ONLY"
        required = False
        safe_exclude = True
        decision = "EXCLUDE_EXPORT"
    elif p.startswith("builds/"):
        category = "DOC_ONLY"
        required = False
        safe_exclude = True
        decision = "EXCLUDE_EXPORT"
    elif p.startswith("assets/production/"):
        category = "REQUIRED_RUNTIME"
    elif p.startswith("assets/"):
        category = "REQUIRED_RUNTIME"
    elif p.startswith("data/"):
        category = "REQUIRED_RUNTIME"
    elif p.endswith(".so"):
        category = "REQUIRED_RUNTIME"
    elif p.endswith(".pck"):
        category = "REQUIRED_RUNTIME"

    return {
        "runtime_referenced": required,
        "production": category in ("REQUIRED_RUNTIME", "REQUIRED_DYNAMIC"),
        "category": category,
        "required": required,
        "safe_to_exclude": safe_exclude,
        "decision": decision,
    }


def build_offenders(apk_audit: dict) -> list[dict]:
    offenders = []
    for e in apk_audit["top_100"]:
        src = map_apk_to_source(e["path"])
        meta = classify_entry(e["path"], src)
        offenders.append(
            {
                "path": e["path"],
                "source_path": src,
                "file_type": e["file_type"],
                "compressed_bytes": e["compressed_bytes"],
                "uncompressed_bytes": e["uncompressed_bytes"],
                "percentage_of_apk": e["percentage_of_apk"],
                "duplicate": False,
                **meta,
            }
        )
    return offenders


def audit_source_dirs() -> dict:
    dir_sizes = defaultdict(lambda: {"bytes": 0, "files": 0})
    all_files: list[tuple[int, str]] = []

    skip = {".git", ".godot", "builds"}
    for dirpath, dirnames, filenames in os.walk(ROOT):
        rel_dir = Path(dirpath).relative_to(ROOT)
        parts = rel_dir.parts
        if parts and parts[0] in skip:
            dirnames[:] = []
            continue
        for fn in filenames:
            fp = Path(dirpath) / fn
            try:
                size = fp.stat().st_size
            except OSError:
                continue
            rel = str(fp.relative_to(ROOT)).replace("\\", "/")
            all_files.append((size, rel))
            top = rel.split("/")[0] if "/" in rel else rel
            dir_sizes[top]["bytes"] += size
            dir_sizes[top]["files"] += 1
            # also track docs subdirs
            if rel.startswith("docs/"):
                sub = "/".join(rel.split("/")[:2])
                dir_sizes[sub]["bytes"] += size
                dir_sizes[sub]["files"] += 1

    all_files.sort(reverse=True)
    return {
        "by_top_directory": {k: v for k, v in sorted(dir_sizes.items(), key=lambda x: -x[1]["bytes"])},
        "top_100_source_files": [{"path": p, "bytes": s} for s, p in all_files[:100]],
    }


def audit_duplicates(limit_mb: float = 0.1) -> dict:
    min_size = int(limit_mb * 1024 * 1024)
    hashes: dict[str, list[str]] = defaultdict(list)
    skip_dirs = {".git", ".godot", "builds"}

    for dirpath, dirnames, filenames in os.walk(ROOT):
        rel_dir = Path(dirpath).relative_to(ROOT)
        if rel_dir.parts and rel_dir.parts[0] in skip_dirs:
            dirnames[:] = []
            continue
        for fn in filenames:
            fp = Path(dirpath) / fn
            try:
                size = fp.stat().st_size
            except OSError:
                continue
            if size < min_size:
                continue
            h = hashlib.sha256()
            with open(fp, "rb") as f:
                for chunk in iter(lambda: f.read(1024 * 1024), b""):
                    h.update(chunk)
            rel = str(fp.relative_to(ROOT)).replace("\\", "/")
            hashes[h.hexdigest()].append({"path": rel, "bytes": size})

    groups = []
    wasted = 0
    for digest, items in hashes.items():
        if len(items) < 2:
            continue
        items.sort(key=lambda x: x["bytes"], reverse=True)
        dup_waste = sum(i["bytes"] for i in items[1:])
        wasted += dup_waste
        groups.append(
            {
                "sha256": digest,
                "count": len(items),
                "wasted_bytes": dup_waste,
                "files": items,
            }
        )
    groups.sort(key=lambda g: g["wasted_bytes"], reverse=True)
    return {"duplicate_groups": groups[:100], "total_wasted_bytes": wasted, "group_count": len(groups)}


def image_dimensions(limit_bytes: int = 500_000) -> list[dict]:
    rows = []
    try:
        from PIL import Image
    except ImportError:
        return [{"error": "PIL not available"}]

    for dirpath, _, filenames in os.walk(ROOT / "assets"):
        for fn in filenames:
            if not fn.lower().endswith((".png", ".webp", ".jpg", ".jpeg")):
                continue
            fp = Path(dirpath) / fn
            try:
                size = fp.stat().st_size
            except OSError:
                continue
            if size < limit_bytes:
                continue
            rel = str(fp.relative_to(ROOT)).replace("\\", "/")
            try:
                with Image.open(fp) as im:
                    w, h = im.size
                    mode = im.mode
            except Exception as exc:
                rows.append({"path": rel, "bytes": size, "error": str(exc)})
                continue
            rows.append(
                {
                    "path": rel,
                    "bytes": size,
                    "width": w,
                    "height": h,
                    "channels": mode,
                    "has_alpha": "A" in mode,
                    "megapixels": round(w * h / 1_000_000, 3),
                }
            )
    rows.sort(key=lambda r: r.get("bytes", 0), reverse=True)
    return rows[:100]


def write_baseline_md(apk_audit: dict, source_audit: dict, dup_audit: dict, offenders: list) -> None:
    total = apk_audit["total_compressed_bytes"]
    lines = [
        "# APK Size Baseline — V2.09",
        "",
        f"Generated: {datetime.now(timezone.utc).isoformat()}",
        f"Git HEAD: (see audit run)",
        "",
        "## Current APK",
        "",
        f"- Path: `{apk_audit['apk_path']}`",
        f"- Compressed bytes: **{total:,}**",
        f"- Uncompressed bytes: {apk_audit['total_uncompressed_bytes']:,}",
        f"- MB (decimal): **{total / 1_000_000:.2f} MB**",
        f"- MiB: **{total / (1024 * 1024):.2f} MiB**",
        f"- File count: {apk_audit['file_count']:,}",
        "",
        "## APK Breakdown by Type (compressed)",
        "",
        "| Type | Files | Compressed | % |",
        "|---|---:|---:|---:|",
    ]
    for ft, data in sorted(apk_audit["by_type"].items(), key=lambda x: -x[1]["compressed"]):
        lines.append(
            f"| {ft} | {data['count']} | {data['compressed']:,} | {pct(data['compressed'], total):.2f}% |"
        )

    lines += ["", "## APK Breakdown by Top Directory (compressed)", "", "| Dir | Files | Compressed | % |", "|---|---:|---:|---:|"]
    for d, data in sorted(apk_audit["by_top_directory"].items(), key=lambda x: -x[1]["compressed"])[:20]:
        lines.append(f"| `{d}` | {data['count']} | {data['compressed']:,} | {pct(data['compressed'], total):.2f}% |")

    lines += ["", "## Source Breakdown (top directories)", "", "| Directory | Files | Bytes | MB |", "|---|---:|---:|---:|"]
    for d, data in list(source_audit["by_top_directory"].items())[:25]:
        lines.append(f"| `{d}` | {data['files']} | {data['bytes']:,} | {data['bytes']/1_000_000:.2f} |")

    qa_waste = sum(o["compressed_bytes"] for o in offenders if o["category"] in ("QA_ONLY", "DOC_ONLY"))
    master_waste = sum(o["compressed_bytes"] for o in offenders if o["category"] == "PRODUCTION_SOURCE_ONLY")

    lines += [
        "",
        "## Root Cause Summary",
        "",
        f"- **Export mode:** `all_resources` with empty `exclude_filter` — entire repo exported into PCK.",
        f"- **QA/DOC in top offenders (sample):** {qa_waste:,} bytes compressed in top-100 alone.",
        f"- **Master/source sheets in top offenders (sample):** {master_waste:,} bytes.",
        f"- **Duplicate asset waste (source, >100KB groups):** {dup_audit['total_wasted_bytes']:,} bytes.",
        "",
        "## Safe Optimization Candidates (Tier 1)",
        "",
        "- Exclude `docs/**` from Android export",
        "- Exclude QA runtime screenshot folders",
        "- Exclude `tools/**`, `builds/**`",
        "- Exclude `*_source_sheet*` / production master sheets if runtime uses cropped states",
        "- Keep `arm64-v8a` only (already set)",
        "",
        "## Risky Optimization Candidates (Tier 2+)",
        "",
        "- Texture compression tuning per asset class",
        "- Background resolution reduction",
        "- Runtime derivative generation for oversized PNGs",
        "",
    ]
    (OUT / "APK_SIZE_BASELINE.md").write_text("\n".join(lines), encoding="utf-8")


def main() -> int:
    OUT.mkdir(parents=True, exist_ok=True)
    apk_audit = audit_apk(APK)
    source_audit = audit_source_dirs()
    dup_audit = audit_duplicates()
    offenders = build_offenders(apk_audit)
    images = image_dimensions()

    (OUT / "apk_internal_audit.json").write_text(json.dumps(apk_audit, indent=2), encoding="utf-8")
    (OUT / "source_audit.json").write_text(json.dumps(source_audit, indent=2), encoding="utf-8")
    (OUT / "duplicate_assets.json").write_text(json.dumps(dup_audit, indent=2), encoding="utf-8")
    (OUT / "top_size_offenders.json").write_text(json.dumps(offenders, indent=2), encoding="utf-8")
    (OUT / "image_dimension_audit.json").write_text(json.dumps(images, indent=2), encoding="utf-8")

    md_lines = ["# Top Size Offenders (APK)", "", f"APK: `{APK.name}` — {apk_audit['total_compressed_bytes']:,} bytes compressed", ""]
    md_lines += ["| # | Path | Type | Compressed | % APK | Category | Decision |", "|---:|---|---|---:|---:|---|---|"]
    for i, o in enumerate(offenders, 1):
        md_lines.append(
            f"| {i} | `{o['path'][:80]}` | {o['file_type']} | {o['compressed_bytes']:,} | {o['percentage_of_apk']:.2f}% | {o['category']} | {o['decision']} |"
        )
    (OUT / "top_size_offenders.md").write_text("\n".join(md_lines), encoding="utf-8")
    write_baseline_md(apk_audit, source_audit, dup_audit, offenders)

    print(json.dumps({"ok": True, "apk_mb": apk_audit["total_compressed_bytes"] / 1_000_000, "files": apk_audit["file_count"]}, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
