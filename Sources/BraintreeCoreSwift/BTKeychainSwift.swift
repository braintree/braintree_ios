import Foundation
import Security

@objc public class BTKeychainSwift: NSObject {
    
    @objc public static func setString(_ string: String, forKey key: String) -> Bool {
        let data: Data = string.data(using: .utf8) ?? Data()
        return setData(data, forKey: key)
    }
    
    @objc public static func stringForKey(_ key: String) -> String {
        let data: Data = dataForKey(key) ?? Data()
        guard let dataString = String(data: data, encoding: .utf8) else { return "" }
        return dataString
    }
    
    static func keychainForKey(_ key: String) -> String {
        String(format: "com.braintreepayments.Braintree-API.", key)
    }
    
    static func setData(_ data: Data, forKey key: String) -> Bool {
        var success: Bool = true
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
                success = false
            }
        } else if status == errSecSuccess {
            let attributeDictionary = [kSecValueData: data] as CFDictionary
            
            status = SecItemUpdate(existsQueryDictionary as CFDictionary, attributeDictionary)
            
            if status != errSecSuccess {
                success = false
            }
        } else {
            success = false
        }

        return success
    }
    
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
