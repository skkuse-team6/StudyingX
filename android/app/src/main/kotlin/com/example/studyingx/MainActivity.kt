package com.example.studyingx

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.view.MotionEvent

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.studyingx/android_pen"

    override fun dispatchGenericMotionEvent(event: MotionEvent): Boolean {
        if (event.buttonState == MotionEvent.BUTTON_STYLUS_PRIMARY) {
            if (event.action == MotionEvent.ACTION_HOVER_MOVE) {
                MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL).invokeMethod("stylusButtonPressed", null)
            }
        } else if (event.action == MotionEvent.ACTION_HOVER_EXIT){
            MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL).invokeMethod("stylusButtonReleased", null)
        }
        return super.dispatchGenericMotionEvent(event)
    }
}
