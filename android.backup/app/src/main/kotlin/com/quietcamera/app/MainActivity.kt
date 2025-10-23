package com.quietcamera.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.quietcamera/silent"
    private lateinit var silentCameraModule: SilentCameraModule

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        silentCameraModule = SilentCameraModule(this)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "takeSilentPhoto" -> {
                    val args = call.arguments as? Map<String, Any>
                    if (args != null) {
                        silentCameraModule.takeSilentPhoto(args, result)
                    } else {
                        result.error("INVALID_ARGS", "Invalid arguments", null)
                    }
                }
                "startSilentVideo" -> {
                    val args = call.arguments as? Map<String, Any>
                    if (args != null) {
                        silentCameraModule.startSilentVideo(args, result)
                    } else {
                        result.error("INVALID_ARGS", "Invalid arguments", null)
                    }
                }
                "stopSilentVideo" -> {
                    silentCameraModule.stopSilentVideo(result)
                }
                "testConnection" -> {
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
