//
//  AuthTextField.swift
//  Yippi
//
//  Created by francis on 23/07/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation
import UIKit


class AuthTextfield: CustomTextfield {
    
    weak var delegate: AuthTextfieldDelegate?
    var type: AuthFieldType
    var countryCode: String? = Country.default.phoneCode {
        didSet {
            countryCodeLabel.text = countryCode
        }
    }
    var code: String {
        return countryCodeLabel.text ?? ""
    }
    
    var minAmt: String? = ""
    var maxAmt: String? = ""
    var isPanda: Bool? = false
    var currency: String? = ""
    
    init(type: AuthFieldType, delegate: AuthTextfieldDelegate, minAmt: String? = nil, isPanda: Bool? = nil, currency: String? = nil, maxAmt: String? = nil) {
        self.type = type
        super.init(frame: .zero)
        self.delegate = delegate
        self.minAmt = minAmt
        self.maxAmt = maxAmt
        self.isPanda = isPanda
        self.currency = currency
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.type = .username
        super.init(coder: aDecoder)
    }
    
    
    override func setupView() {
        super.setupView()
        textfield.delegate = self
        
    }
    @objc func countryCodeDidTapped() {
        self.delegate?.countryCodeDidTapped(view: self)
    }
    
    override func configure() {
        phoneView.makeHidden()
        
        switch type {
        case .username:
            placeholder = "placeholder_username".localized
            textfield.autocorrectionType = .no
            textfield.autocapitalizationType = .none
            break
        case .otp:
            placeholder = "OTP".localized.uppercased()
            textfield.keyboardType = .numberPad
            break
        case .password:
            placeholder = "".localized
            textfield.isSecureTextEntry = true
            textfield.keyboardType = .default
            break
        case .newPassword:
            placeholder = "new_password".localized
            textfield.isSecureTextEntry = true
            textfield.keyboardType = .default
            break
        case .confirmNewPassword:
            placeholder = "retype_new_password".localized
            textfield.isSecureTextEntry = true
            textfield.keyboardType = .default
            break
        case .confirmPassword:
            placeholder = "placeholder_confirm_pwd".localized
            textfield.keyboardType = .default
            textfield.isSecureTextEntry = true
            break
        case .oldPassword:
            placeholder = "old_password".localized
            textfield.keyboardType = .default
            textfield.isSecureTextEntry = true
            break
        case .phoneNumber:
            placeholder = "placeholder_phone_no".localized
            textfield.keyboardType = .numberPad
            phoneView.makeVisible()
            let tap = UITapGestureRecognizer(target: self, action: #selector(countryCodeDidTapped))
            phoneView.addGestureRecognizer(tap)
            countryCodeLabel.makeVisible()
            countryCodeLabel.text = countryCode
            break
        case .referral:
            placeholder = "authentication_placeholder_referral".localized
            textfield.keyboardType = .default
            break
        case .accountId:
            placeholder = "mobile_top_up_payment_history_provider_account_id".localized
            textfield.keyboardType = .default
            break
        case .name:
            placeholder = "user_name".localized
            textfield.keyboardType = .default
            textNumLabel.makeVisible()
            break
        case .vote:
            textfield.keyboardType = .default
            break
            
        case .icNo:
            placeholder = "srs_utilities_placeholder_ic_no".localized
            break
        case .notEnabled:
            textfield.isUserInteractionEnabled = false
            wrapper.backgroundColor = UIColor(red: 237.0/255.0, green: 237.0/255.0, blue: 237.0/255.0, alpha: 1.0)
            titleView.textColor = UIColor(red: 165, green: 165, blue: 165)
            break
        case .email:
            textfield.keyboardType = .default
            break
        case .website:
            textfield.keyboardType = .default
            break
        case .redPacket:
            textfield.keyboardType = .numberPad
            break
        case .bestWish:
            textfield.keyboardType = .default
            break
        default:break
        }
    }
    
}

extension AuthTextfield {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        ///群投票
        if type == .vote {
            if textfield.text!.count + string.count > 20 &&  string.count != 0{
                return false
            }
            return true
        }
        
        if type == .redPacket {
            let currentCharacterCount = textField.text?.count ?? 0
            if range.length + range.location > currentCharacterCount {
                return false
            }
            let newLength = currentCharacterCount + string.count - range.length
            return newLength <= 10 - 1
        }
        
