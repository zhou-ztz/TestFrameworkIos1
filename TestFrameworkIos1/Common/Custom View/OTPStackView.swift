//
//  OTPStackView.swift
//  Yippi
//
//  Created by John Wong on 03/11/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import UIKit


protocol OTPDelegate: class {
    func didChangeValidity(isValid: Bool)
}

class OTPTextField: UITextField {
    weak var previousTextField: OTPTextField?
    weak var nextTextField: OTPTextField?
    override public func deleteBackward(){
        text = ""
        previousTextField?.becomeFirstResponder()
    }
}

class OTPStackView: UIStackView {
    
    let numberOfFields = 6
    var textFieldsCollection: [OTPTextField] = []
    weak var delegate: OTPDelegate?
    var showsWarningColor = false
    
    let inactiveFieldBorderColor = UIColor.lightGray
    let textBackgroundColor = UIColor(white: 1, alpha: 0.5)
    let activeFieldBorderColor = UIColor(red: 59.0/255.0, green: 179.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    var remainingStrStack: [String] = []
    
    let codeStackView: UIStackView = UIStackView()
    let errorLabel: UILabel = UILabel()
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStackView()
        addOTPFields()
    }
    
    //Customisation and setting stackView
    private final func setupStackView() {
        self.backgroundColor = .clear
        self.alignment = .fill
        self.distribution = .fill
        self.axis = .vertical
        self.spacing = 8
        self.addArrangedSubview(codeStackView)
        self.addArrangedSubview(errorLabel)
        
        codeStackView.backgroundColor = .clear
        codeStackView.isUserInteractionEnabled = true
        codeStackView.translatesAutoresizingMaskIntoConstraints = false
        codeStackView.contentMode = .center
        codeStackView.distribution = .equalSpacing
        
        errorLabel.isHidden = true
        errorLabel.applyStyle(.regular(size: 12, color: AppTheme.red))
        errorLabel.numberOfLines = 0
        errorLabel.textAlignment = .right
    }
    
    func showError() {
        self.errorLabel.makeVisible()
        self.layoutIfNeeded()
        self.superview?.layoutIfNeeded()
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
    
    private final func addOTPFields() {
        for index in 0..<numberOfFields{
            let field = OTPTextField()
            setupTextField(field)
            textFieldsCollection.append(field)
            index != 0 ? (field.previousTextField = textFieldsCollection[index-1]) : (field.previousTextField = nil)
            index != 0 ? (textFieldsCollection[index-1].nextTextField = field) : ()
        }
    }
    
    private final func setupTextField(_ textField: OTPTextField){
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        codeStackView.addArrangedSubview(textField)
        textField.backgroundColor = textBackgroundColor
        textField.textAlignment = .center
        textField.adjustsFontSizeToFitWidth = false
        textField.font = UIFont(name: "Kefa", size: 20)
        textField.textColor = .black
        textField.roundCorner()
        textField.layer.borderWidth = 1
        textField.layer.borderColor = inactiveFieldBorderColor.cgColor
        textField.keyboardType = .numberPad
        textField.autocorrectionType = .yes
        textField.isSecureTextEntry = false
        
        textField.snp.makeConstraints {
            $0.height.width.equalTo(50)
        }
        
        if #available(iOS 12.0, *) {
            textField.textContentType = .oneTimeCode
        }
    }
    
    private final func checkForValidity() {
        for fields in textFieldsCollection {
            if (fields.text == ""){
                delegate?.didChangeValidity(isValid: false)
                return
            }
        }
        delegate?.didChangeValidity(isValid: true)
    }
    
    final func getOTP() -> String {
        var OTP = ""
        for textField in textFieldsCollection {
            OTP += textField.text ?? ""
        }
        return OTP
    }

    final func setAllFieldColor(isWarningColor: Bool = false, color: UIColor){
        for textField in textFieldsCollection{
            textField.layer.borderColor = color.cgColor
        }
        showsWarningColor = isWarningColor
    }
    
    //autofill textfield starting from first
    private final func autoFillTextField(with string: String) {
        remainingStrStack = string.reversed().compactMap{String($0)}
        for textField in textFieldsCollection {
            if let charToAdd = remainingStrStack.popLast() {
                textField.text = String(charToAdd)
            } else {
                break
            }
        }
        checkForValidity()
        remainingStrStack = []
    }
    
    public func clearFields() {
        for textField in textFieldsCollection {
            textField.text = ""
        }
        textFieldsCollection[0].becomeFirstResponder()
    }
    
}

extension OTPStackView: UITextFieldDelegate {
        
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if showsWarningColor {
            setAllFieldColor(color: inactiveFieldBorderColor)
            showsWarningColor = false
        }
        textField.layer.borderColor = activeFieldBorderColor.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkForValidity()
        textField.layer.borderColor = inactiveFieldBorderColor.cgColor
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range:NSRange,
                   replacementString string: String) -> Bool {
        guard let textField = textField as? OTPTextField else {
            return true
        }
        if string.count > 1 {
            textField.resignFirstResponder()
            autoFillTextField(with: string)
            return false
        } else {
            if (range.length == 0){
                if !string.replacingOccurrences(of: " ", with: "").isEmpty {
                    if let selectedTextField = textFieldsCollection.first(where: { ($0.text ?? "").isEmpty }) {
                        selectedTextField.becomeFirstResponder()
                        selectedTextField.text? = string
                        if textField.nextTextField == nil {
                            textField.resignFirstResponder()
                        } else {
                            textField.nextTextField?.becomeFirstResponder()
                        }
                        return false
                    }
                    return false
                }
            }
            return true
        }
    }
    
}
