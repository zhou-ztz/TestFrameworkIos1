//
//  MessageRequestTableViewCell.swift
//  Yippi
//
//  Created by Kit Foong on 21/02/2023.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK

protocol MessageRequestTableViewCellDelegate: class {
    func buttonActionDelegate(isAccept: Bool, indexPath: IndexPath)
}

class MessageRequestTableViewCell: UITableViewCell, BaseCellProtocol {
    @IBOutlet weak var avatarView: AvatarView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!
    var indexPath: IndexPath!
    weak var delegate: MessageRequestTableViewCellDelegate?
    
    static let cellReuseIdentifier = "MessageRequestTableViewCell"
    
    class func nib() -> UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: nil)
    }
    
    @IBAction func acceptAction(_ sender: Any) {
        self.delegate?.buttonActionDelegate(isAccept: true, indexPath: self.indexPath)
    }
    
    @IBAction func rejectAction(_ sender: Any) {
        self.delegate?.buttonActionDelegate(isAccept: false, indexPath: self.indexPath)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        
        acceptButton.titleLabel?.text = "accept_session".localized
        acceptButton.backgroundColor = TSColor.main.theme
        acceptButton.setTitleColor(TSColor.main.white, for: .normal)
        acceptButton.layer.cornerRadius = 10
        
        rejectButton.titleLabel?.text = "reject_session".localized
        rejectButton.backgroundColor = UIColor(hex: 0xE5E6EB)
        rejectButton.setTitleColor(TSColor.normal.blackTitle, for: .normal)
        rejectButton.layer.cornerRadius = 10
    }
    
    func updatePersonalCell(data: MessageRequestModel) {
        guard let userInfo = data.user else { return }
        
        titleLabel.text = ""
        descLabel.text = ""

        avatarView.avatarPlaceholderType = AvatarView.PlaceholderType(sexNumber: (CurrentUserSessionInfo?.sex ?? 0))
        avatarView.avatarInfo = userInfo.avatarInfo()
        
        titleLabel.text = data.user?.name
        
        let userId = userInfo.userIdentity
        let username = userInfo.username
        let name = userInfo.name
        
        // MARK: REMARK NAME
        LocalRemarkName.getRemarkName(userId: "\(userId)", username: username, originalName: name, label: titleLabel)
        descLabel.text = data.messageDetail?.content
        
        if data.fromUserID == CurrentUserSessionInfo?.userIdentity {
            acceptButton.isHidden = true
        } else {
            acceptButton.isHidden = false
        }
    }
    
    func updateGroupCell(data: NIMSystemNotification?) {
        titleLabel.text = ""
        descLabel.text = ""
        acceptButton.isHidden = false
        
        guard let noti = data, let targetId = noti.targetID else { return }
        
        //self.avatarView.avatarInfo = AvatarInfo(avatarURL: userInfo.avatarUrlString ?? "", verifiedInfo: nil)
        avatarView.avatarPlaceholderType = .unknown
        avatarView.avatarInfo = NIMSDKManager.shared.getAvatarIcon(userId: noti.sourceID ?? "")
        
        // MARK: REMARK NAME
        LocalRemarkName.getRemarkName(userId: nil, username: NIMSDKManager.shared.getNimKitInfo(userId: noti.sourceID ?? ""), originalName: NIMSDKManager.shared.getNimKitInfo(userId: noti.sourceID ?? "", type: .showName), label: titleLabel)
        
        var teamName = ""
        
        if let team = NIMSDK.shared().teamManager.team(byId: targetId) {
            teamName = team.teamName.orEmpty
            switch noti.type {
            case .teamApply:
                descLabel.text = String(format: "request_join_group".localized, teamName)
                
            case .teamApplyReject:
                descLabel.text = String(format: "group_denied_your_apply".localized, teamName)
                
            case .teamInvite:
                descLabel.text = String(format: "text_group_invitation".localized, teamName)
                
            case .teamIviteReject:
                descLabel.text = String(format: "user_denied_invitation_join_group".localized, teamName)
                
            default:
                break
            }
        }
        
        switch noti.handleStatus {
        case NotificationHandleType.ok.rawValue:
            descLabel.text = String(format: "notification_group_joined".localized, teamName)
        case NotificationHandleType.no.rawValue:
            descLabel.text = "Rejected".localized
        case NotificationHandleType.outOfDate.rawValue:
            descLabel.text = "text_expired".localized
        default:
            break
        }
    }
    
    func updateBackgroundColor() {
        backgroundColor = .clear
        contentView.backgroundColor = .white
        let margins = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        contentView.frame = contentView.frame.inset(by: margins)
        contentView.roundCorner(10)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateBackgroundColor()
    }
}

