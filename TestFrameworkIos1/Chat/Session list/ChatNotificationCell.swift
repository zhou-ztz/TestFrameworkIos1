//
//  ChatNotificationCell.swift
//  Yippi
//
//  Created by Khoo on 13/05/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//


import UIKit


class ChatNotificationCell: TSTableViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: TSLabel!
    @IBOutlet weak var contentLabel: TSLabel!
    @IBOutlet weak var countLabel: TSLabel!
    weak var delegate: TSConversationTableViewCellDelegate?
    
    static let cellReuseIdentifier = "ChatNotificationCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        customUI()
    }
    
    private func customUI() {
        iconImageView.circleCorner()
        
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        titleLabel.textColor = TSColor.main.content
        titleLabel.lineBreakMode = .byTruncatingMiddle
        
        contentLabel.font = UIFont.systemFont(ofSize: 14)
        contentLabel.textColor = TSColor.normal.minor
        
        countLabel.font = UIFont.boldSystemFont(ofSize: 12)
        countLabel.textColor = AppTheme.red
        
        self.selectionStyle = .gray
    }
    
    func refresh(data: [String : Any]) {
        let maxWidthLabel: CGFloat = contentView.width - 30
        
        titleLabel?.text = data["title"] as? String
        titleLabel?.sizeToFit()
        contentLabel.text = data["desp"] as? String
        contentLabel.sizeToFit()
        iconImageView.image = UIImage.set_image(named: data["icon"] as? String ?? "")
        
        guard let count = data["count"] as? Int else { return }
        if count > 0 {
            let countStr = count > 99 ? "99+" : NSNumber(value: count).stringValue
            countLabel.isHidden = false
            countLabel.text = countStr
            countLabel.sizeToFit()
            accessoryType = .disclosureIndicator
        } else {
            countLabel.isHidden = true
            accessoryType = .none
        }
        
    }
    
    class func nib() -> UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: nil)
    }
    
}

