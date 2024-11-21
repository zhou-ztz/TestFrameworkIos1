//
//  BaseMessageCell.swift
//  Yippi
//
//  Created by Tinnolab on 01/04/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit
import SnapKit
import NIMSDK
import FLAnimatedImage
//import NIMPrivate

protocol MessageCellDelegate: class {
    func longPressMessageCell(_ cell: BaseMessageCell, message: MessageData)
    func longPressAvatar(_ cell: BaseMessageCell, message: MessageData)
    func tappedAvatar(_ userId: String)
    
    func tappedContactCard(_ cell: BaseMessageCell, message: MessageData)
    func tappedStickerCard(_ cell: BaseMessageCell, message: MessageData)
    func tappedSocialPost(_ cell: BaseMessageCell, message: MessageData)
    func tappedImage(_ cell: BaseMessageCell, message: MessageData)
    func tappedVideo(_ cell: BaseMessageCell, message: MessageData)
    func tappedLocation(_ cell: BaseMessageCell, message: MessageData)
    func tappedEgg(_ cell: BaseMessageCell, message: MessageData)
    func tappedRetryTextTranslate(_ cell: BaseMessageCell, message: MessageData)
    func tappedFile(_ cell: BaseMessageCell, message: MessageData)
    func tappedMeeting(_ cell: BaseMessageCell, message: MessageData)
    func tappedReplyMessage(_ cell: BaseMessageCell, message: MessageData)
    func onRemoveSecretMessage(message: MessageData)
    func tappedSnapMessage(_ cell: BaseMessageCell, message: MessageData, baseView: UIView, isEnd: Bool)
    func tappedMiniProgramMessage(_ cell: BaseMessageCell, message: MessageData)
    func tappedStickerRPSMessage(_ cell: BaseMessageCell, message: MessageData)
    func tappedAnnouncementMessage(_ cell: BaseMessageCell, url: String?)
    func tappedVoiceMessage(_ cell: BaseMessageCell, message: MessageData, contentView: VoiceMessageContentView)
    func tappedTextUrl(_ url: String?)
    func selectionLanguageTapped(_ cell: BaseMessageCell, message: MessageData)
    func tappedWhiteboard(_ cell: BaseMessageCell, message: MessageData)
    func tappedUnknown()
    func tappedVoucher(_ cell: BaseMessageCell, message: MessageData)
}

class BaseMessageCell: UITableViewCell, BaseCellProtocol {
    weak var delegate: MessageCellDelegate?
    @IBOutlet weak var avatarHeaderView: AvatarView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var alertButton: UIButton!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    @IBOutlet weak var secretTimerLabel: UILabel!
    @IBOutlet weak var bubbleContentView: BaseContentView!
    @IBOutlet weak var alertLoadingView: UIView!
    @IBOutlet weak var bubbleTimerView: UIView!
    
    @IBOutlet weak var bubbleContentStackView: UIStackView!
    @IBOutlet weak var nameContentStackView: UIStackView!
    @IBOutlet weak var wholeContentStackView: UIStackView!
    var laodImageView = FLAnimatedImageView().configure {
        $0.image = UIImage.set_image(named: "icon_sessionlist_more_normal")
        $0.contentMode = .scaleAspectFit
        $0.isHidden = true
    }
    private let pulseIndicator = IMSendMsgIndicator(radius: 8.0, color: TSColor.main.theme)
    var timerCounting: Bool = false
    var timer: Timer? = nil
    var currSeconds: Int = 0
    var currCountingMsg: NIMMessage?
    
    var showUserProfile: ((String?) -> Void)?
    var resendMessage: ((MessageData) -> Void)?
    
