import UIKit
import WalletCore
import GiphyUISDK

class RootViewController: UIViewController
{
    private var mActivityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        //        KeychainWrapper.delete(key: Bundle.main.bundleIdentifier! + "-" + "WalletDataKey")
        configure()
    }
}

private extension RootViewController
{
    func configure()
    {
        view.backgroundColor = .white
        
        Giphy.configure(apiKey: "k5u1MFnstpnGpQ96fNl0UmPBkCVYc7QF")
        
        configureActivityIndicator()
        configureWallet()
    }
    
    func configureActivityIndicator()
    {
        mActivityIndicator = .init(style: .medium)
        
        mActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        mActivityIndicator.tintColor = .systemGray
        
        view.addSubview(mActivityIndicator)
        
        NSLayoutConstraint.activate(
            [
                mActivityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                mActivityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ]
        )
    }
    
    func configureWallet()
    {
        mActivityIndicator.startAnimating()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1)
        { [weak self] in
            if let wallet = WalletService.skShared.getWallet()
            {
                hdWallet = wallet
                let walletDashVC = WalletDashboardViewController()
                let navVc = UINavigationController(rootViewController: walletDashVC)
                
                navVc.modalPresentationStyle = .fullScreen
                
                self?.present(navVc, animated: true)
                {
                    self?.mActivityIndicator.stopAnimating()
                }
            }
            else
            {
                let createWalletVC = CreateWalletViewController()
                
                createWalletVC.modalPresentationStyle = .fullScreen
                
                self?.present(createWalletVC, animated: true)
                {
                    self?.mActivityIndicator.stopAnimating()
                }
            }
        }
    }
}
