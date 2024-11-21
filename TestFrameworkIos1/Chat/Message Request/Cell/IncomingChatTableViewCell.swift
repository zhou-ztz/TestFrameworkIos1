//
//  IncomingChatTableViewCell.swift
//  Yippi
//
//  Created by Tinnolab on 22/08/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import UIKit


class IncomingChatTableViewCell: UITableViewCell, BaseCellProtocol {
    
    @IBOutlet weak var avatarView: AvatarView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var messageLbl: UILabel!
    @IBOutlet weak var bubbleImg: UIImageView!
    @IBOutlet weak var timeLbl: UILabel!
    
    var longPressGesture: UILongPressGestureRecognizer!
    
    var messageItem: MessageItem?
    
    static let cellReuseIdentifier = "IncomingChatTableViewCell"
    
    class func nib() -> UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        bubbleImg.image = UIImage.set_image(named: "receiver_bubble")?.resizableImage(withCapInsets: UIEdgeInsets(top: 18, left: 25, bottom: 17, right: 25), resizingMode: .stretch)
        
        nameLbl.font = UIFont.systemFont(ofSize: FontSize.nicknameFontSize)
        nameLbl.textColor = UIColor.darkGray
        messageLbl.font = UIFont.systemFont(ofSize: FontSize.defaultFontSize)
        messageLbl.preferredMaxLayoutWidth = 193
        messageLbl.numberOfLines = 0
        messageLbl.setNeedsLayout()
        messageLbl.layoutIfNeeded()
        timeLbl.font = UIFont.systemFont(ofSize: YPCustomizer.FontSize.verySmall)
        timeLbl.textColor = UIColor.lightGray
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(cellLongPress))
        self.addGestureRecognizer(longPressRecognizer)
    }
    
    func cellUpdate(messageInfo: MessageItem) {
        self.messageItem = messageInfo
        
        guard let userInfo = UserInfoModel.retrieveUser(username: messageInfo.username) else { return }

        self.avatarView.avatarPlaceholderType = AvatarView.PlaceholderType(sexNumber: (CurrentUserSessionInfo?.sex ?? 0))
        self.avatarView.avatarInfo = userInfo.avatarInfo()
        self.nameLbl.text = userInfo.name
        
        
        // MARK: REMARK NAME
        let userId = userInfo.userIdentity
        let username = userInfo.username
        let name = userInfo.name        
        LocalRemarkName.getRemarkName(userId: "\(userId)", username: username, originalName: name, label: nameLbl)
        
        self.messageLbl.text = messageInfo.content
        self.timeLbl.text = TSDate().dateString(.timeOnly, nDate: messageInfo.time)
        self.messageLbl.sizeToFit()
        cellSetConstraints()
    }
    
    func cellSetConstraints() {
        self.messageLbl.setNeedsLayout()
        self.messageLbl.layoutIfNeeded()
        avatarView.snp.removeConstraints()
        nameLbl.snp.removeConstraints()
        messageLbl.snp.removeConstraints()
        bubbleImg.snp.removeConstraints()
        timeLbl.snp.removeConstraints()

        switch self.messageLbl.numberOfLines {
            case 1:
                avatarView.snp.makeConstraints { (make) in
                    make.top.equalToSuperview().inset(8)
                    make.leading.equalToSuperview().offset(15)
                    make.width.height.equalTo(30)
                }
                nameLbl.snp.makeConstraints{ (make) in
                    make.top.equalToSuperview().inset(8)
                    make.left.equalTo(avatarView.snp.right).offset(8)
                }
                messageLbl.snp.makeConstraints { (make) in
                    make.top.equalTo(nameLbl).inset(30)
                    make.left.equalTo(avatarView.snp.right).offset(20)
                    make.width.lessThanOrEqualTo(193)
                }
                bubbleImg.snp.makeConstraints { (make) in
                    make.top.equalTo(messageLbl.snp.top).inset(-8)
                    make.bottom.equalToSuperview().inset(5)
                    make.left.equalTo(messageLbl.snp.left).offset(-14)
                    make.right.equalTo(messageLbl.snp.right).offset(75)
                    make.height.equalTo(messageLbl.height + 20)
                }
                timeLbl.snp.makeConstraints { (make) in
                    make.bottom.equalTo(bubbleImg).inset(12)
                    make.trailing.equalTo(bubbleImg).offset(-6)
                }
                break
            default:
                avatarView.snp.makeConstraints { (make) in
                    make.top.equalToSuperview().inset(8)
                    make.leading.equalToSuperview().offset(15)
                    make.width.height.equalTo(30)
                }
                nameLbl.snp.makeConstraints{ (make) in
                    make.top.equalToSuperview().inset(8)
                    make.left.equalTo(avatarView.snp.right).offset(8)
                }
                messageLbl.snp.makeConstraints { (make) in
                    make.top.equalTo(nameLbl).inset(30)
                    make.left.equalTo(avatarView.snp.right).offset(20)
                    make.width.lessThanOrEqualTo(193)
                }
                bubbleImg.snp.makeConstraints { (make) in
                    make.top.equalTo(messageLbl.snp.top).inset(-8)
                    make.bottom.equalToSuperview().inset(5)
                    make.left.equalTo(messageLbl.snp.left).offset(-14)
                    make.right.equalTo(messageLbl.snp.right).offset(15)
                    make.height.equalTo(messageLbl.height + 25)
                }
                timeLbl.snp.makeConstraints { (make) in
                    make.bottom.equalTo(bubbleImg).inset(5)
                    make.trailing.equalTo(bubbleImg).offset(-6)
                }
                break
        }
    }
    
    @objc private func cellLongPress(gestureRecognizer: UIGestureRecognizer) {
        guard let messageItem = self.messageItem else { return }
        if gestureRecognizer.state == .began {
            ChatMessageManager.shared.delegate?.onMessageLongPress(messageItem, on: self.bubbleImg)
        }
    }
}
