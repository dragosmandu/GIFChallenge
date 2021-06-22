import Foundation

struct AccountInfo: Codable
{
    var address: String
    var balance: String
    var nonce: UInt16
    var txCount: UInt64
}
