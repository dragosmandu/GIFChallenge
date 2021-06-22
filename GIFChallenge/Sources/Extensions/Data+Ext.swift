import Foundation
import CryptoKit
import ImageIO

public extension Data
{
    // MARK: - Constants & Variables
    
    /// The SHA1 hash string representation of the current Data.
    /// ```
    /// ATTENTION: Don't use it for cryptographic meanings.
    /// ```
    var sha1HashString: String
    {
        let digest = Insecure.SHA1.hash(data: self)
        
        return digest.map
        {
            String(format: "%02hhx", $0)
        }
        .joined()
    }
}
