import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  private var channel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    if #available(iOS 12.1, *) {
      let pencilInteraction = UIPencilInteraction()
      pencilInteraction.delegate = self
      window?.addInteraction(pencilInteraction)
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

@available(iOS 12.1, *)
extension AppDelegate: UIPencilInteractionDelegate {
    func pencilInteractionDidTap(_ interaction: UIPencilInteraction) {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: "com.studyingx/apple_pencil", binaryMessenger: controller.binaryMessenger)
        channel.invokeMethod("applePencilSideDoubleTapped", arguments: nil)
    }
}
