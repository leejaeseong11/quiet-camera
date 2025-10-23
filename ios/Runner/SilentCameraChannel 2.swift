import Foundation
import AVFoundation
import Photos
import Flutter
import AudioToolbox

class SilentCameraHandler: NSObject {
    private var captureSession: AVCaptureSession?
    private var photoOutput: AVCapturePhotoOutput?
    private var movieOutput: AVCaptureMovieFileOutput?
    private var currentDevice: AVCaptureDevice?
    private var photoCompletionHandler: FlutterResult?
    private var videoOutputURL: URL?
    
    override init() {
        super.init()
        setupCaptureSession()
    }
    
    // MARK: - Setup
    
    private func setupCaptureSession() {
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = .photo
        
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Failed to get camera device")
            return
        }
        
        currentDevice = camera
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession?.canAddInput(input) == true {
                captureSession?.addInput(input)
            }
            
            // Photo output
            photoOutput = AVCapturePhotoOutput()
            if let photoOutput = photoOutput, captureSession?.canAddOutput(photoOutput) == true {
                captureSession?.addOutput(photoOutput)
                photoOutput.isHighResolutionCaptureEnabled = true
                if #available(iOS 13.0, *) {
                    photoOutput.maxPhotoQualityPrioritization = .quality
                }
            }
            
            // Movie output
            movieOutput = AVCaptureMovieFileOutput()
            if let movieOutput = movieOutput, captureSession?.canAddOutput(movieOutput) == true {
                captureSession?.addOutput(movieOutput)
            }
            
        } catch {
            print("Error setting up capture session: \(error)")
        }
    }
    
    // MARK: - Photo Capture
    
    func takeSilentPhoto(settings: [String: Any], result: @escaping FlutterResult) {
        guard let photoOutput = photoOutput else {
            result(FlutterError(code: "NO_CAMERA", message: "Photo output not available", details: nil))
            return
        }
        
        if captureSession?.isRunning == false {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession?.startRunning()
            }
        }
        
        var photoSettings: AVCapturePhotoSettings
        
        // HEVC 지원 여부 확인
        if #available(iOS 11.0, *), photoOutput.availablePhotoCodecTypes.contains(.hevc) {
            photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
        } else {
            photoSettings = AVCapturePhotoSettings()
        }
        
        // Photo quality
        if #available(iOS 13.0, *) {
            photoSettings.photoQualityPrioritization = .quality
        }
        
        // Flash mode
        if let flashMode = settings["flashMode"] as? String {
            switch flashMode {
            case "auto":
                photoSettings.flashMode = .auto
            case "on":
                photoSettings.flashMode = .on
            case "off":
                photoSettings.flashMode = .off
            default:
                photoSettings.flashMode = .auto
            }
        }
        
        // Disable system shutter sound
        AudioServicesDisposeSystemSoundID(1108)
        
        photoCompletionHandler = result
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    // MARK: - Video Recording
    
    func startSilentVideo(settings: [String: Any], result: @escaping FlutterResult) {
        guard let movieOutput = movieOutput else {
            result(FlutterError(code: "NO_CAMERA", message: "Movie output not available", details: nil))
            return
        }
        
        guard !movieOutput.isRecording else {
            result(FlutterError(code: "ALREADY_RECORDING", message: "Already recording", details: nil))
            return
        }
        
        if captureSession?.isRunning == false {
            captureSession?.startRunning()
        }
        
        let outputFileName = "video_\(UUID().uuidString).mov"
        let outputFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent(outputFileName)
        videoOutputURL = URL(fileURLWithPath: outputFilePath)
        
        let recordAudio = settings["recordAudio"] as? Bool ?? false
        if !recordAudio {
            if let audioConnection = movieOutput.connection(with: .audio) {
                audioConnection.isEnabled = false
            }
        }
        
        AudioServicesDisposeSystemSoundID(1117) // start sound
        AudioServicesDisposeSystemSoundID(1118) // stop sound
        
        if let url = videoOutputURL {
            movieOutput.startRecording(to: url, recordingDelegate: self)
            result(outputFilePath)
        } else {
            result(FlutterError(code: "INVALID_PATH", message: "Could not create output path", details: nil))
        }
    }
    
    func stopSilentVideo(result: @escaping FlutterResult) {
        guard let movieOutput = movieOutput else {
            result(FlutterError(code: "NO_CAMERA", message: "Movie output not available", details: nil))
            return
        }
        
        guard movieOutput.isRecording else {
            result(FlutterError(code: "NOT_RECORDING", message: "Not currently recording", details: nil))
            return
        }
        
        movieOutput.stopRecording()
        if let url = videoOutputURL {
            result(url.path)
        } else {
            result(FlutterError(code: "NO_VIDEO", message: "No video output", details: nil))
        }
    }
    
    deinit {
        captureSession?.stopRunning()
    }
}

// MARK: - AVCapturePhotoCaptureDelegate

extension SilentCameraHandler: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            photoCompletionHandler?(FlutterError(
                code: "CAPTURE_ERROR",
                message: "Error capturing photo: \(error.localizedDescription)",
                details: nil
            ))
            photoCompletionHandler = nil
            return
        }
        
        guard let imageData = photo.fileDataRepresentation() else {
            photoCompletionHandler?(FlutterError(
                code: "NO_DATA",
                message: "Could not get image data",
                details: nil
            ))
            photoCompletionHandler = nil
            return
        }
        
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            guard status == .authorized else {
                self?.photoCompletionHandler?(FlutterError(
                    code: "PERMISSION_DENIED",
                    message: "Photo library access denied",
                    details: nil
                ))
                self?.photoCompletionHandler = nil
                return
            }
            
            PHPhotoLibrary.shared().performChanges({
                let creationRequest = PHAssetCreationRequest.forAsset()
                creationRequest.addResource(with: .photo, data: imageData, options: nil)
            }) { success, error in
                DispatchQueue.main.async {
                    if success {
                        self?.photoCompletionHandler?("Photo saved successfully")
                    } else {
                        self?.photoCompletionHandler?(FlutterError(
                            code: "SAVE_ERROR",
                            message: "Error saving photo: \(error?.localizedDescription ?? "Unknown")",
                            details: nil
                        ))
                    }
                    self?.photoCompletionHandler = nil
                }
            }
        }
    }
}

// MARK: - AVCaptureFileOutputRecordingDelegate

extension SilentCameraHandler: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Error recording video: \(error.localizedDescription)")
            return
        }
        
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                print("Photo library access denied")
                return
            }
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetCreationRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
            }) { success, error in
                if success {
                    print("Video saved successfully")
                } else {
                    print("Error saving video: \(error?.localizedDescription ?? "Unknown")")
                }
                
                try? FileManager.default.removeItem(at: outputFileURL)
            }
        }
    }
}
