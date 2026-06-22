import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "passport_reader/image_decoder",
                                              binaryMessenger: controller.binaryMessenger)
    
    channel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "decodeJp2k" {
        if let args = call.arguments as? [String: Any],
           let bytes = args["bytes"] as? FlutterStandardTypedData {
            let data = bytes.data
            if let image = UIImage(data: data), let jpegData = image.jpegData(compressionQuality: 1.0) {
                result(FlutterStandardTypedData(bytes: jpegData))
            } else {
                result(FlutterError(code: "DECODE_ERROR", message: "Failed to decode JP2 image", details: nil))
            }
        } else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Bytes array is null", details: nil))
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    })

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
