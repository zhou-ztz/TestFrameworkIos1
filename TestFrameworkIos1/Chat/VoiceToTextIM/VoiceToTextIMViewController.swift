//
//  VoiceToTextIMViewController.swift
//  Yippi
//
//  Created by Kit Foong on 28/09/2022.
//  Copyright © 2022 Toga Capital. All rights reserved.
//

import UIKit
import Speech


class VoiceToTextIMViewController: TSViewController {
    var isLanguageSelection: Bool = false
    var selectedLanguage: SupportedLanguage?
    let fileUrl: URL
    
    // Langauge Selection
    var currentLanguageText = UILabel()
    
    var toolBar = UIToolbar()
    var picker  = UIPickerView()
    
    var onLanguageChanged: ((SupportedLanguage) -> Void)?
    
    // Display Translated text
    var translatedText = UILabel()
    var scrollView = UIScrollView()
    
    private var currentSelectedLangCode: SupportedLanguage = {
        let langIdentifier = LanguageIdentifier(rawValue: LocalizationManager.getCurrentLanguage())?.rawValue ?? "en"
        
        if let preferredLanguageObject = UserDefaults.standard.object(forKey: "SpeechTypingLanguage") as? [String:String] {
            return SupportedLanguage(code: preferredLanguageObject["locale"] ?? langIdentifier, name: preferredLanguageObject["name"] ?? LocalizationManager.getDisplayNameForLanguageIdentifier(identifier: langIdentifier))
        }
        
        return SupportedLanguage(code: langIdentifier, name: LocalizationManager.getDisplayNameForLanguageIdentifier(identifier: langIdentifier))
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
    
    init(fileUrl: URL, selectedLanguage: SupportedLanguage?, isLanguageSelection: Bool) {
        self.fileUrl = fileUrl
        self.selectedLanguage = selectedLanguage
        self.isLanguageSelection = isLanguageSelection
        
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialUI()
        
        if isLanguageSelection == false {
            voiceToText(language: selectedLanguage ?? currentSelectedLangCode)
        }
    }
    
    fileprivate func initialUI() -> Void {
        let closeBtnH: CGFloat = 45
        let closeLrMargin: CGFloat = 15
        let closeTopMargin: CGFloat = 30
        
        self.view.backgroundColor = .white
        self.view.roundCorners([.topLeft, .topRight], radius: 10)
        
        let closeBtn = UIButton(cornerRadius: 5)
        closeBtn.addTarget(self, action: #selector(closeBtnClick(_:)), for: .touchUpInside)
        closeBtn.setTitle("close".localized, for: .normal)
        closeBtn.setTitleColor(UIColor.white, for: .normal)
        closeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        closeBtn.setBackgroundImage(UIImage(color: TSColor.main.theme), for: .normal)
        
        if isLanguageSelection {
            toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: 0, width: UIScreen.main.bounds.size.width, height: 50))
            toolBar.tintColor = UIColor(hex: 0xefeff4)
            
            currentLanguageText = UILabel(text: selectedLanguage?.name ?? currentSelectedLangCode.name ?? "English", font: AppTheme.Font.regular(16), textColor: .black)
            currentLanguageText.textAlignment = .center
            currentLanguageText.bounds = CGRect(x: 0, y: 0, width: toolBar.bounds.width / 3, height: toolBar.bounds.height)
            
            let doneButton = UIBarButtonItem(title: "done".localized, style: UIBarButtonItem.Style.done, target: self, action: #selector(onDoneButtonTapped))
            doneButton.tintColor = UIColor.black
            let spacing = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, action: {})
            let middelLabelItem = UIBarButtonItem(customView: currentLanguageText)
            let cancelButton = UIBarButtonItem(title: "cancel".localized, style: UIBarButtonItem.Style.plain, target: self, action: #selector(onCancelButtonTapped))
            cancelButton.tintColor = UIColor.black
            
            toolBar.setItems([cancelButton, spacing, middelLabelItem, spacing,  doneButton], animated: false)
            view.addSubview(toolBar)
            
            picker = UIPickerView.init()
            picker.delegate = self
            picker.dataSource = self
            picker.backgroundColor = UIColor.white
            picker.setValue(UIColor.black, forKey: "textColor")
            picker.autoresizingMask = .flexibleWidth
            picker.contentMode = .center
            
            view.addSubview(picker)
            picker.snp.makeConstraints { (make) in
                make.height.equalTo(self.view.frame.size.height * 0.8)
                make.top.equalTo(toolBar.snp.bottom).offset(15)
                make.leading.equalTo(self.view).offset(10)
                make.trailing.equalTo(self.view).offset(-10)
            }
            
            view.addSubview(closeBtn)
            closeBtn.snp.makeConstraints { (make) in
                make.height.equalTo(closeBtnH)
                make.leading.equalTo(self.view).offset(closeLrMargin)
                make.trailing.equalTo(self.view).offset(-closeLrMargin)
                make.top.equalTo(picker.snp.bottom).offset(closeTopMargin)
                make.bottom.equalTo(self.view).offset(-closeTopMargin)
            }
        } else {
            translatedText = UILabel(text: "", font: UIFont.systemFont(ofSize: 25), textColor: TSColor.main.content)
            translatedText.numberOfLines = 0
            translatedText.sizeToFit()
            view.addSubview(scrollView)
            scrollView.snp.makeConstraints { (make) in
                make.top.leading.trailing.equalToSuperview()
            }
            
            scrollView.addSubview(translatedText)
            translatedText.snp.makeConstraints { (make) in
                make.leading.equalTo(self.view).offset(10)
                make.trailing.equalTo(self.view).offset(-10)
                make.top.bottom.equalToSuperview()
            }
            
            let stackView = UIStackView()
            view.addSubview(stackView)
            stackView.snp.makeConstraints { (make) in
                make.top.equalTo(scrollView.snp.bottom)
                make.leading.trailing.equalTo(self.view).offset(10)
            }
            
            view.addSubview(closeBtn)
            closeBtn.snp.makeConstraints { (make) in
                make.height.equalTo(closeBtnH)
                make.leading.equalTo(self.view).offset(closeLrMargin)
                make.trailing.equalTo(self.view).offset(-closeLrMargin)
                make.top.equalTo(stackView.snp.bottom).offset(closeTopMargin)
                make.bottom.equalTo(self.view).offset(-closeTopMargin)
            }
        }
    }
    
    @objc func onDoneButtonTapped() {
        let selectedLang = picker.selectedRow(inComponent: 0)
        onLanguageChanged(availableLanguages[selectedLang])
    }
    
    func onLanguageChanged(_ model: SupportedLanguage) {
        self.onLanguageChanged?(model)
        onCancelButtonTapped()
    }
    
    @objc func onCancelButtonTapped() {
        self.dismiss(animated: true)
    }
    
    func voiceToText(language: SupportedLanguage) {
        showLoadingAnimation()

        let recognizer = SFSpeechRecognizer(locale: Locale(identifier: language.code ?? "en"))!
        let request = SFSpeechURLRecognitionRequest(url: fileUrl)
        request.requiresOnDeviceRecognition = false
        recognizer.recognitionTask(with: request, resultHandler: { (result, error) in
            guard let result = result else {
                let speechError = error as! NSError
                if speechError.domain == "kLSRErrorDomain" && (speechError.code == 102 || speechError.code == 201) {
                    self.dismissLoadingAnimation()
                    debugPrint("There was an error: \(speechError.domain) \(speechError.code)")
                    var alert = TSAlertController(style: .alert)
                    alert = TSAlertController(title: "",
                                              message: "You need to turn on Keyboard Dictation to proceed use this function.",
                                              style: .alert, hideCloseButton: true, animateView: false)

                    let alertAction = TSAlertAction(title: "ok".localized, style: TSAlertActionStyle.default) { (_) in
                        alert.dismiss()
                    }
                    alert.addAction(alertAction)
                    self.present(alert, animated: false, completion: nil)
                } else {
                    self.dismissLoadingAnimation()
                    self.showError(message: error?.localizedDescription ?? "")
                }
                return
            }

            if result.isFinal {
                self.textTranslate(withText: result.bestTranscription.formattedString)
                self.viewDidLayoutSubviews()
            }
        })
    }
    
    func textTranslate(withText messageText: String) {
        ChatroomNetworkManager().translateTexts(message: messageText, onSuccess: { [weak self] message in
            self?.dismissLoadingAnimation()
            guard let self = self else { return }
            self.translatedText.text = message
        }, onFailure: { [weak self] errMsg, code in
            self?.dismissLoadingAnimation()
            guard let self = self else { return }
            self.translatedText.text = messageText
            self.showError(message: errMsg)
        })
    }
    
    @objc fileprivate func closeBtnClick(_ button: UIButton) -> Void {
        self.dismiss(animated: true)
    }
}

extension VoiceToTextIMViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
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
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentLanguageText.text = self.availableLanguages[row].name
    }
}

extension VoiceToTextIMViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let controller = HalfScreenPresentationController(presentedViewController: presented, presenting: presenting)
        controller.heightPercentage = 0.5
        return controller
    }
}
