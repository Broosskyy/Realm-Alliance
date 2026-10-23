#!/usr/bin/env python3
"""One-time, LOCAL setup of encrypted GitHub Actions signing secret.

Usage:
  python setup_signing_secret.py /path/to/REALM_ALLIANCE_709_Quellen.zip

Requires: Python, Java keytool, authenticated GitHub CLI (gh auth login).
The keystore is read from the user's local zip and sent *only* as an encrypted
GitHub Actions secret using gh. It is never printed or added to a git commit.
"""
import base64, hashlib, os, pathlib, shutil, subprocess, sys, tempfile, zipfile
REPO="Broosskyy/Realm-Alliance"
TARGET="Source/development/realm-preview-debug.keystore"
CERT="317eb8e2e5bf1c8a5bd8b0433a7536bcc903da97d5ba437c20e9474cdd4af219"

def main():
    if len(sys.argv)!=2:
        raise SystemExit("Usage: python setup_signing_secret.py <REALM_ALLIANCE_709_Quellen.zip>")
    if not shutil.which("gh"):
        raise SystemExit("GitHub CLI (gh) fehlt. Erst installieren und 'gh auth login' ausführen.")
    if not shutil.which("keytool"):
        raise SystemExit("Java keytool fehlt. Bitte Java JDK 17 installieren.")
    path=pathlib.Path(sys.argv[1])
    if not path.is_file():raise SystemExit("Die angegebene lokale 709 ZIP wurde nicht gefunden.")
    with zipfile.ZipFile(path) as archive:
        matches=[x for x in archive.infolist() if x.filename.endswith(TARGET)]
        if len(matches)!=1 or not (500<=matches[0].file_size<=16384):
            raise SystemExit("Der originale 709 Signierschlüssel wurde im Quellarchiv nicht eindeutig gefunden.")
        data=archive.read(matches[0])
    # Validate the certificate BEFORE granting GitHub Actions access.
    with tempfile.TemporaryDirectory(prefix="realm-signcheck-") as temp:
        store=pathlib.Path(temp)/"signer.keystore"
        store.write_bytes(data);store.chmod(0o600)
        env=os.environ.copy()
        env["REALM_ANDROID_KEYSTORE_PASSWORD"]=env.get("REALM_ANDROID_KEYSTORE_PASSWORD","android")
        alias=env.get("REALM_ANDROID_KEY_ALIAS","androiddebugkey")
        try:
            cert=subprocess.check_output(["keytool","-exportcert","-keystore",str(store),
                "-alias",alias,"-storepass:env","REALM_ANDROID_KEYSTORE_PASSWORD"],
                env=env,stderr=subprocess.DEVNULL)
        except subprocess.CalledProcessError:
            raise SystemExit("Der Keystore konnte nicht geprüft werden (Alias/Passwort?).")
    if hashlib.sha256(cert).hexdigest()!=CERT:
        raise SystemExit("Falsches Signaturzertifikat! Es wurde NICHTS hochgeladen.")
    try:
        subprocess.run(["gh","auth","status"],check=True,stdout=subprocess.DEVNULL)
        subprocess.run(["gh","secret","set","REALM_ANDROID_KEYSTORE_BASE64",
            "--repo",REPO],input=base64.b64encode(data),check=True)
    except (subprocess.CalledProcessError,FileNotFoundError):
        raise SystemExit("GitHub Secret konnte nicht gesetzt werden. Bitte 'gh auth login' prüfen.")
    print("Erfolg: passender REALM-Signierschlüssel als verschlüsseltes GitHub-Actions-Secret hinterlegt.")
    print("Nie die Keystore-Datei oder deren Base64-Inhalt in Chats oder Commits veröffentlichen.")
if __name__=="__main__":main()
