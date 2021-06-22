import UIKit
import SnapKit

class WalletDashboardViewController: UIViewController
{
    private var mBalanceTitleLabel: UILabel!
    private var mBalanceLabel: UILabel!
    private var mBalanceStackView: UIStackView!
    
    private var mAddressTitleLabel: UILabel!
    private var mAddressLabel: UILabel!
    private var mCopyAddressBtn: UIButton!
    
    private var mSendBtn: ActionButton!
    //    private var mSendBtnBottomConstraint: NSLayoutConstraint!
    private let mSendVc: SendViewController = .init()
    
    init()
    {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
}

extension WalletDashboardViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        configure()
        updateBalance()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        updateBalance()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
    {
        super.viewWillTransition(to: size, with: coordinator)
        
        //        DispatchQueue.main.async
        //        {
        //            self.mSendBtnBottomConstraint.constant = -safeAreaInsets.bottom
        //        }
    }
}

private extension WalletDashboardViewController
{
    var mTitleFont: UIFont
    {
        let font = UIFont.preferredFont(forTextStyle: .title3)
        return .systemFont(ofSize: font.pointSize, weight: .semibold)
    }
    
    var mBalanceFont: UIFont
    {
        let font = UIFont.preferredFont(forTextStyle: .title2)
        return .systemFont(ofSize: font.pointSize, weight: .semibold)
    }
    
    func configure()
    {
        view.backgroundColor = .white
        title = "Dashboard"
        
        setObservers()
        configureAddress()
        configureBalance()
        configureSendButton()
    }
    
    func setObservers()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    func configureAddress()
    {
        configureAddressTitleLabel()
        configureAddressLabel()
        configureCopyAddressBtn()
    }
    
    func configureAddressTitleLabel()
    {
        mAddressTitleLabel = .init()
        
        mAddressTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        mAddressTitleLabel.text = "Wallet Address"
        mAddressTitleLabel.font = mTitleFont
        mAddressTitleLabel.textColor = .black
        
        view.addSubview(mAddressTitleLabel)
        
        mAddressTitleLabel.snp.makeConstraints
        { make in
            make.centerX.equalTo(self.view.center.x)
            make.top.equalTo(self.view.snp.top).inset(safeAreaInsets.top + (navigationController?.navigationBar.frame.height ?? 0) + kMargin)
        }
        //
        //        NSLayoutConstraint.activate(
        //            [
        //                mAddressTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        //                mAddressTitleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: safeAreaInsets.top + (navigationController?.navigationBar.frame.height ?? 0) + kMargin)
        //            ]
        //        )
    }
    
    func configureAddressLabel()
    {
        mAddressLabel = .init()
        
        mAddressLabel.translatesAutoresizingMaskIntoConstraints = false
        mAddressLabel.font = mBalanceFont
        mAddressLabel.textColor = .black
        mAddressLabel.adjustsFontSizeToFitWidth = true
        
        getAcctInfo
        { acctInfo in
            DispatchQueue.main.async
            {
                self.mAddressLabel.text = acctInfo?.address ?? "Unknown"
            }
        }
        
        view.addSubview(mAddressLabel)
        
        mAddressLabel.snp.makeConstraints
        { make in
            make.centerX.equalTo(self.view.center.x)
            make.top.equalTo(self.mAddressTitleLabel.snp.bottom).inset(5)
            make.width.equalTo(self.view.snp.width).inset(kMargin)
        }
        //
        //        NSLayoutConstraint.activate(
        //            [
        //                mAddressLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        //                mAddressLabel.topAnchor.constraint(equalTo: mAddressTitleLabel.bottomAnchor, constant: 5),
        //                mAddressLabel.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -kMargin * 2)
        //            ]
        //        )
    }
    
