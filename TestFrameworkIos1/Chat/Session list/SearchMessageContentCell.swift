//
//  SearchMessageContentCell.swift
//  Yippi
//
//  Created by Khoo on 06/04/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//


import UIKit
//import NIMPrivate
import NIMSDK

class SearchMessageContentCell: TSTableViewCell {
    @IBOutlet weak var namewith: NSLayoutConstraint!
    @IBOutlet weak var headerButton: AvatarView!
    @IBOutlet weak var titleLabel: TSLabel!
    @IBOutlet weak var contentLabel: TSLabel!
    @IBOutlet weak var timeLabel: TSLabel!
    weak var delegate: TSConversationTableViewCellDelegate?
   
    var object: SearchLocalHistoryObject?
    
    static let cellReuseIdentifier = "SearchMessageContentCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        customUI()
    }
    
    private func customUI() {
        headerButton.circleCorner()
        
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        titleLabel.textColor = TSColor.main.content
        titleLabel.lineBreakMode = .byTruncatingMiddle
        
        contentLabel.font = UIFont.systemFont(ofSize: 12)
        contentLabel.textColor = TSColor.normal.minor
        
        timeLabel.font = UIFont.systemFont(ofSize: TSFont.Time.normal.rawValue)
        timeLabel.textColor = TSColor.normal.disabled
        
        self.selectionStyle = .gray
    }
    
    func refresh (object: SearchLocalHistoryObject) {
        self.object = object
        
        var titleLabelString = ""
        var urlString = ""
        var messageString = ""
        var avatarImg: UIImage?
        guard let message = object.message else { return }
                
//        switch message.session!.sessionType {
//        case NIMSessionType.P2P:
//            let info = NIMBridgeManager.sharedInstance().getUserInfo(message.from ?? "")
//            titleLabelString = info.showName
//            urlString = info.avatarUrlString ?? ""
//            avatarImg = info.avatarImage
//            messageString = message.text ?? ""
//            break
//            
//        case NIMSessionType.team:
//            let info = NIMBridgeManager.sharedInstance().getUserInfo(message.from ?? "")
//            titleLabelString = info.showName
//            urlString = info.avatarUrlString ?? ""
//            avatarImg = info.avatarImage
//            
//            if message.from == NIMSDK.shared().loginManager.currentAccount() {
//                messageString = "\("You".localized) : \(message.text ?? "")"
//            } else {
//                messageString = titleLabelString + (" : \(message.text ?? "")")
//            }
//            break
//        default:
//            break
//        }
        
        headerButton.avatarInfo = AvatarInfo(avatarURL: urlString, verifiedInfo: nil)
        titleLabel?.text = titleLabelString
        contentLabel.text = messageString
        timeLabel.text = TSDate().dateString(.normal, nsDate: NSDate(timeIntervalSince1970: message.timestamp))
        titleLabel?.sizeToFit()
        
        var itemTextSize: CGSize? = nil
        if let font = UIFont(name: "Helvetica Neue", size: 12.0) {
            itemTextSize = contentLabel.text?.boundingRect(with: CGSize(width: CGFloat(Constants.Layout.SearchCellContentMaxWidth * CGFloat(Constants.Layout.UISreenWidthScale)), height: CGFloat(Constants.Layout.MessageCellMaxHeight)), options: .usesLineFragmentOrigin, attributes: [
                NSAttributedString.Key.font: font
            ], context: nil).size
        }
        contentLabel.size = contentLabel.sizeThatFits(CGSize(width: CGFloat(Constants.Layout.SearchCellContentMaxWidth * CGFloat(Constants.Layout.UISreenWidthScale)), height: itemTextSize?.height ?? 0.0))
        contentLabel.height = max(Constants.Layout.SearchCellContentMinHeight, itemTextSize!.height)
        timeLabel.sizeToFit()
        
    }
    
    class func nib() -> UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: nil)
    }
    
}

