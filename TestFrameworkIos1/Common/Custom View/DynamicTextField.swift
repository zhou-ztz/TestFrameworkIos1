//
//  DynamicTextField.swift
//  Yippi
//
//  Created by francis on 09/01/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import UIKit

enum FormType: String {
    case fixedText = "fixedtext"
    case text = "text"
    case dropdown = "dropdown"
    case bottom = "bottom"
    case number = "number"
    case unknown = ""
}

enum BankFieldType {
    case holder
    case accountNumber
    case name
    case branch
    case swift
    case routing
    case taxid
}

class DynamicTextField: CustomTextfield {
       
    private(set) var minimumChar: Int = 0
    private(set) var maximumChar: Int = 0
    
    private lazy var picker: UIPickerView = UIPickerView()

    var fieldKey: String = ""
    var value: String {
        switch formType {
        default:
            return textfield.text.orEmpty
        }
    }
    
    
    private var selected: String? {
        willSet {
            self.textfield.text = newValue.orEmpty
        }
    }
    private var options: [String] = [] {
        willSet {
            picker.reloadAllComponents()
        }
    }
    let dropDownImageView = UIImageView(image: UIImage.set_image(named: "ic_drop_down"))
    
    private var formType: FormType = .unknown {
        didSet {
            switch self.formType {
            case .fixedText:
                textfield.isUserInteractionEnabled = false
                titleView.textColor = AppTheme.lightGrey
            case .number: textfield.keyboardType = .numberPad
            case .text: textfield.keyboardType = .default
            case .dropdown: break
            case .bottom: break
            default: break
            }
        }
    }
        
    var isOptional: Bool {
        return minimumChar == 0
    }
    
    var text: String {
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
    
    var onTextDidEndEditing: ((_ text: String, _ type: BankFieldType) -> ())?
    var onTextDidChanged: ((_ text: String, _ type: BankFieldType) -> ())?
    var onDropdownSelected: ((_ selection: String) -> ())?
    var onTapTextField : (()->())?
    
    var didUpdate: ((_ value: Any?) -> ())?
    
    init(minimumChar: Int = 0, maximumChar: Int = 0) {
        self.minimumChar = minimumChar
        self.maximumChar = maximumChar
        super.init(frame: .zero)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupView()
    }
    
    override func setupView() {
        super.setupView()
        
        configure()
        
        textfield.delegate = self
    }
    
    override func configure() {
        phoneView.makeHidden()
        dropDownImageView.contentMode = .scaleAspectFit
        dropDownImageView.tintColor = .black
        textWrapper.addSubview(dropDownImageView)
        dropDownImageView.snp.makeConstraints {
            $0.width.equalTo(dropDownImageView.snp.height)
            $0.top.bottom.equalToSuperview().inset(18)
            $0.right.equalToSuperview().inset(16)
        }
        dropDownImageView.makeHidden()
    }
    
    
    func setForm(formType: FormType, predefinedValue: String = "", options: [String]) {
        self.formType = formType
        
        switch formType {
        case .fixedText:
            self.text = predefinedValue
            
        case .dropdown:
            self.text = predefinedValue
            self.options = options
            dropDownImageView.makeVisible()
            setupAsDropdownKeyboard()
                     
        case .bottom:
            self.text = predefinedValue
            dropDownImageView.makeVisible()
            
        default: break
        }

    }
    
    
    func setupAsDropdownKeyboard() {
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        
        //done button & cancel button
        let doneButton = UIBarButtonItem(title: "done".localized, style: .plain, target: nil, action: nil)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "cancel".localized, style: .plain, target: nil, action: nil)
        
        doneButton.actionBlock = { [unowned self] _ in
            let index = self.picker.selectedRow(inComponent: 0)
            guard index < self.options.count else { return }
            self.selected = self.options[index]
            self.textfield.endEditing(true)
            self.onDropdownSelected?(self.options[index])
        }
        
        cancelButton.actionBlock = { [unowned self] _ in
            self.textfield.endEditing(true)
        }
        
        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        
        picker.delegate = self
        picker.dataSource = self
        
        picker.reloadAllComponents()
        
        // add toolbar to textField
        textfield.inputAccessoryView = toolbar
        // add datepicker to textField
        textfield.inputView = picker
    }
}


extension DynamicTextField: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.configure { (_label) in
            _label.text = options[row]
            _label.applyStyle(.regular(size: 15, color: .black))
            _label.minimumScaleFactor = 0.7
            _label.textAlignment = .center
        }
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options.count
    }
    
}

extension DynamicTextField {
    
    override func textFieldDidBeginEditing(_ textField: UITextField) {
        dropDownImageView.tintColor = AppTheme.warmBlue
        super.textFieldDidBeginEditing(textField)
        
        if formType == .bottom {
            self.onTapTextField?()
        }
    }
    
    override func textFieldDidEndEditing(_ textField: UITextField) {
        dropDownImageView.tintColor = .black
        super.textFieldDidEndEditing(textField)
        VerifyInputValidator.validate(shouldShowError: true, inputView: self)
        self.didUpdate?(textField.text)
    }
    
    @objc override func textFieldDidChange(_ textField: UITextField) {
        super.textFieldDidChange(textField)
        self.didUpdate?(textField.text)
    }
}

