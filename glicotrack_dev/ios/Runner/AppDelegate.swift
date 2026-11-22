import Flutter
import UIKit
import AudioToolbox

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "GlicoTrackAlerts") {
      let channel = FlutterMethodChannel(name: "glicotrack/alerts", binaryMessenger: registrar.messenger())
      channel.setMethodCallHandler { call, result in
        if call.method == "hypoglycemia" {
          AudioServicesPlayAlertSound(1005)
          result(nil)
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    }
  }
}
