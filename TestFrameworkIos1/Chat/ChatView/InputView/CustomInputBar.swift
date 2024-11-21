//
//  CustomInputBar.swift
//  Yippi
//
//  Created by Khoo on 22/07/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import SwiftUI
import InputBarAccessoryView
import SnapKit
import UIKit
import AVFoundation

@objc protocol CustomInputBarDelegate {
    @objc optional func moreTapped ()
    
    @objc optional func imageTapped ()
    @objc optional func cameraTapped ()
    @objc optional func attachmentTapped ()
    @objc optional func eggTapped ()
    @objc optional func videoCallTapped ()
    @objc optional func voiceCallTapped ()
    @objc optional func onContactTapped()
    @objc optional func onWhiteboardTapped()
    @objc optional func onLocationTapped()
    @objc optional func onVoiceToTextTapped()
    @objc optional func onRPSTapped()
    @objc optional func oncollectionMessageTapped()
    @objc optional func onSecretMessageTapped()
    
    @objc optional func emojiContainerTapped ()
    @objc optional func onStartRecording()
    @objc optional func onStopRecording()
    @objc optional func onCancelRecording()
    @objc optional func onConverting()
    @objc optional func onConvertError()
    @objc optional func pasteImage(image: UIImage)
    @objc optional func onPasteMentioned(usernames: [String], _ message: String)

    //取消发送
    @objc optional func cancelButtonTapped()
    //发送原语音
    @objc optional func sendVoiceButtonTapped()
    //发送文字
    @objc optional func sendVoiceMsgTextButtonTapped()
    //弹出更多语言页面
    @objc optional func moreLanguageButtonTapped()
}

class CustomInputBar: InputBarAccessoryView {
    
    var inputDelegate: CustomInputBarDelegate?
    
    lazy var recordButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 18
        button.backgroundColor = .white
        button.setTitle("input_panel_hold_talk".localized, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(.black, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(red: 245 / 255.0, green: 245 / 255.0, blue: 245 / 255.0, alpha: 1).cgColor
        return button
    }()
    
    
    var stickerBtn, moreBtn: InputBarButtonItem!
    
    // Recording
    var _recordPhase: AudioRecordPhase? = nil
    var recordPhase: AudioRecordPhase? = nil {
        willSet {
            
            let prevPhase = recordPhase
            _recordPhase = newValue
            self.audioRecordIndicator.phase = recordPhase
            if prevPhase == .end || prevPhase == .converterror {
                if  _recordPhase == .start {
                    inputDelegate?.onStartRecording?()
                }
            }else if prevPhase == .start || prevPhase == .recording {
                if _recordPhase == .end {
                    inputDelegate?.onStopRecording?()
                }
            }else if prevPhase == .cancelling {
                if _recordPhase == .end {
                    inputDelegate?.onCancelRecording?()
                }
            }else if prevPhase == .converting {
                if _recordPhase == .converted {
                    self.audioRecordIndicator.phase = .converted
                    inputDelegate?.onConverting?()
                }
                if _recordPhase == .converterror {
                    self.audioRecordIndicator.phase = .converterror
                    inputDelegate?.onConvertError?()
                }
            }else if _recordPhase == .converterror {
                self.audioRecordIndicator.phase = .converterror
                inputDelegate?.onConvertError?()
            }else if _recordPhase == .converted {
                self.audioRecordIndicator.phase = .converted
                inputDelegate?.onConverting?()
            }
        }
    }
    
    var recognizedText: String = "" {
        didSet {
            SpeechVoiceDetectManager.shared.hasRecognizedText = true
            self.audioRecordIndicator.recognizedTextView.text = "\(recognizedText) ···"
            if SpeechVoiceDetectManager.shared.isRecordEnd == true {
                var recognizedStr = self.audioRecordIndicator.recognizedTextView.text
                recognizedStr = recognizedStr?.replacingOccurrences(of: "·", with: "")
                self.audioRecordIndicator.recognizedTextView.text = recognizedStr
            }
            
        }
    }
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    var recording: Bool = false {
        didSet {
            if recording {
                let soundShort = SystemSoundID(1519)
                AudioServicesPlaySystemSound(soundShort)
                self.audioRecordIndicator.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight)
                UIApplication.shared.windows.first?.addSubview(self.audioRecordIndicator)
                self.recordPhase = .end
                self.setRecordIndicatorAction()
                self.audioRecordIndicator.recordStateView.startMeterTimer()
            } else {
                self.audioRecordIndicator.recordStateView.stopMeterTimer()
                self.recordPhase = .end
                self.audioRecordIndicator.removeFromSuperview()
            }
        }
    }
    
