import Foundation

public extension String
{
    // MARK: - Constants & Variables
    
    /// An empty String.
    static let sk_Empty: String = ""
    
    /// The SHA1 hash string representation of the current String.
    /// ```
    /// ATTENTION: Don't use it for cryptographic meanings.
    /// ```
    var sha1HashString: String?
    {
        var sha1HashString: String?
        
        if let data = self.data(using: .utf8)
        {
            sha1HashString = data.sha1HashString
        }
        
        return sha1HashString
    }
}
