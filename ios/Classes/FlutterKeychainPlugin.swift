import Flutter
import Security
import UIKit

private let CHANNEL_NAME = "flutter_keychain_channel"

public class FlutterKeychainPlugin: NSObject, FlutterPlugin {

    final let _keychain = Keychain()

    /// `FlutterMethodChannel`
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: CHANNEL_NAME, binaryMessenger: registrar.messenger())
        let instance = FlutterKeychainPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    /// `handle`
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        do {
            switch call.method {
            case MethodChannelAction.GET.lowercased:
                try _get(call: call, result: result)
            case MethodChannelAction.PUT.lowercased:
                try _put(call: call, result: result)
            case MethodChannelAction.REMOVE.lowercased:
                try _remove(call: call, result: result)
            case MethodChannelAction.CLEAR.lowercased:
                try _clear(result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        } catch let error as KeychainError {
            switch error {
            case .operationFailed(let status, let message):
                result(FlutterError(code: "KEYCHAIN_ERROR", message: message, details: status))
            }
        } catch {
            result(FlutterError(code: "UNKNOWN_ERROR", message: error.localizedDescription, details: nil))
        }
    }

    ///  `_get`
    private func _get(call :FlutterMethodCall , result: @escaping FlutterResult) throws {
        guard let args = call.arguments as? [String: Any],
              let key = args["key"] as? String
        else { throw KeychainError.operationFailed(status: -50, message: "GET_MISSING_KEY") }
        result(try _keychain.get(key: key))
    }

    /// `_put`
    private func _put(call :FlutterMethodCall , result: @escaping FlutterResult) throws {
        guard let args = call.arguments as? [String: Any],
              let key = args["key"] as? String,
              let value = args["value"] as? String
        else { throw KeychainError.operationFailed(status: -50, message: "PUT_MISSING_KEY_VALUE") }
        if(key.isEmpty) {
            throw KeychainError.operationFailed(status: -50, message: "PUT_MISSING_KEY")
        }
        if (value.isEmpty) {
            throw KeychainError.operationFailed(status: -50, message: "PUT_MISSING_VALUE")

        }
        result(try _keychain.put(value: value, forKey: key))
    }

    /// `_remove`
    private func _remove(call :FlutterMethodCall , result: @escaping FlutterResult) throws {
        guard let args = call.arguments as? [String: Any],
              let key = args["key"] as? String
        else { throw KeychainError.operationFailed(status: -50, message: "REMOVE_MISSING_KEY") }
        try _keychain.remove(key: key)
        result(nil)
    }

    /// `_clear`
    private func _clear(result: @escaping FlutterResult) throws {
         try _keychain.clear()
        result(nil)
    }
}
