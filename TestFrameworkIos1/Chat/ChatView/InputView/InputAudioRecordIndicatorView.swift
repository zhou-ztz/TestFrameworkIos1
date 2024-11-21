//
//  InputAudioRecordIndicatorView.swift
//  Yippi
//
//  Created by Khoo on 08/07/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import UIKit

enum AudioRecordPhase : Int {
    case start
    case recording
    case cancelling //取消录音
    case converting //转换文字中
    case converted //已转换
    case converterror //转换文字错误
    case end //结束录制语音
    case authError //授权错误
}

class InputAudioRecordIndicatorView: UIView {
    
    private var backgroundView: UIImageView!
    //底部View
    private var bottomStackView: UIStackView!
    private var audioTipLabel: UILabel!
    private var audioIconImageView: UIImageView!
    //按钮View
    public var sectionView: UIView!
    //取消录音
    public var cancelImageView: UIImageView!
    private var cancelIconImageView: UIImageView!
    private var cancelTipLabel: UILabel!
    //发送原语音
    public var sendVoiceImageView: UIImageView!
    private var sendVoiceIconImageView: UIImageView!
    private var sendVoiceTipLabel: UILabel!
    //转换文字
    public var convertImageView: UIImageView!
    private var convertLangNameLabel: UILabel!
    private var convertTipLabel: UILabel!
    //确认发送转换文字
    public var sendMsgImageView: UIImageView!
    private var sendMsgIconImageView: UIImageView!
    
    //管理两个气泡View
    private var allBubbleStackView: UIStackView!
    
    //内容气泡背景框
    private var centerBubbleView: UIView!
    private var bubbleStackView: UIStackView!
    private var bubbleImageView: UIImageView!
    private var bubbleArrowImageView: UIImageView!
    
    //倒计时气泡背景框
    private var countDownBubbleView: UIView!
    private var countDownBubbleImageView: UIImageView!
    private var countDownBubbleArrowImageView: UIImageView!
    
    //转换文字识别结果
    public  var recognizedTextView: UITextView!
    //音高波纹
    public  var recordStateView: IMRecordStateView!
    //more
    public  var moreButton: UIButton!
    //错误状态
    public var convertErrorView: UIView!
    private var convertErrorIconImageView: UIImageView!
    private var convertErrorLabel: UILabel!
    
    private var currentSelectedLangCode: SupportedLanguage = SupportedLanguage(code: "en", name: "English")
  
