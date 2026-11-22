package com.example.glicotrack_dev

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.media.AudioManager
import android.media.ToneGenerator
import android.os.Handler
import android.os.Looper

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "glicotrack/alerts")
            .setMethodCallHandler { call, result ->
                if (call.method == "hypoglycemia") {
                    try {
                        val tone = ToneGenerator(AudioManager.STREAM_ALARM, 80)
                        tone.startTone(ToneGenerator.TONE_CDMA_ALERT_CALL_GUARD, 600)
                        Handler(Looper.getMainLooper()).postDelayed({ tone.release() }, 800)
                        result.success(null)
                    } catch (error: Exception) {
                        result.error("alert-unavailable", "Alerta sonoro indisponível", null)
                    }
                } else result.notImplemented()
            }
    }
}
