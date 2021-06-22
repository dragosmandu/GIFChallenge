import UIKit

class TextField: UITextField
{
    static var sInputFont: UIFont
    {
        let font = UIFont.preferredFont(forTextStyle: .body)
        return .systemFont(ofSize: font.pointSize, weight: .regular)
    }
    
    private var mkPadding: UIEdgeInsets
    {
        return .init(top: 0, left: kMargin / 2, bottom: 0, right: kMargin / 2 + (rightView?.frame.width ?? 0))
    }
    private var mToolbar: UIToolbar = .init()
    
    init()
    {
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        textColor = .systemGray2
        layer.masksToBounds = true
        layer.cornerCurve = .continuous
        layer.cornerRadius = TextField.sInputFont.pointSize
        backgroundColor = .systemGray5
        font = TextField.sInputFont
        autocorrectionType = .no
        
        heightAnchor.constraint(equalToConstant: TextField.sInputFont.pointSize * 2).isActive = true
        
        setToolbar()
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect
    {
        return bounds.inset(by: mkPadding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect
    {
        return bounds.inset(by: mkPadding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect
    {
        return bounds.inset(by: mkPadding)
    }
    
    func setToolbar()
    {
        mToolbar = .init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 35))
        let cancelBtn = UIButton(type: .system)
        let doneBtn = UIButton(type: .system)
        
        cancelBtn.addTarget(self, action: #selector(didPressCancel), for: .touchUpInside)
        cancelBtn.setTitleColor(.systemRed, for: .normal)
        cancelBtn.setTitle("Cancel", for: .normal)
        
        doneBtn.addTarget(self, action: #selector(didPressDone), for: .touchUpInside)
        doneBtn.setTitleColor(.systemBlue, for: .normal)
        doneBtn.setTitle("Done", for: .normal)
        
        let cancelBarItem = UIBarButtonItem(customView: cancelBtn)
        let spacerBarItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneBarItem = UIBarButtonItem(customView: doneBtn)
        
        mToolbar.items = [cancelBarItem, spacerBarItem, doneBarItem]
        mToolbar.barStyle = .default
        mToolbar.sizeToFit()
        
        inputAccessoryView = mToolbar
    }
    
    @objc private func didPressCancel()
    {
        text = ""
        resignFirstResponder()
    }
    
    @objc private func didPressDone()
    {
        resignFirstResponder()
    }
}
