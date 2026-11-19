package com.hisabmitra.app

import android.app.Activity
import android.content.Intent
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.ContactsContract
import android.provider.Settings
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.security.MessageDigest

/**
 * Hosts two small platform channels:
 *  - hisabmitra/contacts: system contact picker (no READ_CONTACTS permission;
 *    the picker grants temporary access to the chosen row only).
 *  - hisabmitra/installer: inspect a downloaded APK's package name, version
 *    and signing certificates, and hand it to the system installer. The user
 *    always confirms installation in the Android UI.
 */
class MainActivity : FlutterActivity() {
    private var pendingContactResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger

        MethodChannel(messenger, "hisabmitra/contacts").setMethodCallHandler { call, result ->
            when (call.method) {
                "pickContact" -> pickContact(result)
                else -> result.notImplemented()
            }
        }

        MethodChannel(messenger, "hisabmitra/installer").setMethodCallHandler { call, result ->
            when (call.method) {
                "selfInfo" -> result.success(describe(selfPackageInfo()))
                "inspectApk" -> {
                    val path = call.argument<String>("path")
                    if (path == null) {
                        result.error("bad_args", "path required", null)
                    } else {
                        result.success(inspectApk(path))
                    }
                }
                "canInstall" -> result.success(canRequestInstalls())
                "openInstallSettings" -> {
                    openUnknownSourcesSettings()
                    result.success(null)
                }
                "installApk" -> {
                    val path = call.argument<String>("path")
                    if (path == null) {
                        result.error("bad_args", "path required", null)
                    } else {
                        try {
                            launchInstaller(path)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("install_failed", "Could not open installer", null)
                        }
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    // ---------------------------------------------------------------- contacts

    private fun pickContact(result: MethodChannel.Result) {
        if (pendingContactResult != null) {
            result.error("busy", "Picker already open", null)
            return
        }
        pendingContactResult = result
        val intent = Intent(Intent.ACTION_PICK, ContactsContract.CommonDataKinds.Phone.CONTENT_URI)
        try {
            @Suppress("DEPRECATION")
            startActivityForResult(intent, REQUEST_PICK_CONTACT)
        } catch (e: Exception) {
            pendingContactResult = null
            result.error("unavailable", "No contact picker available", null)
        }
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        @Suppress("DEPRECATION")
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != REQUEST_PICK_CONTACT) return
        val result = pendingContactResult ?: return
        pendingContactResult = null
        val uri = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null) {
            result.success(null)
            return
        }
        try {
            val projection = arrayOf(
                ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME,
                ContactsContract.CommonDataKinds.Phone.NUMBER,
            )
            contentResolver.query(uri, projection, null, null, null)?.use { cursor ->
                if (cursor.moveToFirst()) {
                    val name = cursor.getString(0)
                    val number = cursor.getString(1)
                    result.success(mapOf("name" to name, "phone" to number))
                    return
                }
            }
            result.success(null)
        } catch (e: Exception) {
            result.error("read_failed", "Could not read the selected contact", null)
        }
    }

    // --------------------------------------------------------------- installer

    @Suppress("DEPRECATION")
    private fun selfPackageInfo(): PackageInfo? = try {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            packageManager.getPackageInfo(packageName, PackageManager.GET_SIGNING_CERTIFICATES)
        } else {
            packageManager.getPackageInfo(packageName, PackageManager.GET_SIGNATURES)
        }
    } catch (e: Exception) {
        null
    }

    @Suppress("DEPRECATION")
    private fun inspectApk(path: String): Map<String, Any?>? {
        val info = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            packageManager.getPackageArchiveInfo(path, PackageManager.GET_SIGNING_CERTIFICATES)
        } else {
            packageManager.getPackageArchiveInfo(path, PackageManager.GET_SIGNATURES)
        }
        return describe(info)
    }

    @Suppress("DEPRECATION")
    private fun describe(info: PackageInfo?): Map<String, Any?>? {
        if (info == null) return null
        val signatures = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            val signing = info.signingInfo
            when {
                signing == null -> emptyArray()
                signing.hasMultipleSigners() -> signing.apkContentsSigners
                else -> signing.signingCertificateHistory
            }
        } else {
            info.signatures ?: emptyArray()
        }
        val digests = signatures.map { sig ->
            MessageDigest.getInstance("SHA-256").digest(sig.toByteArray())
                .joinToString("") { "%02x".format(it) }
        }
        val versionCode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            info.longVersionCode
        } else {
            info.versionCode.toLong()
        }
        return mapOf(
            "packageName" to info.packageName,
            "versionName" to info.versionName,
            "versionCode" to versionCode,
            "signers" to digests,
        )
    }

    private fun canRequestInstalls(): Boolean =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            packageManager.canRequestPackageInstalls()
        } else {
            true
        }

    private fun openUnknownSourcesSettings() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val intent = Intent(
                Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
                Uri.parse("package:$packageName"),
            )
            startActivity(intent)
        }
    }

    private fun launchInstaller(path: String) {
        val file = File(path)
        val uri = FileProvider.getUriForFile(this, "$packageName.updates.fileprovider", file)
        val intent = Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(uri, "application/vnd.android.package-archive")
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        startActivity(intent)
    }

    companion object {
        private const val REQUEST_PICK_CONTACT = 4201
    }
}