        if type == .amount {
            guard let oldText = textField.text, let r = Range(range, in: oldText) else {
                return true
            }
            
            var newText = oldText.replacingCharacters(in: r, with: string)
            //有”，“先去掉
            if newText.contains(",") {
                let currentText = newText.replacingOccurrences(of: ",", with: "")
                newText = currentText
            }
            
            let isNumeric = newText.isEmpty || (Double(newText) != nil)
            //小数点的个数
            let numberOfDots = newText.components(separatedBy: ".").count - 1
            
            //防止首位为0
            let numbers = newText.components(separatedBy: ".")
            if numbers.count >= 1 {
                if let str = numbers.first, str.count >= 2, let index = str.first , index == "0"{
                    return false
                }
            }
            
            //第一次进来
            if !newText.contains(".") && oldText.count == 0 {
                let text = (Double(newText) ?? 0) / 100.00
                textField.text = text.tostring(decimal: 2, grouping: false)
                self.delegate?.textFieldHandler(-1, type: type, view: self)
                return false
            }
            
            if let dotIndex = newText.index(of: ".") {
                let num = newText.distance(from: dotIndex, to: newText.endIndex) - 1
                if num >= 3 {
                    let text = (Double(newText) ?? 0) * 10.00
                    textField.text = text.tostring(decimal: 2)
                    self.delegate?.textFieldHandler(-1, type: type, view: self)
                    return false
                } else if num < 2 {
                    let text = (Double(newText) ?? 0) / 10.00
                    textField.text = text.tostring(decimal: 2)
                    self.delegate?.textFieldHandler(-1, type: type, view: self)
                    return false
                } else if num == 2 { //在小数点前删除、插入数字时，需要处理 ”，“
                    let text = Double(newText) ?? 0
                    textField.text = text.tostring(decimal: 2)
                    self.delegate?.textFieldHandler(-1, type: type, view: self)
                    return false
                }
            }
            
            let numberOfDecimalDigits: Int
            if let dotIndex = newText.index(of: ".") {
                numberOfDecimalDigits = newText.distance(from: dotIndex, to: newText.endIndex) - 1
            } else {
                numberOfDecimalDigits = 0
            }
            
            return isNumeric && numberOfDots <= 1 && numberOfDecimalDigits <= 2
        }
        
        return true
    }
    
    override func textFieldDidBeginEditing(_ textField: UITextField) {
        super.textFieldDidBeginEditing(textField)
    }
    
    override func textFieldDidEndEditing(_ textField: UITextField) {
        super.textFieldDidEndEditing(textField)
      //  AuthInputValidator.validate(state: .notSpecified, for: true, inputView: self)
        
        self.delegate?.textDidEndEditing(textField.text.orEmpty, type: type, view: self)
    }
    
    @objc override func textFieldDidChange(_ textField: UITextField) {
        super.textFieldDidChange(textField)
        switch type {
        case .otp:
            if textField.text.orEmpty.count > 6 {
                let str = textField.text.orEmpty
                textField.text = String(str.suffix(6))
            }
            //        case .email:
            //            if self.validateAsEmail() == true{
            //                self.textfield.textColor = .black
            //            }else{
            //                self.textfield.textColor = AppTheme.errorRed
            //            }
        case .name:
            self.textNumLabel.text = "\(self.textfield.text?.count ?? 0)/20"
            
        default: break
            
        }
        if let text = textfield.text {
            self.delegate?.textDidChanged(text, type: type, view: self)
        }
    }
    
    @discardableResult
    func verifyInputs() -> Bool {
        let text = textfield.text.orEmpty
        
        switch type {
        case .username:
            if text.count < Constants.minimumUsernameLength {
                showError("rw_text_invalid_username_length".localized)
                return false
            } else if text.count > Constants.maximumUsernameLength {
                showError("rw_text_invalid_username_length".localized)
                return false
            } else {
                hideError()
            }
        case .email:
            if text.isEmpty {
                showError("无效的电子邮件地址".localized)
                return false
            }
        case .password, .newPassword:
            if text.isEmpty {
                showError("warning_pwd_cnt_empty".localized)
                return false
            }
            
        case .confirmPassword ,.confirmNewPassword:
            if text.isEmpty {
                showError("warning_pwd_cnt_empty".localized)
                return false
            }
            
        case .otp:
            if text.isEmpty {
                showError("cannot_be_empty".localized)
                return false
            }
            
        case .phoneNumber:
            if text.isEmpty {
                showError("cannot_be_empty".localized)
                return false
            }
            
        case .accountId:
            if text.isEmpty {
                showError("cannot_be_empty".localized)
            }
            
        case .icNo:
            if text.isEmpty {
                showError("cannot_be_empty".localized)
            }
            
        case .amount:
            if isPanda ?? false {
                if Double(text) ?? 0.00 < Double(self.minAmt ?? "") ?? 0.00 || Double(text) ?? 0.00 > Double(self.maxAmt ?? "") ?? 0.0 {
                    showError(String(format: "rw_text_defined_amount_error_value_ios".localized, currency ?? "", minAmt ?? "", currency ?? "", maxAmt ?? ""))
                    return false
                }
            }
        default:
            break
        }
        
        return true
    }
    
}

