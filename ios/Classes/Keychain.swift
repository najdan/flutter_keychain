private let KEYCHAIN_SERVICE = "flutter_keychain"

struct Keychain {
    /// `baseQuery` - keychain settings
    private var baseQuery: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword, // treat item as a generic password
            kSecAttrService as String: KEYCHAIN_SERVICE, // name of the service
            //  NOTE ADDING ACCESSIBLE VALUES WILL RESET THE KEYCHAIN
            //  kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly  Readable/writable after first unlock until reboot.
        ]
    }
        
    ///`put` - saved item to keychain
    func put(value: String, forKey key: String) throws -> String?  {
        let data = Data(value.utf8)
        
        if String(data: data, encoding: .utf8) == nil {
            throw NSError(domain: "PUT_KEYCHAIN_ERROR", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "Value contains invalid UTF-8"]
            )
        }

        var query = baseQuery
        query[kSecAttrAccount as String] = key
        // attempt to update if existing
        let update: [String: Any] = [kSecValueData as String: data]
        var status = SecItemUpdate(query as CFDictionary, update as CFDictionary)
        // add item
        if status == errSecItemNotFound {
            var add = baseQuery
            add[kSecAttrAccount as String] = key
            add[kSecValueData as String] = data
            status = SecItemAdd(add as CFDictionary, nil)
            // throw error if unable to save after item not found
            if status != errSecSuccess {
                throw KeychainError.operationFailed(status: status, message: secErrorString(status))
            }
            return String(data: data, encoding: .utf8)

        // throw error if unable to save successfully either by update or adding
        } else if status != errSecSuccess {
            throw KeychainError.operationFailed(status: status, message: secErrorString(status))
        }
        return nil
    }
    
    /// `get` gets saved items from keychain
    func get(key: String) throws -> String? {
        var query = baseQuery
        query[kSecAttrAccount as String] = key
        query[kSecReturnData as String] = kCFBooleanTrue
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        // throw error if errSecSuccess is not successful or not found
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.operationFailed(status: status, message: secErrorString(status))
        }
        guard let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    /// `remove` - removes item from keychain
     func remove(key: String) throws {
        var query = baseQuery
        query[kSecAttrAccount as String] = key
        let status = SecItemDelete(query as CFDictionary)
         // throw error if unable to remove
        if status != errSecSuccess && status != errSecItemNotFound {
            throw KeychainError.operationFailed(status: status, message: secErrorString(status))
        }
    }
    
    /// `clear` clears ALL items from keychain
     func clear() throws {
        let status = SecItemDelete(baseQuery as CFDictionary)
         // throw error if unable to clear
        if status != errSecSuccess && status != errSecItemNotFound {
            throw KeychainError.operationFailed(status: status, message: secErrorString(status))
        }
    }
    
    /// `secErrorString` -  human readable error
    private func secErrorString(_ status: OSStatus) -> String {
        if let s = SecCopyErrorMessageString(status, nil) as String? {
            return s
        }
        return "OSStatus \(status)"
    }
}
