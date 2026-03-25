package com.example.mobile_assistant

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.GestureDescription
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.graphics.Path
import android.os.Build
import android.view.accessibility.AccessibilityEvent
import androidx.annotation.RequiresApi

class GestureService : AccessibilityService() {

    // Слухач, який чекає команду від Flutter
    private val scrollReceiver = object : BroadcastReceiver() {
        @RequiresApi(Build.VERSION_CODES.N)
        override fun onReceive(context: Context?, intent: Intent?) {
            if (intent?.action == "com.example.mobile_assistant.SCROLL_UP") {
                performScrollUp()
            }
        }
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        // Реєструємо нашого слухача при запуску служби
        val filter = IntentFilter("com.example.mobile_assistant.SCROLL_UP")
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(scrollReceiver, filter, Context.RECEIVER_EXPORTED)
        } else {
            registerReceiver(scrollReceiver, filter)
        }
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        // Нам не потрібно реагувати на події системи, лише на команди з Flutter
    }

    override fun onInterrupt() {}

    override fun onDestroy() {
        super.onDestroy()
        unregisterReceiver(scrollReceiver)
    }

    @RequiresApi(Build.VERSION_CODES.N)
    private fun performScrollUp() {
        val displayMetrics = resources.displayMetrics
        val middleX = displayMetrics.widthPixels / 2f
        
        // Імітуємо рух пальця знизу (80% екрану) вгору (20% екрану)
        val startY = displayMetrics.heightPixels * 0.8f
        val endY = displayMetrics.heightPixels * 0.2f

        val path = Path()
        path.moveTo(middleX, startY)
        path.lineTo(middleX, endY)

        val gestureBuilder = GestureDescription.Builder()
        // Свайп триває 300 мілісекунд
        gestureBuilder.addStroke(GestureDescription.StrokeDescription(path, 0, 300))
        
        dispatchGesture(gestureBuilder.build(), null, null)
    }
}