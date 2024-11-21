//
//  LiveChatInteractionView.swift
//  Yippi
//
//  Created by Jerry Ng on 10/08/2021.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit
import SDWebImage

class LiveChatInteractionView: UIView {
    
    public var titleLabel: UILabel = UILabel().configure {
        $0.text = "feed_live_pin_comment".localized
        $0.setFontSize(with: 14, weight: .medium)
    }
    private var contentView: UIView = UIView().configure {
        $0.backgroundColor = .black.withAlphaComponent(0.4)//UIColor(red: 235.0/255.0, green: 235.0/255.0, blue: 235.0/255.0, alpha: 1.0)
    }
    private var chatContent: UILabel = UILabel().configure {
        $0.setFontSize(with: 12, weight: .medium)
    }
    private var stickerImageView: SDAnimatedImageView = SDAnimatedImageView(frame: .zero)
    
    private var buttonStackView: UIStackView = UIStackView().configure {
        $0.axis = .horizontal
        $0.distribution = .fill
        $0.alignment = .center
        $0.spacing = 5
    }
    private var replyButton: ReplyStackView = ReplyStackView()
    private var pinButton: ReplyStackView = ReplyStackView()
    private var unpinButton: ReplyStackView = ReplyStackView()
    //replyStackView
    private var pinButtonContainer: UIView = UIView()
    private var unpinButtonContainer: UIView = UIView()
    private var pinButtonActivityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(style: .medium)
    private var unpinButtonActivityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(style: .medium)
    
    public let baseStackView = UIStackView()
    
    public var didTapReplyButton: EmptyClosure?
    public var didTapPinButton: EmptyClosure?
    public var didTapUnpinButton: EmptyClosure?
    var isShowTwo: Bool = false //回复view 是否显示两个按钮
    var landscape = false //是否横屏
    init() {
        super.init(frame: .zero)
        setupUI()
        configureReplyButton()
        configurePinButton()
        configureUnpinButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        chatContent.preferredMaxLayoutWidth = UIScreen.main.bounds.width - 56
    }
    
