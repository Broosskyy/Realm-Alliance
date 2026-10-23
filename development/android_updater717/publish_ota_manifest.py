#!/usr/bin/env python3
"""Promote a signed, verified Android release to the existing REALM OTA test channel.

Invoke only AFTER a matching GitHub Release asset is publicly available.
Never publish an unsigned APK or mutate the manifest before verifying the asset.
"""
import base64
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys

REPO = "Broosskyy/Realm-Alliance"
BRANCH = "distribution/realm-715-test"
MANIFEST = "godot/realm_alliance/data/update715_manifest.json"
CERT = "317eb8e2e5bf1c8a5bd8b0433a7536bcc903da97d5ba437c20e9474cdd4af219"
PACKAGE = "com.avenor.realmalliance.mockuptest"

def gh(*arguments, payload=None):
    args = ["gh", "api", *arguments]
    result = subprocess.run(args, input=payload, text=True, capture_output=True, check=False)
    if result.returncode:
        raise RuntimeError("GitHub API action failed: " + result.stderr[:500])
    return json.loads(result.stdout)

def main():
    if len(sys.argv) != 2:
        raise SystemExit("usage: publish_ota_manifest.py <directory-of-signed-release>")
    root = Path(sys.argv[1]).resolve()
    release_data = root / "RELEASE_718.json"
    if not release_data.is_file():
        raise SystemExit("Signed release metadata missing; OTA remains disabled")
    spec = json.loads(release_data.read_text())
    version = int(spec["version_code"])
    if version < 718 or version > 1000000 or spec.get("package") != PACKAGE or spec.get("certificate_sha256") != CERT or spec.get("signed") is not True:
        raise SystemExit("Unexpected app version, package, certificate, or signature")
    filename = f"REALM_ALLIANCE_{version}.apk"
    path = root / filename
    expected = hashlib.sha256(path.read_bytes()).hexdigest()
    if expected != spec["sha256"] or path.stat().st_size != spec["bytes"]:
        raise SystemExit("Local signed APK does not match verified release metadata")
    tag = f"realm-{version}-android"
    release = gh(f"repos/{REPO}/releases/tags/{tag}")
    asset = next((a for a in release.get("assets", []) if a.get("name") == filename), None)
    url = f"https://github.com/{REPO}/releases/download/{tag}/{filename}"
    if asset is None or int(asset["size"]) != int(spec["bytes"]) or asset["browser_download_url"] != url:
        raise SystemExit("Release asset not present or size/URL incorrect. OTA remains disabled")

    # GitHub contents API provides optimistic locking by blob SHA.
    fileinfo = gh(f"repos/{REPO}/contents/{MANIFEST}?ref={BRANCH}")
    old = json.loads(base64.b64decode(fileinfo["content"]).decode("utf-8"))
    if old.get("schema") != 3 or old.get("channel") != "test":
        raise SystemExit("Wrong distribution channel: refusing to publish")
    current = int(old.get("latest_app_version_code", 0))
    if current > version:
        raise SystemExit("Refusing to roll back users to an older APK")
    info = {
        "version_code": version,
        "package": PACKAGE,
        "certificate_sha256": CERT,
        "bytes": int(spec["bytes"]),
        "sha256": expected,
        "url": url
    }
    if current == version and old.get("app_update") == info:
        print("REALM_OTA_MANIFEST_ALREADY_CURRENT", version)
        return
    # The unrelated PNG/JSON content manifests, min version and user saves stay unchanged.
    old["latest_app_version_code"] = version
    old["app_update"] = info
    old["release_notes"] = f"REALM ALLIANCE {version}: Android update through launcher. Content packs unchanged."
    payload = json.dumps({
        "message": f"release: activate signed Android {version} OTA update for 717+",
        "content": base64.b64encode((json.dumps(old, indent=2, ensure_ascii=False)+"\n").encode("utf-8")).decode("ascii"),
        "sha": fileinfo["sha"],
        "branch": BRANCH,
    })
    gh("-X", "PUT", f"repos/{REPO}/contents/{MANIFEST}", "--input", "-", payload=payload)
    check = gh(f"repos/{REPO}/contents/{MANIFEST}?ref={BRANCH}")
    verified = json.loads(base64.b64decode(check["content"]))
    if verified.get("app_update") != info:
        raise RuntimeError("Distribution manifest did not match expected OTA metadata")
    print("REALM_OTA_MANIFEST_PUBLISHED", version, "release tag", tag)

if __name__ == "__main__":
    main()
