import Foundation
import Security

/// Wraps access to the iOS Keychain
@objcMembers public class BTKeychain: NSObject {
    
    
    /// Saves a `String` to the keychain.
    /// - Parameters:
    ///   - string: the `String` to be saved to the keychain
    ///   - key: the key to be used to access it later
    /// - Returns: `true` if the key/value pair was written successfully, `false` otherwise
    public static func setString(_ string: String, forKey key: String) -> Bool {
        let data: Data = string.data(using: .utf8) ?? Data()
        return setData(data, forKey: key)
    }
    
    /// Reads a `String` from the keychain.
    /// - Parameter key: the key associated to the desired `String` value in the keychain.
    /// - Returns: the `String` read from the keychain if successful, otherwise the empty `String`.
    public static func stringForKey(_ key: String) -> String {
        let data: Data = dataForKey(key) ?? Data()
        guard let dataString = String(data: data, encoding: .utf8) else { return "" }
        return dataString
    }
    
    /// Creates a key for the keychain, formatted with a unique Braintree identifier.
    /// - Parameter key: the unique `String` key for your value.
    /// - Returns: the key formatted with the Braintree identifier.
    static func keychainForKey(_ key: String) -> String {
        "com.braintreepayments.Braintree-API.\(key)"
    }
    
    
    /// Saves `Data` to the keychain with a given `key`.
    /// - Parameters:
    ///   - data: `Data` to save to the keychain
    ///   - key: `String` associated key to write to the keychain.
    /// - Returns: `true` if `data` was written successfully, `false` otherwise.
    static func setData(_ data: Data, forKey key: String) -> Bool {
        let formattedKey: String = keychainForKey(key)
        
        var existsQueryDictionary: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: "Service",
            kSecAttrAccount: formattedKey
        ]
        
        var status: OSStatus = SecItemCopyMatching(existsQueryDictionary as CFDictionary, nil)
        
        if status == errSecItemNotFound {
            existsQueryDictionary[kSecValueData] = data
            existsQueryDictionary[kSecAttrAccessible] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            
            status = SecItemAdd(existsQueryDictionary as CFDictionary, nil)
            
            if status != errSecSuccess {
                return false
            }
        } else if status == errSecSuccess {
            let attributeDictionary = [kSecValueData: data] as CFDictionary
            
            status = SecItemUpdate(existsQueryDictionary as CFDictionary, attributeDictionary)
            
            if status != errSecSuccess {
                return false
            }
        } else {
            return false
        }

        return true
    }
    
    /// Read`Data` from keychain.
    /// - Parameter key: the key associated to the desired `Data`value in the keychain.
    /// - Returns: The `Data` associated to `key`, `nil` otherwise.
    static func dataForKey(_ key: String) -> Data? {
        let formattedKey: String = keychainForKey(key)
        
        let existsQueryDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: "Service",
            kSecAttrAccount: formattedKey,
            kSecReturnData: kCFBooleanTrue as Any
        ] as CFDictionary
        
        var cfData: AnyObject? = nil
        let status: OSStatus = SecItemCopyMatching(existsQueryDictionary, &cfData)
        
        if status == errSecSuccess {
            return cfData as? Data
        }
        
        return nil
    }
}
