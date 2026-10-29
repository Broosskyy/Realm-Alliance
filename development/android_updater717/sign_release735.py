#!/usr/bin/env python3
"""Fail-closed signing of Realm 735 with the original update identity.

Keep stdout (binary X.509 DER) separate from stderr: keytool emits JKS
migration warnings to stderr, which MUST NOT be included in the SHA256 digest.
"""
import base64
import hashlib
import json
import os
import pathlib
import subprocess
import sys
import tempfile

CERT = "317eb8e2e5bf1c8a5bd8b0433a7536bcc903da97d5ba437c20e9474cdd4af219"
PKG = "com.avenor.realmalliance.mockuptest"
VERSION = 735

def run(*args):
    return subprocess.check_output(list(args), stderr=subprocess.PIPE)

def main():
    if len(sys.argv) != 2:
        raise SystemExit("usage: sign_release735.py <artifact-directory>")
    root = pathlib.Path(sys.argv[1]).resolve()
    unsigned = root / "REALM_ALLIANCE_735_aligned_unsigned.apk"
    out = root / "REALM_ALLIANCE_735.apk"
    signerjar = root / "apksigner.jar"
    raw = os.environ.get("REALM_ANDROID_KEYSTORE_BASE64", "")
    if not raw:
        raise SystemExit("Signing secret REALM_ANDROID_KEYSTORE_BASE64 absent: no release will be published")
    if not unsigned.is_file() or not signerjar.is_file():
        raise SystemExit("Required checked native APK/signing utility missing")
    password = os.environ.get("REALM_ANDROID_KEYSTORE_PASSWORD", "android")
    alias = os.environ.get("REALM_ANDROID_KEY_ALIAS", "androiddebugkey")
    os.environ["REALM_ANDROID_KEYSTORE_PASSWORD"] = password
    os.environ["REALM_ANDROID_KEY_PASSWORD"] = os.environ.get("REALM_ANDROID_KEY_PASSWORD", password)
    with tempfile.TemporaryDirectory(prefix="realm735-sign-") as tmp:
        key = pathlib.Path(tmp) / "private.keystore"
        key.write_bytes(base64.b64decode("".join(raw.split()), validate=True))
        key.chmod(0o600)
        exported = run("keytool", "-exportcert", "-keystore", str(key), "-alias", alias,
                       "-storepass:env", "REALM_ANDROID_KEYSTORE_PASSWORD")
        if hashlib.sha256(exported).hexdigest() != CERT:
            raise SystemExit("Wrong certificate: refusing to create update-incompatible APK")
        run("java", "-jar", str(signerjar), "sign", "--ks", str(key),
            "--ks-key-alias", alias, "--ks-pass", "env:REALM_ANDROID_KEYSTORE_PASSWORD",
            "--key-pass", "env:REALM_ANDROID_KEY_PASSWORD", "--out", str(out), str(unsigned))
    inspection = run("java", "-jar", str(signerjar), "verify", "--verbose", "--print-certs", str(out)).decode("utf-8")
    if CERT not in inspection.lower() or "Verified using v2 scheme" not in inspection:
        raise SystemExit("APK signature verification failed")
    if out.stat().st_size < 1_000_000:
        raise SystemExit("Unexpected APK length")
    details = {"version_code": VERSION, "package": PKG, "bytes": out.stat().st_size,
               "sha256": hashlib.sha256(out.read_bytes()).hexdigest(),
               "certificate_sha256": CERT, "signed": True, "release_tag": "realm-735-android"}
    (root / "RELEASE_735.json").write_text(json.dumps(details, indent=2) + "\n")
    print("REALM735_SIGNING_VERIFIED version_code=735 certificate_matches_existing_application=True")
    print("sha256=" + details["sha256"])
    print("bytes=" + str(details["bytes"]))

if __name__ == "__main__":
    main()
