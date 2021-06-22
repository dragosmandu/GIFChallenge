import UIKit
import SnapKit

class CreateWalletViewController: UIViewController
{
    private var mTitle: UILabel!
    private var mPassphraseInput: TextField!
    private var mCreateWalletBtn: ActionButton!
    //    private var mTitleTopConstraint: NSLayoutConstraint!
    private var mPassphrase: String = ""
    //    private var mCreateWalletBtnBottomConstraint: NSLayoutConstraint!
    private var mWarningLabel: UILabel!
    
    init()
    {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
}

extension CreateWalletViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        configure()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
    {
        super.viewWillTransition(to: size, with: coordinator)
        
        //        DispatchQueue.main.async
        //        {
        //            self.mTitleTopConstraint.constant = safeAreaInsets.top + kMargin
        //            self.mCreateWalletBtnBottomConstraint.constant = -safeAreaInsets.bottom
        //        }
    }
}

extension CreateWalletViewController: UITextFieldDelegate
{
    func textFieldDidChangeSelection(_ textField: UITextField)
    {
        mPassphrase = textField.text ?? ""
        
        if mPassphrase == ""
        {
            mWarningLabel.text = "Passphrase cannot be empty!"
            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut)
            {
                self.mWarningLabel.layer.opacity = 1
            }
        }
        else if mPassphrase.count < mkMinPassphraseChars
        {
            mWarningLabel.text = "Passphrase should be at least 5 characters long!"
            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut)
            {
                self.mWarningLabel.layer.opacity = 1
            }
        }
        else
        {
            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut)
            {
                self.mWarningLabel.layer.opacity = 0
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        mPassphraseInput.resignFirstResponder()
        return false
    }
}

private extension CreateWalletViewController
{
    var mTitleFont: UIFont
    {
        let font = UIFont.preferredFont(forTextStyle: .title2)
        return .systemFont(ofSize: font.pointSize, weight: .semibold)
    }
    
    var mWarningLblFont: UIFont
    {
        let font = UIFont.preferredFont(forTextStyle: .footnote)
        return .systemFont(ofSize: font.pointSize, weight: .regular)
    }
    
    func configure()
    {
        view.backgroundColor = .white
        
        configureTitleLabel()
        configurePassphraseInput()
        configureCreateWalletBtn()
        configureWarningLabel()
    }
    
    func configureTitleLabel()
    {
        mTitle = .init()
        
        mTitle.translatesAutoresizingMaskIntoConstraints = false
        mTitle.text = "Create Wallet"
        mTitle.textColor = .black
        mTitle.font = mTitleFont
        
        view.addSubview(mTitle)
        
        mTitle.snp.makeConstraints
        { make in
            make.centerX.equalTo(self.view.snp.centerX)
            make.top.equalTo(self.view.snp.top).inset(safeAreaInsets.top + kMargin)
        }
        
        //        NSLayoutConstraint.activate(
        //            [
        //                mTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        //            ]
        //        )
        //
        //        mTitleTopConstraint = mTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: safeAreaInsets.top + kMargin)
        //        mTitleTopConstraint.isActive = true
    }
    
    func configurePassphraseInput()
    {
        mPassphraseInput = .init()
        
        mPassphraseInput.placeholder = "Write a passphrase..."
        mPassphraseInput.delegate = self
        mPassphraseInput.isSecureTextEntry = true
        
        view.addSubview(mPassphraseInput)
        
        mPassphraseInput.snp.makeConstraints
        { make in
            make.center.equalTo(self.view.center)
            make.width.equalTo(self.view.snp.width).inset(kMargin)
        }
        //        NSLayoutConstraint.activate(
        //            [
        //                mPassphraseInput.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        //                mPassphraseInput.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        //                mPassphraseInput.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -kMargin  * 2)
        //            ]
        //        )
    }
    
    func configureCreateWalletBtn()
    {
        mCreateWalletBtn = .init(title: "Create Wallet", didPressCreate)
        
        view.addSubview(mCreateWalletBtn)
        
        mCreateWalletBtn.snp.makeConstraints
        { make in
            make.centerX.equalTo(self.view.snp.centerX)
            make.width.equalTo(self.view.snp.width).inset(kMargin)
            make.bottom.equalTo(self.view.snp.bottom).inset(safeAreaInsets.bottom)
        }
        //        NSLayoutConstraint.activate(
        //            [
        //                mCreateWalletBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        //                mCreateWalletBtn.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -kMargin * 2)
        //            ]
        //        )
        //
        //        mCreateWalletBtnBottomConstraint = mCreateWalletBtn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -safeAreaInsets.bottom)
        //        mCreateWalletBtnBottomConstraint.isActive = true
    }
    
    func configureWarningLabel()
    {
        mWarningLabel = .init()
        
        mWarningLabel.translatesAutoresizingMaskIntoConstraints = false
        mWarningLabel.font = mWarningLblFont
        mWarningLabel.textColor = .red
        mWarningLabel.text = "Invalid passphrase, try again!"
        mWarningLabel.layer.opacity = 0
        
        view.addSubview(mWarningLabel)
        
        mWarningLabel.snp.makeConstraints
        { make in
            make.leading.equalTo(self.mPassphraseInput.snp.leading).inset(10)
            make.top.equalTo(self.mPassphraseInput.snp.bottom)
        }
        //        NSLayoutConstraint.activate(
        //            [
        //                mWarningLabel.leadingAnchor.constraint(equalTo: mPassphraseInput.leadingAnchor, constant: 10),
        //                mWarningLabel.topAnchor.constraint(equalTo: mPassphraseInput.bottomAnchor, constant: 5)
        //            ]
        //        )
    }
}

private extension CreateWalletViewController
{
    var mkMinPassphraseChars: Int { return 5 }
    
    func didPressCreate()
    {
        if mPassphrase.count > mkMinPassphraseChars
        {
            hdWallet = WalletService.skShared.createWallet(passphrase: mPassphrase)
            presentDashboard()
        }
    }
    
    func presentDashboard()
    {
        let walletDashVC = WalletDashboardViewController()
        let navVc = UINavigationController(rootViewController: walletDashVC)
        
        navVc.modalPresentationStyle = .fullScreen
        
        present(navVc, animated: true)
    }
}
