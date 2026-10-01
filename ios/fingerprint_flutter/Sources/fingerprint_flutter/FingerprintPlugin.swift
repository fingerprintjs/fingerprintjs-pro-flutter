// Plugin entry point: registers the Pigeon host API on each Flutter engine.
// https://pub.dev/packages/pigeon
import Flutter
import UIKit

public final class FingerprintPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    FingerprintHostApiSetup.setUp(
      binaryMessenger: registrar.messenger(),
      api: FingerprintHostApiImpl()
    )
  }
}
