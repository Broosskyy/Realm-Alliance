"""Build a 711 update APK using the original 709 certificate; never create keys."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import zipfile

EXPECTED_CERT = "317eb8e2e5bf1c8a5bd8b0433a7536bcc903da97d5ba437c20e9474cdd4af219"
PACKAGE = "com.avenor.realmalliance.mockuptest"

def run(args, **kwargs):
    return subprocess.run([str(x) for x in args], check=True, **kwargs)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--godot", required=True)
    parser.add_argument("--keystore", required=True)
    parser.add_argument("--output", required=True)
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[2]
    project = root / "godot/realm_alliance"
    key = Path(args.keystore).resolve()
    if not key.is_file():
        raise SystemExit("Original signing keystore is missing. No replacement will be generated.")
    alias = os.environ.get("REALM_ANDROID_KEY_ALIAS") or "androiddebugkey"
    password = os.environ.get("REALM_ANDROID_KEYSTORE_PASSWORD") or "android"
    env = dict(os.environ, REALM_ANDROID_KEYSTORE_PASSWORD=password)
    certificate = run([
        "keytool", "-exportcert", "-keystore", key, "-alias", alias,
        "-storepass:env", "REALM_ANDROID_KEYSTORE_PASSWORD",
    ], env=env, capture_output=True).stdout
    if hashlib.sha256(certificate).hexdigest() != EXPECTED_CERT:
        raise SystemExit("Signing certificate does not match 709. Refusing an incompatible update.")
    sdk = Path(os.environ["ANDROID_HOME"]).resolve()
    java = Path(os.environ["JAVA_HOME"]).resolve()
    tools = sdk / "build-tools/35.0.0"
    for tool in ("apksigner", "aapt", "zipalign"):
        if not (tools / tool).is_file():
            raise SystemExit("Missing Android SDK build tool: " + tool)
    config = Path(os.environ.get("XDG_CONFIG_HOME", str(Path.home() / ".config"))) / "godot"
    config.mkdir(parents=True, exist_ok=True)
    (config / "editor_settings-4.7.tres").write_text(
        '[gd_resource type="EditorSettings" format=3]\n\n[resource]\n'
        + 'export/android/android_sdk_path=' + json.dumps(str(sdk)) + '\n'
        + 'export/android/java_sdk_path=' + json.dumps(str(java)) + '\n'
    )
    env.update({
        "GODOT_ANDROID_KEYSTORE_DEBUG_PATH": str(key),
        "GODOT_ANDROID_KEYSTORE_DEBUG_USER": alias,
        "GODOT_ANDROID_KEYSTORE_DEBUG_PASSWORD": password,
    })
    output = Path(args.output).resolve()
    output.mkdir(parents=True, exist_ok=True)
    apk = output / "REALM_ALLIANCE_711.apk"
    apk.unlink(missing_ok=True)
    base = [args.godot, "--headless", "--path", project]
    run(base + ["--import"], env=env)
    run(base + ["--export-debug", "Android Debug", apk], env=env)
    if not apk.is_file():
        raise SystemExit("Godot did not produce an APK.")
    signature = run([tools / "apksigner", "verify", "--verbose", "--print-certs", apk],
                    capture_output=True, text=True).stdout
    certs = re.findall(r"Signer #\d+ certificate SHA-256 digest: ([0-9a-fA-F]+)", signature)
    if len(certs) != 1 or certs[0].lower() != EXPECTED_CERT:
        raise SystemExit("APK signing identity verification failed.")
    run([tools / "zipalign", "-c", "-P", "16", "4", apk])
    badging = run([tools / "aapt", "dump", "badging", apk],
                  capture_output=True, text=True).stdout
    if not re.search(r"package: name='" + re.escape(PACKAGE) + r"' versionCode='711'", badging):
        raise SystemExit("APK has the wrong application ID or version code.")
    with zipfile.ZipFile(apk) as archive:
        if not any(name.startswith("lib/arm64-v8a/") and name.endswith(".so")
                   for name in archive.namelist()):
            raise SystemExit("APK has no ARM64 native library.")
        if archive.testzip() is not None:
            raise SystemExit("APK ZIP integrity check failed.")
    report = {
        "version": 711, "package": PACKAGE,
        "source_commit": run(["git", "rev-parse", "HEAD"], cwd=root,
                             capture_output=True, text=True).stdout.strip(),
        "apk": apk.name, "size_bytes": apk.stat().st_size,
        "sha256": hashlib.sha256(apk.read_bytes()).hexdigest(),
        "certificate_sha256": EXPECTED_CERT,
        "signature_verified": True, "alignment_verified": True,
        "arm64_verified": True, "android_device_tested": False,
    }
    (output / "APK_711.json").write_text(json.dumps(report, indent=2) + "\n")
    (output / "SHA256_APK_711.txt").write_text(report["sha256"] + "  " + apk.name + "\n")
    print(json.dumps(report, indent=2))

if __name__ == "__main__":
    main()
