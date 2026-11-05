package com.sehatak.app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import androidx.core.app.NotificationCompat

class CallForegroundService : Service() {
    private var wakeLock: PowerManager.WakeLock? = null
    companion object {
        const val ACTION_START = "com.sehatak.app.call.START"
        const val EXTRA_CALL_ID = "callId"
        const val EXTRA_CALLER_NAME = "callerName"
        private const val CHANNEL_ID = "sehatak_call_foreground_v1"
        private const val NOTIFICATION_ID = 0x5343
    }

    override fun onCreate() {
        super.onCreate()
        createChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action != ACTION_START) {
            stopSelf()
            return START_NOT_STICKY
        }
        val callerName = intent.getStringExtra(EXTRA_CALLER_NAME)?.trim().orEmpty().ifEmpty { localizedText("مكالمة واردة", "Incoming call", "Appel entrant") }
        val callId = intent.getStringExtra(EXTRA_CALL_ID)?.trim().orEmpty()
        if (callId.isEmpty()) {
            stopSelf()
            return START_NOT_STICKY
        }
        acquireBoundedWakeLock()
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(com.sehatak.app.R.drawable.ic_notification)
            .setContentTitle(callerName)
            .setContentText(localizedText("المكالمة جارية", "Call in progress", "Appel en cours"))
            .setCategory(NotificationCompat.CATEGORY_CALL)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .build()
        if (Build.VERSION.SDK_INT >= 34) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
        return START_NOT_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        releaseWakeLock()
        super.onDestroy()
    }


    private fun localizedText(ar: String, en: String, fr: String): String {
        val language = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            resources.configuration.locales[0]?.language
        } else {
            @Suppress("DEPRECATION")
            resources.configuration.locale?.language
        }
        return when (language) {
            "en" -> en
            "fr" -> fr
            else -> ar
        }
    }

    private fun acquireBoundedWakeLock() {
        val power = getSystemService(POWER_SERVICE) as PowerManager
        synchronized(this) {
            wakeLock?.let { if (it.isHeld) it.release() }
            wakeLock = power.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "Sehatak:IncomingCall").apply {
                setReferenceCounted(false)
                acquire(10_000L)
            }
        }
    }

    private fun releaseWakeLock() {
        synchronized(this) {
            wakeLock?.let { if (it.isHeld) it.release() }
            wakeLock = null
        }
    }

    private fun createChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = getSystemService(NotificationManager::class.java)
        manager.createNotificationChannel(
            NotificationChannel(
                CHANNEL_ID,
                localizedText("صحتك - خدمة المكالمات", "Sehatak - Call service", "Sehatak - Service d’appel"),
                NotificationManager.IMPORTANCE_LOW
            )
        )
    }
}
