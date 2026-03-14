package com.example.lexicon_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.lexicon/intent"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getSharedText") {
                val text = handleIntent(intent)
                result.success(text)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun handleIntent(intent: Intent): String? {
        if (intent.action == "com.example.lexicon.ACTION_SEARCH") {
            return "WIDGET_SEARCH_FOCUS"
        }
        if (intent.action == Intent.ACTION_PROCESS_TEXT) {
            return intent.getCharSequenceExtra(Intent.EXTRA_PROCESS_TEXT)?.toString()
        }
        if (intent.action == Intent.ACTION_VIEW) {
            return intent.data?.getQueryParameter("word")
        }
        return null
    }
}