extension AuthTextfield {
    public func roundBorder() {
        wrapper.clipsToBounds = true
        wrapper.layer.cornerRadius = 10.0
    }
    
    public func checkForInvalidCharacters() -> Bool {
        var validationString = [String]()
        if self.texts.unicodeScalars.first(where: { !$0.isASCII }) != nil {
            validationString.append("text_emoji".localized)
        }
        if self.texts.contains(CharacterSet.whitespacesAndNewlines) {
            validationString.append("text_spacebar".localized)
        }
        if !validationString.isEmpty {
            var finalErrorString = "text_password_security_error".localized
            if shouldPutSpace() {
                finalErrorString += " "
            }
            finalErrorString += validationString.joined(separator: ", ")
            self.showError(finalErrorString)
            return false
        }
        return true
    }
    
    public func validateAsPassword() -> Bool {
        var validationString = [String]()
        if self.texts.count < 8 {
            validationString.append("text_password_security_characters".localized)
        }
        if !self.texts.isMatchRegex(".*[A-Z]+.*") {
            let errString = buildContainsErrorString(onValidationString: validationString, errString: "text_password_security_uppercase".localized)
            validationString.append(errString)
        }
        if !self.texts.isMatchRegex(".*[a-z]+.*") {
            let errString = buildContainsErrorString(onValidationString: validationString, errString: "text_password_security_lowercase".localized)
            validationString.append(errString)
        }
        if !self.texts.isMatchRegex(#".*[:;()$&".,?!\[{}#%^*=_~<>@]+.*"#) {
            let errString = buildContainsErrorString(onValidationString: validationString, errString: "text_password_security_symbol".localized)
            validationString.append(errString)
        }
        if !self.texts.isMatchRegex(".*[0-9]+.*") {
            let errString = buildContainsErrorString(onValidationString: validationString, errString: "text_password_security_digit".localized)
            validationString.append(errString)
        }
        if !validationString.isEmpty {
            var finalErrorString = "text_password_security".localized
            if shouldPutSpace() {
                finalErrorString += " "
            }
            finalErrorString += validationString.joined(separator: ", ")
            self.showError(finalErrorString)
            return false
        }
        return true
    }
    public func validateAsEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+\\@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self.texts)
        //        var validationString = [String]()
        //        if !self.texts.isMatchRegex("[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}") {
        //            validationString.append("text_password_security_characters".localized)
        //        }
        //        if self.texts.count == 0 {
        //            return false
        //        }
        //        if !validationString.isEmpty {
        //            return false
        //        }
        //        return true
    }
    private func buildContainsErrorString(onValidationString validationString:[String], errString:String) -> String {
        var newErrString = ""
        if !validationString.contains(where: { $0.contains("text_password_security_contains".localized) }) {
            newErrString += "text_password_security_contains".localized
        }
        if shouldPutSpace() {
            newErrString += " "
        }
        newErrString += errString
        return newErrString
    }
    
    private func shouldPutSpace() -> Bool {
        let currentLanguage = LanguageIdentifier(rawValue: LocalizationManager.getCurrentLanguage()) ?? .english
        if currentLanguage == .english || currentLanguage == .malay || currentLanguage == .indonesian || currentLanguage == .vietnamese || currentLanguage == .filipino {
            return true
        }
        return false
    }
}

enum AuthFieldType {
    case username
    case password
    case phoneNumber
    case confirmPassword
    case oldPassword
    case newPassword
    case confirmNewPassword
    case otp
    case referral
    case accountId
    case name
    case vote
    case icNo
    case notEnabled //新增类型：不可编辑
    case email      //新增类型：email
    case website    //新增类型：网页
    case redPacket
    case amount
    case bestWish
}

protocol AuthTextfieldDelegate: class {
    func textDidEndEditing(_ text: String, type: AuthFieldType, view: AuthTextfield)
    func textDidChanged(_ text: String, type: AuthFieldType, view: AuthTextfield)
    func countryCodeDidTapped(view: AuthTextfield)
    func textFieldHandler(_ selectedPrice: Int, type: AuthFieldType, view: AuthTextfield)
}
