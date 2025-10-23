import UIKit
import Flutter
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let silentCameraChannel = FlutterMethodChannel(
            name: "com.quietcamera/silent",
            binaryMessenger: controller.binaryMessenger
        )
        
        let silentCameraHandler = SilentCameraHandler()
        
        silentCameraChannel.setMethodCallHandler({
            [weak silentCameraHandler] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            
            guard let handler = silentCameraHandler else {
                result(FlutterError(code: "UNAVAILABLE", message: "Handler not available", details: nil))
                return
            }
            
            switch call.method {
            case "takeSilentPhoto":
                if let args = call.arguments as? [String: Any] {
                    handler.takeSilentPhoto(settings: args, result: result)
                } else {
                    result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
                }
                
            case "startSilentVideo":
                if let args = call.arguments as? [String: Any] {
                    handler.startSilentVideo(settings: args, result: result)
                } else {
                    result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
                }
                
            case "stopSilentVideo":
                handler.stopSilentVideo(result: result)
                
            case "testConnection":
                result(true)
                
            default:
                result(FlutterMethodNotImplemented)
            }
        })
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
