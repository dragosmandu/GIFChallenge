import Foundation
import WalletCore

let kMargin: CGFloat = 20
var hdWallet: HDWallet?
var safeAreaInsets: UIEdgeInsets
{
    return UIApplication.shared.windows.first?.safeAreaInsets ?? .init(top: 0, left: 0, bottom: 0, right: 0)
}
