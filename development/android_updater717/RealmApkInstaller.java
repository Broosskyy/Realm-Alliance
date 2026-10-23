package com.avenor.realmupdater;

import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.Signature;
import android.net.Uri;
import android.os.Build;
import android.provider.Settings;
import androidx.core.content.FileProvider;
import org.godotengine.godot.Godot;
import org.godotengine.godot.plugin.GodotPlugin;
import org.godotengine.godot.plugin.UsedByGodot;
import java.io.File;
import java.security.MessageDigest;

/** Platform package validation happens AFTER GDScript SHA256 and BEFORE Android installer. */
public final class RealmApkInstaller extends GodotPlugin {
    private static final String GAME_ID = "com.avenor.realmalliance.mockuptest";
    private static final String TRUSTED_CERT = "317eb8e2e5bf1c8a5bd8b0433a7536bcc903da97d5ba437c20e9474cdd4af219";

    public RealmApkInstaller(Godot godot) {
        super(godot);
    }

    @Override
    public String getPluginName() {
        return "RealmApkInstaller";
    }

    @UsedByGodot
    public String installValidatedApk(String absolutePath, int requestedVersion) {
        final Activity activity = getActivity();
        if (activity == null) return "activity_missing";
        try {
            if (!GAME_ID.equals(activity.getPackageName())) return "wrong_installed_package";
            final File internalRoot = new File(activity.getFilesDir(), "realm_apk_updater").getCanonicalFile();
            final File externalBase = activity.getExternalFilesDir(null);
            final File externalRoot = externalBase == null ? null : new File(externalBase, "realm_apk_updater").getCanonicalFile();
            final File apk = new File(absolutePath).getCanonicalFile();
            final boolean approved = apk.getPath().startsWith(internalRoot.getPath() + File.separator)
                    || (externalRoot != null && apk.getPath().startsWith(externalRoot.getPath() + File.separator));
            if (!approved
                    || !apk.getName().endsWith(".apk")
                    || !apk.isFile() || apk.length() < 1000000L || apk.length() > 350000000L) {
                return "untrusted_path_or_size";
            }
            if (requestedVersion <= 0 || requestedVersion > 1000000) return "invalid_version";
            final PackageManager pm = activity.getPackageManager();
            final PackageInfo archive;
            if (Build.VERSION.SDK_INT >= 28) {
                archive = pm.getPackageArchiveInfo(apk.getPath(), PackageManager.GET_SIGNING_CERTIFICATES);
            } else {
                archive = pm.getPackageArchiveInfo(apk.getPath(), PackageManager.GET_SIGNATURES);
            }
            if (archive == null || !GAME_ID.equals(archive.packageName)) return "wrong_apk_package";
            final long apkVersion = Build.VERSION.SDK_INT >= 28 ? archive.getLongVersionCode() : archive.versionCode;
            final PackageInfo installed = pm.getPackageInfo(GAME_ID, 0);
            final long installedVersion = Build.VERSION.SDK_INT >= 28 ? installed.getLongVersionCode() : installed.versionCode;
            if (apkVersion != requestedVersion || apkVersion <= installedVersion) return "wrong_apk_version";
            Signature[] signers;
            if (Build.VERSION.SDK_INT >= 28) {
                signers = archive.signingInfo != null ? archive.signingInfo.getApkContentsSigners() : null;
            } else {
                signers = archive.signatures;
            }
            if (signers == null || signers.length != 1) return "invalid_apk_signature";
            final byte[] fingerprint = MessageDigest.getInstance("SHA-256").digest(signers[0].toByteArray());
            if (!TRUSTED_CERT.equals(toHex(fingerprint))) return "certificate_mismatch";
            if (Build.VERSION.SDK_INT >= 26 && !pm.canRequestPackageInstalls()) {
                Intent allow = new Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES);
                allow.setData(Uri.parse("package:" + GAME_ID));
                activity.startActivity(allow);
                return "permission_required";
            }
            Uri contentUri = FileProvider.getUriForFile(
                activity, GAME_ID + ".realmupdater.files", apk);
            Intent install = new Intent(Intent.ACTION_VIEW);
            install.setDataAndType(contentUri, "application/vnd.android.package-archive");
            install.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_GRANT_READ_URI_PERMISSION);
            activity.startActivity(install);
            return "installer_opened";
        } catch (ActivityNotFoundException error) {
            return "system_installer_unavailable";
        } catch (Exception error) {
            // No private paths, URLs, or credentials are returned through GDScript.
            return "android_validation_failed";
        }
    }

    private static String toHex(byte[] raw) {
        final char[] out = new char[raw.length * 2];
        final char[] symbols = "0123456789abcdef".toCharArray();
        for (int i = 0; i < raw.length; i++) {
            out[i * 2] = symbols[(raw[i] >> 4) & 15];
            out[i * 2 + 1] = symbols[raw[i] & 15];
        }
        return new String(out);
    }
}
