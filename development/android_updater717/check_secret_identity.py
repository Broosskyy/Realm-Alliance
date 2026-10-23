#!/usr/bin/env python3
"""Fail fast if Actions has an absent/mismatched private signing identity.

Never print or upload keystore bytes or passwords. Only the public certificate
fingerprint is compared to the committed identity of the installed test app.
"""
import base64
import hashlib
import os
from pathlib import Path
import subprocess
import tempfile
import sys

EXPECTED = "317eb8e2e5bf1c8a5bd8b0433a7536bcc903da97d5ba437c20e9474cdd4af219"

def main():
    raw=os.environ.get("REALM_ANDROID_KEYSTORE_BASE64","").strip()
    if not raw:
        raise SystemExit("SIGNER_MISSING: Configure REALM_ANDROID_KEYSTORE_BASE64 in Actions secrets.")
    try:
        data=base64.b64decode("".join(raw.split()),validate=True)
    except Exception:
        raise SystemExit("SIGNER_BAD_ENCODING: Secret must be complete Base64 of existing 709 test keystore.")
    if len(data)<100 or len(data)>50000:
        raise SystemExit("SIGNER_BAD_LENGTH: Supplied key data not a valid test-keystore size.")
    with tempfile.TemporaryDirectory(prefix="realm-sign-check-") as tmp:
        path=Path(tmp)/"private.keystore"
        path.write_bytes(data)
        path.chmod(0o600)
        password=os.environ.get("REALM_ANDROID_KEYSTORE_PASSWORD","android")
        alias=os.environ.get("REALM_ANDROID_KEY_ALIAS","androiddebugkey")
        env=os.environ.copy()
        env["REALM_ANDROID_KEYSTORE_PASSWORD"]=password
        call=subprocess.run(["keytool","-exportcert","-keystore",str(path),"-alias",alias,
                         "-storepass:env","REALM_ANDROID_KEYSTORE_PASSWORD"],env=env,
                         capture_output=True)
        if call.returncode!=0:
            raise SystemExit("SIGNER_ALIAS_OR_PASSWORD_INVALID: Check configured alias/password.")
        actual=hashlib.sha256(call.stdout).hexdigest()
        if actual!=EXPECTED:
            raise SystemExit(
                "SIGNER_MISMATCH: Actions secret has certificate "+actual+
                "; installed test application requires "+EXPECTED+
                ". Replace GitHub Actions secret using verified original keystore, never create a new key."
            )
    print("REALM_SIGNER_CHECK_PASS: original test-app signing certificate verified.")

if __name__=="__main__":
    main()
