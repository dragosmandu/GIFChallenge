import Foundation
import WalletCore

extension HDWallet
{
    func hasBalanceFor(amount: String, _ completion: @escaping (Bool) -> Void)
    {
        let address = getAddressForCoin(coin: .elrond)
        
        ElrondAPIService.sShared.getAccountInfo(address: address)
        { acctInfo in
            guard let acctInfo = acctInfo
            else
            {
                print("Invalid nil account info")
                completion(false)
                return
            }
            
            var amountWei = WeiConvertor.toWeiWith(egld: amount)
            var balanceWei = WeiConvertor.toWeiWith(egld: acctInfo.balance)
            
            if balanceWei.count > amountWei.count
            {
                completion(true)
                return
            }
            else if balanceWei.count < amountWei.count
            {
                completion(false)
                return
            }
            
            while true
            {
                let bVal = Int(balanceWei.removeFirst().lowercased()) ?? 0
                let aVal = Int(amountWei.removeFirst().lowercased()) ?? 0
                
                if bVal > aVal || (balanceWei.count == 0 && amountWei.count == 0)
                {
                    completion(true)
                    return
                }
                else if bVal < aVal
                {
                    completion(false)
                    return
                }
            }
        }
    }
    
    func sendEgld(amount: String, toAddress: String, gifUrl: String, _ completion: @escaping (_ success: Bool, _ msg: String) -> Void)
    {
        if amount == "0"
        {
            completion(false, "Invalid amount. Should be higher than 0!")
            return
        }
        
        hasBalanceFor(amount: amount)
        { hasBalance in
            if !hasBalance
            {
                completion(false, "Invalid amount. Should be lower than the balance!")
                return
            }
            
            let wei = WeiConvertor.toWeiWith(egld: amount)
            
            print("Sending...")
            
            ElrondAPIService.sShared.sendEgld(amount: wei, toAddress: toAddress, gifUrl: gifUrl)
            { success in
                if success
                {
                    completion(true, "Transaction finished successfully!")
                }
                else
                {
                    completion(true, "Transaction failed!")
                }
            }
        }
    }
}
