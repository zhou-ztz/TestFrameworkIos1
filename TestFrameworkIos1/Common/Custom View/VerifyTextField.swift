//
//  VerifyTextField.swift
//  Yippi
//
//  Created by francis on 23/07/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation

import SnapKit

enum VerifyFieldType {
    case name
    case id
    case birthday
    case gender
    case birthdaySignUp
}

enum GenderType: Int {
    case keepSecret = 0
    case male = 1
    case female = 2
    
    var stringValue: String {
        switch self {
        case .keepSecret:
            return "keep_secret".localized
        case .female:
            return "female".localized
        case .male:
            return "male".localized
        }
    }
    
    static var values: [String] {
        return ["keep_secret".localized, "male".localized, "female".localized]
    }
}

class VerifyTextField: CustomTextfield {
    
    let datePicker: UIDatePicker = UIDatePicker()
    let picker: UIPickerView = UIPickerView()
    var type: VerifyFieldType = .name
    
    var onTextDidEndEditing: ((_ text: String, _ type: VerifyFieldType) -> ())?
    var onTextDidChanged: ((_ text: String, _ type: VerifyFieldType) -> ())?
    var onDateDidSelect: ((Date) -> Void)?
    var onGenderDidSelect: ((Int) -> Void)?
    
    var calenderImageView: UIImageView = UIImageView(frame: .zero).configure {
        $0.image = UIImage.set_image(named: "kyc_calender")
    }
    
    init(type: VerifyFieldType) {
        self.type = type
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.type = .name
        super.init(coder: aDecoder)
    }
    
    override func setupView() {
        super.setupView()
        textfield.delegate = self
    }
    
    override func configure() {
        phoneView.makeHidden()
        
        switch type {
        case .name:
            placeholder = "placeholder_fullname_input_hint".localized
            textfield.keyboardType = .default
            
        case .id:
            placeholder = "placeholder_id_input_hint".localized
            textfield.keyboardType = .numbersAndPunctuation
            
        case .birthday:
            placeholder = "placeholder_birthday_hint".localized
            setupBirthday()
            
        case .gender:
            placeholder = "authentication_placeholder_birthday".localized
            setupGenderPicker()
            break
        case .birthdaySignUp:
            placeholder = "birthday".localized
            setupBirthday(isLogin: true)
        }
    }
    
    
    private func donedatePicker(){
        textfield.text = datePicker.date.toFormat("dd-MM-yyyy")
        
        onDateDidSelect?(datePicker.date)
        self.textfield.endEditing(true)
    }
    
    private func cancelDatePicker() {
        self.textfield.endEditing(true)
    }
    
    func setupGenderPicker() {
        picker.dataSource = self
        picker.delegate = self
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        
        //done button & cancel button
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: nil, action: nil)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: nil)
        
        doneButton.actionBlock = { [unowned self] _ in
            let selectedTitle = GenderType.values[picker.selectedRow(inComponent: 0)]
            self.textfield.text = selectedTitle
            self.onGenderDidSelect?(picker.selectedRow(inComponent: 0))
            self.textfield.endEditing(true)
            self.onTextDidChanged?(self.textfield.text.orEmpty, self.type)
        }
        cancelButton.actionBlock = { [unowned self] _ in
            self.textfield.endEditing(true)
            self.onTextDidChanged?(self.textfield.text.orEmpty, self.type)
        }
        
        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        
        // add toolbar to textField
        textfield.inputAccessoryView = toolbar
        // add datepicker to textField
        textfield.inputView = picker
    }
    
    func setupBirthday(isLogin: Bool = false) {
        datePicker.timeZone = TimeZone.init(identifier: "UTC")
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        if #available(iOS 14, *) {
            datePicker.preferredDatePickerStyle = .wheels
            datePicker.sizeToFit()
        }
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        
        //done button & cancel button
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: nil, action: nil)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: nil)
        
        doneButton.actionBlock = { [unowned self] _ in
            self.donedatePicker()
            self.onTextDidChanged?(self.textfield.text.orEmpty, self.type)
        }
        cancelButton.actionBlock = { [unowned self] _ in
            self.cancelDatePicker()
            self.onTextDidChanged?(self.textfield.text.orEmpty, self.type)
        }
        
        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        
        // add toolbar to textField
        textfield.inputAccessoryView = toolbar
        // add datepicker to textField
        textfield.inputView = datePicker
        
        calenderImageView.contentMode = .scaleAspectFit
        calenderImageView.tintColor = .black
        textWrapper.addSubview(calenderImageView)
        calenderImageView.snp.makeConstraints {
            $0.width.equalTo(calenderImageView.snp.height)
            $0.top.bottom.equalToSuperview().inset(18)
            $0.right.equalToSuperview().inset(16)
        }
        
        if isLogin {
            calenderImageView.isHidden = true
        }
    }
    
}

extension VerifyTextField: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return GenderType.values.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return GenderType.values[row]
    }
}

extension VerifyTextField {
    
    override func textFieldDidBeginEditing(_ textField: UITextField) {
        super.textFieldDidBeginEditing(textField)
    }
    
    override func textFieldDidEndEditing(_ textField: UITextField) {
        super.textFieldDidEndEditing(textField)
        VerifyInputValidator.validate(shouldShowError: true, inputView: self)
        onTextDidEndEditing?(textField.text.orEmpty, type)
    }
    
    @objc override func textFieldDidChange(_ textField: UITextField) {
        super.textFieldDidChange(textField)
        if let text = textfield.text {
            onTextDidChanged?(text, type)
        }
    }
    
}


class VerifyInputValidator {
    @discardableResult
    static func validate(shouldShowError: Bool = false, inputView: DynamicTextField...) -> Bool {
        
        let showError = { (view: DynamicTextField, text: String) in
            guard shouldShowError == true else { return }
            view.showError(text)
        }

        var result = true
        
        for view in inputView {
            let text = view.texts
            
            if view.isOptional == false {
                switch text.count {
                case 0:
                    showError(view, "warning_mandatory_textfield".localized)
                    result = false
                case ..<view.minimumChar:
                    showError(view, String(format: "warning_min_char".localized, view.minimumChar))
                    result = false
                case (view.maximumChar+1)...:
                    result = false
                    showError(view, String(format: "warning_max_char".localized, view.maximumChar))
                    
                default: result = true
                }
            }
        }
        
        return result
    }
    
    
    
    @discardableResult
    static func validate(shouldShowError: Bool = false, inputView: VerifyTextField...) -> Bool {
        
        let showError = { (view: VerifyTextField, text: String) in
            guard shouldShowError == true else { return }
            view.showError(text)
        }
        
        var result = true
        
        for view in inputView {
            let text = view.texts
            
            switch view.type {
            case .name:
                if text.isEmpty {
                    showError(view, String(format: "warning_cnt_empty".localized, "placeholder_fullname_input_hint".localized))
                    result = false
                }
                
            case .id:
                if text.isEmpty {
                    showError(view, String(format: "warning_cnt_empty".localized, "placeholder_id_input_hint".localized))
                    result = false
                }
                
            case .birthday:
                if text.isEmpty {
                    showError(view, String(format: "warning_cnt_empty".localized, "placeholder_birthday_hint".localized))
                    result = false
                }
            case .gender:
                if text.isEmpty {
                    showError(view, String(format: "warning_cnt_empty".localized, "authentication_placeholder_gender".localized))
                    result = false
                }
            case .birthdaySignUp:
                if text.isEmpty {
                    showError(view, String(format: "warning_cnt_empty".localized, "authentication_placeholder_birthday".localized))
                    result = false
                }
            }
        }
        
        return result
    }
    

}
