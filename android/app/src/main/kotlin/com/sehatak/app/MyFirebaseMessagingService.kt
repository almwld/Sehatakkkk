package com.sehatak.app

import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

class MyFirebaseMessagingService : FirebaseMessagingService() {

    override fun onMessageReceived(message: RemoteMessage) {
        super.onMessageReceived(message)
        // معالجة الرسالة
    }

    override fun onNewToken(token: String) {
        super.onNewToken(token)
        // تحديث التوكن
    }
}
