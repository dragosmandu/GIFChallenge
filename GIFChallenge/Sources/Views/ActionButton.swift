import UIKit

class ActionButton: UIButton
{
    private var mOnPressAction: () -> Void = { }
    private var mBtnFont: UIFont
    {
        let font = UIFont.preferredFont(forTextStyle: .title3)
        return .systemFont(ofSize: font.pointSize, weight: .semibold)
    }
    
    init(title: String, _ onPressAction: @escaping () -> Void)
    {
        mOnPressAction = onPressAction
        
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        setTitle(title, for: .normal)
        titleLabel?.font = mBtnFont
        setTitleColor(.white, for: .normal)
        backgroundColor = .systemBlue
        layer.masksToBounds = true
        layer.cornerCurve = .continuous
        layer.cornerRadius = mBtnFont.pointSize
        addTarget(self, action: #selector(didPress), for: .touchUpInside)
        heightAnchor.constraint(equalToConstant: mBtnFont.pointSize * 2).isActive = true
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
    override var isHighlighted: Bool
    {
        didSet
        {
            if isHighlighted
            {
                highlightButton()
            }
            else
            {
                unhighlightButton()
            }
        }
    }
    
    override var buttonType: UIButton.ButtonType
    {
        return .system
    }
    
    @objc private func didPress(_ sender: UIButton)
    {
        mOnPressAction()
    }
    
    private var mkHighlightAnimationDuration: Double { return 0.1 }
    private var mkMinHighlightOpacity: Float { return 0.5 }
    private var mkMaxHighlightOpacity: Float { return 1.0 }
    
    private func highlightButton()
    {
        DispatchQueue.main.async
        { [weak self] in
            guard let `self` = self else { return }
            
            self.layer.removeAllAnimations()
            UIView.animate(withDuration: self.mkHighlightAnimationDuration, delay: 0, options: .curveLinear)
            {
                self.layer.opacity = self.mkMinHighlightOpacity
            }
        }
    }
    
    private func unhighlightButton()
    {
        DispatchQueue.main.async
        { [weak self] in
            guard let `self` = self else { return }
            
            self.layer.removeAllAnimations()
            UIView.animate(withDuration: self.mkHighlightAnimationDuration, delay: 0, options: .curveLinear)
            {
                self.layer.opacity = self.mkMaxHighlightOpacity
            }
        }
    }
}
