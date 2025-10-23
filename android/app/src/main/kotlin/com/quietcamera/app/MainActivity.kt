package com.quietcamera.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.quietcamera/silent"
    private lateinit var cameraModule: SilentCameraModule

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        cameraModule = SilentCameraModule(this)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "takeSilentPhoto" -> {
                    val quality = call.argument<Int>("quality")
                    val flashMode = call.argument<String>("flashMode")
                    if (quality != null && flashMode != null) {
                        val settings = mapOf(
                            "quality" to quality,
                            "flashMode" to flashMode
                        )
                        cameraModule.takeSilentPhoto(settings, result)
                    } else {
                        result.error("INVALID_ARGS", "Missing quality or flashMode", null)
                    }
                }
                "startSilentVideo" -> {
                    val resolution = call.argument<String>("resolution")
                    val fps = call.argument<Int>("fps")
                    val recordAudio = call.argument<Boolean>("recordAudio") ?: false
                    if (resolution != null && fps != null) {
                        val settings = mapOf(
                            "resolution" to resolution,
                            "fps" to fps,
                            "recordAudio" to recordAudio
                        )
                        cameraModule.startSilentVideo(settings, result)
                    } else {
                        result.error("INVALID_ARGS", "Missing resolution or fps", null)
                    }
                }
                "stopSilentVideo" -> {
                    cameraModule.stopSilentVideo(result)
                }
                "testConnection" -> {
                    result.success("Connection OK")
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
