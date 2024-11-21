//
//  SnapMessageContentView.swift
//  Yippi
//
//  Created by Tinnolab on 12/06/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import NIMSDK
import ActiveLabel

class SnapMessageContentView: BaseContentView {
    
    var longpressGesture: UILongPressGestureRecognizer!
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.set_image(named:"hold_to_check_image")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.regular(FontSize.defaultLocationDefaultFontSize)
        label.textColor = .gray
        label.text = "snapchat_longclick_to_view".localized
        label.numberOfLines = 1
        return label
    }()
    
    lazy var contentStackView: UIStackView = {
        let stackView = UIStackView().configure { (stack) in
            stack.axis = .vertical
            stack.spacing = 8
            stack.distribution = .fill
            stack.alignment = .trailing
        }
        return stackView
    }()
    
    override init(messageModel: MessageData) {
        super.init(messageModel: messageModel)
        UISetup(messageModel: messageModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func UISetup(messageModel: MessageData) {
        let showLeft = messageModel.type == .incoming
        
        let stackView = UIStackView().configure { (stack) in
            stack.axis = .horizontal
            stack.spacing = 8
        }
        
        if showLeft {
            stackView.addArrangedSubview(imageView)
            stackView.addArrangedSubview(label)
        } else {
            stackView.addArrangedSubview(label)
            stackView.addArrangedSubview(imageView)
        }

        contentStackView.addArrangedSubview(stackView)
        contentStackView.addArrangedSubview(timeTickStackView)

        self.addSubview(contentStackView)
        contentStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-8)
            make.left.equalToSuperview().offset(showLeft ? 8:0)
            make.right.equalToSuperview().offset(showLeft ? 0:-8)
        }
        self.bubbleImage.isHidden = true
        longpressGesture = UILongPressGestureRecognizer(target: self, action: #selector(onLongPressDown))
        self.addGestureRecognizer(longpressGesture)
    }
    
    func dataUpdate(messageModel: MessageData) {
        
        guard let message = messageModel.nimMessageModel else { return }
        let object = message.messageObject as! NIMCustomObject
        let attachment = object.attachment as! IMSnapchatAttachment
        self.imageView.image = attachment.coverImage
        self.label.isHidden = attachment.isFired
        self.longpressGesture.isEnabled = !attachment.isFired
    }
    
    @objc func onLongPressDown(recognizer: UILongPressGestureRecognizer){
        
        guard let message = self.model.nimMessageModel else {
            return
        }
        if (!message.isReceivedMsg && message.deliveryState != .deliveried) {
            return
        }
        if (recognizer.state != .began) {
            if (recognizer.state == .ended) {
                self.delegate?.snapMessageTapped(self.model, baseView: self, isEnd: true)
             return
            }
            return
        }
        
        //recognizer.isEnabled = false
        self.goOpen()
        
    }
    
    func goOpen(){
        self.delegate?.snapMessageTapped(self.model, baseView: self, isEnd: false)
    }
    
}