    private func setupUI() {
        self.backgroundColor = .white
        
        baseStackView.axis = .horizontal
        baseStackView.distribution = .fill
        baseStackView.alignment = .center
        baseStackView.spacing = 15
        
        addSubview(titleLabel)
        addSubview(baseStackView)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.left.right.equalToSuperview().inset(15)
        }
        baseStackView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(46)
            //$0.bottom.equalToSuperview().inset(16 + TSBottomSafeAreaHeight)
            $0.left.equalToSuperview().inset(15)
            $0.right.equalToSuperview().inset(85)
        }
        
        baseStackView.addArrangedSubview(contentView)

        addSubview(buttonStackView)
        buttonStackView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(46)
            $0.bottom.equalToSuperview().inset(20 + TSBottomSafeAreaHeight)
            $0.right.equalToSuperview().inset(15)
        }
        let contentStackView = UIStackView()
        contentStackView.axis = .vertical
        contentStackView.distribution = .fill
        contentStackView.alignment = .leading
        contentStackView.spacing = 2
        
        contentStackView.addArrangedSubview(chatContent)
        contentStackView.addArrangedSubview(stickerImageView)
        
        contentView.addSubview(contentStackView)
        contentView.roundCorner(6)
        
        contentStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(8)
        }
        
        pinButtonContainer.addSubview(pinButton)
        pinButtonContainer.addSubview(pinButtonActivityIndicator)
        unpinButtonContainer.addSubview(unpinButton)
        unpinButtonContainer.addSubview(unpinButtonActivityIndicator)
        
        pinButtonContainer.snp.makeConstraints {
            $0.width.equalTo(40)
            $0.height.equalTo(60)
        }
        unpinButtonContainer.snp.makeConstraints {
            $0.width.equalTo(40)
            $0.height.equalTo(60)
        }
        pinButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        unpinButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        pinButtonActivityIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        unpinButtonActivityIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        buttonStackView.addArrangedSubview(replyButton)
        buttonStackView.addArrangedSubview(pinButtonContainer)
        buttonStackView.addArrangedSubview(unpinButtonContainer)
        
        replyButton.snp.makeConstraints {
            $0.width.equalTo(40)
            $0.height.equalTo(60)
        }
        
        stickerImageView.snp.makeConstraints {
            $0.width.height.lessThanOrEqualTo(50)
        }
    }
    
    public func showPinLoading() {
        pinButtonActivityIndicator.startAnimating()
        pinButtonActivityIndicator.isHidden = false
    }
    
    public func showUnPinLoading() {
        unpinButtonActivityIndicator.startAnimating()
        unpinButtonActivityIndicator.isHidden = false
    }
    
    public func hidePinLoading() {
        pinButtonActivityIndicator.stopAnimating()
        pinButtonActivityIndicator.isHidden = true
    }
    
    public func hideUnpinLoading() {
        unpinButtonActivityIndicator.stopAnimating()
        unpinButtonActivityIndicator.isHidden = true
    }
    
    func setUpChatContent(senderName:String, content:String, isSticker:Bool, isHost: Bool = false, isOwnComment: Bool = false, isPinnedComment: Bool = false, isShowPinnedOnly: Bool = false) {
        
        if isSticker {
            stickerImageView.makeVisible()
            
            chatContent.textColor = .white
            chatContent.numberOfLines = 3
            chatContent.lineBreakMode = NSLineBreakMode.byWordWrapping
            chatContent.text = senderName + ": "
            chatContent.sizeToFit()
            
            stickerImageView.sd_imageIndicator = SDWebImageActivityIndicator.white
            stickerImageView.sd_setImage(with: URL(string: content), completed: nil)
            stickerImageView.shouldCustomLoopCount = true
            stickerImageView.animationRepeatCount = 0
            stickerImageView.backgroundColor = .clear
            
            replyButton.isHidden = isOwnComment
            buttonStackView.isHidden = isShowPinnedOnly
            setReplayViewframe(isHost: isHost, isOwnComment: isOwnComment)
            if isHost {
                self.titleLabel.text = "feed_live_pin_comment".localized
                buttonStackView.isHidden = false
                if isShowPinnedOnly { // show by tap pin button
                    pinButtonContainer.isHidden = true
                    unpinButtonContainer.isHidden = false
                } else {
                    pinButtonContainer.isHidden = isPinnedComment
                    unpinButtonContainer.isHidden = !isPinnedComment
                    if !isOwnComment {
                        replyButton.isHidden = isPinnedComment
                    }
                }
            } else {
                self.titleLabel.text = senderName + ": "
                buttonStackView.isHidden = isShowPinnedOnly
                pinButtonContainer.isHidden = true
                unpinButtonContainer.isHidden = true
            }
        }
        else {
            chatContent.textColor = .white
            chatContent.text = senderName + ": " + content
            
            let string: NSMutableAttributedString = NSMutableAttributedString(string: chatContent.text!)
            string.setColorForText(textToFind: senderName + ": ", withColor: .white)
            chatContent.attributedText = string
            
            chatContent.numberOfLines = 4
            chatContent.lineBreakMode = NSLineBreakMode.byWordWrapping
            chatContent.sizeToFit()
            
            stickerImageView.makeHidden()
            stickerImageView.image = nil
            
            replyButton.isHidden = isOwnComment
            setReplayViewframe(isHost: isHost, isOwnComment: isOwnComment)
            if isHost {
                self.titleLabel.text = "feed_live_pin_comment".localized
                buttonStackView.isHidden = false
                if isShowPinnedOnly { // show by tap pin button
                    pinButtonContainer.isHidden = true
                    unpinButtonContainer.isHidden = false
                } else {
                    pinButtonContainer.isHidden = isPinnedComment
                    unpinButtonContainer.isHidden = !isPinnedComment
                    if !isOwnComment {
                        replyButton.isHidden = isPinnedComment
                    }
                }
            } else {
                self.titleLabel.text = senderName + ": "
                buttonStackView.isHidden = isShowPinnedOnly
                pinButtonContainer.isHidden = true
                unpinButtonContainer.isHidden = true
            }
        }
    }
    
    private func configureReplyButton() {

        replyButton.clickBtn.layer.cornerRadius = 15
        replyButton.clickBtn.clipsToBounds = true
        replyButton.titleLabel.text = "longclick_msg_reply".localized
        replyButton.clickBtn.setImage(UIImage.set_image(named: "iconsReplyWhite"), for: .normal)
        replyButton.clickBtn.throttle(.touchUpInside, interval: 0.2) { [weak self] in
            guard let self = self else { return }
            self.didTapReplyButton?()
        }

    }
    
    private func configurePinButton() {

        pinButton.clickBtn.layer.cornerRadius = 15
        pinButton.clickBtn.clipsToBounds = true
        pinButton.titleLabel.text = "feed_live_pin".localized
        pinButton.clickBtn.setImage(UIImage.set_image(named: "icPinWhite"), for: .normal)
        pinButton.clickBtn.throttle(.touchUpInside, interval: 0.2) { [weak self] in
            guard let self = self else { return }
            guard self.pinButton.clickBtn.isEnabled else { return }
            self.didTapPinButton?()
        }
       
    }
    
    private func configureUnpinButton() {

        unpinButton.clickBtn.layer.cornerRadius = 15
        unpinButton.clickBtn.clipsToBounds = true
        unpinButton.titleLabel.text = "feed_live_unpin".localized
        unpinButton.clickBtn.setImage(UIImage.set_image(named: "icUnpinWhite"), for: .normal)
        unpinButton.clickBtn.contentMode = .scaleAspectFit
        unpinButton.clickBtn.throttle(.touchUpInside, interval: 0.2) { [weak self] in
            guard let self = self else { return }
            guard self.unpinButton.clickBtn.isEnabled else { return }
            self.didTapUnpinButton?()
        }
        
    }
    
    public func setPinButtonStatus(enable: Bool) {
        if enable {
            pinButton.clickBtn.isEnabled = true
            unpinButton.clickBtn.isEnabled = true

        } else {
            pinButton.clickBtn.isEnabled = false
            unpinButton.clickBtn.isEnabled = false
        }
    }
    
    func setReplayViewframe(isHost: Bool = false, isOwnComment: Bool = false){
        self.isShowTwo = false
        let rightSpace = landscape == true ? TSBottomSafeAreaHeight : 0.0
        let isRight = getScreenDirection()
        baseStackView.snp.updateConstraints {
            if isHost {
                if isOwnComment {
                    if isRight {
                        $0.right.equalToSuperview().inset(85 + rightSpace)
                        $0.left.equalToSuperview().inset(15)
                    }else{
                        $0.right.equalToSuperview().inset(85)
                        $0.left.equalToSuperview().inset(15 + rightSpace)
                    }
                    
                }else{
                    self.isShowTwo = true
                    if isRight {
                        $0.right.equalToSuperview().inset(85 + 65 + rightSpace)
                        $0.left.equalToSuperview().inset(15)
                    }else{
                        $0.right.equalToSuperview().inset(85 + 65)
                        $0.left.equalToSuperview().inset(15  + rightSpace)
                    }
                    
                }
            }else{
                if isRight {
                    $0.right.equalToSuperview().inset(85 + rightSpace)
                    $0.left.equalToSuperview().inset(15)
                }else{
                    $0.right.equalToSuperview().inset(85)
                    $0.left.equalToSuperview().inset(15 + rightSpace)
                }
                
            }
        }
        buttonStackView.snp.updateConstraints {
            if landscape {
                if isRight {
                    $0.right.equalToSuperview().inset(15 + TSBottomSafeAreaHeight)
                }else{
                    $0.right.equalToSuperview().inset(15 )
                }
            }else{
                $0.right.equalToSuperview().inset(15)
            }
        }
        titleLabel.snp.updateConstraints {
            if landscape {
                if isRight {
                    $0.left.equalToSuperview().inset(15 )
                }else{
                    $0.left.equalToSuperview().inset(15 + TSBottomSafeAreaHeight)
                }
            }else{
                $0.left.equalToSuperview().inset(15 )
            }
        }
    }
    
    func updateView(isLandscape: Bool){
        landscape = isLandscape
        let isRight = getScreenDirection()
        
        buttonStackView.snp.updateConstraints {
            if isLandscape {
                if isRight {
                    $0.right.equalToSuperview().inset(15 + TSBottomSafeAreaHeight)
                }else{
                    $0.right.equalToSuperview().inset(15 )
                }
            }else{
                $0.right.equalToSuperview().inset(15)
            }
            
        }
        
        titleLabel.snp.updateConstraints {
            if isLandscape {
                if isRight {
                    $0.left.equalToSuperview().inset(15 )
                }else{
                    $0.left.equalToSuperview().inset(15 + TSBottomSafeAreaHeight)
                }
            }else{
                $0.left.equalToSuperview().inset(15 )
            }
        }
        
        self.baseStackView.snp.updateConstraints {
            if isLandscape {
                if isRight {
                    if isShowTwo {
                        $0.right.equalToSuperview().inset(85 + 65 + TSBottomSafeAreaHeight)
                        $0.left.equalToSuperview().inset(15)
                    }else{
                        $0.right.equalToSuperview().inset(85 + TSBottomSafeAreaHeight)
                        $0.left.equalToSuperview().inset(15)
                    }
                }else{
                    if isShowTwo {
                        $0.right.equalToSuperview().inset(85 + 65)
                        $0.left.equalToSuperview().inset(15 + TSBottomSafeAreaHeight)
                    }else{
                        $0.right.equalToSuperview().inset(85)
                        $0.left.equalToSuperview().inset(15 + TSBottomSafeAreaHeight)
                    }
                }
                
                
            } else {
                //$0.left.equalToSuperview().inset(15)
                if isShowTwo {
                    $0.right.equalToSuperview().inset(85 + 65)
                }else{
                    $0.right.equalToSuperview().inset(85)
                }
            }
        }
        
    }
    
    func getScreenDirection() -> Bool{
        let orientation = UIDevice.current.orientation
        switch orientation {
        case .landscapeLeft:
            return false
        case .landscapeRight:
            return true
        default:
            return false
        }
    }
}

class ReplyStackView: UIStackView{
    
    public var titleLabel: UILabel = UILabel().configure {
        $0.text = "feed_live_pin_comment".localized
        $0.setFontSize(with: 12, weight: .medium)
        $0.textAlignment = .center
    }
    public var clickBtn: UIButton = UIButton().configure {
        $0.backgroundColor = TSColor.main.theme
    }
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI(){
        axis = .vertical
        distribution = .fill
        alignment = .center
        spacing = 5
        addArrangedSubview(clickBtn)
        addArrangedSubview(titleLabel)
        clickBtn.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(5)
            make.width.height.equalTo(30)
        }
//        titleLabel.snp.makeConstraints { make in
//            make.top.equalTo(clickBtn.snp.bottom).inset(-20)
//        }
        clickBtn.roundCorner(15)
    }
}
