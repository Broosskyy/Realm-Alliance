#!/usr/bin/env python3
"""Update trusted content manifest after a signed GitHub Release exists.

Never publish OTA metadata before GitHub has accepted the signed release APK.
This script operates on a checked-out copy of distribution/realm-715-test.
"""
import json, pathlib, re, sys, os
PKG="com.avenor.realmalliance.mockuptest"
CERT="317eb8e2e5bf1c8a5bd8b0433a7536bcc903da97d5ba437c20e9474cdd4af219"
ROOT="https://github.com/Broosskyy/Realm-Alliance/releases/download/"
def apply(signed:dict,manifest:dict)->dict:
    v=signed.get("version_code")
    if not isinstance(v,int) or isinstance(v,bool) or v<718 or v>1000000:
        raise ValueError("Invalid target version")
    if signed.get("signed") is not True or signed.get("package")!=PKG or signed.get("certificate_sha256")!=CERT:
        raise ValueError("App signing identity / signing verification absent")
    if signed.get("release_tag")!=f"realm-{v}-android":
        raise ValueError("Release tag mismatch")
    size=signed.get("bytes")
    if not isinstance(size,int) or isinstance(size,bool) or not (1_000_000<size<350_000_000):
        raise ValueError("APK size invalid")
    digest=signed.get("sha256")
    if not isinstance(digest,str) or re.fullmatch(r"[0-9a-f]{64}",digest) is None:
        raise ValueError("APK SHA256 invalid")
    if manifest.get("schema")!=3 or manifest.get("channel")!="test":
        raise ValueError("Unexpected content channel/schema")
    current=manifest.get("latest_app_version_code")
    if not isinstance(current,int) or current>v:
        raise ValueError("Manifest newer than release: refusing rollback")
    if not isinstance(manifest.get("packs"),list) or len(manifest["packs"])!=2:
        raise ValueError("No original content packs; do not erase game content")
    result=dict(manifest)
    result["latest_app_version_code"]=v
    result["app_update"]={
       "version_code":v,"package":PKG,"certificate_sha256":CERT,
       "bytes":size,"sha256":digest,
       "url":ROOT+f"realm-{v}-android/REALM_ALLIANCE_{v}.apk"}
    result["release_notes"]=f"Android-App-Update {v} verfügbar; vorhandene PNG/JSON-Spielinhalte bleiben unverändert."
    return result
def main():
    if len(sys.argv) not in (3,4):
        raise SystemExit("Usage: publish_release_manifest.py <RELEASE_NNN.json> <manifest.json> [--check-only]")
    release=pathlib.Path(sys.argv[1]);target=pathlib.Path(sys.argv[2])
    result=apply(json.loads(release.read_text()),json.loads(target.read_text()))
    if len(sys.argv)==4 and sys.argv[3]=="--check-only":
        print("MANIFEST_VALID",result["latest_app_version_code"]);return
    if len(sys.argv)!=3:raise SystemExit("Invalid optional flag")
    target.write_text(json.dumps(result,indent=2,ensure_ascii=False)+"\n")
    print("OTA_MANIFEST_PUBLISHED",result["latest_app_version_code"])
if __name__=="__main__":main()