    let defaultBubbleImage = UIImage.set_image(named: "ic_nim_bubble")?.resizableImage(withCapInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 18), resizingMode: .stretch)
    let errorBubbleImage = UIImage.set_image(named: "ic_nim_bubble_red")?.resizableImage(withCapInsets: UIEdgeInsets(top: 10, left: 18, bottom: 10, right: 10), resizingMode: .stretch)
    
    var phase: AudioRecordPhase? {
        didSet {
            //隐藏识别文字
            recognizedTextView.isHidden = true
            //显示音高波纹
            recordStateView.isHidden = countDownNumber <= maxCountDownReminderNum ? true : false
            //隐藏发送原语音按钮
            sendVoiceImageView.isHidden = true
            sendVoiceIconImageView.isHidden = true
            sendVoiceTipLabel.isHidden = true
            //隐藏发送按钮
            sendMsgImageView.isHidden = true
            sendMsgIconImageView.isHidden = true
            //显示转换按钮
            convertImageView.isHidden = false
            convertLangNameLabel.isHidden = false
            convertTipLabel.isHidden = false
            //隐藏更多语言按钮
            moreButton.isHidden = true
            //显示底部
            backgroundView.isHidden = false
            bottomStackView.isHidden = false
            //更新语言标识
            currentSelectedLangCode = getSupportedLanguageData()
            guard var langCode = currentSelectedLangCode.code?.uppercased() else {
                convertLangNameLabel.text = "EN"
                return
            }
            langCode = langCode.replacingOccurrences(of: "-HANS", with: "").replacingOccurrences(of: "-HANT", with: "")
            convertLangNameLabel.text = langCode
            
            convertErrorView.isHidden = (phase != AudioRecordPhase.converterror)
            sendMsgImageView.image = UIImage.set_image(named: "ic_nim_audio_circlebg_sel")
            if phase == AudioRecordPhase.start {
                
                bubbleArrowImageView.image = UIImage.set_image(named: "ic_nim_bubble_arrow")
                //每次重新录制清除掉识别结果
                recognizedTextView.text = "..."
                centerBubbleView.isHidden = countDownNumber <= maxCountDownReminderNum
                bubbleArrowImageView.isHidden = countDownNumber <= maxCountDownReminderNum
                recognizedTextView.snp.updateConstraints { make in
                    make.height.equalTo(60) // 设置最小高度
                }
                
            } else if phase == AudioRecordPhase.cancelling {
                //取消录制
                centerBubbleView.isHidden = countDownNumber <= maxCountDownReminderNum
                bubbleArrowImageView.isHidden = countDownNumber <= maxCountDownReminderNum
                
            }else if phase == AudioRecordPhase.converting {
                //转换录制内容
                recordStateView.isHidden = true
                recognizedTextView.isHidden = false
                recognizedTextView.isUserInteractionEnabled = false
                centerBubbleView.isHidden = false
                bubbleArrowImageView.isHidden = false
                bubbleArrowImageView.image = UIImage.set_image(named: "ic_nim_bubble_arrow")
                convertImageView.image = UIImage.set_image(named: "ic_nim_audio_circlebg_sel")

            }else if phase == AudioRecordPhase.converterror {
                
                //显示发送原语音按钮
                sendVoiceImageView.isHidden = false
                sendVoiceIconImageView.isHidden = false
                sendVoiceTipLabel.isHidden = false
                //隐藏底部view
                backgroundView.isHidden = true
                bottomStackView.isHidden = true
                recordStateView.isHidden = true
                //隐藏转换按钮
                convertImageView.isHidden = true
                convertLangNameLabel.isHidden = true
                convertTipLabel.isHidden = true
                //显示发送按钮
                sendMsgImageView.isHidden = false
                sendMsgImageView.image = UIImage.set_image(named: "ic_nim_audio_circlebg_disabled")
                sendMsgIconImageView.isHidden = true
                //显示更多语言按钮
                moreButton.isHidden = !SpeechVoiceDetectManager.shared.hasRecognizedText
            }
            else if phase == AudioRecordPhase.converted {
   
                recognizedTextView.isHidden = false
                recognizedTextView.isUserInteractionEnabled = true
                //显示发送原语音按钮
                sendVoiceImageView.isHidden = false
                sendVoiceIconImageView.isHidden = false
                sendVoiceTipLabel.isHidden = false
                //隐藏底部view
                backgroundView.isHidden = true
                bottomStackView.isHidden = true
                recordStateView.isHidden = true
                //隐藏转换按钮
                convertImageView.isHidden = true
                convertLangNameLabel.isHidden = true
                convertTipLabel.isHidden = true
                //显示发送按钮
                sendMsgImageView.isHidden = false
                sendMsgIconImageView.isHidden = false
                //显示更多语言按钮
                moreButton.isHidden = false
                //隐藏倒计时Label
                countDownBubbleView.isHidden = true
                countDownBubbleArrowImageView.isHidden = true
                
                var recognizedStr = recognizedTextView.text
                recognizedStr = recognizedStr?.replacingOccurrences(of: ".", with: "")
                recognizedTextView.text = recognizedStr
             
            } else {
                bubbleArrowImageView.image = UIImage.set_image(named: "ic_nim_bubble_arrow")
            }
            //设置气泡颜色
            bubbleImageView.image = (phase == AudioRecordPhase.converterror || phase == AudioRecordPhase.cancelling) ? errorBubbleImage : defaultBubbleImage
            bubbleArrowImageView.image = UIImage.set_image(named: (phase == AudioRecordPhase.converterror || phase == AudioRecordPhase.cancelling) ? "ic_nim_bubble_arrow_red" : "ic_nim_bubble_arrow")
            
            countDownBubbleImageView.image = (phase == AudioRecordPhase.converterror || phase == AudioRecordPhase.cancelling) ? errorBubbleImage : defaultBubbleImage
            countDownBubbleArrowImageView.image = UIImage.set_image(named: (phase == AudioRecordPhase.converterror || phase == AudioRecordPhase.cancelling) ? "ic_nim_bubble_arrow_red" : "ic_nim_bubble_arrow")
            
            //设置箭头位置
            self.bubbleArrowImageView.snp.updateConstraints { make in
                make.centerX.equalTo(self.centerBubbleView).offset((phase == AudioRecordPhase.converting || phase == AudioRecordPhase.converted) ? 100 : 0)
            }
            self.sectionView.snp.updateConstraints { make in
                make.bottom.equalToSuperview().inset((phase == AudioRecordPhase.converterror || phase == AudioRecordPhase.converted) ?  Constants.NIM.NIMKit_ViewHeight :Constants.NIM.NIMKit_BottomViewHeight)
            }
            self.centerBubbleView.snp.updateConstraints { make in
                make.width.equalTo((phase == AudioRecordPhase.cancelling || phase == AudioRecordPhase.recording) ?  bubble_width : large_bubble_width)
            }
            //设置取消状态
            cancelImageView.image = phase == AudioRecordPhase.cancelling ?  UIImage.set_image(named: "ic_nim_audio_circlebg_sel") : UIImage.set_image(named: "ic_nim_audio_circlebg")
            cancelIconImageView.image = phase == AudioRecordPhase.cancelling ?  UIImage.set_image(named: "ic_nim_audio_cancel_sel") : UIImage.set_image(named: "ic_nim_audio_cancel")
            convertImageView.image = phase == AudioRecordPhase.converting ?  UIImage.set_image(named: "ic_nim_audio_circlebg_sel") : UIImage.set_image(named: "ic_nim_audio_circlebg")
            
            convertLangNameLabel.font = UIFont.boldSystemFont(ofSize: (phase == AudioRecordPhase.converting) ? 31 : 18)
            convertLangNameLabel.textColor = (phase == AudioRecordPhase.converting) ? UIColor(hex: 0x34C759) : .white
            
        }
    }
    var authErrorMsg: String? {
        didSet {
            convertErrorLabel.text = authErrorMsg ?? ""
        }
    }
    var countDownNumber: Int = 60 {
        didSet {
            countDownNumberLabel.text = String(format: "voice_msg_countdown".localized, "\(countDownNumber)")
            centerBubbleView.isHidden = (phase == AudioRecordPhase.converting) ? false : countDownNumber < maxCountDownReminderNum
            bubbleArrowImageView.isHidden = (phase == AudioRecordPhase.converting) ? false : countDownNumber < maxCountDownReminderNum
            countDownBubbleView.isHidden =  countDownNumber >= maxCountDownReminderNum
            countDownBubbleArrowImageView.isHidden = countDownNumber >= maxCountDownReminderNum
        }
    }
    var recordTime: TimeInterval = 0.0 {
        didSet {
            let minutes = Int(recordTime) / 60
            let seconds = Int(recordTime) % 60
        }
    }
    var countDownNumberLabel: UILabel!
    
    private let frameSideLength: CGFloat = 42
    private let x_cancel: CGFloat = 64
    private let x_convert: CGFloat = ScreenWidth - 64 - 42
    private let y_view: CGFloat = 50
    private let bubble_width: CGFloat = ScreenWidth * 0.65
    private let large_bubble_width: CGFloat = ScreenWidth * 0.75
    //最大倒计时提醒数
    private let maxCountDownReminderNum : Int = 10
    private let bubbleHeight : CGFloat = (ScreenWidth * 0.75) * 0.2
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addKeyboardObserver()
        self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        //底部椭圆视图
        backgroundView = UIImageView(image: UIImage.set_image(named: "ic_nim_audio_bottom"))
        backgroundView.contentMode = .scaleAspectFit
        addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(20)
            make.height.equalTo(Constants.NIM.NIMKit_BottomViewHeight)
        }
        //椭圆视图内部视图
        bottomStackView = UIStackView()
        bottomStackView.axis = .vertical
        bottomStackView.distribution = .fill
        bottomStackView.alignment = .center
        bottomStackView.spacing = 7
        addSubview(bottomStackView)
    
        
        audioTipLabel = UILabel(frame: CGRect.zero)
        audioTipLabel.font = UIFont.systemFont(ofSize: CGFloat(Constants.NIM.NIMKit_TipFontSize))
        audioTipLabel.textColor = UIColor(hex: 0x808080)
        audioTipLabel.textAlignment = .center
        audioTipLabel.text = "im_release_to_send".localized
        
        audioIconImageView = UIImageView(frame: CGRectMake(0, 0, 18, 25))
        audioIconImageView.image = UIImage.set_image(named: "ic_nim_audio_icon")
        
        bottomStackView.addArrangedSubview(audioTipLabel)
        bottomStackView.addArrangedSubview(audioIconImageView)
        
        bottomStackView.snp.makeConstraints { make in
            make.centerX.equalTo(backgroundView)
            make.centerY.equalTo(backgroundView).offset(-15)
        }
        //底部按钮视图
        sectionView = UIView(frame: .zero)
        addSubview(sectionView)
        sectionView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().inset(Constants.NIM.NIMKit_BottomViewHeight)
            make.height.equalTo(150)
        }
        
        allBubbleStackView = UIStackView()
        allBubbleStackView.axis = .vertical
        allBubbleStackView.distribution = .fill
        allBubbleStackView.alignment = .center
        allBubbleStackView.spacing = 7
        addSubview(allBubbleStackView)
        allBubbleStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.sectionView.snp.top).offset(-25)
        }
        
        //取消
        cancelImageView = UIImageView(frame: CGRectMake(x_cancel, y_view, frameSideLength, frameSideLength))
        cancelImageView.image = UIImage.set_image(named: "ic_nim_audio_circlebg")
        sectionView.addSubview(cancelImageView)
        
        cancelIconImageView = UIImageView(frame: .zero)
        cancelIconImageView.image = UIImage.set_image(named: "ic_nim_audio_cancel")
        sectionView.addSubview(cancelIconImageView)
        cancelIconImageView.snp.makeConstraints { make in
            make.center.equalTo(cancelImageView)
        }
        cancelTipLabel = UILabel(frame: CGRect.zero)
        cancelTipLabel.font = UIFont.systemFont(ofSize: CGFloat(Constants.NIM.NIMKit_TipFontSize))
        cancelTipLabel.textColor = .white
        cancelTipLabel.textAlignment = .center
        cancelTipLabel.text = "cancel".localized
        sectionView.addSubview(cancelTipLabel)
        cancelTipLabel.snp.makeConstraints { make in
            make.centerX.equalTo(cancelImageView)
            make.top.equalTo(cancelImageView.snp.bottom).offset(12)
        }
        
        //发送原语音
        sendVoiceImageView = UIImageView(frame: .zero)
        sendVoiceImageView.image = UIImage.set_image(named: "ic_nim_audio_circlebg")
        sendVoiceImageView.isHidden = true
        sectionView.addSubview(sendVoiceImageView)
        sendVoiceImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(y_view)
        }
        sendVoiceIconImageView = UIImageView(frame: .zero)
        sendVoiceIconImageView.image = UIImage.set_image(named: "ic_nim_voice_icon")
        sectionView.addSubview(sendVoiceIconImageView)
        sendVoiceIconImageView.isHidden = true
        sendVoiceIconImageView.snp.makeConstraints { make in
            make.center.equalTo(sendVoiceImageView)
        }
        
        sendVoiceTipLabel = UILabel(frame: CGRect.zero)
        sendVoiceTipLabel.font = UIFont.systemFont(ofSize: CGFloat(Constants.NIM.NIMKit_TipFontSize))
        sendVoiceTipLabel.textColor = .white
        sendVoiceTipLabel.textAlignment = .center
        sendVoiceTipLabel.numberOfLines = 0
        sendVoiceTipLabel.isHidden = true
        sendVoiceTipLabel.text = "im_send_voice_message".localized
        sectionView.addSubview(sendVoiceTipLabel)
        sendVoiceTipLabel.snp.makeConstraints { make in
            make.centerX.equalTo(sendVoiceImageView)
            make.top.equalTo(sendVoiceImageView.snp.bottom).offset(12)
            make.width.equalTo(108)
        }
        
        //转换
        convertImageView = UIImageView(frame: CGRectMake(x_convert, y_view, frameSideLength, frameSideLength))
        convertImageView.image = UIImage.set_image(named: "ic_nim_audio_circlebg")
        sectionView.addSubview(convertImageView)
        
        convertLangNameLabel = UILabel(frame: CGRect.zero)
        convertLangNameLabel.font = UIFont.boldSystemFont(ofSize: CGFloat(18))
        convertLangNameLabel.textColor = .white
        convertLangNameLabel.textAlignment = .center
        //更新语言标识
        guard var langCode = currentSelectedLangCode.code?.uppercased() else {
            convertLangNameLabel.text = "EN"
            return
        }
        langCode = langCode.replacingOccurrences(of: "-HANS", with: "").replacingOccurrences(of: "-HANT", with: "")
        convertLangNameLabel.text = langCode
        sectionView.addSubview(convertLangNameLabel)
        convertLangNameLabel.snp.makeConstraints { make in
            make.center.equalTo(convertImageView)
        }
        
        convertTipLabel = UILabel(frame: CGRect.zero)
        convertTipLabel.font = UIFont.systemFont(ofSize: CGFloat(Constants.NIM.NIMKit_TipFontSize))
        convertTipLabel.textColor = .white
        convertTipLabel.textAlignment = .center
        convertTipLabel.text = "im_convert_to_text".localized
        sectionView.addSubview(convertTipLabel)
        convertTipLabel.snp.makeConstraints { make in
            make.centerX.equalTo(convertImageView)
            make.top.equalTo(convertImageView.snp.bottom).offset(12)
        }
        
        //确认发送转换文字
        sendMsgImageView = UIImageView(frame: .zero)
        sendMsgImageView.image = UIImage.set_image(named: "ic_nim_audio_circlebg_sel")
        sendMsgImageView.isHidden = true
        
        sectionView.addSubview(sendMsgImageView)
        sendMsgImageView.snp.makeConstraints { make in
            make.center.equalTo(convertImageView)
            make.size.equalTo(CGSize(width: 64, height: 64))
        }
        
        sendMsgIconImageView = UIImageView(frame: .zero)
        sendMsgIconImageView.image = UIImage.set_image(named: "ic_nim_audio_confirm")
        sectionView.addSubview(sendMsgIconImageView)
        sendMsgIconImageView.isHidden = true
        sendMsgIconImageView.snp.makeConstraints { make in
            make.center.equalTo(sendMsgImageView)
        }
        
        //倒计时气泡视图
        countDownBubbleView = UIView()
        countDownBubbleView.isHidden = true
        allBubbleStackView.addArrangedSubview(countDownBubbleView)
        countDownBubbleView.snp.makeConstraints { make in
            make.width.equalTo(bubble_width)
            make.height.equalTo(100)
        }
        //倒计时气泡图片
        countDownBubbleImageView = UIImageView(image: UIImage.set_image(named: "ic_nim_bubble"))
        countDownBubbleView.addSubview(countDownBubbleImageView)
        countDownBubbleImageView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.equalTo(-30)
        }
        //倒计时提示Label
        countDownNumberLabel = UILabel(frame: CGRect.zero)
        countDownNumberLabel.font = UIFont.systemFont(ofSize: CGFloat(14))
        countDownNumberLabel.textColor = UIColor.white
        countDownNumberLabel.textAlignment = .center
        countDownNumberLabel.text = "-"
        countDownBubbleView.addSubview(countDownNumberLabel)
        countDownNumberLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-15)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(25)
        }
        //倒计时箭头
        countDownBubbleArrowImageView = UIImageView(image: UIImage.set_image(named: "ic_nim_bubble_arrow"))
        countDownBubbleView.addSubview(countDownBubbleArrowImageView)
        countDownBubbleArrowImageView.isHidden = true
        countDownBubbleArrowImageView.snp.makeConstraints { make in
            make.centerX.equalTo(countDownBubbleView)
            make.top.equalTo(countDownBubbleImageView.snp.bottom).offset(-10)
            make.size.equalTo(CGSize(width: 49, height: 29))
        }
        //气泡View
        centerBubbleView = UIView()
        centerBubbleView.backgroundColor = .clear
        allBubbleStackView.addArrangedSubview(centerBubbleView)
        centerBubbleView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.sectionView.snp.top).offset(-25)
            make.width.equalTo(bubble_width)
            make.height.greaterThanOrEqualTo(60).priority(.high)
        }
        //气泡背景图片
        bubbleImageView = UIImageView(image: UIImage.set_image(named: "ic_nim_bubble"))
        centerBubbleView.addSubview(bubbleImageView)
        bubbleImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        //气泡内部视图
        bubbleStackView = UIStackView()
        bubbleStackView.axis = .vertical
        bubbleStackView.distribution = .fill
        bubbleStackView.alignment = .center
        bubbleStackView.spacing = 0
        bubbleStackView.isLayoutMarginsRelativeArrangement = true
        bubbleStackView.layoutMargins = UIEdgeInsets(top: 25, left: 0, bottom: 25, right: 0)
        centerBubbleView.addSubview(bubbleStackView)
        bubbleStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        //识别错误视图
        convertErrorView = UIView()
        bubbleStackView.addArrangedSubview(convertErrorView)
        convertErrorView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(bubbleHeight)
        }
        //识别错误icon
        convertErrorIconImageView = UIImageView(image: UIImage.set_image(named: "ic_nim_audio_error_icon"))
        convertErrorView.addSubview(convertErrorIconImageView)
        convertErrorIconImageView.snp.makeConstraints { make in
            make.left.equalTo(25)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 15, height: 15))
        }
        //识别错误提示
        convertErrorLabel = UILabel(frame: CGRect.zero)
        convertErrorLabel.font = UIFont.systemFont(ofSize: CGFloat(Constants.NIM.NIMKit_TipFontSize))
        convertErrorLabel.textColor = .white
        convertErrorLabel.numberOfLines = 0
        convertErrorLabel.text = "im_unable_to_recognize_words".localized
        convertErrorView.addSubview(convertErrorLabel)
        convertErrorLabel.snp.makeConstraints { make in
            make.left.equalTo(convertErrorIconImageView.snp.right).offset(8)
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
        }
        //气泡箭头
        bubbleArrowImageView = UIImageView(image: UIImage.set_image(named: "ic_nim_bubble_arrow"))
        centerBubbleView.addSubview(bubbleArrowImageView)
        bubbleArrowImageView.snp.makeConstraints { make in
            make.centerX.equalTo(centerBubbleView)
            make.top.equalTo(centerBubbleView.snp.bottom).offset(-10)
            make.size.equalTo(CGSize(width: 49, height: 29))
        }
        //音量波纹
        recordStateView = IMRecordStateView(frame: CGRect(x: 0, y: 0, width: bubble_width, height: 70))
        bubbleStackView.addArrangedSubview(recordStateView)
        recordStateView.snp.makeConstraints { make in
            make.height.equalTo(70)
            make.width.equalTo(bubble_width)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-10)
        }
        //识别内容TextView
        recognizedTextView = UITextView(frame: CGRect.zero)
        recognizedTextView.font = UIFont.systemFont(ofSize: CGFloat(Constants.NIM.NIMKit_TextFontSize))
        recognizedTextView.textColor = .white
        recognizedTextView.backgroundColor = .clear
        recognizedTextView.textAlignment = .left
        recognizedTextView.delegate = self
        recognizedTextView.tintColor = UIColor.white
        recognizedTextView.isScrollEnabled = true
        bubbleStackView.addArrangedSubview(recognizedTextView)
        recognizedTextView.addObserver(self, forKeyPath: "text", options: .new, context: nil)
        recognizedTextView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(5)
            make.trailing.equalToSuperview().offset(-5)
            make.height.equalTo(60) // 设置最小高度
        }
        //识别更多语种按钮
        moreButton = UIButton(type: .custom)
        moreButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        moreButton.layer.masksToBounds = true
        moreButton.layer.cornerRadius = 10
        moreButton.isHidden = true
        moreButton.setImage(UIImage.set_image(named: "ic_nim_audio_more"))
        addSubview(moreButton)
        moreButton.snp.makeConstraints { make in
            make.bottom.equalTo(centerBubbleView.snp.top).offset(-6)
            make.right.equalTo(centerBubbleView.snp.right)
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    private func addKeyboardObserver() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(setVoiceKeyboardHidden), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(setVoiceKeyboardSwitchButton), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    @objc func setVoiceKeyboardSwitchButton(notification: Notification) {
        guard let keyboardValue = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        let keyboardHeight : Int = Int(keyboardValue.height)
        sectionView.snp.updateConstraints { make in
            make.height.equalTo(50 + keyboardHeight)
        }

    }
    @objc func setVoiceKeyboardHidden(notification: Notification) {
 
        sectionView.snp.updateConstraints { make in
            make.height.equalTo(150)
        }
    }
    
    func getSupportedLanguageData() -> SupportedLanguage {
        let langIdentifier = Locale.current.languageCode ?? "en"
        if let preferredLanguageObject = UserDefaults.standard.object(forKey: "SpeechToTextTypingLanguage") as? [String:String] {
            return SupportedLanguage(code: preferredLanguageObject["locale"] ?? langIdentifier, name: preferredLanguageObject["name"] ?? LocalizationManager.getDisplayNameForLanguageIdentifier(identifier: langIdentifier))
        }

        return SupportedLanguage(code: langIdentifier, name: LocalizationManager.getDisplayNameForLanguageIdentifier(identifier: langIdentifier))
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
// MARK: - UITextView delegate
extension InputAudioRecordIndicatorView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let maxHeight = recognizedTextView.contentSize.height > 200 ? 200 : recognizedTextView.contentSize.height
        recognizedTextView.snp.updateConstraints { make in
            make.height.equalTo(maxHeight + 5)
        }
        bubbleStackView.layoutIfNeeded()
    }
    
}
// MARK: - 实现 KVO 回调方法
extension InputAudioRecordIndicatorView {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "text" && (phase == AudioRecordPhase.converting || phase == AudioRecordPhase.converted){
            let maxHeight = recognizedTextView.contentSize.height > 200 ? 200 : recognizedTextView.contentSize.height
            recognizedTextView.snp.updateConstraints { make in
                make.height.equalTo(maxHeight + 5)
            }
            bubbleStackView.layoutIfNeeded()
        }
    }
    
}
