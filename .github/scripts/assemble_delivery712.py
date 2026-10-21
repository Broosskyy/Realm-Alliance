"""Restore a checked 712 APK from small committed transfer parts."""
import argparse
import hashlib
import json
from pathlib import Path
import zipfile

def assemble(manifest_path, destination):
    manifest_path = Path(manifest_path).resolve()
    manifest = json.loads(manifest_path.read_text())
    if manifest["version"] != 712 or not manifest["parts"]:
        raise ValueError("Invalid 712 delivery manifest")
    root = manifest_path.parent
    destination = Path(destination).resolve()
    destination.mkdir(parents=True, exist_ok=True)
    temporary = destination / "REALM_ALLIANCE_712.apk.partial"
    output = destination / "REALM_ALLIANCE_712.apk"
    with temporary.open("wb") as target:
        for part in manifest["parts"]:
            name = part["name"]
            if Path(name).name != name or not name.startswith("apk.part"):
                raise ValueError("Invalid transfer-part path")
            data = (root / name).read_bytes()
            if len(data) != part["bytes"] or hashlib.sha256(data).hexdigest() != part["sha256"]:
                raise ValueError("Transfer-part integrity failed: " + name)
            target.write(data)
    data = temporary.read_bytes()
    if len(data) != manifest["apk"]["size_bytes"] or hashlib.sha256(data).hexdigest() != manifest["apk"]["sha256"]:
        raise ValueError("APK integrity failed")
    with zipfile.ZipFile(temporary) as archive:
        if archive.testzip() is not None:
            raise ValueError("APK ZIP integrity failed")
    temporary.replace(output)
    (destination / "APK_712.json").write_text(json.dumps(manifest["apk"], indent=2) + "\n")
    return output

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--manifest", required=True)
    parser.add_argument("--output", required=True)
    args = parser.parse_args()
    print(assemble(args.manifest, args.output))
