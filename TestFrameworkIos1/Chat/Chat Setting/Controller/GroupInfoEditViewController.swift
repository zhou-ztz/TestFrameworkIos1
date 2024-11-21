//
//  GroupInfoEditViewController.swift
//  Yippi
//
//  Created by Tinnolab on 14/10/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import UIKit

enum GroupInfoEditType: Int {
        case name = 0
        case description
        case nickname
}

class GroupInfoEditViewController: TSViewController {
    @IBOutlet weak var charLimitLabel: UILabel!
    @IBOutlet weak var editTextView: UITextView!
    @IBOutlet weak var editInfoView: UIView!
    @IBOutlet weak var charLimitLabelWidth: NSLayoutConstraint!
    @IBOutlet weak var footerLabel: UILabel!
    
    private var canEdit: Bool = false
    private var textLimit: Int = 25
    private var editType: GroupInfoEditType = .name
    private var textToDisplay: String = ""
    private var loadingAlert: TSIndicatorWindowTop?
    private var hideKeyboardGesture: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addObserver()
        hideKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        setupUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeObserver()
    }
   
    init(editType: GroupInfoEditType, editText: String, canEdit: Bool) {
        self.textToDisplay = editText
        self.editType = editType
        self.canEdit = canEdit
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func removeObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupUI() {
        switch editType {
        case .name:
            textLimit = 25
            setCloseButton(backImage: true, titleStr: "group_name".localized)
            setPlaceholder(placeHolder: "team_settings_set_name".localized)
            break
        case .nickname:
            textLimit = 32
            setCloseButton(backImage: true, titleStr: "group_nickname".localized)
            setPlaceholder(placeHolder: "group_nickname".localized)
            break
        case .description:
            textLimit = 150
            setCloseButton(backImage: true, titleStr: "group_introduce".localized)
            setPlaceholder(placeHolder: "team_introduce_hint".localized)
            break
        }
        
        editTextView.textColor = textToDisplay.isEmpty ? .lightGray : .black
        editTextView.sizeToFit()
        charLimitLabel.text = "\(textLimit - (textToDisplay.count))"
        editTextView.delegate = self
        
        charLimitLabel.isHidden = true
        editTextView.isEditable = false
        editTextView.isSelectable = false
        charLimitLabelWidth.constant = 0
        if canEdit {
            self.setupRightBarButton()
            charLimitLabel.isHidden = false
            editTextView.isEditable = true
            editTextView.isSelectable = true
            charLimitLabelWidth.constant = 30
        } else {
            footerLabel.text = "group_creator_or_admin_edit_description".localized
            footerLabel.sizeToFit()
            footerLabel.isHidden = false
        }
        
        if canEdit && textToDisplay != "" {
            setCloseButton(backImage: true, titleStr: "edit".localized)
        }
    }
    
    private func setupRightBarButton() {
        let rightBtn = UIBarButtonItem(title: "save".localized, style: .plain, target: self, action: #selector(saveInfo))
        self.navigationItem.rightBarButtonItem = rightBtn
    }

    @objc func saveInfo() {
        var currentText = editTextView.text ?? ""
        
        if editTextView.textColor == .lightGray {
            currentText = ""
        }
        
        switch editType {
        case .name:
            TeamDetailHelper.shared.updateTeamName(currentText)
            if !currentText.isEmpty {
                self.perform(#selector(self.dismissView), afterDelay: 0.8)
            }
            break
        case .nickname:
            TeamDetailHelper.shared.updateUserNickname(currentText)
            self.perform(#selector(self.dismissView), afterDelay: 0.8)
            break
        case .description:
             TeamDetailHelper.shared.updateTeamIntro(currentText)
             self.perform(#selector(self.dismissView), afterDelay: 0.8)

            break
        }
    }
    
    private func helperCallback() {
        TeamDetailHelper.shared.onShowSuccess = { msg in
            self.showSuccess(msg)
        }
        
        TeamDetailHelper.shared.onShowFail = { msg in
            self.showFail(msg)
        }
    }
    
    private func showFail(_ msg: String? = nil) {
        loadingAlert = TSIndicatorWindowTop(state: .faild, title: msg ?? "error_tips_fail".localized)
        loadingAlert?.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
    }
    
    private func showSuccess(_ msg: String? = nil) {
        loadingAlert = TSIndicatorWindowTop(state: .success, title: msg ?? "change_success".localized)
        loadingAlert?.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
    }
    
    private func setPlaceholder (placeHolder: String) {
        if textToDisplay.isEmpty && canEdit {
            editTextView.text = placeHolder
        } else if textToDisplay.isEmpty && !canEdit {
            editTextView.text = "not_set_content".localized
        } else {
            editTextView.text = textToDisplay
        }
    }
    
    @objc private func dismissView() {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - keyboard
    @objc private func hideKeyboard() {
        editTextView.resignFirstResponder()
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        self.view.addGestureRecognizer(hideKeyboardGesture)
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        self.view.removeGestureRecognizer(hideKeyboardGesture)
    }
}

extension GroupInfoEditViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // get the current text, or use an empty string if that failed
        let currentText = textView.text ?? ""

        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }

        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)

        let charCount = textLimit - (updatedText.count)
        if charCount >= 0 {
            charLimitLabel.text = "\(charCount)"
        }
        return updatedText.count <= textLimit
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            switch editType {
            case .name:
                textView.text = "team_settings_set_name".localized
                break
            case .nickname:
                textView.text = "group_nickname".localized
                break
            case .description:
                textView.text = "team_introduce_hint".localized
                break
            }
            textView.textColor = .lightGray
        }
    }
}
