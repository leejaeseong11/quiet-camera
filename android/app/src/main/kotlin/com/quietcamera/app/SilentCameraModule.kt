package com.quietcamera.app

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.hardware.camera2.*
import android.media.AudioManager
import android.media.ImageReader
import android.media.MediaRecorder
import android.os.Handler
import android.os.HandlerThread
import android.util.Log
import android.view.Surface
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.text.SimpleDateFormat
import java.util.*

class SilentCameraModule(private val context: Context) {
    private val TAG = "SilentCameraModule"
    
    private var cameraDevice: CameraDevice? = null
    private var cameraCaptureSession: CameraCaptureSession? = null
    private var imageReader: ImageReader? = null
    private var mediaRecorder: MediaRecorder? = null
    private var backgroundThread: HandlerThread? = null
    private var backgroundHandler: Handler? = null
    
    private val cameraManager = context.getSystemService(Context.CAMERA_SERVICE) as CameraManager
    private val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
    
    private var currentVideoPath: String? = null
    private var originalRingerMode: Int = AudioManager.RINGER_MODE_NORMAL
    private var originalStreamVolume: Int = 0

    // MARK: - Photo Capture
    
    fun takeSilentPhoto(settings: Map<String, Any>, result: MethodChannel.Result) {
        Log.d(TAG, "takeSilentPhoto called")
        
        // Save current audio settings
        muteSystemSounds()
        
        try {
            val quality = settings["quality"] as? Int ?: 95
            val flashMode = settings["flashMode"] as? String ?: "auto"
            
            // Setup image reader
            imageReader = ImageReader.newInstance(1920, 1080, android.graphics.ImageFormat.JPEG, 1)
            
            // Open camera
            val cameraId = getCameraId()
            if (ActivityCompat.checkSelfPermission(
                    context,
                    Manifest.permission.CAMERA
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                result.error("PERMISSION_DENIED", "Camera permission not granted", null)
                return
            }
            
            startBackgroundThread()
            
            cameraManager.openCamera(cameraId, object : CameraDevice.StateCallback() {
                override fun onOpened(camera: CameraDevice) {
                    cameraDevice = camera
                    captureStillPicture(quality, flashMode, result)
                }
                
                override fun onDisconnected(camera: CameraDevice) {
                    camera.close()
                    cameraDevice = null
                    restoreSystemSounds()
                }
                
                override fun onError(camera: CameraDevice, error: Int) {
                    camera.close()
                    cameraDevice = null
                    result.error("CAMERA_ERROR", "Camera error: $error", null)
                    restoreSystemSounds()
                }
            }, backgroundHandler)
            
        } catch (e: Exception) {
            Log.e(TAG, "Error taking photo", e)
            result.error("CAPTURE_ERROR", e.message, null)
            restoreSystemSounds()
        }
    }
    
    private fun captureStillPicture(quality: Int, flashMode: String, result: MethodChannel.Result) {
        try {
            val captureBuilder = cameraDevice?.createCaptureRequest(CameraDevice.TEMPLATE_STILL_CAPTURE)
            
            imageReader?.let { reader ->
                captureBuilder?.addTarget(reader.surface)
                
                // Set JPEG quality
                captureBuilder?.set(CaptureRequest.JPEG_QUALITY, quality.toByte())
                
                // Set flash mode
                when (flashMode) {
                    "auto" -> captureBuilder?.set(
                        CaptureRequest.CONTROL_AE_MODE,
                        CaptureRequest.CONTROL_AE_MODE_ON_AUTO_FLASH
                    )
                    "on" -> captureBuilder?.set(
                        CaptureRequest.CONTROL_AE_MODE,
                        CaptureRequest.CONTROL_AE_MODE_ON_ALWAYS_FLASH
                    )
                    "off" -> captureBuilder?.set(
                        CaptureRequest.CONTROL_AE_MODE,
                        CaptureRequest.CONTROL_AE_MODE_ON
                    )
                }
                
                // Create capture session
                cameraDevice?.createCaptureSession(
                    listOf(reader.surface),
                    object : CameraCaptureSession.StateCallback() {
                        override fun onConfigured(session: CameraCaptureSession) {
                            cameraCaptureSession = session
                            
                            // Capture image
                            session.capture(
                                captureBuilder?.build()!!,
                                object : CameraCaptureSession.CaptureCallback() {
                                    override fun onCaptureCompleted(
                                        session: CameraCaptureSession,
                                        request: CaptureRequest,
                                        captureResult: TotalCaptureResult
                                    ) {
                                        super.onCaptureCompleted(session, request, captureResult)
                                        
                                        // Save image
                                        val image = reader.acquireLatestImage()
                                        val buffer = image.planes[0].buffer
                                        val bytes = ByteArray(buffer.remaining())
                                        buffer.get(bytes)
                                        
                                        // Save to file
                                        val photoFile = createImageFile()
                                        photoFile.writeBytes(bytes)
                                        
                                        image.close()
                                        cleanup()
                                        restoreSystemSounds()
                                        
                                        result.success(photoFile.absolutePath)
                                    }
                                    
                                    override fun onCaptureFailed(
                                        session: CameraCaptureSession,
                                        request: CaptureRequest,
                                        failure: CaptureFailure
                                    ) {
                                        super.onCaptureFailed(session, request, failure)
                                        cleanup()
                                        restoreSystemSounds()
                                        result.error("CAPTURE_FAILED", "Capture failed", null)
                                    }
                                },
                                backgroundHandler
                            )
                        }
                        
                        override fun onConfigureFailed(session: CameraCaptureSession) {
                            cleanup()
                            restoreSystemSounds()
                            result.error("CONFIG_FAILED", "Configuration failed", null)
                        }
                    },
                    backgroundHandler
                )
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error capturing image", e)
            cleanup()
            restoreSystemSounds()
            result.error("CAPTURE_ERROR", e.message, null)
        }
    }
    
    // MARK: - Video Recording
    
    fun startSilentVideo(settings: Map<String, Any>, result: MethodChannel.Result) {
        Log.d(TAG, "startSilentVideo called")
        
        // Save current audio settings and mute
        muteSystemSounds()
        
        try {
            val recordAudio = settings["recordAudio"] as? Boolean ?: false
            
            // Create video file
            val videoFile = createVideoFile()
            currentVideoPath = videoFile.absolutePath
            
            // Setup MediaRecorder
            mediaRecorder = MediaRecorder().apply {
                if (recordAudio) {
                    setAudioSource(MediaRecorder.AudioSource.MIC)
                }
                setVideoSource(MediaRecorder.VideoSource.SURFACE)
                setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
                setOutputFile(videoFile.absolutePath)
                setVideoEncodingBitRate(10000000)
                setVideoFrameRate(30)
                setVideoSize(1920, 1080)
                setVideoEncoder(MediaRecorder.VideoEncoder.H264)
                if (recordAudio) {
                    setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
                }
                prepare()
            }
            
            // Start recording
            mediaRecorder?.start()
            
            result.success(videoFile.absolutePath)
            
        } catch (e: Exception) {
            Log.e(TAG, "Error starting video", e)
            restoreSystemSounds()
            result.error("VIDEO_ERROR", e.message, null)
        }
    }
    
    fun stopSilentVideo(result: MethodChannel.Result) {
        Log.d(TAG, "stopSilentVideo called")
        
        try {
            mediaRecorder?.apply {
                stop()
                release()
            }
            mediaRecorder = null
            
            restoreSystemSounds()
            
            result.success(currentVideoPath)
            currentVideoPath = null
            
        } catch (e: Exception) {
            Log.e(TAG, "Error stopping video", e)
            restoreSystemSounds()
            result.error("STOP_ERROR", e.message, null)
        }
    }
    
    // MARK: - Audio Control
    
    fun muteSystemSounds() {
        try {
            // Save original settings
            originalRingerMode = audioManager.ringerMode
            originalStreamVolume = audioManager.getStreamVolume(AudioManager.STREAM_SYSTEM)
            
            // Mute system sounds
            audioManager.ringerMode = AudioManager.RINGER_MODE_SILENT
            audioManager.setStreamVolume(AudioManager.STREAM_SYSTEM, 0, 0)
            
            Log.d(TAG, "System sounds muted")
        } catch (e: Exception) {
            Log.e(TAG, "Error muting sounds", e)
        }
    }
    
    fun restoreSystemSounds() {
        try {
            // Restore original settings
            audioManager.setStreamVolume(AudioManager.STREAM_SYSTEM, originalStreamVolume, 0)
            audioManager.ringerMode = originalRingerMode
            
            Log.d(TAG, "System sounds restored")
        } catch (e: Exception) {
            Log.e(TAG, "Error restoring sounds", e)
        }
    }
    
    // MARK: - Helper Methods
    
    private fun getCameraId(): String {
        val cameraIds = cameraManager.cameraIdList
        for (id in cameraIds) {
            val characteristics = cameraManager.getCameraCharacteristics(id)
            val facing = characteristics.get(CameraCharacteristics.LENS_FACING)
            if (facing == CameraCharacteristics.LENS_FACING_BACK) {
                return id
            }
        }
        return cameraIds[0]
    }
    
    private fun createImageFile(): File {
        val timeStamp = SimpleDateFormat("yyyyMMdd_HHmmss", Locale.getDefault()).format(Date())
        val storageDir = context.getExternalFilesDir(null)
        return File.createTempFile("IMG_${timeStamp}_", ".jpg", storageDir)
    }
    
    private fun createVideoFile(): File {
        val timeStamp = SimpleDateFormat("yyyyMMdd_HHmmss", Locale.getDefault()).format(Date())
        val storageDir = context.getExternalFilesDir(null)
        return File.createTempFile("VID_${timeStamp}_", ".mp4", storageDir)
    }
    
    private fun startBackgroundThread() {
        backgroundThread = HandlerThread("CameraBackground").also { it.start() }
        backgroundHandler = Handler(backgroundThread!!.looper)
    }
    
    private fun stopBackgroundThread() {
        backgroundThread?.quitSafely()
        try {
            backgroundThread?.join()
            backgroundThread = null
            backgroundHandler = null
        } catch (e: InterruptedException) {
            Log.e(TAG, "Error stopping background thread", e)
        }
    }
    
    private fun cleanup() {
        cameraCaptureSession?.close()
        cameraCaptureSession = null
        
        cameraDevice?.close()
        cameraDevice = null
        
        imageReader?.close()
        imageReader = null
        
        stopBackgroundThread()
    }
}
