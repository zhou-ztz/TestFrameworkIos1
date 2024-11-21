// 
// Copyright © 2018 Toga Capital. All rights reserved.
//


import UIKit

class CustomTextfield: UIView {

    @IBOutlet var container: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var stackview: UIStackView!
    @IBOutlet weak var errorLabel: UILabel!
    //显示输入字数
    @IBOutlet weak var textNumLabel: UILabel!
    @IBOutlet weak var phoneView: UIView!
    @IBOutlet weak var countryCodeLabel: UILabel!
    @IBOutlet weak var dropdownImage: UIImageView!
    @IBOutlet weak var wrapper: UIView!
    @IBOutlet weak var infoButton: UIButton!
    
    let textfield: UITextField = UITextField()
    let showHidePasswordButton: UIButton = UIButton(frame: .zero).configure {
        $0.setImage(UIImage.set_image(named: "ic_showpassword"), for: .normal)
        $0.setImage(UIImage.set_image(named: "ic_hidepassword"), for: .selected)
        $0.imageView?.contentMode = .scaleAspectFit
        $0.contentVerticalAlignment = .fill
        $0.contentHorizontalAlignment = .fill
        $0.imageEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    }
    let textWrapper: UIView = UIView(frame: .zero).configure {
        $0.backgroundColor = .clear
    }
    let contentStackView: UIStackView = UIStackView().configure {
        $0.alignment = .fill
        $0.distribution = .fill
        $0.axis = .horizontal
    }
    
    var placeholder: String = "" {
        willSet {
            self.titleView.text = newValue
        }
    }
    
    var attributePlaceholder: NSAttributedString? {
        willSet {
            self.titleView.attributedText = newValue
        }
    }
    
    var texts: String {
        get {
            return textfield.text.orEmpty
        }
        set {
            self.textfield.text = newValue
            if newValue.isEmpty && textfield.isEditing == false {
                animateRestore(animated: false)
            } else {
                animateToSelected(animated: false)
            }
        }
    }
    
    var needBorder: Bool = true
    
    var titleView = UILabel().configure {
        $0.setFontSize(with: 14, weight: .norm)
        $0.textColor = NormalColor().textFieldPlaceholder
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        setupView()
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        setupView()
        configure()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed(String(describing: CustomTextfield.self), owner: self, options: nil)
        container.frame = self.bounds
        container.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(container)
        titleView.textColor = AppTheme.lightGrey
        if placeholder.isEmpty == false {
            titleView.text = placeholder
        } else {
            textWrapper.backgroundColor = UIColor(hexString: "#F5F5F5")
            titleView.attributedText = attributePlaceholder
        }
    }
    
    func setupView() {
        textWrapper.backgroundColor = .white
        container.sizeToFit()
        errorLabel.makeHidden()
        textNumLabel.makeHidden()
        infoButton.makeHidden()
        showHidePasswordButton.makeHidden()
        errorLabel.numberOfLines = 0
        //if placeholder.isEmpty == false {
        if needBorder {
            wrapper.applyBorder(color: AppTheme.lightGrey, width: 0.5)
        }
        //}
        wrapper.roundCorner()
        errorLabel.applyStyle(.regular(size: 12, color: AppTheme.errorRed))
        textNumLabel.applyStyle(.regular(size: 10, color: AppTheme.headerTitleGrey))
        countryCodeLabel.applyStyle(.regular(size: 14   , color: AppTheme.black))
        dropdownImage.tintColor = AppTheme.black
        
        contentStackView.addArrangedSubview(textWrapper)
        contentStackView.addArrangedSubview(showHidePasswordButton)
        wrapper.addSubview(contentStackView)
        contentStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        textWrapper.addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(6)
        }
        
        textWrapper.addSubview(textfield)
        textfield.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(6)
        }
        textfield.add(event: .editingChanged) { [weak self] in
            guard let self = self else { return }
            self.textFieldDidChange(self.textfield)
        }
        showHidePasswordButton.snp.makeConstraints {
            $0.width.equalTo(showHidePasswordButton.snp.height)
        }
        showHidePasswordButton.addTap { [weak self] (_) in
            guard let self = self else { return }
            self.showHidePasswordButton.isSelected.toggle()
            self.textfield.isSecureTextEntry.toggle()
        }
    }
    
    
    func showError() {
        self.errorLabel.makeVisible()
        self.container.layoutIfNeeded()
        superview?.layoutIfNeeded()
    }
    
    func showError(_ text: String) {
        self.errorLabel.text = text
        showError()
    }
    
    
    func hideError() {
        if errorLabel.isHidden == false {
            self.errorLabel.makeHidden()
        }
    }
    
    
    func animateToSelected(animated: Bool = true, isFirst: Bool = false) {
        titleView.snp.remakeConstraints {
            $0.left.right.top.equalToSuperview().inset(6)
        }
        
        textfield.snp.remakeConstraints { (make) in
            make.top.equalTo(titleView.snp.bottom).offset(6)
            make.left.right.bottom.equalToSuperview().inset(6)
        }
        
        UIView.animate(withDuration: animated ? 0.25 : 0) {
            self.layoutIfNeeded()
            self.titleView.setFontSize(with: 10, weight: .bold)
            if isFirst {
                self.titleView.textColor = AppTheme.lightGrey
            } else {
                self.titleView.textColor = AppTheme.black
            }
            if self.placeholder.isEmpty == false {
                self.titleView.text = self.placeholder
            } else {
                self.titleView.attributedText = self.attributePlaceholder
            }
        }
    }
    
    
    func animateRestore(animated: Bool = true) {
        titleView.snp.remakeConstraints {
            $0.edges.equalToSuperview().inset(6)
        }
        
        textfield.snp.remakeConstraints { (make) in
            make.edges.equalToSuperview().inset(6)
        }
        
        UIView.animate(withDuration: animated ? 0.25 : 0) {
            self.layoutIfNeeded()
            self.titleView.setFontSize(with: 14, weight: .norm)
            self.titleView.textColor = AppTheme.lightGrey
            if self.placeholder.isEmpty == false {
                self.titleView.text = self.placeholder
            } else {
                self.titleView.attributedText = self.attributePlaceholder
            }
        }
    }
    
    
    var isFieldEmpty: Bool {
        if let text = textfield.text {
            return text.count == 0
        }
        return false
    }
    
    func configure() { }
}


extension CustomTextfield: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        hideError()
        if needBorder {
            wrapper.applyBorder(color: AppTheme.black, width: 1.0)
        }
        animateToSelected(animated: false)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        titleView.textColor = AppTheme.lightGrey
        
        if placeholder.isEmpty == true {
            //            wrapper.applyBorder(color: AppTheme.black, width: 0.5)
            //            titleView.text = self.placeholder
            //        } else {
            if needBorder {
                wrapper.applyBorder(color: AppTheme.lightGrey, width: 0.5)
            }
            titleView.attributedText = self.attributePlaceholder
        }
        
        if textField.text.orEmpty.isEmpty {
            animateRestore()
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        hideError()
        
        if textField.text.orEmpty.isEmpty == false {
            animateToSelected()
        }
    }
}