    var audioRecordIndicator: InputAudioRecordIndicatorView = InputAudioRecordIndicatorView()
    
    var isShowingPressToTalk = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBtns()
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupBtns () {
        moreBtn = makeButton(named: "plus").onSelected { _ in
            self.inputDelegate?.moreTapped?()
        }
        
        stickerBtn = makeButton(named: "emoji").onSelected {_ in
            self.inputDelegate?.emojiContainerTapped?()
        }
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(recognizer:)))
        longPressRecognizer.delegate = self
        recordButton.addGestureRecognizer(longPressRecognizer)
        
        let panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panAction(recognizer:)))
        panGesture.delegate = self
        recordButton.addGestureRecognizer(panGesture)
        
        
    }
    func setRecordIndicatorAction() {
        self.audioRecordIndicator.cancelImageView.addTap { [weak self] (v) in
            guard let self = self else { return }
            self.audioRecordIndicator.recognizedTextView.resignFirstResponder()
            self.inputDelegate?.cancelButtonTapped?()
        }
        self.audioRecordIndicator.sendVoiceImageView.addTap { [weak self] (v) in
            guard let self = self else { return }
            self.inputDelegate?.sendVoiceButtonTapped?()
        }
        self.audioRecordIndicator.sendMsgImageView.addTap { [weak self] (v) in
            guard let self = self, self.recordPhase != .converterror else { return }
            self.audioRecordIndicator.recognizedTextView.resignFirstResponder()
            self.inputDelegate?.sendVoiceMsgTextButtonTapped?()
        }
        self.audioRecordIndicator.moreButton.addTap { [weak self] (v) in
            guard let self = self else { return }
            self.inputDelegate?.moreLanguageButtonTapped?()
        }
    }
    func configure() {
        // We can change the container insets if we want
        inputTextView.isImagePasteEnabled = false
        inputTextView.backgroundColor = UIColor(hexString: "#F5F5F5")!
        inputTextView.placeholderTextColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 50, bottom: 8, right: 36)
        inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 55, bottom: 8, right: 36)
        inputTextView.placeholder = "rw_placeholder_comment".localized
        //inputTextView.layer.borderColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1).cgColor
        inputTextView.layer.borderWidth = 1.0
        inputTextView.layer.cornerRadius = 18
        inputTextView.layer.masksToBounds = true
        inputTextView.layer.borderColor = UIColor(red: 245 / 255.0, green: 245 / 255.0, blue: 245 / 255.0, alpha: 1).cgColor
        inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        
        setLeftStackViewWidthConstant(to: 80, animated: false)
        setRightStackViewWidthConstant(to: 80, animated: false)
        configureTextInput()
        
        stickerBtn.setSize(CGSize(width: 36, height: 36), animated: false)
        shouldAutoUpdateMaxTextViewHeight = false
        maxTextViewHeight = 108
        
        rightStackView.alignment = .bottom
        bottomStackView.distribution = .equalSpacing
        
        middleContentViewPadding.left = -38
        middleContentViewPadding.right = -40
       // isTranslucent = true
        self.backgroundView.backgroundColor = .white
        recordPhase = .end
        
        moreBtn.setSize(CGSize(width: 36, height: 36), animated: false)
        self.addSubview(moreBtn)
        moreBtn.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.top.equalToSuperview().offset(5)
        }
        
        self.addSubview(recordButton)
        recordButton.snp.makeConstraints {
            $0.left.right.top.bottom.equalTo(inputTextView)
        }
        recordButton.isHidden = true
    }
    
    override func paste(_ sender: Any?) {
        if let image = UIPasteboard.general.image {
            self.inputDelegate?.pasteImage?(image: image)
        } else if UIPasteboard.general.numberOfItems > 0 {
            guard let item = UIPasteboard.general.items.first, let usernamedata = item["usernames"] as? Data, let messageData = item["message"] as? Data else {
                return
            }
            if let usernames = String(data: usernamedata, encoding: .utf8), let message = String(data: messageData, encoding: .utf8) {
                self.inputDelegate?.onPasteMentioned?(usernames: usernames.components(separatedBy: ","), message)
            }
        } else{
            super.paste(sender)
        }
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) {
            if UIPasteboard.general.numberOfItems > 0 {
                return true
            }else {
                return false
            }
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    private func makeButton(named: String) -> InputBarButtonItem {
        return InputBarButtonItem()
            .configure {
                $0.spacing = .fixed(10)
                $0.image = UIImage.set_image(named: named)
                $0.setSize(CGSize(width: 30, height: 48), animated: false)
        }
    }
    
    private func configureTextInput () {
        setStackViewItems([stickerBtn, InputBarButtonItem.fixedSpace(2),  sendButton
            .configure {
                $0.isEnabled =  true
                $0.setImage(UIImage.set_image(named: "speech"), for: .normal)
                $0.setSize(CGSize(width: 40, height: 40), animated: false)
                $0.layer.cornerRadius = $0.width/2
                $0.title = ""
            }.onTextViewDidChange { button, textView in
                if textView.text.isEmpty {
                    button.isEnabled =  true
                    button.setImage(UIImage.set_image(named: "speech"), for: .normal)
                } else {
                    button.setImage(UIImage.set_image(named: "icASendBlue"), for: .normal)
                }
            }], forStack: .right, animated: false)
    }
    
    public func configureHoldToTalk () {
        recordButton.isHidden = false
        sendButton.setImage(UIImage.set_image(named: "keyboard"), for: .normal)
        ResetStickerImage()
    }
    public func changeStickerImageToKeyboard () {
        stickerBtn.setImage(UIImage.set_image(named: "keyboard"), for: .normal)
    }
    public func ResetStickerImage () {
        stickerBtn.setImage(UIImage.set_image(named: "emoji"), for: .normal)
    }
    public func hideHoldToTalk () {
        recordButton.isHidden = true
        sendButton.setImage(UIImage.set_image(named: "speech"), for: .normal)
    }
    
    public func checkAudioPermission (permission: @escaping (Bool) -> ()) {
        weak var weakSelf = self
        if AVAudioSession.sharedInstance().responds(to: #selector(AVAudioSession.requestRecordPermission(_:))) {
            AVAudioSession.sharedInstance().requestRecordPermission { (granted) in
                if granted {
                    DispatchQueue.main.async {
                        permission(true)
                    }
                }
            }
        }
        permission(false)
    }
    
    public func updateAudioRecordTime(time: TimeInterval) {
        self.audioRecordIndicator.recordTime = time
    }
    
}

