import Foundation
import WalletCore

class WalletService
{
    static var skShared: WalletService = .init()
    
    private let kStrength: Int32 = 256
    private let kWalletKey: String = Bundle.main.bundleIdentifier! + "-" + "WalletDataKey"
    
    private init() { }
    
    func getWallet() -> HDWallet?
    {
        guard let data = KeychainWrapper.load(key: kWalletKey)
        else
        {
            print("Wallet is not found")
            return nil
        }
        
        let encoder = JSONDecoder()
        
        do
        {
            let walletData = try encoder.decode(WalletData.self, from: data)
            
            return HDWallet(mnemonic: walletData.mnemonic, passphrase: walletData.passphrase)
        }
        catch let error
        {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func createWallet(passphrase: String) -> HDWallet
    {
        let wallet = HDWallet(strength: kStrength, passphrase: passphrase)
        
        save(wallet: wallet, passphrase: passphrase)
        
        return wallet
    }
    
    private func save(wallet: HDWallet, passphrase: String)
    {
        let walletData = WalletData(mnemonic: wallet.mnemonic, passphrase: passphrase)
        
        let encoder = JSONEncoder()
        
        do
        {
            let data = try encoder.encode(walletData)
            let success = KeychainWrapper.save(key: kWalletKey, data: data)
            
            if !success
            {
                print("Saving wallet failed")
            }
        }
        catch let error
        {
            print(error.localizedDescription)
        }
    }
}
