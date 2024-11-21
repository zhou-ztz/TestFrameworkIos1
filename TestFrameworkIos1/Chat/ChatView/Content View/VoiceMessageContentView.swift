//
//  VoiceMessageContentView.swift
//  Yippi
//
//  Created by Tinnolab on 09/04/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import NIMSDK

import ActiveLabel

class VoiceMessageContentView: BaseContentView {
    let leftSeparatorColor = UIColor(red: 216.0/255.0, green: 216.0/255.0, blue: 216.0/255.0, alpha: 1)
    let rightSeparatorColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1)
    
    lazy var playButtonImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage.set_image(named:"voice_play_blue")
        return image
    }()
    var maximumValue: Float = 0.0
    var progressValue: Float = 0.0
    lazy var durationLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.regular(FontSize.defaultTipAndNotiFontSize)
        label.textColor = UIColor(hex: 0x212121)
        label.text = "0:00"
        label.numberOfLines = 1
        return label
    }()
    //音高波纹
    public var msgStateView: IMAudioMessageStateView = IMAudioMessageStateView(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
    
    lazy var selectionLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.regular(9)
        label.textColor = .black
        label.text = ""
        label.numberOfLines = 1
        label.isUserInteractionEnabled = true
        return label
    }()
    
    var currSeconds: Int = 0
    var currMinute: Int = 0
    var index: Float = 0.0
    var labelTimer: Timer?
    var pauseTime: TimeInterval = 0.0
    var playTime: TimeInterval = 0.0
    var levels: [Float] = []
    let stateStackView = UIStackView().configure { (stack) in
        stack.axis = .horizontal
        stack.spacing = 8
    }
    
    let durationTimeStack = UIStackView().configure { (stack) in
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .equalCentering
    }
    
    let selectionTickStackView = UIStackView().configure { (stack) in
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fill
        stack.alignment = .bottom
    }
    
    let wholeStackView = UIStackView().configure { (stack) in
        stack.axis = .vertical
        stack.spacing = 6
        stack.distribution = .fill
    }

    lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = leftSeparatorColor
        return view
    }()
    
    override init(messageModel: MessageData) {
        super.init(messageModel: messageModel)
        NIMSDK.shared().mediaManager.add(self)
        setUI()
        UISetup(messageModel: messageModel)
        dataUpdate(messageModel: messageModel)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NIMSDK.shared().mediaManager.remove(self)
    }
    

    func setUI(){
        
        timeTickStackView.alignment = .center
        
        durationTimeStack.addArrangedSubview(durationLabel)
        durationTimeStack.addArrangedSubview(timeTickStackView)
        
        stateStackView.addArrangedSubview(playButtonImage)
        stateStackView.addArrangedSubview(msgStateView)
        
        wholeStackView.addArrangedSubview(stateStackView)
        wholeStackView.addArrangedSubview(durationTimeStack)

        selectionTickStackView.addArrangedSubview(selectionLabel)
//        selectionTickStackView.addArrangedSubview(timeTickStackView)
        
        self.addSubview(wholeStackView)
        self.addSubview(separatorView)
        self.addSubview(selectionTickStackView)
    }
    
    func UISetup(messageModel: MessageData) {
        selectionLabel.attributedText = "setting_language".localized.attributonString().setlineSpacing(10)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(selectionTapFunction))
        selectionLabel.addGestureRecognizer(tap)
        

        let ext = messageModel.nimMessageModel?.remoteExt
        let audioJson = ext?["voice"] as? String ?? ""
        
        if let jsonData = audioJson.data(using: .utf8) {
            do {
                let voice = try JSONDecoder().decode(VoiceDBBean.self, from: jsonData)
                let levels = voice.dbList.map({Float( Float($0) / 100) ?? 0.0})
                if let audioObject = messageModel.nimMessageModel?.messageObject as? NIMAudioObject{
                    msgStateView.duration = audioObject.duration / 1000
                    msgStateView.currentLevels = levels
                    self.levels = levels
                }
            } catch {
              
            }
        }
        
        let showReadLabel = messageModel.showReadLabel ?? false
        tickImage.isHidden = !showReadLabel
        

        let showLeft = messageModel.type == .incoming
        bubbleImage.image = showLeft ? defaultReceiverImage : defaultSenderImage

        if let messageTimeInterval = messageModel.messageTime {
            timeLabel.isHidden = false
            timeLabel.text = messageTimeInterval.messageTimeString()
        }
        timeLabel.isHidden = false
        bubbleImage.isHidden = false

        tickImage.image = messageModel.nimMessageModel!.isRemoteRead ? UIImage.set_image(named: "icon_readed_button") : UIImage.set_image(named: "icon_read_button")
        
        self.model = messageModel
        //let showLeft = messageModel.type == .incoming
 
        playButtonImage.snp.makeConstraints { make in
            make.width.height.equalTo(25)
        }
        wholeStackView.snp.removeConstraints()
        wholeStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(13)
            make.right.equalToSuperview().offset(showLeft ? -8:-18)
        }
        var levelWidth = self.levels.count * 5
        msgStateView.snp.makeConstraints { make in
            make.width.equalTo(levelWidth < 100 ? 100 : levelWidth)
        }
        
        separatorView.backgroundColor = showLeft ? leftSeparatorColor : rightSeparatorColor
        separatorView.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.top.equalTo(wholeStackView.snp.bottom).offset(10)
            make.width.equalTo(wholeStackView)
            make.centerX.equalToSuperview()
        }
        
        selectionTickStackView.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom).offset(5)
            make.left.equalToSuperview().offset(showLeft ? 18:8)
            make.right.equalToSuperview().offset(showLeft ? -8:-18)
            make.bottom.equalToSuperview().offset(-8)
            
        }
    }
    
    func dataUpdate(messageModel: MessageData) {
        
        guard let message = messageModel.nimMessageModel else { return }
        
        let audioObject = message.messageObject as! NIMAudioObject
        
        if (!message.isPlayed && message.isReceivedMsg) {
            playButtonImage.image = UIImage.set_image(named:"voice_play_blue")
        } else {
    
            playButtonImage.image = UIImage.set_image(named:"voice_play_gray")
        }
        
        let animationImages: [UIImage] = [UIImage.set_image(named: "voice_pause_gray")!]
        
        playButtonImage.animationImages = animationImages
        playButtonImage.animationDuration = 1.0
        playButtonImage.addAction {
            self.clickPlayButton()
        }
        if self.labelTimer == nil && self.progressValue == 0 {
            let seconds: Float = Float(audioObject.duration) / 1000.0
            
            self.maximumValue = seconds
            self.progressValue = Float(Double(messageModel.audioTimeDifferent ?? 0.0))
            var milliseconds = Float(audioObject.duration)
            milliseconds = milliseconds / 1000
            currSeconds = Int(fmod(milliseconds, 60))
            currMinute = Int(fmod((milliseconds / 60), 60))
            durationLabel.text = String(format: "%d:%02d", currMinute, currSeconds)
        }

        setPlaying(self.isPlaying())
    }
        
    func setPlaying(_ isPlaying: Bool) {
        
        if isPlaying {
            playButtonImage.startAnimating()
            if (labelTimer == nil) {
                let startingValue = self.progressValue
                currSeconds = Int(fmod(startingValue, 60))
                currMinute = Int(fmod((startingValue / 60), 60))
                durationLabel.text = String(format: "%01d:%02d", currMinute, currSeconds)
                labelTimer = Timer.scheduledTimer(timeInterval: TimeInterval(Float(1) / 60), target: self, selector: #selector(timerCountDown), userInfo: nil, repeats: true)
                RunLoop.current.add(labelTimer!, forMode: .common)
            }
            
        } else {
            playButtonImage.stopAnimating()
            guard let message = self.model.nimMessageModel else { return }
            let object = message.messageObject as! NIMAudioObject
            
            var milliseconds = Float(object.duration)
            milliseconds = milliseconds / 1000
            currSeconds = Int(fmod(milliseconds, 60))
            currMinute = Int(fmod((milliseconds / 60), 60))

            durationLabel.text = String(format: "%01d:%02d", currMinute, currSeconds)
            if self.progressValue == self.maximumValue {
                self.progressValue = 0
            }
            if labelTimer != nil {
                labelTimer?.invalidate()
                labelTimer = nil
            }
            self.msgStateView.resetLevelColor()
        }
    }
    
    @objc
    func selectionTapFunction(sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.2) {
            self.selectionLabel.textColor = .purple
        }
        self.delegate?.selectionLanguageTapped(model)
    }
    
    @objc func sliderAction(audioSlider: UISlider) {
        if NIMSDK.shared().mediaManager.isPlaying() {
            NIMSDK.shared().mediaManager.stopPlay()
        }
        
        let dragValue = audioSlider.value
        currSeconds = Int(fmod(dragValue, 60))
        currMinute = Int(fmod((dragValue / 60), 60))
        durationLabel.text = String(format: "%01d:%02d", currMinute, currSeconds)

        model.audioTimeDifferent = TimeInterval(audioSlider.value)
        let maximumValue = audioSlider.maximumValue
        model.audioLeftDuration = TimeInterval(maximumValue) - TimeInterval(model.audioTimeDifferent ?? 0.0)
        
        model.audioIsPaused = true
    }
    
    @objc func timerCountDown() {
        let temp = Float(1) / 60
        index = index + temp
        let indexValue = self.progressValue + temp
        self.progressValue = indexValue
        //去更新动态进度条视图的状态
        self.msgStateView.updateLevelColor(CGFloat(self.progressValue))
        self.model.audioTimeDifferent = TimeInterval(self.progressValue)
        if index >= 1 {
            currSeconds += 1
            if currSeconds == 60 {
                currSeconds = 0
                currMinute += 1
            }
            durationLabel.text = String(format: "%d:%02d", currMinute, currSeconds)
            index = 0
        }
    }
    
    @objc func clickPlayButton() {
        
        guard let message = self.model.nimMessageModel else { return }
        
        if VideoPlayer.shared.isPlaying {
            VideoPlayer.shared.stop()
        }
        if message.attachmentDownloadState == NIMMessageAttachmentDownloadState.failed || message.attachmentDownloadState == NIMMessageAttachmentDownloadState.needDownload {
            do {
                try NIMSDK.shared().chatManager.fetchMessageAttachment(message)
            } catch {
            }
            return
        }
            
        if message.attachmentDownloadState != NIMMessageAttachmentDownloadState.downloaded {
            return
        }
                            
        if IMAudioCenter.shared.currentMessage == message {
            if NIMSDK.shared().mediaManager.isPlaying() {
                NIMSDK.shared().mediaManager.stopPlay()
                stopPlayingUI()
                let maximumValue = self.maximumValue
                let timeDiff = Float(self.model.audioTimeDifferent ?? 0.0)
                model.audioTimeDifferent = TimeInterval(self.progressValue)
                model.audioLeftDuration = TimeInterval(maximumValue - self.progressValue)
                model.audioIsPaused = true
                
            } else {
                playButtonImage.startAnimating()
                self.delegate?.voiceTapped(model, contentView: self)
            }
        } else {
            if NIMSDK.shared().mediaManager.isPlaying() {
                NIMSDK.shared().mediaManager.stopPlay()
                self.stopPlayingUI()
            }

            let maximumValue = self.maximumValue
            let timeDiff = Float(self.model.audioTimeDifferent ?? 0.0)
            model.audioTimeDifferent = TimeInterval(self.progressValue)
            model.audioLeftDuration = TimeInterval(maximumValue - self.progressValue)
            model.audioIsPaused = true
            playButtonImage.startAnimating()
            self.delegate?.voiceTapped(model, contentView: self)
        }
    }
    
    func stopPlayingUI() {
        IMAudioCenter.shared.currentMessage = nil
        self.setPlaying(false)
        if (!NIMSDK.shared().mediaManager.isPlaying() && model.audioIsPaused == false) || self.progressValue == self.maximumValue {
            self.progressValue = 0
            model.audioTimeDifferent = 0
        }
    }
    
    func isPlaying() -> Bool {
        return IMAudioCenter.shared.currentMessage == self.model.nimMessageModel //对比是否是同一条消息，严格同一条，不能是相同ID，防止进了会话又进云端消息界面，导致同一个ID的云消息也在动画
    }
    
    private func playAudio(_ messageModel: MessageData) {
 
        guard let message = self.model.nimMessageModel, let audioObject = message.messageObject as? NIMAudioObject else { return }
        if VideoPlayer.shared.isPlaying {
            VideoPlayer.shared.stop()
        }
        let milliseconds = Double(audioObject.duration)
        let seconds = milliseconds / 1000.0
        
        if !NIMSDK.shared().mediaManager.isPlaying() {
            NIMSDK.shared().mediaManager.switch(NIMAudioOutputDevice.speaker)
            //pendingAudioMessages = findRemainAudioMessages(messageModel.message)
            if messageModel.audioIsPaused ?? false {
                messageModel.audioTimeSeek = seconds
                messageModel.audioTimeSeek = (messageModel.audioTimeSeek ?? 0.0) - (messageModel.audioLeftDuration ?? 0.0)
                IMAudioCenter.shared.resume(for: messageModel)
            }
            playTime = Date.timeIntervalSinceReferenceDate
        } else {
            pauseTime = Date.timeIntervalSinceReferenceDate
            messageModel.audioTimeDifferent = pauseTime - playTime
            //            pendingAudioMessages = nil
            NIMSDK.shared().mediaManager.stopPlay()
            messageModel.audioLeftDuration = (messageModel.audioLeftDuration ?? 0.0) - (messageModel.audioTimeDifferent ?? 0.0)
            messageModel.audioIsPaused = true
        }
        
    }
}

extension VoiceMessageContentView: NIMMediaManagerDelegate {
    func playAudio(_ filePath: String, didBeganWithError error: Error?) {
        self.dataUpdate(messageModel: model)
    }
    
    func playAudio(_ filePath: String, didCompletedWithError error: Error?) {
        self.stopPlayingUI()
    }
    
    func stopPlayAudio(_ filePath: String, didCompletedWithError error: Error?) {
        self.stopPlayingUI()
    }
    
    func playAudio(_ filePath: String, progress value: Float) {
       
    }
}
