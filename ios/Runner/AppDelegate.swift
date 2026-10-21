import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // ── Open-Settings channel (used by BiometricService) ──────────────
    // On iOS we can only open the app's own Settings page, not the
    // Face ID/Touch ID page directly — Apple doesn't allow that.
    let controller = window?.rootViewController as! FlutterViewController
    let settingsChannel = FlutterMethodChannel(
      name: "secure_audio/settings",
      binaryMessenger: controller.binaryMessenger
    )
    settingsChannel.setMethodCallHandler { [weak self] call, result in
      if call.method == "openBiometricSettings" {
        // Opens the app's entry in iOS Settings (closest we can get)
        if let url = URL(string: UIApplication.openSettingsURLString) {
          UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        result(nil)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
    // ──────────────────────────────────────────────────────────────────

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
