package com.example.studyingx

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.view.MotionEvent

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.studyingx/android_pen"
    private var lastButtonState = 0

    override fun dispatchGenericMotionEvent(event: MotionEvent): Boolean {
        if (event.action == MotionEvent.ACTION_HOVER_MOVE) {
            if (event.buttonState == MotionEvent.BUTTON_STYLUS_PRIMARY && lastButtonState == 0) {
                MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL).invokeMethod("stylusButtonPressed", null)
                lastButtonState = 1
            }
            if (event.buttonState == MotionEvent.TOOL_TYPE_UNKNOWN && lastButtonState == 1) {
                MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL).invokeMethod("stylusButtonReleased", null)
                lastButtonState = 0
            }
        }
        if (event.action == MotionEvent.ACTION_HOVER_EXIT && event.buttonState == MotionEvent.TOOL_TYPE_UNKNOWN && lastButtonState == 1) {
            MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL).invokeMethod("stylusButtonReleased", null)
            lastButtonState = 0
        }

        return super.dispatchGenericMotionEvent(event)
    }
}