    var messageModel: MessageData!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let selectedBackground = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        selectedBackground.backgroundColor = .clear
        self.selectedBackgroundView = selectedBackground
    }
    
    func commonInit() {
        pulseIndicator.isHidden = true
        self.avatarHeaderView.backgroundColor = .clear
        
        nicknameLabel.font = AppTheme.Font.regular(13.0)
        nicknameLabel.textColor = .darkGray
        nicknameLabel.text = ""
        nicknameLabel.textAlignment = .left
        nicknameLabel.numberOfLines = 1
        
        secretTimerLabel.font = AppTheme.Font.regular(9.0)
        secretTimerLabel.textColor = .white
        secretTimerLabel.backgroundColor = AppTheme.aquaGreen
        secretTimerLabel.text = "1"
        secretTimerLabel.textAlignment = .center
        secretTimerLabel.numberOfLines = 1
        secretTimerLabel.layer.masksToBounds = true
        secretTimerLabel.circleCorner()
        
        loadingView.hidesWhenStopped = true
        loadingView.stopAnimating()
        alertLoadingView.addSubview(pulseIndicator)
        pulseIndicator.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
        pulseIndicator.layoutIfNeeded()
        let avatar = AvatarInfo()
        avatar.avatarPlaceholderType = .unknown
        avatarHeaderView.avatarInfo = avatar
    }
    
    func dataUpdate(contentView:BaseContentView, messageModel: MessageData) {
        self.messageModel = messageModel
        self.bubbleContentView?.removeFromSuperview()
        self.bubbleContentView = contentView
        
        self.bubbleContentView.delegate = self
        
        let showLeft = messageModel.type == .incoming
        let isSecretMsg = messageModel.isSecretMsg ?? false
        let showAvatar = messageModel.showAvatar ?? false
        let showNickname = messageModel.showName ?? false
        avatarHeaderView.isHidden = !showAvatar
        nicknameLabel.isHidden = !showNickname
        secretTimerLabel.isHidden = !isSecretMsg
        alertButton.isHidden = hideErrorButton(messageModel.nimMessageModel)
        pulseIndicator.isHidden = hideloadingView(messageModel.nimMessageModel)
//        if messageModel.nimMessageModel?.session?.sessionType == .P2P || messageModel.nimMessageModel?.session?.sessionType == .team {
//            nicknameLabel.text = NIMKitUtil.showNick(messageModel.nimMessageModel?.from, in: messageModel.nimMessageModel?.session)
//        } else {
//            self.nickname(messageModel.nimMessageModel)
//        }
        if let model = messageModel.nimMessageModel, let object = model.messageObject as? NIMCustomObject, object.attachment is IMTextTranslateAttachment {
            avatarHeaderView.isHidden = showLeft ? false : true
            avatarHeaderView.alpha = 0
            alertButton.isHidden = true
        }
        
        // By Kit Foong (Check is Remote Read Status)
        if messageModel.nimMessageModel?.session?.sessionType == .P2P {
            self.bubbleContentView.tickImage.image = messageModel.nimMessageModel!.isRemoteRead ? UIImage.set_image(named: "readTick") : UIImage.set_image(named: "unreadTick")
        } else {
            self.bubbleContentView.tickImage.image = (messageModel.nimMessageModel!.teamReceiptInfo?.unreadCount ?? 0) == 0 ? UIImage.set_image(named: "readTick") : UIImage.set_image(named: "unreadTick")
        }
    
        self.avatarHeaderView.avatarInfo = NIMSDKManager.shared.getAvatarIconFromMessage(message: messageModel.nimMessageModel)
        self.avatarHeaderView.buttonForAvatar.addAction { [weak self] in
            self?.showUserProfile?(messageModel.nimMessageModel?.from)
            self?.avatarTaped(userId: messageModel.nimMessageModel?.from ?? "")
        }
        UIUpdate(showLeft: showLeft, showTimer: isSecretMsg)
        
        if !(contentView.isKind(of: SnapMessageContentView.self) && hideErrorButton(messageModel.nimMessageModel) ){
            let longPressAction = UILongPressGestureRecognizer(target: self, action: #selector(cellLongGesturePress))
            self.bubbleContentView.addGestureRecognizer(longPressAction)
            
        }
        
        let avatarLongPressAction = UILongPressGestureRecognizer(target: self, action: #selector(avatarLongGesturePress))
        self.avatarHeaderView.addGestureRecognizer(avatarLongPressAction)
        self.bubbleContentView.layoutIfNeeded()
        self.bubbleTimerView.layoutIfNeeded()
        self.bubbleContentStackView.layoutIfNeeded()
        self.nameContentStackView.layoutIfNeeded()
        self.wholeContentStackView.layoutIfNeeded()
        self.layoutIfNeeded()
    }
    
    func UIUpdate(showLeft: Bool, showTimer:Bool) {
        nameContentStackView.alignment = showLeft ? .leading : .trailing
        nicknameLabel.textAlignment = showLeft ? .left : .right
        wholeContentStackView.removeAllArrangedSubviews()
        bubbleContentStackView.removeAllArrangedSubviews()
        
        if showLeft {
            wholeContentStackView.addArrangedSubview(avatarHeaderView)
            wholeContentStackView.addArrangedSubview(nameContentStackView)
            bubbleContentStackView.addArrangedSubview(bubbleTimerView)
            bubbleContentStackView.addArrangedSubview(alertLoadingView)
            
        } else {
            wholeContentStackView.addArrangedSubview(nameContentStackView)
            wholeContentStackView.addArrangedSubview(avatarHeaderView)
            bubbleContentStackView.addArrangedSubview(alertLoadingView)
            bubbleContentStackView.addArrangedSubview(bubbleTimerView)
        }
        self.wholeContentStackView.removeConstraints(self.wholeContentStackView.constraints)
        wholeContentStackView.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            if showLeft {
                make.leading.equalToSuperview().offset(8)
                make.width.lessThanOrEqualTo(ScreenWidth - 50)
            } else {
                make.right.equalToSuperview().offset(-8)
                make.width.lessThanOrEqualTo(ScreenWidth - 50)
            }
        }
       
        self.bubbleTimerView.removeConstraints(self.bubbleTimerView.constraints)
        self.bubbleTimerView.addSubview(bubbleContentView)
        self.bubbleTimerView.bringSubviewToFront(secretTimerLabel)
        secretTimerLabel.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        secretTimerLabel.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.width.height.equalTo(20)
            if showLeft {
                make.trailing.equalToSuperview().offset(-2)
            } else {
                make.leading.equalToSuperview().offset(2)
            }
        }
        secretTimerLabel.circleCorner()
        bubbleContentView.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(showTimer ? 10 : 0)
            make.bottom.equalToSuperview()
            if showLeft {
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview().inset(showTimer ? 13 : 0)
            } else {
                make.leading.equalToSuperview().offset(showTimer ? 13 : 0)
                make.trailing.equalToSuperview()
            }
        }
        if showTimer {
            self.identifySecretMessage(data: self.messageModel)
        }
    }
    
    @IBAction func alertButtonClicked(_ sender: Any) {
//        guard let message = self.messageModel.nimMessageModel else { return }
//        self.resendMessage?(message)
        self.resendMessage?(self.messageModel)
    }
    
    private func nickname(_ message: NIMMessage?) -> String {
        guard let message = message else {
            return ""
        }
        if let ext = message.remoteExt, let nickname = ext["nickname"] as? String {
            return nickname
        } else {
            return NIMSDKManager.shared.getDisplayName(from: message)
        }
    }
    
    private func hideErrorButton(_ message: NIMMessage?) -> Bool {
        guard let message = message else {
            return true
        }
        
        if !message.isReceivedMsg {            
            if let yidunAntiSpamRes = message.yidunAntiSpamRes, yidunAntiSpamRes.isEmpty == false {
                return false
            } else if let localExt = message.localExt, let yidunAntiSpam = localExt["yidunAntiSpamRes"] as? String, yidunAntiSpam.isEmpty == false {
                return false
            }
            return message.deliveryState != .failed
        } else {
            return message.attachmentDownloadState != .failed
        }
    }
    
    private func hideloadingView(_ message: NIMMessage?) -> Bool{
        guard let message = message else {
            pulseIndicator.stopAnimating()
            return true
        }
        if !message.isReceivedMsg {
            pulseIndicator.startAnimating()
            message.deliveryState == .delivering ? pulseIndicator.startAnimating() : pulseIndicator.stopAnimating()
            return message.deliveryState != .delivering
        } else {
            pulseIndicator.stopAnimating()
            return true
        }
    }
    
    @objc func cellLongGesturePress(_ gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == .began {
            self.delegate?.longPressMessageCell(self, message: self.messageModel)
        }
    }
    
    @objc func avatarLongGesturePress(_ gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == .began {
            self.delegate?.longPressAvatar(self, message: self.messageModel)
        }
    }
    
    @objc func avatarTaped(userId: String) {
        self.delegate?.tappedAvatar(userId)
    }
    
    func identifySecretMessage(data: MessageData) {
        guard let message = self.messageModel.nimMessageModel else { return }
        let timeStampValue: TimeInterval = Date().timeIntervalSince1970
        let duration = data.secretMsgDuration! / 1000
        var localReceiverTimestamp = Int(round(timeStampValue))
        
        if !self.timerCounting {
            self.currSeconds = duration
        }
            
        if(message.isReceivedMsg) {
            if let ext = message.localExt, let time = ext["receiverLocalSecretChatTimer"] as? Int {
                localReceiverTimestamp = time
            } else {
                let receiverSecretTimeStampValue = localReceiverTimestamp + duration
                localReceiverTimestamp = receiverSecretTimeStampValue
                message.localExt = ["receiverLocalSecretChatTimer":localReceiverTimestamp]
                NIMSDK.shared().conversationManager.update(message, for: message.session!, completion: nil)
            }
        }

        let currentTimeInterval = Date().timeIntervalSince1970

        let messageTimeStamp = Int(round(message.timestamp)) + duration

        let currentDuration = message.isReceivedMsg ? localReceiverTimestamp - Int(round(currentTimeInterval)) : messageTimeStamp - Int(round(currentTimeInterval))
        
        if currentDuration > 0 {
            secretTimerLabel.text = "\(currentDuration)"
            self.startTimer(duration: currentDuration, message: message, messageData: data)
        } else {
            self.startTimer(duration: 0, message: message, messageData: data)
        }
    }

    func startTimer(duration: Int, message: NIMMessage, messageData: MessageData) {
        var currSeconds: Int
        currSeconds = duration
        if let timer = self.timer {
            timer.invalidate()
            self.timer = nil
        }
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (time) in
            self.timerCounting = true
            if currSeconds > 0 {
                if message.deliveryState == .deliveried {
                    currSeconds = currSeconds - 1
                    DispatchQueue.main.async {
                        self.secretTimerLabel.text = "\(currSeconds)"
                    }
                    self.currSeconds = currSeconds
                }
            }
            
            if currSeconds == 0 {
                self.currSeconds = currSeconds
                if let timer = self.timer {
                    timer.invalidate()
                    self.timer = nil
                }
                self.timerCounting = false

                if (message.remoteExt != nil) {
                    let ext = message.remoteExt!
                    let durati = ext["secretChatTimer"] as! Int
                    if durati != 0 {
                        self.currCountingMsg = nil
                        self.onTimeExpired(message: messageData)
                    }
                }
            }
        })
    }
    
    func onTimeExpired(message: MessageData) {
        self.delegate?.onRemoveSecretMessage(message: message)
    }
}

