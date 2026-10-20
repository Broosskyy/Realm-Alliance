#!/usr/bin/env python3
"""Safely restore user-provided REALM ALLIANCE 709 sources to a REVIEW branch."""
import hashlib
import shutil
import subprocess
import tempfile
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PARTS_DIR = ROOT / "transfer" / "709"
PARTS = [PARTS_DIR / f"REALM_709_Quellen_GitHub_sicher.part{i:02d}-of-05" for i in range(1, 6)]
EXPECTED_SIZE = 94680643
EXPECTED_SHA256 = "7fab33ffe228ec4fbb1f25d542380833d52ed4b213f925a80a33f27b4c72e980"
TARGET_BRANCH = "review/realm-709"


def run(*args):
    subprocess.run(args, cwd=ROOT, check=True)


def main():
    missing = [p.name for p in PARTS if not p.is_file()]
    if missing:
        print("709 source upload is not complete yet. Waiting for:", ", ".join(missing))
        return
    with tempfile.TemporaryDirectory(prefix="realm709-") as tmp:
        archive = Path(tmp) / "source.zip"
        digest = hashlib.sha256()
        total = 0
        with archive.open("wb") as destination:
            for part in PARTS:
                with part.open("rb") as source:
                    for block in iter(lambda: source.read(1024 * 1024), b""):
                        total += len(block)
                        digest.update(block)
                        destination.write(block)
        if total != EXPECTED_SIZE or digest.hexdigest() != EXPECTED_SHA256:
            raise RuntimeError("709 source chunks are incomplete or modified; no changes pushed")
        print("Verified 709 public-safe source ZIP:", digest.hexdigest())
        with zipfile.ZipFile(archive) as z:
            entries = z.infolist()
            for entry in entries:
                path = Path(entry.filename)
                if not path.parts or path.parts[0] != "Source" or ".." in path.parts:
                    raise RuntimeError("Unsafe ZIP entry: " + entry.filename)
                if entry.filename.endswith(".keystore"):
                    raise RuntimeError("Signing material must never enter the public repository")
            extracted = Path(tmp) / "extracted"
            z.extractall(extracted)
        source_root = extracted / "Source"
        assert (source_root / "BUILD_INFO.json").is_file()
        run("git", "fetch", "origin", "main")
        run("git", "checkout", "-B", TARGET_BRANCH, "origin/main")
        for path in source_root.rglob("*"):
            if path.is_dir():
                continue
            rel = path.relative_to(source_root)
            target = ROOT / rel
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(path, target)
        ignore = ROOT / ".gitignore"
        current = ignore.read_text(encoding="utf-8") if ignore.exists() else ""
        # Godot .uid references and production artwork are required for a full reproducible 709 checkout.
        current = "\n".join(line for line in current.splitlines() if line.strip() not in ("**/*.uid", "/godot/realm_alliance/assets/production/")) + "\n"
        safe_lines = ["**/*.keystore", "**/*.jks", "**/.env", "**/.env.*", "**/.godot/"]
        with ignore.open("w", encoding="utf-8") as f:
            f.write(current.rstrip() + "\n" + "\n".join(x for x in safe_lines if x not in current.splitlines()) + "\n")
        log = ROOT / "RESTORE_709_INFO.md"
        log.write_text(
            "# REALM ALLIANCE 709 restoration\n\n"
            "Restored from the verified full 709 source archive provided by the project owner.\n\n"
            f"Sanitized source archive SHA-256: `{EXPECTED_SHA256}`\n\n"
            "Android debug signing keystore intentionally excluded from the public repository.\n"
            "The original full 709 ZIP must be retained privately to preserve APK update signing.\n"
            "Existing repository contents not present in the snapshot have not been deleted.\n",
            encoding="utf-8",
        )
        run("git", "config", "user.name", "github-actions[bot]")
        run("git", "config", "user.email", "41898282+github-actions[bot]@users.noreply.github.com")
        run("git", "add", "-A")
        run("git", "commit", "-m", "Restore verified REALM ALLIANCE Godot 709 source (review)")
        run("git", "push", "origin", "HEAD:refs/heads/" + TARGET_BRANCH)
        print("Restored to", TARGET_BRANCH, "for review. No changes made to main.")


if __name__ == "__main__":
    main()
