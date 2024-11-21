//
//  whiteBoardInputBar.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/5/11.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit
import Foundation
import InputBarAccessoryView
import SnapKit
import AVFAudio

@objc protocol WhiteBoardInputBarDelegate {
    
    //@objc optional func attachmentTapped ()
    
    @objc optional func emojiContainerTapped()
    
    @objc optional func onStartRecording()
    @objc optional func onStopRecording()
    @objc optional func onCancelRecording()
    
   
}

class whiteBoardInputBar: InputBarAccessoryView {

    
    var inputDelegate: WhiteBoardInputBarDelegate?
    
    var inputBarItems: [InputBarButtonItem] = [InputBarButtonItem]()
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
    
    
    var stickerBtn: InputBarButtonItem!
    
    
    // Recording
    var _recordPhase: AudioRecordPhase? = nil
    var recordPhase: AudioRecordPhase? = nil {
        willSet {
            let prevPhase = recordPhase
            _recordPhase = newValue
            self.audioRecordIndicator.phase = recordPhase
            
            if prevPhase == .end {
                if  _recordPhase == .start {
                    inputDelegate?.onStartRecording?()
                }
            }else if prevPhase == .start || prevPhase == .recording {
                if _recordPhase == .end {
                    inputDelegate?.onStopRecording?()
                }
            } else if prevPhase == .cancelling {
                if _recordPhase == .end {
                    inputDelegate?.onCancelRecording?()
                }
            }
        }
    }
    
    var recording: Bool = false {
        didSet {
            if recording {
                self.audioRecordIndicator.center = self.superview!.center
                self.superview!.addSubview(self.audioRecordIndicator)
                self.recordPhase = .end
            } else {
                self.audioRecordIndicator.removeFromSuperview()
                self.recordPhase = .end
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
        
        stickerBtn = makeButton(named: "ic_nim_sticker").onSelected {_ in
            self.inputDelegate?.emojiContainerTapped?()
        }
        
        recordButton.addTarget(self, action: #selector(self.onTouchRecordBtnDown(_:)), for: .touchDown)
        recordButton.addTarget(self, action: #selector(self.onTouchRecordBtnDragInside(_:)), for: .touchDragInside)
        recordButton.addTarget(self, action: #selector(self.onTouchRecordBtnDragOutside(_:)), for: .touchDragOutside)
        recordButton.addTarget(self, action: #selector(self.onTouchRecordBtnUpInside(_:)), for: .touchUpInside)
        recordButton.addTarget(self, action: #selector(self.onTouchRecordBtnUpOutside(_:)), for: .touchUpOutside)
    }
    
    func configure() {
        let items: [InputBarButtonItem] = []
        
        items.forEach { $0.tintColor = .lightGray }
        // We can change the container insets if we want
        inputTextView.backgroundColor = .white
        inputTextView.placeholderTextColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 36)
        inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 15, bottom: 8, right: 36)
        inputTextView.placeholder = "rw_placeholder_comment".localized
        //inputTextView.layer.borderColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1).cgColor
        inputTextView.layer.borderWidth = 1.0
        inputTextView.layer.cornerRadius = 18
        inputTextView.layer.masksToBounds = true
        inputTextView.layer.borderColor = UIColor(red: 245 / 255.0, green: 245 / 255.0, blue: 245 / 255.0, alpha: 1).cgColor
        inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        
        inputBarItems = [stickerBtn]
        
        setLeftStackViewWidthConstant(to: 38, animated: false)
//        setStackViewItems([inputBarItems[0], InputBarButtonItem.fixedSpace(2)], forStack: .left, animated: false)
//        inputBarItems[0].setSize(CGSize(width: 36, height: 36), animated: false)
        
        setRightStackViewWidthConstant(to: 80, animated: false)
        configureTextInput()
        
        inputBarItems[0].setSize(CGSize(width: 36, height: 36), animated: false)
        shouldAutoUpdateMaxTextViewHeight = false

        maxTextViewHeight = 100
        rightStackView.alignment = .bottom
        
        setStackViewItems(items, forStack: .bottom, animated: false)
        bottomStackView.distribution = .equalSpacing
        
        middleContentViewPadding.left = -38
        middleContentViewPadding.right = -40
       // isTranslucent = true
        self.backgroundView.backgroundColor = .white
        recordPhase = .end
        
        self.addSubview(recordButton)
        recordButton.snp.makeConstraints {
            $0.left.right.top.bottom.equalTo(inputTextView)
        }
        
        recordButton.isHidden = true
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
        setStackViewItems([inputBarItems[0], InputBarButtonItem.fixedSpace(2),  sendButton
            .configure {
                $0.isEnabled =  true
                $0.setImage(UIImage.set_image(named: "iconsKeyboardMIc"), for: .normal)
                $0.setSize(CGSize(width: 30, height: 30), animated: false)
                $0.layer.cornerRadius = $0.width/2
                $0.title = ""
        }.onTextViewDidChange { button, textView in
            if textView.text.isEmpty {
                button.isEnabled =  true
                button.setImage(UIImage.set_image(named: "iconsKeyboardMIc"), for: .normal)
            } else {
                button.setImage(UIImage.set_image(named: "icASendBlue"), for: .normal)
            }
            }], forStack: .right, animated: false)
    }
    
    public func configureHoldToTalk () {
        recordButton.isHidden = false
    }
    
    public func hideHoldToTalk () {
        recordButton.isHidden = true
    }

    public func updateMoreButton () {
       // hideBtn.setImage(UIImage.set_image(named: "ic_nim_hide"), for: .normal)
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
    
    // Record Button
    @IBAction func onTouchRecordBtnDown(_ sender: Any) {
        recordPhase = .start
    }

    @IBAction func onTouchRecordBtnUpInside(_ sender: Any) {
        // finish Recording
        recordPhase = .end
    }

    @IBAction func onTouchRecordBtnUpOutside(_ sender: Any) {
        // cancel Recording
        recordPhase = .end
    }

    @IBAction func onTouchRecordBtnDragInside(_ sender: Any) {
        // "手指上滑，取消发送"
        recordPhase = .recording
    }

    @IBAction func onTouchRecordBtnDragOutside(_ sender: Any) {
        // "松开手指，取消发送"
        recordPhase = .cancelling
    }
    
}

extension whiteBoardInputBar: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
