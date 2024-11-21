//
//  MsgRequestListTableViewCell.swift
//  Yippi
//
//  Created by Tinnolab on 22/08/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import UIKit

class MsgRequestListTableViewCell: UITableViewCell, BaseCellProtocol {

    @IBOutlet weak var avatarView: AvatarView!
    
    @IBOutlet weak var avatarNameLbl: UILabel!
    @IBOutlet weak var previewMsgLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var unreadVw: UIView!
    
    static let cellReuseIdentifier = "MsgRequestListTableViewCell"
    
    class func nib() -> UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        unreadVw.layer.cornerRadius = 3
        
        avatarNameLbl.font = UIFont.boldSystemFont(ofSize: YPCustomizer.FontSize.big)
        previewMsgLbl.font = UIFont.systemFont(ofSize: YPCustomizer.FontSize.normal)
        previewMsgLbl.textColor = UIColor.lightGray
        timeLbl.font = UIFont.systemFont(ofSize: YPCustomizer.FontSize.normal)
        timeLbl.textColor = UIColor.lightGray
        
        unreadVw.backgroundColor = AppTheme.red
    }

    func UISetup(data: MessageRequestModel) {
        guard let userInfo = data.user else { return }
        avatarView.avatarPlaceholderType = AvatarView.PlaceholderType(sexNumber: (CurrentUserSessionInfo?.sex ?? 0))
        avatarView.avatarInfo = userInfo.avatarInfo()
        
        avatarNameLbl.text = data.user?.name
        
        let userId = userInfo.userIdentity
        let username = userInfo.username
        let name = userInfo.name

        // MARK: REMARK NAME
        LocalRemarkName.getRemarkName(userId: "\(userId)", username: username, originalName: name, label: avatarNameLbl)
        
        previewMsgLbl.text = data.messageDetail?.content
        if data.messageDetail?.fromUserID != CurrentUserSessionInfo?.userIdentity {
            unreadVw.isHidden = (data.messageDetail?.isRead != 0)
        } else {
            unreadVw.isHidden = true
        }
        
        timeLbl.text = TSDate().dateString(.messageRequestTime, nDate: data.messageDetail?.createdAt ?? Date())
    }
    
}
