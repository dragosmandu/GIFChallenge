import Foundation
import WalletCore

class ElrondAPIService
{
    static let sShared: ElrondAPIService = .init()
    
    private let kApiUrl = "https://devnet-api.elrond.com"
    private var mUrlSession: URLSession!
    
    private init()
    {
        mUrlSession = URLSession(configuration: .default, delegate: nil, delegateQueue: nil)
    }
    
    func getAccountInfo(address: String, _ completion: @escaping (_ accountInfo: AccountInfo?) -> Void)
    {
        guard let acctInfoUrl = getAccountInfoUrl(address: address)
        else
        {
            return
        }
        
        var request = URLRequest(url: acctInfoUrl)
        
        request.httpMethod = "GET"
        
        let task = mUrlSession.dataTask(with: request)
        { data, _, error in
            if let error = error
            {
                print(error.localizedDescription)
                completion(nil)
                return
            }
            
            guard let data = data
            else
            {
                print("Empty account info")
                completion(nil)
                return
            }
            let decoder = JSONDecoder()
            
            do
            {
                var accountInfo = try decoder.decode(AccountInfo.self, from: data)
                
                accountInfo.balance = WeiConvertor.toEgldWith(wei: accountInfo.balance)
                
                completion(accountInfo)
            }
            catch let error
            {
                print(error.localizedDescription)
                completion(nil)
                return
            }
        }
        
        task.resume()
    }
    
    func sendEgld(amount: String, toAddress: String, gifUrl: String = "", _ completion: @escaping (_ success: Bool) -> Void)
    {
        guard let transactionsUrl = getTransactionsUrl(),
              let hdWallet = hdWallet
        else
        {
            print("Send failed")
            completion(false)
            return
        }
        
        let address = hdWallet.getAddressForCoin(coin: .elrond)
        TXSigner.signWith(amount: amount, fromAddress: address, toAddress: toAddress, data: gifUrl)
        { [weak self] sigOutput in
            guard let sigOutput = sigOutput,
                  let `self` = self
            else
            {
                print("Failed to sign data")
                completion(false)
                return
            }
            
            var request = URLRequest(url: transactionsUrl)
            guard let bodyData = sigOutput.encoded.data(using: .utf8)
            else
            {
                print("Failed to encode signing output")
                completion(false)
                return
            }
            
            request.httpMethod = "POST"
            request.httpBody = bodyData
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let task = self.mUrlSession.dataTask(with: request)
            { data, resp, error in
                if let error = error
                {
                    print(error.localizedDescription)
                    completion(false)
                    return
                }
                
                if let resp = resp as? HTTPURLResponse, resp.statusCode != 201
                {
                    print("Transaction failed with status code \(resp.statusCode)")
                    completion(false)
                    return
                }
                
                completion(true)
            }
            
            task.resume()
        }
        
    }
    
    func getNetConfig(_ completion: @escaping (_ gasData: GasData?) -> Void)
    {
        guard let netConfigUrl = getNetConfigUrl()
        else
        {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: netConfigUrl)
        
        request.httpMethod = "GET"
        
        let task = mUrlSession.dataTask(with: request)
        { data, _, error in
            if let error = error
            {
                print(error.localizedDescription)
                completion(nil)
                return
            }
            
            guard let data = data
            else
            {
                print("Invalid nil data")
                completion(nil)
                return
            }
            
            do
            {
                guard let jsonObj = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String : Any],
                      let data = jsonObj["data"] as? [String : Any],
                      let config = data["config"] as? [String : Any],
                      let minGasLimit = config["erd_min_gas_limit"] as? UInt64,
                      let gasPerByte = config["erd_gas_per_data_byte"] as? UInt64,
                      let gasPrice = config["erd_min_gas_price"] as? UInt64
                else
                {
                    print("Invalid data")
                    completion(nil)
                    return
                }
                
                completion(.init(minGasLimit: minGasLimit, gasPerByte: gasPerByte, gasPrice: gasPrice))
            }
            catch let error
            {
                print(error.localizedDescription)
                completion(nil)
            }
        }
        
        task.resume()
    }
    
    private func getAccountInfoUrl(address: String) -> URL?
    {
        return URL(string: "\(kApiUrl)/accounts/\(address)")
    }
    
    private func getTransactionsUrl() -> URL?
    {
        return URL(string: "\(kApiUrl)/transactions")
    }
    
    private func getNetConfigUrl() -> URL?
    {
        return URL(string: "\(kApiUrl)/network/config")
    }
}
