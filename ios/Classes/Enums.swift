
/// `KeychainError` - A simple error type for Keychain operations
enum KeychainError: Error {
    case operationFailed(status: OSStatus, message: String)
}

/// `MethodChannelAction` - Used to handle messages from flutter
enum MethodChannelAction: String, CaseIterable {
    case PUT
    case GET
    case REMOVE
    case CLEAR
}

extension MethodChannelAction {
    var lowercased: String {
        return self.rawValue.lowercased()
    }
}
