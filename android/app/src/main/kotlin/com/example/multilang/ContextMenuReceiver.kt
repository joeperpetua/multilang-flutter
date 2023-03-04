package com.example.multilang;

import android.content.Intent
import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodChannel

class ContextMenuReceiver : FlutterActivity() {

    private var sharedText: String? = null
    private val CHANNEL = "app.channel.shared.data"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val intent: Intent? = intent
        val action: String? = intent?.action
        val type: String? = intent?.type

        if (action == Intent.ACTION_PROCESS_TEXT && type == "text/plain") {
            handleSendText(intent)
        }
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "getSharedText") {
                    result.success(this.sharedText)
                    sharedText = null
                }
            }
    }

    private fun handleSendText(intent: Intent) {
        sharedText = intent.getStringExtra(Intent.EXTRA_PROCESS_TEXT)
    }
}