extension CustomInputBar: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        
        picker.dismiss(animated: true, completion: {
            if let pickedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
                self.inputPlugins.forEach { _ = $0.handleInput(of: pickedImage) }
            }
        })
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}

extension CustomInputBar: UIGestureRecognizerDelegate {
    

    @objc public func panAction(recognizer: UIPanGestureRecognizer) {
        if  SpeechVoiceDetectManager.shared.isRecordEnd == true {
            return
        }
        let translationPoint: CGPoint = recognizer.translation(in: self.superview)
        let centerP: CGPoint = recognizer.view?.center ?? CGPoint.zero
        var pointX = centerP.x + translationPoint.x
        var pointY = centerP.y + translationPoint.y
        switch recognizer.state {
       
        case  .changed:
            if pointY > 0 {
                recordPhase = .recording
                UIView.animate(withDuration: 0.1, animations: {
                    self.audioRecordIndicator.cancelImageView.transform = .identity
                    self.audioRecordIndicator.convertImageView.transform = .identity
                })
                return
            }
            if pointX < ScreenWidth / 2 {
                recordPhase = .cancelling
                UIView.animate(withDuration: 0.1, animations: {
                    self.audioRecordIndicator.cancelImageView.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.0)
                })
            } else {
                recordPhase = .converting
                UIView.animate(withDuration: 0.1, animations: {
                    self.audioRecordIndicator.convertImageView.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.0)
                })
            }
        case .ended:
            audioRecordIndicator.cancelImageView.transform = .identity
            audioRecordIndicator.convertImageView.transform = .identity
        @unknown default:
            break
        }
    }
    @objc public func longPress(recognizer:UILongPressGestureRecognizer) {
        
        if recognizer.state == .began {
            SpeechVoiceDetectManager.shared.isRecordEnd = false
            SpeechVoiceDetectManager.shared.hasRecognizedText = false
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) { [weak self] in
                self?.recordPhase = .start
            }
        } else if recognizer.state == .ended {
            SpeechVoiceDetectManager.shared.isRecordEnd = true
            let isConvert = (recordPhase == .converting || recordPhase == .converted)
            if isConvert && self.recognizedText.isEmpty {
                //没有识别到任何文字
                recordPhase = .converterror
            } else {
                recordPhase = isConvert == true ? .converted : .end
            }
        }
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
      }
}
