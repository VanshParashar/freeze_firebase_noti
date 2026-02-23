package com.example.firebse_freeze_app

import android.app.KeyguardManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity

class AlarmActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        unlockAndShow()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        val action = intent.getStringExtra("action")
        if (action == "stop") {
            finish() // Activity band karo
        }
    }

    private fun unlockAndShow() {
        // Screen ON karo aur lock screen hata do
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
            val keyguardManager =
                getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
            keyguardManager.requestDismissKeyguard(this, null)
        }

        window.addFlags(
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON        or
                    WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED      or
                    WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON        or
                    WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
        )
    }

    // ← BACK BUTTON BLOCK — user back nahi kar sakta
    @Deprecated("Deprecated in Java")
    override fun onBackPressed() {
        // Kuch mat karo — back button kaam nahi karega
    }

    // Home button se bhi wapas laao
    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        // Jab user home dabaye — app wapas aajaye
        val intent = Intent(this, AlarmActivity::class.java)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                Intent.FLAG_ACTIVITY_REORDER_TO_FRONT
        startActivity(intent)
    }
}