extension BaseMessageCell: ContentViewDelegate {
    func contactCardTapped(_ message: MessageData) {
        self.delegate?.tappedContactCard(self, message: self.messageModel)
    }
    
    func stickerCardTapped(_ message: MessageData) {
        self.delegate?.tappedStickerCard(self, message: self.messageModel)
    }
    
    func socialPostTapped(_ message: MessageData) {
        self.delegate?.tappedSocialPost(self, message: self.messageModel)
    }
    
    func imageTapped(_ message: MessageData) {
        self.delegate?.tappedImage(self, message: self.messageModel)
    }
    
    func videoTapped(_ message: MessageData) {
        self.delegate?.tappedVideo(self, message: self.messageModel)
    }
    
    func locationTapped(_ message: MessageData) {
        self.delegate?.tappedLocation(self, message: self.messageModel)
    }
    
    func eggTapped(_ message: MessageData) {
        self.delegate?.tappedEgg(self, message: self.messageModel)
    }
    
    func retryTextTranslate(_ message: MessageData) {
        self.delegate?.tappedRetryTextTranslate(self, message: self.messageModel)
    }
    
    func fileTapped(_ message: MessageData) {
        self.delegate?.tappedFile(self, message: self.messageModel)
    }
    
    func meetingTapped(_ message: MessageData) {
        self.delegate?.tappedMeeting(self, message: self.messageModel)
    }
    
