//
//  OutgoingChatTableViewCell.swift
//  Yippi
//
//  Created by Tinnolab on 22/08/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import UIKit


class OutgoingChatTableViewCell: UITableViewCell, BaseCellProtocol {
    
    @IBOutlet weak var bubbleImg: UIImageView!
    @IBOutlet weak var messageLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var alertBtn: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var menuAction: UIMenuController!
    
    weak var delegate: ChatMessageManagerDelegate?
    
    var messageItem: MessageItem?
    
    static let cellReuseIdentifier = "OutgoingChatTableViewCell"
    
    class func nib() -> UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        bubbleImg.image = UIImage.set_image(named: "sender_bubble")?.resizableImage(withCapInsets: UIEdgeInsets(top: 18, left: 25, bottom: 17, right: 25), resizingMode: .stretch)
        messageLbl.textColor = UIColor.black
        messageLbl.font = UIFont.systemFont(ofSize: FontSize.defaultFontSize)
        messageLbl.numberOfLines = 0
        timeLbl.font = UIFont.systemFont(ofSize: YPCustomizer.FontSize.verySmall)
        timeLbl.textColor = UIColor.lightGray
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(cellLongPress))
        self.addGestureRecognizer(longPressRecognizer)
    }
    
    func cellUpdate(messageInfo: MessageItem) {
        self.loadingIndicator.stopAnimating()
        self.messageItem = messageInfo
        self.messageLbl.text = messageInfo.content
        self.messageLbl.preferredMaxLayoutWidth = 193
        self.timeLbl.text = TSDate().dateString(.timeOnly, nDate: messageInfo.time)
        self.alertBtn.isHidden = (messageInfo.status != .failed)
        self.messageLbl.sizeToFit()
        cellSetConstraints()
    }
    
    func cellSetConstraints() {
        self.messageLbl.setNeedsLayout()
        self.messageLbl.layoutIfNeeded()
        messageLbl.snp.removeConstraints()
        bubbleImg.snp.removeConstraints()
        timeLbl.snp.removeConstraints()
        alertBtn.snp.removeConstraints()
        loadingIndicator.snp.removeConstraints()

        switch self.messageLbl.numberOfLines {
          case 1:
            messageLbl.snp.makeConstraints { (make) in
                make.top.equalToSuperview().inset(15)
                make.trailing.equalToSuperview().inset(85)
                make.width.lessThanOrEqualTo(193)
            }
            bubbleImg.snp.makeConstraints { (make) in
                make.top.bottom.equalToSuperview().inset(5)
                make.trailing.equalToSuperview().offset(-15)
                make.leading.equalTo(messageLbl).offset(-10)
                make.height.equalTo(messageLbl.height + 20)
            }
            timeLbl.snp.makeConstraints { (make) in
                make.bottom.equalTo(bubbleImg).inset(12)
                make.trailing.equalTo(bubbleImg).offset(-15)
            }
            break
        default:
            messageLbl.snp.makeConstraints { (make) in
                make.top.equalToSuperview().inset(15)
                make.trailing.equalToSuperview().inset(35)
                make.width.lessThanOrEqualTo(193)
            }
            bubbleImg.snp.makeConstraints { (make) in
                make.top.bottom.equalToSuperview().inset(5)
                make.trailing.equalToSuperview().offset(-15)
                make.leading.equalTo(messageLbl).offset(-10)
                make.height.equalTo(messageLbl.height + 30)
            }
            timeLbl.snp.makeConstraints { (make) in
                make.bottom.equalTo(bubbleImg).inset(6)
                make.trailing.equalTo(bubbleImg).offset(-15)
            }
            break
        }
        alertBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(20)
            make.top.equalTo(bubbleImg).inset(10)
            make.right.equalTo(bubbleImg.snp.left).inset(-10)
        }
        loadingIndicator.snp.makeConstraints { (make) in
            make.size.equalTo(alertBtn)
            make.top.equalTo(bubbleImg).inset(10)
            make.right.equalTo(bubbleImg.snp.left).inset(-10)
        }
    }
    
    @objc private func cellLongPress(gestureRecognizer: UIGestureRecognizer) {
        guard let messageItem = self.messageItem else { return }
        if gestureRecognizer.state == .began {
            ChatMessageManager.shared.delegate?.onMessageLongPress(messageItem, on: self.bubbleImg)
        }
    }
    
    @IBAction func alertButtonClicked(_ sender: UIButton) {
        self.alertBtn.isHidden = true
        self.loadingIndicator.startAnimating()
        ChatMessageManager.shared.delegate?.onResendMessageClicked(self)
    }
}
