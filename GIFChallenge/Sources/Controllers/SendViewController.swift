import UIKit
import GiphyUISDK
import SnapKit

class SendViewController: UIViewController
{
    private var mToAddressInput: TextField!
    private var mAmountInput: TextField!
    private var mNoteInput: TextField!
    private var mGifBtn: UIButton!
    private var mInputsStackView: UIStackView!
    private var mSendBtn: ActionButton!
    private var mSendBtnBottomConstraint: NSLayoutConstraint!
    private var mGiphyVc: GiphyViewController!
    private var mGifPlayer: GIFPlayer!
    private var mWarningLabel: UILabel!
    private var mFeeLabel: UILabel!
    private var mDeleteGifBtn: UIButton!
    private var mEgldAmount: String? = nil
    private var mGifUrlStr: String? = nil
    private var mReceiverAddress: String? = nil
    
    init()
    {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
}

extension SendViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        configure()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
    {
        super.viewWillTransition(to: size, with: coordinator)
        
        DispatchQueue.main.async
        {
            self.mSendBtnBottomConstraint.constant = -safeAreaInsets.bottom
        }
    }
}

extension SendViewController: UITextFieldDelegate, GiphyDelegate
{
    func didDismiss(controller: GiphyViewController?)
    {
        
    }
    
    func didSelectMedia(giphyViewController: GiphyViewController, media: GPHMedia)
    {
        giphyViewController.dismiss(animated: true, completion: nil)
        
        guard let gifUrlStr = media.url(rendition: .original, fileType: .gif),
              let gifUrl = URL(string: gifUrlStr)
        else { return }
        
        mGifUrlStr = gifUrlStr
        mGifPlayer.updateUrlWith(url: gifUrl)
        
        ElrondAPIService.sShared.getNetConfig
        { gasData in
            guard let gasData = gasData else { return }
            
            let fee = TXSigner.calcGasLimitWith(gasData: gasData, data: gifUrlStr)
            let feeEgldStr = WeiConvertor.toEgldWith(wei: String(fee))
            
            DispatchQueue.main.async
            {
                self.mFeeLabel.text = "Transaction fee(EGLD): \(feeEgldStr)"
            }
        }
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut)
        {
            self.mGifPlayer.layer.opacity = 1
        }
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField)
    {
        DispatchQueue.main.async
        {
            self.mWarningLabel.layer.opacity = 0
        }
        
        if textField == mAmountInput
        {
            mEgldAmount = textField.text
        }
        
        if textField == mToAddressInput
        {
            mReceiverAddress = textField.text
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        mAmountInput.resignFirstResponder()
        mNoteInput.resignFirstResponder()
        
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        // No more than one dot.
        if string == "." && (textField.text ?? "").contains(".")
        {
            return false
        }
        
        return true
    }
}

private extension SendViewController
{
    var mkDefaultReceiverAddress: String
    {
        return "erd1lstsyc8wu8ckw4gdjckuaev463h3xxzun7ne9ewqk6scu4yfzfhqg2zwa8"
    }
    
    func configure()
    {
        view.backgroundColor = .white
        title = "Send"
        
        configureToAddressInput()
        configureAmountInput()
        configureNoteInput()
        configureGifPlayer()
        configureFeeLabel()
        configureInputsStack()
        configureGifBtn()
        configureSendBtn()
        configureGiphyVc()
        configureDeleteGifBtn()
        configureWarningLabel()
    }
    
    func configureToAddressInput()
    {
        mToAddressInput = .init()
        
        mToAddressInput.placeholder = "Receiver Address (Optional, uses default)"
        mToAddressInput.delegate = self
    }
    
    func configureAmountInput()
    {
        mAmountInput = .init()
        
        mAmountInput.placeholder = "Amount (EGLD)"
        mAmountInput.delegate = self
        mAmountInput.keyboardType = .decimalPad
    }
    
    func configureNoteInput()
    {
        mNoteInput = .init()
        
        mNoteInput.placeholder = "Note"
        mNoteInput.delegate = self
        mNoteInput.rightViewMode = .always
    }
    
    func configureInputsStack()
    {
        mInputsStackView = .init(arrangedSubviews: [mToAddressInput, mAmountInput, mNoteInput, mFeeLabel, mGifPlayer])
        
        mInputsStackView.translatesAutoresizingMaskIntoConstraints = false
        mInputsStackView.axis = .vertical
        mInputsStackView.distribution = .equalSpacing
        mInputsStackView.alignment = .leading
        mInputsStackView.spacing = 10
        
        view.addSubview(mInputsStackView)
        
        mInputsStackView.snp.makeConstraints
        { make in
            make.center.equalTo(self.view.snp.center)
            make.width.equalTo(self.view.snp.width).inset(kMargin)
        }
        
        mToAddressInput.snp.makeConstraints { make in make.width.equalTo(self.mInputsStackView.snp.width) }
        mAmountInput.snp.makeConstraints { make in make.width.equalTo(self.mInputsStackView.snp.width) }
        mNoteInput.snp.makeConstraints { make in make.width.equalTo(self.mInputsStackView.snp.width) }
        mGifPlayer.snp.makeConstraints
        { make in
            make.width.equalTo(self.view.snp.width).multipliedBy(0.33)
            make.height.equalTo(self.view.snp.width).multipliedBy(0.33)
        }
        
        //        NSLayoutConstraint.activate(
        //            [
        //                mInputsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        //                mInputsStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        //                mInputsStackView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -kMargin  * 2),
        //                mToAddressInput.widthAnchor.constraint(equalTo: mInputsStackView.widthAnchor),
        //                mAmountInput.widthAnchor.constraint(equalTo: mInputsStackView.widthAnchor),
        //                mNoteInput.widthAnchor.constraint(equalTo: mInputsStackView.widthAnchor),
        //                mGifPlayer.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.33),
        //                mGifPlayer.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.33),
        //            ]
        //        )
    }
    
