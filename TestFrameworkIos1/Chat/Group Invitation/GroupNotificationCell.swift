//
//  GroupNotificationCell.swift
//  Yippi
//
//  Created by Yong Tze Ling on 28/05/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK
//import NIMPrivate

protocol GroupNotificationCellDelegate: class {
    func acceptDidTapped(_ cell: GroupNotificationCell, notification: NIMSystemNotification)
    func rejectDidTapped(_ cell: GroupNotificationCell, notification: NIMSystemNotification)
    func headerDidTapped(notification: NIMSystemNotification)
}

class GroupNotificationCell: UITableViewCell, BaseCellProtocol {

    @IBOutlet weak var avatarView: AvatarView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var rejectButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var buttonContainer: UIView!
    
    weak var delegate: GroupNotificationCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.selectionStyle = .none
        
        acceptButton.applyStyle(.custom(text: "accept_session".localized, textColor: .white, backgroundColor: YPCustomizer.Color.primaryBlue, cornerRadius: 2))
        rejectButton.applyStyle(.custom(text: "reject_session".localized, textColor: YPCustomizer.Color.primaryBlue, backgroundColor: .white, cornerRadius: 2))
        
        
        acceptButton.applyBorder(color: YPCustomizer.Color.primaryBlue, width: 1)
        rejectButton.applyBorder(color: YPCustomizer.Color.primaryBlue, width: 1)
        
        acceptButton.titleLabel?.font = UIFont.systemFont(ofSize: YPCustomizer.FontSize.normal)
        rejectButton.titleLabel?.font = UIFont.systemFont(ofSize: YPCustomizer.FontSize.normal)

        dateLabel.textAlignment = .left
        dateLabel.textColor = TSColor.normal.disabled
        
        acceptButton.addAction {
            self.delegate?.acceptDidTapped(self, notification: self.notification!)
        }
        
        rejectButton.addAction {
            self.delegate?.rejectDidTapped(self, notification: self.notification!)
        }
        
        avatarView.avatarPlaceholderType = .unknown
        avatarView.buttonForAvatar.addAction {
            self.delegate?.headerDidTapped(notification: self.notification!)
        }
    }

    var notification: NIMSystemNotification? {
        didSet {
            guard let noti = notification, let targetId = noti.targetID else { return }
            dateLabel.text = TSDate().dateString(.normal, nDate: Date(timeIntervalSinceReferenceDate: noti.timestamp))
            
//            let userInfo = NIMBridgeManager.sharedInstance().getUserInfo(noti.sourceID ?? "")
//            self.avatarView.avatarInfo = AvatarInfo(avatarURL: userInfo.avatarUrlString ?? "", verifiedInfo: nil)
            
//            // MARK: REMARK NAME
//            LocalRemarkName.getRemarkName(userId: nil, username: userInfo.infoId!, originalName: userInfo.showName, label: self.descriptionLabel)

            var teamName = ""
            
            if let team = NIMSDK.shared().teamManager.team(byId: targetId) {
                teamName = team.teamName.orEmpty
                switch noti.type {
                case .teamApply:
                    self.dateLabel.text = String(format: "request_join_group".localized, teamName)
                    
                case .teamApplyReject:
                    self.dateLabel.text = String(format: "group_denied_your_apply".localized, teamName)
 
                case .teamInvite:
                    self.dateLabel.text = String(format: "text_group_invitation".localized, teamName)
                    
                    acceptButton.applyStyle(.custom(text: "join".localized, textColor: .white, backgroundColor: YPCustomizer.Color.primaryBlue, cornerRadius: 2))

                case .teamIviteReject:
                    self.dateLabel.text = String(format: "user_denied_invitation_join_group".localized, teamName)

                default:
                    break
                }
            }
            
            switch noti.handleStatus {
            case NotificationHandleType.ok.rawValue:
                self.dateLabel.text = String(format: "notification_group_joined".localized, teamName)
            case NotificationHandleType.no.rawValue:
                self.dateLabel.text = "Rejected".localized
            case NotificationHandleType.outOfDate.rawValue:
                self.dateLabel.text = "text_expired".localized
            default:
                break
            }
            
            if shouldHideActionButton() {
                buttonContainer.makeHidden()
            } else {
                buttonContainer.makeVisible()
            }
        }
    }
    
    func shouldHideActionButton() -> Bool {
        guard let noti = notification else { return false }
        return noti.handleStatus != 0
    }
}
