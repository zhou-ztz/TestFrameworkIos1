//
//  CallTableViewCell.swift
//  Yippi
//
//  Created by Wong Jin Lun on 06/03/2023.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK
//import NIMPrivate

class CallTableViewCell: UITableViewCell, BaseCellProtocol {
    
    @IBOutlet weak var infoImageView: UIImageView!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var avatarView: AvatarView!
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupView()
    }
    
    private func setupView() {
      
        self.dateTimeLabel.textColor = AppTheme.lightGrey
        
    }
    
    func setModel(model: CallListModel) {
        guard let filter = model.filterData else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.dateTimeLabel.text = TSDate().dateString(.normal, nDate: filter.date?.toDate("yyyy-MM-dd'T'HH:mm:ss.ssssssZ") ?? Date())
            self.statusLabel.isHidden = true
            self.statusImageView.isHidden = true
            self.infoImageView.isHidden = false
            
            if filter.groupType == "group" {
            
                if let team: NIMTeam = NIMSDK.shared().teamManager.team(byId: String(filter.user?.id ?? 0) ?? "") {
                    let avatarURL = team.thumbAvatarUrl
                    let avatarInfo = AvatarInfo()
                    avatarInfo.avatarURL = avatarURL
                    avatarInfo.avatarPlaceholderType = .group
                    self.avatarView.avatarInfo = avatarInfo
                    self.usernameLabel.text = team.teamName
                }
                
            } else {
                
                let nick = SessionUtil.showNick(filter.user?.username ?? "", in: nil)
                if let count = filter.count {
                    if count > 1 {
                        self.usernameLabel.text = String(format: "%@ (%d)", nick!, count)
                    } else {
                        self.usernameLabel.text = nick
                    }
                }
                
                self.avatarView.avatarPlaceholderType = .unknown
                self.avatarView.avatarInfo = NIMSDKManager.shared.getAvatarIcon(userId: filter.user?.username ?? "")
            }
        }
    }
    
    public func setDetailModel(model: CallDetailData, userId: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.dateTimeLabel.text = TSDate().dateString(.detail, nDate: model.updated_at?.toDate("yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'") ?? Date())
            self.statusLabel.isHidden = false
            self.statusImageView.isHidden = false
            self.infoImageView.isHidden = true
            self.statusLabel.text = model.last_call_action
            if model.last_call_action == "missed" {
                self.statusImageView.image = UIImage.set_image(named: "iconsVideoCam")
                self.statusLabel.textColor = .red
            }else {
                self.statusImageView.image = UIImage.set_image(named: "iconsPhoneGrey")
                self.statusLabel.textColor = .darkGray
            }
            
            if model.group_type == "group" {
                if let team: NIMTeam = NIMSDK.shared().teamManager.team(byId: String(userId ?? 0) ?? "") {
                    let avatarURL = team.thumbAvatarUrl
                    let avatarInfo = AvatarInfo()
                    avatarInfo.avatarURL = avatarURL
                    avatarInfo.avatarPlaceholderType = .group
                    self.avatarView.avatarInfo = avatarInfo
                    self.usernameLabel.text = team.teamName
                }
            } else {
                let nick = SessionUtil.showNick(model.person?.username ?? "", in: nil)
                self.usernameLabel.text = nick
                
                self.avatarView.avatarPlaceholderType = .unknown
                self.avatarView.avatarInfo = NIMSDKManager.shared.getAvatarIcon(userId: model.person?.username ?? "")
            }
        }
    }
    
    private var _session: NIMRecentSession?
    var session: NIMRecentSession? {
        set {
            _session = newValue
            guard let value = newValue, let realSession = value.session else {
                return
            }
//            if realSession.sessionType == NIMSessionType.team {
//                usernameLabel.text = NIMSDK.shared().teamManager.team(byId: realSession.sessionId)?.teamName
//            } else {
//                usernameLabel.text = NIMKitUtil.showNick(realSession.sessionId, in: realSession)
//            }
          
            let avatarInfo = AvatarInfo()
            self.avatarView.avatarInfo = avatarInfo
   
        }
        
        get {
            return _session
        }
    }
}