    func configureCopyAddressBtn()
    {
        let copySymbolConfig = UIImage.SymbolConfiguration(pointSize: mBalanceFont.pointSize / 2, weight: .semibold)
        let copySymbolImg = UIImage(systemName: "doc.on.doc.fill", withConfiguration: copySymbolConfig)
        
        mCopyAddressBtn = .init(type: .system)
        
        mCopyAddressBtn.translatesAutoresizingMaskIntoConstraints = false
        mCopyAddressBtn.setImage(copySymbolImg, for: .normal)
        mCopyAddressBtn.tintColor = .systemBlue
        mCopyAddressBtn.addTarget(self, action: #selector(didCopyAddress), for: .touchUpInside)
        
        view.addSubview(mCopyAddressBtn)
        
        mCopyAddressBtn.snp.makeConstraints
        { make in
            make.centerY.equalTo(self.mAddressTitleLabel.snp.centerY)
            make.leading.equalTo(self.mAddressTitleLabel.snp.trailing).inset(-5)
        }
        //
        //        NSLayoutConstraint.activate(
        //            [
        //                mCopyAddressBtn.centerYAnchor.constraint(equalTo: mAddressTitleLabel.centerYAnchor),
        //                mCopyAddressBtn.leadingAnchor.constraint(equalTo: mAddressTitleLabel.trailingAnchor, constant: 5)
        //            ]
        //        )
    }
    
    func configureBalance()
    {
        configureBalanceTitleLabel()
        configureBalanceLabel()
        configureBalanceStackView()
    }
    
    func configureBalanceTitleLabel()
    {
        mBalanceTitleLabel = .init()
        
        mBalanceTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        mBalanceTitleLabel.text = "Balance (EGLD)"
        mBalanceTitleLabel.font = mTitleFont
        mBalanceTitleLabel.textColor = .black
    }
    
    func configureBalanceLabel()
    {
        mBalanceLabel = .init()
        
        mBalanceLabel.translatesAutoresizingMaskIntoConstraints = false
        mBalanceLabel.font = mBalanceFont
        mBalanceLabel.textColor = .black
        mBalanceLabel.text = "..."
    }
    
    func configureBalanceStackView()
    {
        mBalanceStackView = .init()
        
        mBalanceStackView.translatesAutoresizingMaskIntoConstraints = false
        mBalanceStackView.axis = .vertical
        mBalanceStackView.distribution = .equalSpacing
        mBalanceStackView.alignment = .center
        mBalanceStackView.spacing = 10
        
        mBalanceStackView.addArrangedSubview(mBalanceTitleLabel)
        mBalanceStackView.addArrangedSubview(mBalanceLabel)
        
        view.addSubview(mBalanceStackView)
        
        mBalanceStackView.snp.makeConstraints
        { make in
            make.center.equalTo(self.view.center)
        }
        //        NSLayoutConstraint.activate(
        //            [
        //                mBalanceStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        //                mBalanceStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        //            ]
        //        )
    }
    
    func configureSendButton()
    {
        mSendBtn = .init(title: "Send", onSendAction)
        
        view.addSubview(mSendBtn)
        
        mSendBtn.snp.makeConstraints
        { make in
            make.centerX.equalTo(self.view.snp.centerX)
            make.width.equalTo(self.view.snp.width).inset(kMargin)
            make.bottom.equalTo(self.view.snp.bottom).inset(safeAreaInsets.bottom)
        }
        //        NSLayoutConstraint.activate(
        //            [
        //                mSendBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        //                mSendBtn.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -kMargin * 2),
        //            ]
        //        )
        //
        //        mSendBtnBottomConstraint = mSendBtn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -safeAreaInsets.bottom)
        //        mSendBtnBottomConstraint.isActive = true
    }
}

private extension WalletDashboardViewController
{
    func updateBalance()
    {
        getAcctInfo
        { acctInfo in
            guard let acctInfo = acctInfo
            else
            {
                print("Empty account information")
                return
            }
            
            DispatchQueue.main.async
            {
                self.mBalanceLabel.text = acctInfo.balance
            }
        }
    }
    
    func getAcctInfo(_ completion: @escaping (_ accountInfo: AccountInfo?) -> Void)
    {
        guard let wallet = WalletService.skShared.getWallet() else { return }
        let address = wallet.getAddressForCoin(coin: .elrond)
        
        ElrondAPIService.sShared.getAccountInfo(address: address)
        { acctInfo in
            completion(acctInfo)
        }
    }
    
    func onSendAction()
    {
        navigationController?.pushViewController(mSendVc, animated: true)
    }
    
    @objc func willEnterForeground()
    {
        updateBalance()
    }
    
    @objc func didCopyAddress()
    {
        UIPasteboard.general.string = mAddressLabel.text
    }
}
