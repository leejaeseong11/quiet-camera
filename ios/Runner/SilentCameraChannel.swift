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
    private var videoStopCompletionHandler: FlutterResult?
    
    override init() {
        super.init()
    }
    
    // MARK: - Setup
    
    private func setupCaptureSession(recordAudio: Bool) throws {
        // Create session if needed
        if captureSession == nil {
            captureSession = AVCaptureSession()
        }
        guard let session = captureSession else { throw NSError(domain: "SilentCamera", code: -1, userInfo: [NSLocalizedDescriptionKey: "No capture session"]) }
        session.beginConfiguration()
        session.sessionPreset = .photo
        
        // Camera input (default back camera)
        if currentDevice == nil {
            currentDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        }
        guard let camera = currentDevice else {
            session.commitConfiguration()
            throw NSError(domain: "SilentCamera", code: -2, userInfo: [NSLocalizedDescriptionKey: "Camera not available"])
        }
        
        // Remove existing inputs
        for input in session.inputs { session.removeInput(input) }
        // Add camera input
        let videoInput = try AVCaptureDeviceInput(device: camera)
        if session.canAddInput(videoInput) { session.addInput(videoInput) }
        
        // Add audio input when required
        if recordAudio {
            if let audioDevice = AVCaptureDevice.default(for: .audio) {
                let audioInput = try? AVCaptureDeviceInput(device: audioDevice)
                if let audioInput = audioInput, session.canAddInput(audioInput) {
                    session.addInput(audioInput)
                }
            }
        }
        
        // Photo output
        if photoOutput == nil { photoOutput = AVCapturePhotoOutput() }
        if let photoOutput = photoOutput {
            if session.canAddOutput(photoOutput) && !session.outputs.contains(photoOutput) {
                session.addOutput(photoOutput)
            }
            photoOutput.isHighResolutionCaptureEnabled = true
            if #available(iOS 13.0, *) {
                photoOutput.maxPhotoQualityPrioritization = .quality
            }
        }
        
        // Movie output
        if movieOutput == nil { movieOutput = AVCaptureMovieFileOutput() }
        if let movieOutput = movieOutput {
            if session.canAddOutput(movieOutput) && !session.outputs.contains(movieOutput) {
                session.addOutput(movieOutput)
            }
        }
        
        session.commitConfiguration()
    }
    
    // MARK: - Permissions
    private func ensureCameraPermission(completion: @escaping (Bool) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                completion(granted)
            }
        default:
            completion(false)
        }
    }
    
    private func ensureMicrophonePermission(completion: @escaping (Bool) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            completion(granted)
        }
    }
    
    // MARK: - Photo Capture
    
    func takeSilentPhoto(settings: [String: Any], result: @escaping FlutterResult) {
        ensureCameraPermission { [weak self] granted in
            guard granted else {
                result(FlutterError(code: "CAMERA_DENIED", message: "Camera permission denied", details: nil))
                return
            }
            guard let self = self else { return }
            do {
                try self.setupCaptureSession(recordAudio: false)
            } catch {
                result(FlutterError(code: "SESSION_ERROR", message: error.localizedDescription, details: nil))
                return
            }
            
            guard let photoOutput = self.photoOutput else {
                result(FlutterError(code: "NO_CAMERA", message: "Photo output not available", details: nil))
                return
            }
            
            if self.captureSession?.isRunning == false {
                self.captureSession?.startRunning()
            }
            
            // Configure photo settings
            let photoSettings = AVCapturePhotoSettings()
            if #available(iOS 13.0, *) {
                photoSettings.photoQualityPrioritization = .quality
            }
            if let flashMode = settings["flashMode"] as? String {
                switch flashMode { case "auto": photoSettings.flashMode = .auto; case "on": photoSettings.flashMode = .on; case "off": photoSettings.flashMode = .off; default: photoSettings.flashMode = .auto }
            }
            // HEVC format removed: processedFileType is read-only
            
            // Suppress shutter sound (may not work on all regions)
            AudioServicesDisposeSystemSoundID(1108)
            
            self.photoCompletionHandler = result
            photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }
    
    // MARK: - Video Recording
    
    func startSilentVideo(settings: [String: Any], result: @escaping FlutterResult) {
        let recordAudio = settings["recordAudio"] as? Bool ?? false
        ensureCameraPermission { [weak self] granted in
            guard granted, let self = self else {
                result(FlutterError(code: "CAMERA_DENIED", message: "Camera permission denied", details: nil))
                return
            }
            
            func proceedWithSetup() {
                do {
                    try self.setupCaptureSession(recordAudio: recordAudio)
                } catch {
                    result(FlutterError(code: "SESSION_ERROR", message: error.localizedDescription, details: nil))
                    return
                }
                guard let movieOutput = self.movieOutput else {
                    result(FlutterError(code: "NO_CAMERA", message: "Movie output not available", details: nil))
                    return
                }
                guard !movieOutput.isRecording else {
                    result(FlutterError(code: "ALREADY_RECORDING", message: "Already recording", details: nil))
                    return
                }
                if self.captureSession?.isRunning == false {
                    self.captureSession?.startRunning()
                }
                // Output URL
                let outputFileName = "video_\(UUID().uuidString).mov"
                let outputFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent(outputFileName)
                self.videoOutputURL = URL(fileURLWithPath: outputFilePath)
                // Suppress video sounds
                AudioServicesDisposeSystemSoundID(1117)
                AudioServicesDisposeSystemSoundID(1118)
                if let url = self.videoOutputURL {
                    movieOutput.startRecording(to: url, recordingDelegate: self)
                    result(outputFilePath)
                } else {
                    result(FlutterError(code: "INVALID_PATH", message: "Could not create output path", details: nil))
                }
            }
            
            if recordAudio {
                self.ensureMicrophonePermission { micGranted in
                    if micGranted {
                        proceedWithSetup()
                    } else {
                        // Proceed without audio if mic not granted
                        proceedWithSetup()
                    }
                }
            } else {
                proceedWithSetup()
            }
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
        
        // Defer result until recording finishes
        videoStopCompletionHandler = result
        movieOutput.stopRecording()
    }
    
    // MARK: - Cleanup
    
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
        
        // Write to a temporary file and return its path; Flutter will handle saving to Photos
        let tmpDir = NSTemporaryDirectory()
        let filename = "photo_\(UUID().uuidString).jpg"
        let filePath = (tmpDir as NSString).appendingPathComponent(filename)
        do {
            try imageData.write(to: URL(fileURLWithPath: filePath), options: .atomic)
            photoCompletionHandler?(filePath)
        } catch {
            photoCompletionHandler?(FlutterError(
                code: "WRITE_ERROR",
                message: "Failed to write image: \(error.localizedDescription)",
                details: nil
            ))
        }
        photoCompletionHandler = nil
    }
}

// MARK: - AVCaptureFileOutputRecordingDelegate

extension SilentCameraHandler: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Error recording video: \(error.localizedDescription)")
            videoStopCompletionHandler?(FlutterError(code: "RECORD_ERROR", message: error.localizedDescription, details: nil))
            videoStopCompletionHandler = nil
            return
        }
        // Return the temp file path to Flutter; do not delete here
        videoStopCompletionHandler?(outputFileURL.path)
        videoStopCompletionHandler = nil
    }
}
