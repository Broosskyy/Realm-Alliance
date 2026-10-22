#!/usr/bin/env python3
"""Inject the Java bridge into official Godot 4.7.2 Android Gradle template.

This script runs in CI on the *generated* project, not on committed engine files.
The private APK signing key is never needed by this step.
"""
from pathlib import Path
import shutil
import sys

project = Path(sys.argv[1]).resolve()
source = Path(__file__).resolve().parent
app = project / "src/main"
assert (app / "AndroidManifest.xml").exists(), f"Missing Gradle template manifest: {app}"
java = app / "java/com/avenor/realmupdater/RealmApkInstaller.java"
java.parent.mkdir(parents=True, exist_ok=True)
shutil.copy2(source / "RealmApkInstaller.java", java)
res = app / "res/xml/realm_apk_paths.xml"
res.parent.mkdir(parents=True, exist_ok=True)
shutil.copy2(source / "realm_apk_paths.xml", res)

manifest = app / "AndroidManifest.xml"
content = manifest.read_text()
assert 'xmlns:android=' in content
assert '<application' in content and '</application>' in content
assert "org.godotengine.plugin.v2.RealmApkInstaller" not in content
new_permission = '<uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />'
content = content.replace('<application', new_permission + '\n    <application', 1)
provider = '''<meta-data android:name="org.godotengine.plugin.v2.RealmApkInstaller"
                android:value="com.avenor.realmupdater.RealmApkInstaller" />
            <provider android:name="androidx.core.content.FileProvider"
                android:authorities="${applicationId}.realmupdater.files"
                android:exported="false"
                android:grantUriPermissions="true">
                <meta-data android:name="android.support.FILE_PROVIDER_PATHS"
                    android:resource="@xml/realm_apk_paths" />
            </provider>'''
content = content.replace("</application>", provider + '\n    </application>', 1)
manifest.write_text(content)

gradle = project / "build.gradle"
contents = gradle.read_text()
assert "dependencies {" in contents, "Missing Gradle app dependencies block"
contents = contents.replace("dependencies {", "dependencies {\n    implementation 'androidx.core:core:1.15.0'", 1)
gradle.write_text(contents)
assert "installValidatedApk" in java.read_text()
print("REALM_717_NATIVE_INSTALLER_PATCHED", app)
