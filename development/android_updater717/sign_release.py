#!/usr/bin/env python3
"""Sign a REALM Android release using the existing private Android signing identity.

Requires REALM_ANDROID_KEYSTORE_BASE64 as an Actions secret. Never prints or
publishes the keystore. A bad/missing key fails closed.
"""
import base64, hashlib, json, os, pathlib, subprocess, sys, tempfile
CERT="317eb8e2e5bf1c8a5bd8b0433a7536bcc903da97d5ba437c20e9474cdd4af219"
PKG="com.avenor.realmalliance.mockuptest"
def command(*args):
    return subprocess.check_output(list(args),stderr=subprocess.STDOUT)
def main():
    if len(sys.argv)!=2:raise SystemExit("usage: sign_release.py <APK-artifact-directory>")
    version=int(os.environ["REALM_VERSION"])
    if version<718 or version>1000000:raise SystemExit("Invalid Android versionCode")
    root=pathlib.Path(sys.argv[1]).resolve()
    unsigned=root/f"REALM_ALLIANCE_{version}_aligned_unsigned.apk"
    output=root/f"REALM_ALLIANCE_{version}.apk"
    signerjar=root/"apksigner.jar"
    raw=os.environ.get("REALM_ANDROID_KEYSTORE_BASE64","")
    if not raw:raise SystemExit("GitHub Actions secret REALM_ANDROID_KEYSTORE_BASE64 missing: no release.")
    if not unsigned.is_file() or not signerjar.is_file():raise SystemExit("Verified native APK or signer missing")
    password=os.environ.get("REALM_ANDROID_KEYSTORE_PASSWORD","android")
    alias=os.environ.get("REALM_ANDROID_KEY_ALIAS","androiddebugkey")
    os.environ["REALM_ANDROID_KEYSTORE_PASSWORD"]=password
    os.environ["REALM_ANDROID_KEY_PASSWORD"]=os.environ.get("REALM_ANDROID_KEY_PASSWORD",password)
    with tempfile.TemporaryDirectory(prefix="realm-private-signer-") as folder:
        key=pathlib.Path(folder)/"signer.keystore"
        key.write_bytes(base64.b64decode("".join(raw.split()),validate=True))
        key.chmod(0o600)
        certificate=command("keytool","-exportcert","-keystore",str(key),
            "-alias",alias,"-storepass:env","REALM_ANDROID_KEYSTORE_PASSWORD")
        if hashlib.sha256(certificate).hexdigest()!=CERT:
            raise SystemExit("Original REALM certificate mismatch; refusing incompatible APK.")
        command("java","-jar",str(signerjar),"sign","--ks",str(key),
            "--ks-key-alias",alias,"--ks-pass","env:REALM_ANDROID_KEYSTORE_PASSWORD",
            "--key-pass","env:REALM_ANDROID_KEY_PASSWORD","--out",str(output),str(unsigned))
    verify=command("java","-jar",str(signerjar),"verify","--verbose",
        "--print-certs",str(output)).decode("utf-8")
    if CERT not in verify.lower() or "Verified using v2 scheme" not in verify:
        raise SystemExit("Signed APK did not verify with the original certificate")
    if not (1_000_000 < output.stat().st_size < 350_000_000):
        raise SystemExit("Unacceptable signed APK size")
    metadata={"version_code":version,"package":PKG,"bytes":output.stat().st_size,
      "sha256":hashlib.sha256(output.read_bytes()).hexdigest(),
      "certificate_sha256":CERT,"signed":True,
      "release_tag":f"realm-{version}-android"}
    (root/f"RELEASE_{version}.json").write_text(json.dumps(metadata,indent=2)+"\n")
    print("REALM_ANDROID_RELEASE_VERIFIED",version,"same_app_identity",True,
        "bytes",metadata["bytes"])
if __name__=="__main__":main()
