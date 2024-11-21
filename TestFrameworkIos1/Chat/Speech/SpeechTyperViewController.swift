//
//  SpeechTyperViewController.swift
//  Yippi
//
//  Created by CC Teoh on 16/07/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit
import PusherSwift
import ObjectMapper

import Lottie

struct SupportedLanguage {
    let code: String?
    let name: String?
}


enum ModalScaleState {
    case expanded
    case normal
}


class SpeechTyperViewController: TSViewController, CustomPresentable {
    
    let expandedTextViewHeight : CGFloat = 200
    let collapsedTextViewHeight : CGFloat = 100
    
    var transitionDelegate: UIViewControllerTransitioningDelegate?

    var closure: DidEnterSpeech?
    
    var collapseFrameHeight: CGFloat = 0.0
    
    private var audioAnimationView: AnimationView = {
        let audioAnimationView = AnimationView()
        audioAnimationView.animation = Animation.named("speech_to_text_progress")
        audioAnimationView.loopMode = .loop
        return audioAnimationView
    }()

    private var langPickerViewContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .fill
        stackView.alignment = .fill
        return stackView
    }()
    
    private var langPickerView: UIPickerView = {
        let view = UIPickerView()
        return view
    }()
        
   private var langPickerButtonView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0xefeff4)
        return view
    }()
    
    private var emptyView: UIView = {
         let view = UIView()
         view.backgroundColor = .white
         return view
     }()

    private var currentSelectedLangCode: SupportedLanguage = {
        let langIdentifier = LanguageIdentifier(rawValue: LocalizationManager.getCurrentLanguage())?.rawValue ?? "en"
        
        if let preferredLanguageObject = UserDefaults.standard.object(forKey: "SpeechTypingLanguage") as? [String:String] {
            return SupportedLanguage(code: preferredLanguageObject["locale"] ?? langIdentifier, name: preferredLanguageObject["name"] ?? LocalizationManager.getDisplayNameForLanguageIdentifier(identifier: langIdentifier))
        }

        return SupportedLanguage(code: langIdentifier, name: LocalizationManager.getDisplayNameForLanguageIdentifier(identifier: langIdentifier))
    }()
    
    private var keyboardHeight: Int = 0
            
    private var isExpanded: Bool = false
    
    private let textView = UITextView()
    
    private var languageButtonContainer: UIView = {
        let view = UIView(frame: .zero)
        return view
    }()
    
    private var doneButton: UIButton = {
        let button = UIButton(type: .system)
        return button
    }()
    
    private var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        return button
    }()

    private var languageButton: UIButton = {
        let button = UIButton(type: .custom)
        return button
    }()
            
    private var speechToTextView: SpeechToTextView = SpeechToTextView(frame: CGRect.zero, language: "en")
    
    private var editTitle: UILabel = {
        let editTitle = UILabel()
        editTitle.text = "edit".localized
        return editTitle
    }()
    
    private var collapseButton: UIButton = {
        let backButton = UIButton(type: .custom)
        backButton.setImage(UIImage.set_image(named: "btn_back_normal"), for: .normal)
        return backButton
    }()
    
    private lazy var voiceKeyboardSwitchButtonViewWrapper: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()

    private lazy var voiceKeyboardSwitchButton: UIButton = {
        let voiceKeyboardSwitchButton = UIButton(type: .custom)
        voiceKeyboardSwitchButton.contentMode = .scaleAspectFit
        voiceKeyboardSwitchButton.setImage(UIImage.set_image(named: "ico_chat_keyboard_voice"), for: .normal)
        return voiceKeyboardSwitchButton
    }()
    
    private lazy var sendMessageButton: UIButton = {
        let sendMessageButton = UIButton(type: .custom)
        sendMessageButton.contentMode = .scaleAspectFit
        sendMessageButton.setImage(UIImage.set_image(named: "icASendBlue"), for: .normal)
        return sendMessageButton
    }()
        
    private var availableLanguages: [SupportedLanguage] {
        var availbaleLanguages: [SupportedLanguage] = []
        for locale in LocalizationManager.availableLanugages() {
            if locale != "fil" {
                let language = SupportedLanguage (
                    code: locale,
                    name: LocalizationManager.getDisplayNameForLanguageIdentifier(identifier: locale)
                )
                availbaleLanguages.append(language)
            }
        }
        return availbaleLanguages
    }
    
    func setupView(frame: CGRect = CGRect.zero) {
        self.view.frame = frame
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        speechToTextView = SpeechToTextView(frame: .zero, language: currentSelectedLangCode.code ?? "en")
        speechToTextView.delegate = self

        addKeyboardObserver()
        
        addingShadow()
        
        view.backgroundColor = .white

        textView.font = AppTheme.Font.regular(18)
        textView.delegate = self
        textView.backgroundColor = .white
        manageTextViewAction(gestureEnabled: false)
     
        collapseButton.addTarget(self, action: #selector(collapseView), for: .touchUpInside)

        view.addSubview(editTitle)
        view.addSubview(collapseButton)
        view.addSubview(languageButtonContainer)
        view.addSubview(textView)
        view.addSubview(speechToTextView)
        view.addSubview(audioAnimationView)
        
        
        let icon = UIImage.set_image(named: "ic_drop_down")
        languageButton.setTitle(currentSelectedLangCode.name ?? "English", for: .normal)
        languageButton.setTitleColor(.black, for: .normal)
        languageButton.titleLabel?.font = AppTheme.Font.regular(12)
        languageButton.setImage(icon, for: .normal)
        languageButton.imageView?.contentMode = .scaleAspectFit
        languageButton.tintColor = .black
        languageButton.addTarget(self, action: #selector(langButtonOnTapped), for: .touchUpInside)
        languageButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: view.bounds.width - (collapseFrameHeight * 0.10) - 8, bottom: 0, right: 0)
        languageButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -(collapseFrameHeight * 0.10), bottom: 0, right: 0)
        
        languageButtonContainer.addSubview(languageButton)
        
        addConstraints()
                
        editTitle.isHidden = true
        
        collapseButton.isHidden = true
        
        setupLanguagePickerView()
        
        audioAnimationView.makeHidden()
    }
    
    
    private func addConstraints() {
        editTitle.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview().offset(TSLiuhaiHeight + 30)
            make.centerX.equalToSuperview()
            make.height.equalTo(20)
        }
        
        collapseButton.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(editTitle.snp.centerY)
            make.leading.equalToSuperview().offset(16)
            make.trailing.lessThanOrEqualTo(editTitle.snp.leading).offset(16)
            make.height.equalTo(20)
        }
        
        languageButtonContainer.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview().offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(collapseFrameHeight * 0.10)
        }
        
        textView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(languageButtonContainer.snp.bottom).offset(0)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(collapseFrameHeight * 0.45)
        }
        
        audioAnimationView.snp.makeConstraints { (make) -> Void in
            make.bottom.equalTo(speechToTextView.snp.top).offset(0)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().dividedBy(3)
            make.height.equalTo(collapseFrameHeight * 0.45)
        }

        speechToTextView.snp.makeConstraints { (make) -> Void in
            make.bottom.leading.trailing.equalToSuperview()
            make.top.greaterThanOrEqualTo(textView.snp.bottom).offset(0)
            make.height.equalTo(collapseFrameHeight * 0.45)
        }
        speechToTextView.verticalHuggingPriority = .defaultHigh
        
        languageButton.snp.makeConstraints { (make) -> Void in
            make.top.bottom.trailing.leading.equalToSuperview()
        }
    }
        
    private func addKeyboardObserver() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(setVoiceKeyboardSwitchButton), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(setVoiceKeyboardSwitchButton), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func setVoiceKeyboardSwitchButton(notification: Notification) {
        guard let keyboardValue = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        let keyboardHeight : Int = Int(keyboardValue.height)

        self.keyboardHeight = keyboardHeight

        guard notification.name == UIResponder.keyboardWillChangeFrameNotification && !voiceKeyboardSwitchButtonViewWrapper.isDescendant(of: view) else {
            return
        }
        
        voiceKeyboardSwitchButton.addTarget(self, action: #selector(manageKeyboard), for: .touchUpInside)
        sendMessageButton.addTarget(self, action: #selector(onSend), for: .touchUpInside)

        view.addSubview(voiceKeyboardSwitchButtonViewWrapper)
        
        voiceKeyboardSwitchButtonViewWrapper.snp.makeConstraints { (make) -> Void in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-(self.keyboardHeight))
            make.height.equalTo(40)
        }

        voiceKeyboardSwitchButtonViewWrapper.addSubview(separatorLine)
        voiceKeyboardSwitchButtonViewWrapper.addSubview(voiceKeyboardSwitchButton)
        voiceKeyboardSwitchButtonViewWrapper.addSubview(sendMessageButton)
        
        separatorLine.snp.makeConstraints { (make) -> Void in
            make.trailing.leading.top.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        voiceKeyboardSwitchButton.snp.makeConstraints { (make) -> Void in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.height.width.equalTo(28)
        }
        
        sendMessageButton.snp.makeConstraints { (make) -> Void in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
            make.height.width.equalTo(28)
        }

        voiceKeyboardSwitchButtonViewWrapper.makeVisible()
    }

    private func addingShadow() {
        self.presentationController?.containerView?.layer.shadowPath = UIBezierPath(rect: self.presentationController?.containerView?.bounds ?? CGRect.zero).cgPath
        self.presentationController?.containerView?.layer.shadowColor = UIColor(hex: 0xe3e3e3).cgColor
        self.presentationController?.containerView?.layer.shadowRadius = 5
        self.presentationController?.containerView?.layer.shadowOffset = .zero
        self.presentationController?.containerView?.layer.shadowOpacity = 1
    }
    
    @objc func langButtonOnTapped() {
        showLangSelector()
    }
    
    @objc func manageKeyboard() {
        if textView.isFirstResponder {
            textView.resignFirstResponder()
            voiceKeyboardSwitchButton.setImage(UIImage.set_image(named: "icSpeechToTextKeyboard"), for: .normal)
            sendMessageButton.makeHidden()
            emptyView.makeHidden()
        } else {
            textView.becomeFirstResponder()
            voiceKeyboardSwitchButton.setImage(UIImage.set_image(named: "ic_speech_to_text_record"), for: .normal)
            sendMessageButton.makeVisible()
            emptyView.makeVisible()
        }
    }
    
    @objc func expandView() {
        guard isExpanded == false else {
            manageKeyboard()
            return
        }

        maximizeToFullScreen { (success) -> Void in
            if success {
                isExpanded = true
                editTitle.isHidden = false
                collapseButton.isHidden = false
                
                languageButtonContainer.snp.updateConstraints { (make) -> Void in
                    make.top.equalToSuperview().offset(TSLiuhaiHeight + 66)
                }
                
               textView.snp.updateConstraints { (make) -> Void in
                    make.height.equalTo(expandedTextViewHeight)
                }
                                
                manageKeyboard()
                
                voiceKeyboardSwitchButtonViewWrapper.makeVisible()
                
                languageButtonContainer.makeHidden()
                
                emptyView.snp.updateConstraints { (make) -> Void in
                    make.bottom.equalToSuperview().offset(0)
                }
            }
        }
    }
    @objc func collapseView() {
        minimizeToHalfScreen() { (success) -> Void in
            
            emptyView.makeVisible()

            if success {
                isExpanded = false

                editTitle.isHidden = true
                collapseButton.isHidden = true
                
                languageButtonContainer.snp.updateConstraints { (make) -> Void in
                    make.top.equalToSuperview().offset(16)
                }
                
                textView.snp.updateConstraints { (make) -> Void in
                    make.height.equalTo(collapsedTextViewHeight)
                }
                
                textView.resignFirstResponder()
                
                voiceKeyboardSwitchButtonViewWrapper.makeHidden()
                
                if speechToTextView.state == .idle {
                    languageButtonContainer.makeVisible()
                }
                
                emptyView.snp.updateConstraints { (make) -> Void in
                    make.bottom.equalToSuperview().offset(self.collapseFrameHeight)
                }
            }
        }
    }
    
    @objc func dismissView() {
        PopupWindowManager.shared.changeKeyWindow(rootViewController: nil, height: self.view.height)
    }
}

//MARK: - Language picker controller
extension SpeechTyperViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    @objc func hideLangSelector() {
        UIView.animate(withDuration: 0.5) {
            self.langPickerViewContainer.snp.updateConstraints { (make) -> Void in
                make.bottom.equalToSuperview().offset(self.collapseFrameHeight)
            }
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func showLangSelector() {
        UIView.animate(withDuration: 0.5) {
            self.langPickerViewContainer.snp.updateConstraints { (make) -> Void in
                make.bottom.equalToSuperview().offset(0)
            }
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func didSelectedLang() {
        let selectedLang = langPickerView.selectedRow(inComponent: 0)
        self.speechToTextView.setLanguage(code: availableLanguages[selectedLang].code ?? "en")
        languageButton.setTitle(availableLanguages[selectedLang].name, for: .normal)
        hideLangSelector()
    }
    
    func setupLanguagePickerView() {
        
        doneButton.setTitle("Done", for: .normal)
        doneButton.addTarget(self, action: #selector(didSelectedLang), for: .touchUpInside)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: #selector(hideLangSelector), for: .touchUpInside)
        
        langPickerView.delegate = self
        langPickerView.dataSource = self
        langPickerView.reloadAllComponents()
        langPickerView.backgroundColor = .white
        langPickerView.setValue(UIColor.black, forKey: "textColor")
        langPickerView.contentMode = .center
        langPickerViewContainer.backgroundColor = .white
        
        view.addSubview(langPickerViewContainer)
        view.addSubview(emptyView)
        
        langPickerViewContainer.snp.makeConstraints { (make) -> Void in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(collapseFrameHeight)
            make.height.equalTo(collapseFrameHeight)
        }
        
        emptyView.snp.makeConstraints { (make) -> Void in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(collapseFrameHeight)
            make.height.equalTo(collapseFrameHeight)
        }
        
        langPickerViewContainer.addArrangedSubview(langPickerButtonView)
        langPickerViewContainer.addArrangedSubview(langPickerView)
                
        langPickerButtonView.addSubview(doneButton)
        langPickerButtonView.addSubview(cancelButton)
        
        doneButton.snp.makeConstraints { (make) -> Void in
            make.top.bottom.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
            make.width.equalTo(50)
        }
        
        cancelButton.snp.makeConstraints { (make) -> Void in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.width.equalTo(50)
        }

        langPickerButtonView.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(collapseFrameHeight * 0.2)
        }

        langPickerView.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(collapseFrameHeight * 0.8)
        }
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return availableLanguages.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return availableLanguages[row].name
    }
    
    private func manageTextViewAction(gestureEnabled: Bool = true) {
        let textViewTap = UITapGestureRecognizer(target: self, action: #selector(expandView))
        
        if gestureEnabled {
            textView.isUserInteractionEnabled = true
            textView.addGestureRecognizer(textViewTap)
        } else {
            textView.isUserInteractionEnabled = false
            textView.removeGestures()
        }
    }
}

// MARK: - Speech to text controls delegate
extension SpeechTyperViewController: SpeechToTextDelegate {
    func onStateChanged(state: SpeechToText.SpeechToTextState) {
        switch state {
        case .idle:
            manageTextViewAction(gestureEnabled: false)
            audioAnimationView.makeHidden()
            audioAnimationView.stop()
            if isExpanded == false {
                languageButtonContainer.makeVisible()
            }
        case .loading:
            manageTextViewAction()
            audioAnimationView.makeVisible()
            audioAnimationView.play()
            languageButtonContainer.makeHidden()
        case .recording:
            manageTextViewAction(gestureEnabled: false)
            textView.text = ""
            audioAnimationView.makeHidden()
            audioAnimationView.stop()
            languageButtonContainer.makeHidden()
        default:
            manageTextViewAction()
            audioAnimationView.makeHidden()
            audioAnimationView.stop()
            languageButtonContainer.makeHidden()
        }
    }
    
    func onFinished(with text: String, completion: (Bool) -> Void) {
        textView.text = text
        completion(true)
    }
    
    @objc func onSend() {
        guard textView.text != "" else {
            return
        }
        self.closure?(textView.text)
        onClose()
    }

    func onClear() {
        textView.text = ""
        collapseView()
    }
    
    func onClose() {
        dismissView()
    }
}

// MARK: - UITextView delegate
extension SpeechTyperViewController: UITextViewDelegate {}
