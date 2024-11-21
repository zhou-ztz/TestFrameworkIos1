//
//  PersonInfoTextField.swift
//  Yippi
//
//  Created by francis on 23/07/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation

import SnapKit

protocol PersonInfoTextFieldDelegate: NSObjectProtocol {
    //点击回调
    func didTextFieldSelect(text: String, type: PersonInfoTextFieldType)
}
enum PersonInfoTextFieldType {
    case gender
    case workIndustry
    case birthday
    case languageUKnow
    case relationshipStatus
    case stay
    case country
    case province
    case city
}
class PersonInfoTextField: CustomTextfield {
    
    var delegate: PersonInfoTextFieldDelegate?
    
    var type: PersonInfoTextFieldType = .workIndustry
    
    let datePicker: UIDatePicker = UIDatePicker()
    let picker: UIPickerView = UIPickerView()
    
    var arrowImageView: UIImageView = UIImageView(frame: .zero).configure {
        $0.image = UIImage.set_image(named: "IMG_sec_nav_arrow")
        $0.contentMode = .scaleAspectFit
        $0.isUserInteractionEnabled = false
    }
    
    init(type: PersonInfoTextFieldType) {
        self.type = type
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.type = .workIndustry
        super.init(coder: aDecoder)
    }
    
    override func setupView() {
        super.setupView()
        textfield.delegate = self
        textfield.addAction {
            self.delegate?.didTextFieldSelect(text: self.textfield.text.orEmpty, type: self.type)
        }
    }
    
    override func configure() {
        phoneView.makeHidden()
        
        switch type {
        case .workIndustry:
            placeholder = "text_work_industry".localized
            textfield.keyboardType = .default
            addArrowImageView()
        case .gender:
            placeholder = "authentication_placeholder_gender".localized
            addArrowImageView()
        case .birthday:
            placeholder = "authentication_placeholder_birthday".localized
            arrowImageView.image = UIImage.set_image(named: "date_calender")
            addArrowImageView()
        case .relationshipStatus:
            placeholder = "text_relationship_status".localized
            addArrowImageView()
        case .stay:
            placeholder = "text_where_stay".localized
        case .country:
            placeholder = "personal_info_country_region".localized
            addArrowImageView()
        case .province:
            placeholder = "personal_info_state_province".localized
            addArrowImageView()
        case .city:
            placeholder = "personal_info_city".localized
            addArrowImageView()
        default:break
        }
    }
    // MARK: - 添加输入框右边的图标
    func addArrowImageView() {
        textWrapper.addSubview(arrowImageView)
        arrowImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().inset(16)
        }
    }
    private func donedatePicker(){
        textfield.text = datePicker.date.toFormat("dd-MM-yyyy")
        self.textfield.endEditing(true)
    }
    
    private func cancelDatePicker() {
        self.textfield.endEditing(true)
    }
    
    func setupGenderPicker() {
    
    }

    
}

extension PersonInfoTextField {
    
    override func textFieldDidBeginEditing(_ textField: UITextField) {
        super.textFieldDidBeginEditing(textField)
        self.textfield.endEditing(true)

    }

    override func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
    @objc override func textFieldDidChange(_ textField: UITextField) {
        super.textFieldDidChange(textField)
    }
    
}


class PersonInfoInputValidator {
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
    static func validate(shouldShowError: Bool = false, inputView: PersonInfoTextField...) -> Bool {
        
        let showError = { (view: PersonInfoTextField, text: String) in
            guard shouldShowError == true else { return }
            view.showError(text)
        }
        
        var result = true
        
        for view in inputView {
            let text = view.texts
            
            switch view.type {
            case .workIndustry:
                if text.isEmpty {
                    showError(view, String(format: "warning_cnt_empty".localized, "placeholder_fullname_input_hint".localized))
                    result = false
                }
                

            case .gender:
                if text.isEmpty {
                    showError(view, String(format: "warning_cnt_empty".localized, "authentication_placeholder_gender".localized))
                    result = false
                }
            default: break
            }
           
        }
        
        return result
    }
}