    func replyMessageTapped(_ message: MessageData) {
        self.delegate?.tappedReplyMessage(self, message: self.messageModel)
    }
    
    func snapMessageTapped(_ message: MessageData, baseView: UIView, isEnd: Bool) {
        self.delegate?.tappedSnapMessage(self, message: self.messageModel, baseView: baseView, isEnd: isEnd)
    }
    
    func MiniProgramMessageTapped(_ message: MessageData) {
        self.delegate?.tappedMiniProgramMessage(self, message: self.messageModel)
    }
    
    func stickerPRSTapped(_ message: MessageData) {
        self.delegate?.tappedStickerRPSMessage(self, message: self.messageModel)
    }
    
    func AnnouncementTapped(_ url: String?) {
        self.delegate?.tappedAnnouncementMessage(self, url: url)
    }

    func voiceTapped(_ message: MessageData, contentView: VoiceMessageContentView) {
        self.delegate?.tappedVoiceMessage(self, message: message, contentView: contentView)
    }
    
    func startVoiceUI(_ message: MessageData, contentView: VoiceMessageContentView) {
        self.dataUpdate(contentView: contentView, messageModel: message)
    }
    
    func textUrlTapped(_ url: String?) {
        self.delegate?.tappedTextUrl(url)
    }
    
    func selectionLanguageTapped(_ message: MessageData) {
        self.delegate?.selectionLanguageTapped(self, message: self.messageModel)
    }
    
    func whiteboardTapped(_ message: MessageData) {
        self.delegate?.tappedWhiteboard(self, message: self.messageModel)
    }
    
    func unknownTapped() {
        self.delegate?.tappedUnknown()
    }
    
    func voucherTapped(_ message: MessageData) {
        self.delegate?.tappedVoucher(self, message: self.messageModel)
    }
}
