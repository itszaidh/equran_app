package com.app.equran

import android.Manifest
import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.util.Log
import android.view.WindowManager
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : AudioServiceActivity() {
    private val channelName = "com.app.equran/read_page"
    private val frameRateHintChannelName = "equran/frame_rate_hints"
    private val notificationPermissionChannelName = "com.app.equran/notification_permissions"
    private val downloadChannelId = "com.app.equran.downloads"
    private val downloadChannelName = "Audio Downloads"
    private val refreshRateLogTag = "EquranRefreshRate"
    private val android15Api = 35
    private val prayerNotificationPermissionRequestCode = 4201
    private var pendingPrayerNotificationPermissionResult: MethodChannel.Result? = null
    private var lastRequestedPreferredRefreshRate = 0f
    private var lastRequestedPreferredDisplayModeId = 0
    private var powerSavingsBalancedRequested = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        createDownloadNotificationChannel()

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setKeepScreenOn" -> {
                        val enabled = call.argument<Boolean>("enabled") ?: false
                        runOnUiThread {
                            if (enabled) {
                                window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                            } else {
                                window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                            }
                        }
                        result.success(null)
                    }
                    "showDownloadProgress" -> {
                        val id = call.argument<Int>("id") ?: 1001
                        val title = call.argument<String>("title") ?: "Downloading audio"
                        val progress = call.argument<Int>("progress") ?: 0
                        val max = call.argument<Int>("max") ?: 100
                        val indeterminate = call.argument<Boolean>("indeterminate") ?: false
                        showDownloadProgress(id, title, progress, max, indeterminate)
                        result.success(null)
                    }
                    "completeDownload" -> {
                        val id = call.argument<Int>("id") ?: 1001
                        val title = call.argument<String>("title") ?: "Download complete"
                        completeDownload(id, title)
                        result.success(null)
                    }
                    "failDownload" -> {
                        val id = call.argument<Int>("id") ?: 1001
                        val title = call.argument<String>("title") ?: "Download failed"
                        failDownload(id, title)
                        result.success(null)
                    }
                    "cancelDownloadNotification" -> {
                        val id = call.argument<Int>("id") ?: 1001
                        NotificationManagerCompat.from(this).cancel(id)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, frameRateHintChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setPreferredRefreshRate" -> {
                        val preferredRefreshRate =
                            call.argument<Number>("preferredRefreshRate")?.toFloat() ?: 0f
                        runOnUiThread {
                            applyPreferredRefreshRateHint(preferredRefreshRate)
                            result.success(null)
                        }
                    }
                    "clearPreferredRefreshRate" -> {
                        runOnUiThread {
                            clearPreferredRefreshRateHint()
                            result.success(null)
                        }
                    }
                    "setPowerSavingsBalanced" -> {
                        runOnUiThread {
                            result.success(setPowerSavingsBalancedIfAvailable())
                        }
                    }
                    "debugDiagnostics" -> {
                        val requested =
                            call.argument<Number>("requestedPreferredRefreshRate")?.toFloat()
                        runOnUiThread {
                            result.success(frameRateDiagnostics(requested))
                        }
                    }
                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, notificationPermissionChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "checkNotificationPermission" -> {
                        result.success(notificationPermissionStatus())
                    }
                    "requestNotificationPermission" -> {
                        requestPrayerNotificationPermission(result)
                    }
                    "openNotificationSettings" -> {
                        result.success(openNotificationSettings())
                    }
                    "checkExactAlarmPermission" -> {
                        result.success(exactAlarmPermissionStatus())
                    }
                    "openExactAlarmSettings" -> {
                        result.success(openExactAlarmSettings())
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun applyPreferredRefreshRateHint(preferredRefreshRate: Float) {
        val layoutParams = window.attributes
        val requestedRefreshRate = preferredRefreshRate.coerceAtLeast(0f)
        layoutParams.preferredRefreshRate = requestedRefreshRate
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            layoutParams.preferredDisplayModeId = preferredDisplayModeIdFor(requestedRefreshRate)
        }
        window.attributes = layoutParams
        lastRequestedPreferredRefreshRate = requestedRefreshRate
        lastRequestedPreferredDisplayModeId = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            layoutParams.preferredDisplayModeId
        } else {
            0
        }
        Log.d(
            refreshRateLogTag,
            "Window preferredRefreshRate hint set to ${lastRequestedPreferredRefreshRate}Hz " +
                "displayModeId=$lastRequestedPreferredDisplayModeId"
        )
    }

    private fun clearPreferredRefreshRateHint() {
        val layoutParams = window.attributes
        layoutParams.preferredRefreshRate = 0f
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            layoutParams.preferredDisplayModeId = 0
        }
        window.attributes = layoutParams
        lastRequestedPreferredRefreshRate = 0f
        lastRequestedPreferredDisplayModeId = 0
        Log.d(refreshRateLogTag, "Window preferredRefreshRate hint cleared")
    }

    @Suppress("DEPRECATION")
    private fun preferredDisplayModeIdFor(preferredRefreshRate: Float): Int {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M || preferredRefreshRate <= 0f) return 0

        val modes = windowManager.defaultDisplay.supportedModes
        if (modes.isNullOrEmpty()) return 0

        return modes
            .minWithOrNull(
                compareBy<android.view.Display.Mode> {
                    kotlin.math.abs(it.refreshRate - preferredRefreshRate)
                }.thenBy { it.refreshRate }
            )
            ?.modeId ?: 0
    }

    private fun setPowerSavingsBalancedIfAvailable(): Boolean {
        if (Build.VERSION.SDK_INT < android15Api) return false

        setTouchBoostEnabledIfAvailable()
        return try {
            window.javaClass
                .getMethod(
                    "setFrameRatePowerSavingsBalanced",
                    Boolean::class.javaPrimitiveType ?: Boolean::class.java
                )
                .invoke(window, true)
            powerSavingsBalancedRequested = true
            Log.d(refreshRateLogTag, "Frame-rate power savings balanced enabled")
            true
        } catch (error: Throwable) {
            Log.d(
                refreshRateLogTag,
                "Frame-rate power savings balanced unavailable: ${error.javaClass.simpleName}"
            )
            false
        }
    }

    private fun setTouchBoostEnabledIfAvailable() {
        if (Build.VERSION.SDK_INT < android15Api) return

        try {
            window.javaClass
                .getMethod(
                    "setFrameRateBoostOnTouchEnabled",
                    Boolean::class.javaPrimitiveType ?: Boolean::class.java
                )
                .invoke(window, true)
            Log.d(refreshRateLogTag, "Frame-rate touch boost left enabled")
        } catch (error: Throwable) {
            Log.d(
                refreshRateLogTag,
                "Frame-rate touch boost API unavailable: ${error.javaClass.simpleName}"
            )
        }
    }

    private fun frameRateDiagnostics(requestedPreferredRefreshRate: Float?): Map<String, Any?> {
        return mapOf(
            "sdkInt" to Build.VERSION.SDK_INT,
            "requestedPreferredRefreshRate" to requestedPreferredRefreshRate,
            "windowPreferredRefreshRate" to window.attributes.preferredRefreshRate,
            "windowPreferredDisplayModeId" to if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                window.attributes.preferredDisplayModeId
            } else {
                0
            },
            "lastRequestedPreferredRefreshRate" to lastRequestedPreferredRefreshRate,
            "lastRequestedPreferredDisplayModeId" to lastRequestedPreferredDisplayModeId,
            "powerSavingsBalancedRequested" to powerSavingsBalancedRequested
        )
    }

    private fun createDownloadNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                downloadChannelId,
                downloadChannelName,
                NotificationManager.IMPORTANCE_LOW
            )
            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.createNotificationChannel(channel)
        }
    }

    private fun requestNotificationPermissionIfNeeded() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) return
        if (ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.POST_NOTIFICATIONS
            ) == PackageManager.PERMISSION_GRANTED
        ) {
            return
        }
        ActivityCompat.requestPermissions(
            this,
            arrayOf(Manifest.permission.POST_NOTIFICATIONS),
            1002
        )
    }

    private fun notificationPermissionStatus(): String {
        val notificationsEnabled = NotificationManagerCompat.from(this).areNotificationsEnabled()
        if (!notificationsEnabled) return "denied"
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) return "granted"
        val granted = ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.POST_NOTIFICATIONS
        ) == PackageManager.PERMISSION_GRANTED
        return if (granted) "granted" else "denied"
    }

    private fun requestPrayerNotificationPermission(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            result.success(notificationPermissionStatus())
            return
        }

        val permission = Manifest.permission.POST_NOTIFICATIONS
        val alreadyGranted = ContextCompat.checkSelfPermission(
            this,
            permission
        ) == PackageManager.PERMISSION_GRANTED
        if (alreadyGranted) {
            result.success(notificationPermissionStatus())
            return
        }

        if (pendingPrayerNotificationPermissionResult != null) {
            result.success(notificationPermissionStatus())
            return
        }

        pendingPrayerNotificationPermissionResult = result
        ActivityCompat.requestPermissions(
            this,
            arrayOf(permission),
            prayerNotificationPermissionRequestCode
        )
    }

    private fun openNotificationSettings(): Boolean {
        val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).apply {
                putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
            }
        } else {
            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.parse("package:$packageName")
            }
        }
        return try {
            startActivity(intent)
            true
        } catch (_: Exception) {
            false
        }
    }

    private fun exactAlarmPermissionStatus(): String {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) return "granted"
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        return if (alarmManager.canScheduleExactAlarms()) "granted" else "denied"
    }

    private fun openExactAlarmSettings(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) return true
        val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
            data = Uri.parse("package:$packageName")
        }
        return try {
            startActivity(intent)
            true
        } catch (_: Exception) {
            false
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != prayerNotificationPermissionRequestCode) return

        val granted = grantResults.isNotEmpty() &&
            grantResults[0] == PackageManager.PERMISSION_GRANTED &&
            NotificationManagerCompat.from(this).areNotificationsEnabled()
        pendingPrayerNotificationPermissionResult?.success(
            if (granted) "granted" else "denied"
        )
        pendingPrayerNotificationPermissionResult = null
    }

    private fun showDownloadProgress(
        id: Int,
        title: String,
        progress: Int,
        max: Int,
        indeterminate: Boolean
    ) {
        requestNotificationPermissionIfNeeded()
        val notification = NotificationCompat.Builder(this, downloadChannelId)
            .setSmallIcon(android.R.drawable.stat_sys_download)
            .setContentTitle(title)
            .setContentText(if (indeterminate) "Downloading…" else "$progress%")
            .setOnlyAlertOnce(true)
            .setOngoing(true)
            .setProgress(max, progress, indeterminate)
            .build()

        notifyDownload(id, notification)
    }

    private fun completeDownload(id: Int, title: String) {
        val notification = NotificationCompat.Builder(this, downloadChannelId)
            .setSmallIcon(android.R.drawable.stat_sys_download_done)
            .setContentTitle(title)
            .setContentText("Download complete")
            .setOngoing(false)
            .setAutoCancel(true)
            .build()

        notifyDownload(id, notification)
    }

    private fun failDownload(id: Int, title: String) {
        val notification = NotificationCompat.Builder(this, downloadChannelId)
            .setSmallIcon(android.R.drawable.stat_notify_error)
            .setContentTitle(title)
            .setContentText("Download failed")
            .setOngoing(false)
            .setAutoCancel(true)
            .build()

        notifyDownload(id, notification)
    }

    private fun notifyDownload(id: Int, notification: android.app.Notification) {
        try {
            NotificationManagerCompat.from(this).notify(id, notification)
        } catch (_: SecurityException) {
            // Android 13+ can deny POST_NOTIFICATIONS. Downloads still continue.
        }
    }
}
