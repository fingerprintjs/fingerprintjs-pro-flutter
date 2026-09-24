import Flutter
import UIKit

public final class FpjsProPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    FingerprintHostApiSetup.setUp(
      binaryMessenger: registrar.messenger(),
      api: FingerprintHostApiImpl()
    )
  }
}
