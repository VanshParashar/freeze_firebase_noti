package com.example.firebse_freeze_app
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class NotificationReceiver : BroadcastReceiver() {

    companion object {
        const val TAG = "🔔 NotificationReceiver"
    }

    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "✅ onReceive called")
        Log.d(TAG, "✅ Intent action: ${intent.action}")

        val type = intent.getStringExtra("type") ?: "start"
        Log.d(TAG, "✅ Type: $type")

        when (type) {
            "start" -> {
                Log.d(TAG, "🚨 Starting AlarmActivity")
                try {
                    val alarmIntent = Intent(context, AlarmActivity::class.java).apply {
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                                Intent.FLAG_ACTIVITY_CLEAR_TOP or
                                Intent.FLAG_ACTIVITY_SINGLE_TOP
                        putExtra("action", "start")
                    }
                    context.startActivity(alarmIntent)
                    Log.d(TAG, "✅ AlarmActivity started")
                } catch (e: Exception) {
                    Log.e(TAG, "❌ Error: ${e.message}")
                }
            }
            "stop" -> {
                Log.d(TAG, "🛑 Stopping AlarmActivity")
                try {
                    val stopIntent = Intent(context, AlarmActivity::class.java).apply {
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                                Intent.FLAG_ACTIVITY_SINGLE_TOP
                        putExtra("action", "stop")
                    }
                    context.startActivity(stopIntent)
                    Log.d(TAG, "✅ Stop intent sent")
                } catch (e: Exception) {
                    Log.e(TAG, "❌ Error: ${e.message}")
                }
            }
            else -> Log.e(TAG, "❌ Unknown type: $type")
        }
    }
}