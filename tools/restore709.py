#!/usr/bin/env python3
"""Reconstitute verified 709 multipart archives into an isolated review branch.
The source ZIP was sanitized before upload to exclude Android signing keys.
"""
from __future__ import annotations
import hashlib
import os
from pathlib import Path, PurePosixPath
import shutil
import subprocess
from tempfile import TemporaryDirectory
from zipfile import ZipFile

ROOT = Path(__file__).resolve().parents[1]
BACKUP = Path("backup/pre-709-main-20261020")
REVIEW_BRANCH = "restore/realm709-full"
CHUNKS = {
  "source": ([f"REALM_709_Quellen_GitHub_sicher.part{i:02d}-of-05" for i in range(1, 6)],
             94680643, "7fab33ffe228ec4fbb1f25d542380833d52ed4b213f925a80a33f27b4c72e980"),
  "web": ([f"REALM_709_Web.part{i:02d}-of-03" for i in range(1, 4)],
          54300459, "7c650963e6b9ca94080fc031f5040ab22c99b435ec20e71f1ba58ff7338f82ba"),
}
KEPT_TOOLS = {".github/workflows/restore-709-main.yml", "tools/restore709.py"}

def run(*args):
    subprocess.run(args, cwd=ROOT, check=True)

def read_zip(kind: str, destination: Path) -> ZipFile:
    parts, expected_bytes, expected_sha = CHUNKS[kind]
    digest = hashlib.sha256()
    size = 0
    with destination.open("wb") as target:
        for name in parts:
            with (ROOT / name).open("rb") as source:
                while block := source.read(1024 * 1024):
                    digest.update(block)
                    size += len(block)
                    target.write(block)
    if size != expected_bytes or digest.hexdigest() != expected_sha:
        raise ValueError(f"{kind} checksum mismatch; refusing to edit repository")
    archive = ZipFile(destination)
    if archive.testzip() is not None:
        raise ValueError(f"{kind} ZIP CRC check failed")
    for entry in archive.infolist():
        path = PurePosixPath(entry.filename)
        if path.is_absolute() or ".." in path.parts or not path.parts:
            raise ValueError(f"Unsafe ZIP path: {entry.filename}")
        if ((entry.external_attr >> 16) & 0o170000) == 0o120000:
            raise ValueError(f"Symlink ZIP entry: {entry.filename}")
        if any(x in entry.filename.lower() for x in (".keystore", ".jks", ".env", ".pem", ".sqlite")):
            raise ValueError(f"Potentially confidential entry: {entry.filename}")
        if kind == "source" and path.parts[0] != "Source":
            raise ValueError(f"Unexpected source layout: {entry.filename}")
    print(f"{kind}: verified {len(archive.infolist())} ZIP members, SHA256={expected_sha}")
    return archive

def main():
    if os.environ.get("GITHUB_REF") != "refs/heads/main":
        raise RuntimeError("Must start from main to take exact pre-restore backup")
    for _, (parts, _, _) in CHUNKS.items():
        for filename in parts:
            if not (ROOT / filename).is_file():
                raise RuntimeError(f"Missing GitHub part: {filename}")
    with TemporaryDirectory(prefix="realm709_") as td:
        temporary = Path(td)
        source = read_zip("source", temporary / "source.zip")
        web = read_zip("web", temporary / "web.zip")
        if "Source/godot/realm_alliance/project.godot" not in source.namelist():
            raise RuntimeError("Godot project missing")
        if "Source/BUILD_INFO.json" not in source.namelist():
            raise RuntimeError("Build information missing")
        if "index.pck" not in web.namelist() or "index.wasm" not in web.namelist():
            raise RuntimeError("Web runtime missing")
        run("git", "checkout", "-b", REVIEW_BRANCH)
        run("git", "config", "user.name", "github-actions[bot]")
        run("git", "config", "user.email", "41898282+github-actions[bot]@users.noreply.github.com")
        tracked = subprocess.check_output(["git", "ls-files", "-z"], cwd=ROOT).decode().split("\0")
        chunk_names = {name for parts, _, _ in CHUNKS.values() for name in parts}
        for item in sorted((x for x in tracked if x), key=lambda x: x.count("/"), reverse=True):
            if item in chunk_names or item in KEPT_TOOLS:
                continue
            dest = BACKUP / item
            (ROOT / dest).parent.mkdir(parents=True, exist_ok=True)
            if item.startswith(".github/workflows/"):
                # GitHub's scoped Actions token cannot remove or alter live workflows.
                # Keep them unchanged and separately back them up in the same folder.
                shutil.copy2(ROOT / item, ROOT / dest)
            else:
                run("git", "mv", item, str(dest))
        for member in source.infolist():
            if member.is_dir():
                continue
            rel = PurePosixPath(member.filename).relative_to("Source")
            # Do not modify .github/workflows with a token lacking workflow scope.
            # Preserve every ZIP member, but store historical workflow definitions inertly.
            if rel.parts[:2] == (".github", "workflows"):
                target = ROOT / "restore_metadata" / "709-source-workflows" / rel.name
            else:
                target = ROOT.joinpath(*rel.parts)
            target.parent.mkdir(parents=True, exist_ok=True)
            with source.open(member) as s, target.open("wb") as d:
                shutil.copyfileobj(s, d)
        for member in web.infolist():
            if member.is_dir():
                continue
            target = ROOT / "web_build" / "709" / Path(member.filename)
            target.parent.mkdir(parents=True, exist_ok=True)
            with web.open(member) as s, target.open("wb") as d:
                shutil.copyfileobj(s, d)
        source.close()
        web.close()
    # Original source .gitignore excluded the artwork and Godot resource UIDs;
    # these are actually required for a complete build and now committed as real files.
    ignore = ROOT / ".gitignore"
    old = ignore.read_text(encoding="utf8")
    lines = [line for line in old.splitlines()
             if line.strip() not in ("**/*.uid", "/godot/realm_alliance/assets/production/")]
    lines.extend(["**/*.keystore", "**/*.jks", "**/.env", "**/.env.*", "**/*.pem", "**/*.p12", "**/*.pfx", "**/.godot/"])
    ignore.write_text("\n".join(dict.fromkeys(lines)) + "\n", encoding="utf8")
    (ROOT / "RESTORE_709.md").write_text(
        "# REALM ALLIANCE · 709 restored\n\n"
        "Version 709 restored from all eight GitHub-uploaded parts. "
        "Sources are at repository root. The complete runnable Godot Web export is in "
        "web_build/709/. Pre-709 tracked files are under backup/pre-709-main-20261020/.\n\n"
        "The multipart binary files have been removed from the working tree after "
        "checksum verification, but remain available in the original Git history.\n\n"
        "Android signing keystore was intentionally excluded from public GitHub. "
        "The original owner-provided full source archive must be retained privately "
        "to preserve Android APK update signing.\n\n"
        "Original GitHub main was not modified by this restoration job. "
        "Review the branch before fast-forwarding main.\n",
        encoding="utf8",
    )
    # Keep the job workflow and script at stable paths. Remove multipart uploads
    # only from the new tree (their original blobs remain in Git history).
    for names, _, _ in CHUNKS.values():
        for name in names:
            run("git", "rm", "--", name)
    run("git", "add", "-A", "-f")
    run("git", "commit", "-m", "restore: verified 709 sources and web; archive previous main")
    run("git", "push", "origin", f"HEAD:refs/heads/{REVIEW_BRANCH}")
    print("SUCCESS:", REVIEW_BRANCH)

if __name__ == "__main__":
    main()
