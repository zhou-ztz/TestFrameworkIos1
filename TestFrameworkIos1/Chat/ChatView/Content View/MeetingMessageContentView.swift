//
//  MeetingMessageContentView.swift
//  Yippi
//
//  Created by Kit Foong on 28/10/2022.
//  Copyright © 2022 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK
import ActiveLabel

class MeetingMessageContentView: BaseContentView {
    lazy var meetingView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .white
        return view
    }()
    
    lazy var meetingLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.regular(FontSize.defaultTextFontSize)
        label.textColor = .black
        label.text = ""
        label.numberOfLines = 0
        return label
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
        
        let wholeStackView = UIStackView().configure { (stack) in
            stack.axis = .vertical
            stack.spacing = 8
            stack.alignment = .center
        }
        
        let buttonStackView = UIStackView().configure { (stack) in
            stack.axis = .horizontal
            stack.spacing = 8
        }
        
        let buttonView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        let button = UIButton(type: .custom)
        button.applyStyle(.custom(text: "text_join_meeting".localized, textColor: TSColor.main.white, backgroundColor: TSColor.main.theme, cornerRadius: 5))
        let origImage = UIImage.set_image(named: "im_meeting_send")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        button.setImage(tintedImage, for: .normal)
        button.tintColor = TSColor.main.white
        button.titleLabel?.numberOfLines = 1
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
        button.semanticContentAttribute = .forceRightToLeft
        button.addTarget(self, action: #selector(meetingTapped), for: .touchUpInside)
        buttonView.addSubview(button)
        button.snp.makeConstraints {
            $0.top.bottom.left.right.equalTo(buttonView)
        }
        
        buttonStackView.addArrangedSubview(buttonView)
        buttonStackView.addArrangedSubview(UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30)))
        
        buttonView.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.width.equalTo(140)
        }
        
        wholeStackView.addArrangedSubview(meetingView)
        wholeStackView.addArrangedSubview(UIView(frame: CGRect(x: 0, y: 0, width: 184, height: 10)))
        wholeStackView.addArrangedSubview(meetingLabel)
        wholeStackView.addArrangedSubview(UIView(frame: CGRect(x: 0, y: 0, width: 184, height: 10)))
        wholeStackView.addArrangedSubview(buttonStackView)
        wholeStackView.addArrangedSubview(timeTickStackView)
        
        meetingView.frame = CGRect(x: 0, y: 0, width: 180, height: 180)
        meetingView.image = UIImage.set_image(named: "im_meeting")
        
        let attrs1 = [NSAttributedString.Key.font: AppTheme.Font.bold(FontSize.defaultTextFontSize), NSAttributedString.Key.foregroundColor: UIColor(red: 0, green: 0, blue: 0)]
        let attrs2 = [NSAttributedString.Key.font: AppTheme.Font.regular(FontSize.defaultTextFontSize), NSAttributedString.Key.foregroundColor: UIColor(red: 0, green: 0, blue: 0)]
        
        let attributedString1 = NSMutableAttributedString(string:"\("text_meeting_id".localized) ", attributes:attrs1)
        let object = messageModel.nimMessageModel?.messageObject as! NIMCustomObject
        let attachment = object.attachment as! IMMeetingRoomAttachment
        
        let attributedString2 = NSMutableAttributedString(string:"\(attachment.meetingNum) \r\n\(attachment.meetingSubject)", attributes:attrs2)
        
        attributedString1.append(attributedString2)
        meetingLabel.attributedText = attributedString1
        
        meetingView.snp.makeConstraints { make in
            make.height.equalTo(180)
            make.width.equalTo(180)
            make.centerX.equalToSuperview()
        }
        
        meetingLabel.snp.makeConstraints { make in
            make.width.equalTo(184)
        }
        
        buttonStackView.snp.makeConstraints { make in
            make.width.equalTo(184)
        }
        
        timeTickStackView.snp.makeConstraints { make in
            make.width.equalTo(184)
            make.centerX.equalToSuperview()
        }
        
        self.addSubview(wholeStackView)
        wholeStackView.snp.makeConstraints { make in
            make.width.equalTo(200)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.left.equalToSuperview().offset(showLeft ? 9:0)
            make.right.equalToSuperview().offset(showLeft ? 0:-9)
        }
    }
    
    @objc func meetingTapped() {
        self.delegate?.meetingTapped(self.model)
    }
}
