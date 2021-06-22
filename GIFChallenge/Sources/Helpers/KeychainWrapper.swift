import Foundation
import Security

class KeychainWrapper
{
    /// True for success, false otherwise.
    static func save(key: String, data: Data) -> Bool
    {
        let attributes =
            [
                kSecAttrAccount as String: key,
                
                kSecClass as String: kSecClassGenericPassword,
                kSecValueData as String: data
            ] as [String : Any]
        let status = SecItemAdd(attributes as CFDictionary, nil)
        
        if status != errSecSuccess
        {
            return false
        }
        
        return true
    }
    
    static func load(key: String) -> Data?
    {
        let query =
            [
                kSecAttrAccount as String: key,
                kSecClass as String: kSecClassGenericPassword,
                kSecReturnData as String  : kCFBooleanTrue!,
                kSecMatchLimit as String  : kSecMatchLimitOne
            ] as [String : Any]
        var resultDataRef: AnyObject?
        
        let status = SecItemCopyMatching(query as CFDictionary, &resultDataRef)
        
        guard status == noErr, let data = resultDataRef as? Data
        else
        {
            return nil
        }
        
        return data
    }
    
    static func delete(key: String) -> Bool
    {
        let query =
            [
                kSecAttrAccount as String: key,
                kSecClass as String: kSecClassGenericPassword
            ] as [String : Any]
        
        return SecItemDelete(query as CFDictionary) == noErr
    }
}
