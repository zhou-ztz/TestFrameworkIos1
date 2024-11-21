// 
// Copyright © 2018 Toga Capital. All rights reserved.
//


import UIKit


class SMSCodeView: UIView {

    @IBOutlet weak var codeTitle: UILabel!
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var textfield1: CodeTextField!
    @IBOutlet weak var textfield2: CodeTextField!
    @IBOutlet weak var textfield3: CodeTextField!
    @IBOutlet weak var textfield4: CodeTextField!
    @IBOutlet weak var textfield5: CodeTextField!
    @IBOutlet weak var textfield6: CodeTextField!
    @IBOutlet weak var codeDescription: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    var phonenumber: String? {
        didSet {
            updateCodeDesc(code: countryCode.orEmpty, phonenumber: phonenumber.orEmpty)
        }
    }
    var countryCode: String? {
        didSet {
            updateCodeDesc(code: countryCode.orEmpty, phonenumber: phonenumber.orEmpty)
        }
    }
    
    var onComplete: ((String) -> ())?
    
    init(phoneNumber: String) {
        super.init(frame: .zero)
        commonInit()
        self.phonenumber = phoneNumber
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        setupView()
    }
    
    func updateCodeDesc(code: String, phonenumber: String) {
        codeDescription.text = "signup_sms_code_sent_to".localized + " \(code) *******\(phonenumber.suffix(3))"
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("SMSCodeView", owner: self, options: nil)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(containerView)
    }
    
    private func setupView() {
        [textfield1, textfield2, textfield3, textfield4, textfield5, textfield6].enumerated().forEach { (index, textfield) in
            textfield?.applyBorder(color: AppTheme.lightGrey, width: 1.0)
            textfield?.roundCorner(5)
            textfield?.textAlignment = .center
            textfield?.keyboardType = .numberPad
            textfield?.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            textfield?.delegate = self
            textfield?.deleteDelegate = self
            textfield?.tag = index + 1
        }
        
        if #available(iOS 12.0, *) {
            textfield1.textContentType = .oneTimeCode
            textfield1.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }

        updateCodeDesc(code: countryCode.orEmpty, phonenumber: phonenumber.orEmpty)
        errorLabel.applyStyle(.regular(size: 11, color: AppTheme.red))
        codeDescription.applyStyle(.regular(size: 14, color: AppTheme.black))
        codeTitle.text = "authentication_sign_up_title_otp".localized
        codeTitle.applyStyle(.semibold(size: 24, color: AppTheme.black))
        textfield1.becomeFirstResponder()
    }
    
    func setError(_ text: String) {
        errorLabel.text = text
    }
    
    func hideError() {
        errorLabel.text = ""
    }
    
    func getCodes() -> String {
        guard let code1 = textfield1.text,
            let code2 = textfield2.text,
            let code3 = textfield3.text,
            let code4 = textfield4.text,
            let code5 = textfield5.text,
            let code6 = textfield6.text else { return "" }
        return code1 + code2 + code3 + code4 + code5 + code6
    }
}

extension SMSCodeView: UITextFieldDelegate, CodeTextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.applyBorder(color: AppTheme.red, width: 1.0)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.applyBorder(color: AppTheme.lightGrey, width: 1.0)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        return textField.text.orEmpty.count + string.count <= 1
        
//        return true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        let text = textField.text.orEmpty
        if  text.count >= 1 {
            switch textField {
            case textfield1:
                textfield2.becomeFirstResponder()
            case textfield2:
                textfield3.becomeFirstResponder()
            case textfield3:
                textfield4.becomeFirstResponder()
            case textfield4:
                textfield5.becomeFirstResponder()
            case textfield5:
                textfield6.becomeFirstResponder()
            case textfield6:
                textfield6.becomeFirstResponder()
            default:
                break
            }
        }
        
        if  text.count == 0 {
            switch textField {
            case textfield1:
                textfield1.becomeFirstResponder()
            case textfield2:
                textfield1.becomeFirstResponder()
            case textfield3:
                textfield2.becomeFirstResponder()
            case textfield4:
                textfield3.becomeFirstResponder()
            case textfield5:
                textfield4.becomeFirstResponder()
            case textfield6:
                textfield5.becomeFirstResponder()
            default:
                break
            }
        }
        
        let codes = getCodes()
        if codes.count == 6 {
            onComplete?(codes)
        }
    }
    
    func textFieldDidDelete(_ textField: CodeTextField) {
        hideError()
        
        guard let text = textField.text, text.count == 0 else { return }
        
        let previousTag = textField.tag - 1
        // get next responder
        var previousResponder = textField.superview?.viewWithTag(previousTag)
        
        if previousResponder == nil {
            previousResponder = textField.superview?.viewWithTag(0)
        }
        textField.text = ""
        previousResponder?.becomeFirstResponder()
    }
}

protocol CodeTextFieldDelegate {
    func textFieldDidDelete(_ textField: CodeTextField)
}

class CodeTextField: UITextField {
    
    var deleteDelegate: CodeTextFieldDelegate?
    
    override func deleteBackward() {
        super.deleteBackward()
        deleteDelegate?.textFieldDidDelete(self)
    }
}
