import Foundation
import WalletCore

class TXSigner
{
    static func signWith(amount: String, fromAddress: String, toAddress: String, data: String, _ completion: @escaping (_ sigOutput: ElrondSigningOutput?) -> Void)
    {
        guard let hdWallet = hdWallet
        else
        {
            print("Invalid nil wallet")
            completion(nil)
            return
        }
        
        ElrondAPIService.sShared.getAccountInfo(address: fromAddress)
        { acctInfo in
            guard let acctInfo = acctInfo
            else
            {
                print("Invalid nil account info")
                completion(nil)
                return
            }
            
            ElrondAPIService.sShared.getNetConfig
            { gasData in
                guard let gasData = gasData
                else
                {
                    print("Invalid gas data")
                    completion(nil)
                    return
                }
                
                let privateKey = hdWallet.getKeyForCoin(coin: .elrond)
                let privateKeyData = privateKey.data
                var transferMessage = ElrondTransactionMessage()
                
                transferMessage.nonce = UInt64(acctInfo.nonce) // nonce from balance, you should refresh it after every executed tx
                transferMessage.gasLimit = calcGasLimitWith(gasData: gasData, data: data)
                transferMessage.sender = fromAddress
                transferMessage.receiver = toAddress
                transferMessage.value = amount // string wei value
                transferMessage.gasPrice = gasData.gasPrice
                transferMessage.data = data // gif url
                transferMessage.chainID = "D"
                transferMessage.version = 1
                
                let signerInput = ElrondSigningInput.with
                {
                    $0.privateKey = privateKeyData
                    $0.transaction = transferMessage
                }
                
                completion(AnySigner.sign(input: signerInput, coin: CoinType.elrond))
            }
        }
    }
    
    static func calcGasLimitWith(gasData: GasData, data: String) -> UInt64
    {
        return gasData.minGasLimit + gasData.gasPerByte * UInt64(data.count)
    }
}