    func configureGifBtn()
    {
        mGifBtn = .init(type: .system)
        
        mGifBtn.setTitle("GIF", for: .normal)
        mGifBtn.setTitleColor(.systemBlue, for: .normal)
        mGifBtn.titleLabel?.font = .systemFont(ofSize: TextField.sInputFont.pointSize, weight: .semibold)
        mGifBtn.addTarget(self, action: #selector(presentGifCollection), for: .touchUpInside)
        mGifBtn.contentEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: kMargin / 2)
        
        mNoteInput.rightView = mGifBtn
    }
    
    func configureSendBtn()
    {
        mSendBtn = .init(title: "Send EGLD", onSendAction)
        
        view.addSubview(mSendBtn)
        
        NSLayoutConstraint.activate(
            [
                mSendBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                mSendBtn.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -kMargin * 2)
            ]
        )
        
        mSendBtnBottomConstraint = mSendBtn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -safeAreaInsets.bottom)
        mSendBtnBottomConstraint.isActive = true
    }
    
    func configureGiphyVc()
    {
        mGiphyVc = .init()
        
        mGiphyVc.mediaTypeConfig = [.gifs]
        mGiphyVc.delegate = self
    }
    
    func configureGifPlayer()
    {
        mGifPlayer = .init(url: nil)
        
        mGifPlayer.translatesAutoresizingMaskIntoConstraints = false
        mGifPlayer.layer.cornerRadius = 16
        mGifPlayer.layer.cornerCurve = .continuous
        mGifPlayer.layer.masksToBounds = true
        mGifPlayer.layer.opacity = 0
    }
    
    func configureDeleteGifBtn()
    {
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        let symbolImg = UIImage(systemName: "xmark", withConfiguration: symbolConfig)
        
        mDeleteGifBtn = .init(type: .system)
        
        mDeleteGifBtn.translatesAutoresizingMaskIntoConstraints = false
        mDeleteGifBtn.setImage(symbolImg, for: .normal)
        mDeleteGifBtn.tintColor = .white
        mDeleteGifBtn.layer.shadowColor = UIColor.black.cgColor
        mDeleteGifBtn.layer.shadowOffset = .zero
        mDeleteGifBtn.layer.shadowRadius = 5
        mDeleteGifBtn.layer.shadowOpacity = 0.35
        mDeleteGifBtn.addTarget(self, action: #selector(didDeleteGif), for: .touchUpInside)
        
        mGifPlayer.addSubview(mDeleteGifBtn)
        
        mDeleteGifBtn.snp.makeConstraints
        { make in
            make.trailing.equalTo(self.mGifPlayer.snp.trailing).inset(5)
            make.top.equalTo(self.mGifPlayer.snp.top).inset(5)
        }
        //        NSLayoutConstraint.activate(
        //            [
        //                mDeleteGifBtn.trailingAnchor.constraint(equalTo: mGifPlayer.trailingAnchor, constant: -5),
        //                mDeleteGifBtn.topAnchor.constraint(equalTo: mGifPlayer.topAnchor, constant: 5)
        //            ]
        //        )
    }
    
    func configureWarningLabel()
    {
        mWarningLabel = .init()
        
        mWarningLabel.translatesAutoresizingMaskIntoConstraints = false
        mWarningLabel.font = .preferredFont(forTextStyle: .footnote)
        mWarningLabel.textColor = .red
        mWarningLabel.text = "Invalid amount. Should be higher than 0!"
        mWarningLabel.layer.opacity = 0
        
        view.addSubview(mWarningLabel)
        
        mWarningLabel.snp.makeConstraints
        { make in
            make.leading.equalTo(self.mSendBtn.snp.leading).inset(10)
            make.bottom.equalTo(self.mSendBtn.snp.top).inset(-5)
        }
        //        NSLayoutConstraint.activate(
        //            [
        //                mWarningLabel.leadingAnchor.constraint(equalTo: mSendBtn.leadingAnchor),
        //                mWarningLabel.bottomAnchor.constraint(equalTo: mSendBtn.topAnchor, constant: -5)
        //            ]
        //        )
    }
    
    func configureFeeLabel()
    {
        mFeeLabel = .init()
        
        mFeeLabel.font = .preferredFont(forTextStyle: .footnote)
        mFeeLabel.textColor = .systemBlue
    }
}

private extension SendViewController
{
    func onSendAction()
    {
        guard let hdWallet = hdWallet else { return }
        let toAddress = mReceiverAddress ?? mkDefaultReceiverAddress
        let amount = mEgldAmount ?? "0"
        let gifUrl = mGifUrlStr ?? ""
        
        mAmountInput.text = ""
        didDeleteGif()
        
        hdWallet.sendEgld(amount: amount, toAddress: toAddress, gifUrl: gifUrl)
        { success, msg in
            DispatchQueue.main.async
            {
                self.mWarningLabel.text = msg
                self.mWarningLabel.layer.opacity = 1
            }
        }
    }
    
    @objc func presentGifCollection()
    {
        present(mGiphyVc, animated: true, completion: nil)
    }
    
    @objc func didDeleteGif()
    {
        mGifUrlStr = nil
        mGifPlayer.updateUrlWith(url: nil)
        mFeeLabel.text = nil
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut)
        {
            self.mGifPlayer.layer.opacity = 0
        }
    }
}
