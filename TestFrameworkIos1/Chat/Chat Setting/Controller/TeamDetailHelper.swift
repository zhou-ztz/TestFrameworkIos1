//
//  TeamDetailHelper.swift
//  Yippi
//
//  Created by Yong Tze Ling on 21/08/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK
//import NIMPrivate

class TeamDetailHelper: NSObject {
    
    let maximumMemberDisplayed = 12
    
    static let shared = TeamDetailHelper()
    
    var teamId: String = ""
    var delegate: NIMTeamManagerDelegate?
    var session: NIMSession?
    var myTeamInfo: NIMTeamMember?
    var team: NIMTeam? {
        didSet {
            self.getMyTeamInfo()
            self.onReloadData?(self.selectedType)
            self.selectedType = .none
        }
    }
    var addMemberButton = TeamMember(isAdd: true)
    var removeMemberButton = TeamMember(isReduce: true)
    
    var members: [TeamMember] = [] {
        didSet {
            /// 如果群设定允许添加加成员
            // By Kit Foong (New logic to hide add button)
            if self.members.contains(where: { $0.isAdd == true }) == false {
                if self.hasPermission {
                    self.members.append(addMemberButton)
                } else {
                    if team?.joinMode == .needAuth {
                        // Private Group
                        if team?.inviteMode == .all {
                            self.members.append(addMemberButton)
                        }
                    } else if team?.joinMode == .noAuth {
                        // Public Group
                        if team?.inviteMode == .all {
                            self.members.append(addMemberButton)
                        }
                    } else {
                        // Secret Group
                        if team?.inviteMode == .all {
                            self.members.append(addMemberButton)
                        }
                    }
                }
            }
//            if team?.inviteMode == .all || self.hasPermission {
//                if  let _ = self.members.first(where: { $0.isAdd == addMemberButton.isAdd}) {
//
//                } else {
//                    self.members.append(addMemberButton)
//                }
//            } else {
//                self.members.removeAll(where: { $0 == addMemberButton })
//            }
            /// 如果有权力移除成员
            if self.members.contains(where: { $0.isReduce == true }) == false {
                if self.hasPermission {
                    if  let _ = self.members.first(where: { $0.isReduce == removeMemberButton.isReduce}) {
                        
                    } else {
                        self.members.append(removeMemberButton)
                    }
                } else {
                    self.members.removeAll(where: { $0 == removeMemberButton })
                }
            }
            
            self.onReloadMembers?()
        }
    }
    
    var allMembers: [TeamMember] = []
    var onShowSuccess: ((String?) -> Void)?
    var onShowFail: ((String?) -> Void)?
    var onReloadMembers: EmptyClosure?
    var onReloadData: ((SettingType) -> Void)?
    var selectedType: SettingType = .none
    var p2PSessions: [String] = []
    var failedSessionIds: [String] = []
    var isRequesting = false
    var allTeamMembers: [String] = []
    
    func setTeamId(_ teamId: String, delegate: NIMTeamManagerDelegate) {
        self.teamId = teamId
        self.delegate = delegate
        self.session = NIMSession(teamId, type: .team)
        
        NIMSDK.shared().teamManager.add(delegate)
        
        self.getMyTeamInfo()
        self.getTeamInfo()
    }
    
    func remove(_ delegate: NIMTeamManagerDelegate) {
        NIMSDK.shared().teamManager.remove(delegate)
    }
    
    func getTeamInfo() {
        self.team = NIMSDK.shared().teamManager.team(byId: self.teamId)
    }
    
    func getMyTeamInfo() {
        if let currentUser = CurrentUserSessionInfo, let session = self.session {
            self.myTeamInfo = NIMSDK.shared().teamManager.teamMember(currentUser.username, inTeam: session.sessionId)
        }
    }
    
    func updateTeamMembers() {
        self.members.removeAll(where: { $0.isAdd == true })
        self.members.removeAll(where: { $0.isReduce == true })
        
//        /// 如果群设定允许添加加成员
//        // By Kit Foong (New logic to hide add button)
//        if self.members.contains(addMemberButton) == false {
//            if self.hasPermission {
//                self.members.append(addMemberButton)
//            } else {
//                if team?.joinMode == .needAuth {
//                    // Private Group
//                    if team?.inviteMode == .all {
//                        self.members.append(addMemberButton)
//                    }
//                } else if team?.joinMode == .noAuth {
//                    // Public Group
//                    if team?.inviteMode == .all {
//                        self.members.append(addMemberButton)
//                    }
//                } else {
//                    // Secret Group
//                    if team?.inviteMode == .all {
//                        self.members.append(addMemberButton)
//                    }
//                }
//            }
//        }
////            if team?.inviteMode == .all || self.hasPermission {
////                if  let _ = self.members.first(where: { $0.isAdd == addMemberButton.isAdd}) {
////
////                } else {
////                    self.members.append(addMemberButton)
////                }
////            } else {
////                self.members.removeAll(where: { $0 == addMemberButton })
////            }
//        /// 如果有权力移除成员
//        if self.members.contains(removeMemberButton) == false {
//            if self.hasPermission {
//                if  let _ = self.members.first(where: { $0.isReduce == removeMemberButton.isReduce}) {
//
//                } else {
//                    self.members.append(removeMemberButton)
//                }
//            } else {
//                self.members.removeAll(where: { $0 == removeMemberButton })
//            }
//        }
    }
    
    var canEditTeamInfo: Bool {
        guard let team = self.team, let myTeamInfo = self.myTeamInfo else {
            return false
        }
        if team.updateInfoMode == .manager {
            return myTeamInfo.type == .owner || myTeamInfo.type == .manager
        } else {
            return myTeamInfo.type == .owner || myTeamInfo.type == .manager || myTeamInfo.type == .normal
        }
    }
    
    var hasPermission: Bool {
        guard let myTeamInfo = self.myTeamInfo else {
            return false
        }
        return myTeamInfo.type == .owner || myTeamInfo.type == .manager
    }
    
    var isOwner: Bool {
        guard let myTeamInfo = self.myTeamInfo else {
            return false
        }
        return myTeamInfo.type == .owner
    }
    
    var isManager: Bool {
        guard let myTeamInfo = self.myTeamInfo else {
            return false
        }
        return myTeamInfo.type == .manager
    }
    
    func updateMembersInfo() {
        if isRequesting || self.p2PSessions.count == 0 {
            return
        }
        isRequesting = true
        let userIdList = self.p2PSessions.count > 150 ? Array(self.p2PSessions[0...149]) : self.p2PSessions
        
//        NIMSDK.shared().userManager.fetchUserInfos(userIdList){ [weak self] (users, error) in
//            DispatchQueue.main.async {
//                guard let strongSelf = self else { return }
//                strongSelf.afterRequest(userIdList)
//                if error == nil && users?.count != nil {
//                    NIMKit.shared().notfiyUserInfoChanged(strongSelf.p2PSessions)
//                } else {
//                    strongSelf.failedSessionIds.append(contentsOf: strongSelf.p2PSessions)
//                }
//                
//            }
//        }
    }
    
    func afterRequest(_ userIds: [String]) {
        isRequesting = false
        self.p2PSessions = self.p2PSessions.filter { !userIds.contains($0) }
        self.updateMembersInfo()
    }
    
    func getMembers(completion: @escaping (Bool) -> () = { _ in }) {
        guard let team = self.team else {
            self.onShowFail?("team is nil")
            return
        }
        NIMSDK.shared().teamManager.fetchTeamMembers(fromServer: team.teamId ?? "") { (error, members) in
            guard error == nil else {
                self.onShowFail?(error?.localizedDescription)
                completion(false)
                return
            }
            
            if let members = members {
                
                self.myTeamInfo = members.filter { $0.userId == CurrentUserSessionInfo?.username }.first
                
                var teamMembers = [TeamMember]()
                var teamMemberUserList : [String] = []
                
                teamMembers = members.filter { $0.type == .owner }.compactMap { TeamMember(memberInfo: $0) }
                teamMembers.append(contentsOf: members.filter { $0.type == .manager }.compactMap { TeamMember(memberInfo: $0) })
                teamMembers.append(contentsOf: members.filter { $0.type == .normal }.compactMap { TeamMember(memberInfo: $0) })
                teamMemberUserList.append(contentsOf: members.compactMap { TeamMember(memberInfo: $0).memberInfo?.userId })
                
                self.allMembers.removeAll()
                self.allTeamMembers.removeAll()
                self.p2PSessions.append(contentsOf: teamMemberUserList)
                self.allTeamMembers.append(contentsOf: teamMemberUserList)
                self.allMembers = teamMembers
                self.updateMembersInfo()
                
                if members.count > self.maximumMemberDisplayed {
                    self.members = Array(teamMembers.prefix(self.maximumMemberDisplayed))
                    self.members.append(TeamMember(isViewMore: true))
                } else {
                    self.members = teamMembers
                }
                
                completion(true)
            }
            
        }
        
    }
    
    func getValue(for type: SettingType) -> String? {
        switch type {
        case .groupName:
            guard let team = team, let teamName = team.teamName else {
                return "not_set_content".localized
            }
            return teamName
        case .groupIntro:
            guard let team = team, let intro = team.intro else {
                return "not_set_content".localized
            }
            return intro
            
        case .groupAnnouncement:
            guard let team = team else { return "click_to_check_team_annoucement".localized }
            if let announcement = team.announcement, let data = announcement.data(using: .utf8) {
                do {
                    if let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [Dictionary<String, Any>], let value = object.last?["title"]  as? String {
                        return value
                    }
                } catch {
                    assert(false, error.localizedDescription)
                }
            }
            return "without_content".localized
            
        case .groupIcon:
            return team?.thumbAvatarUrl != nil ? team?.thumbAvatarUrl : Bundle.main.url(forResource: "icon_pin", withExtension: "png")?.absoluteString
        case .groupType:
            return self.joinModeText
        case .groupWhoCanEdit:
            return updateInfoModeText
        case .groupWhoCanInvite:
            return inviteModeText
        case .groupInviteeApproval:
            return beInviteModeText
        case .myNickname:
            guard let myTeamInfo = myTeamInfo else {
                return ""
            }
            
            guard let nickname = myTeamInfo.nickname  else {
                return "click_set".localized
            }
            
            return nickname.isEmpty ?  "click_set".localized : myTeamInfo.nickname
            
        default:
            return nil
        }
        
        
        
    }
    
    func getBoolValue(for type: SettingType) -> Bool {
        switch type {
        case .muteNotification:
            return isNotificationMuted
        case .pinTop:
            return isPinnedToTop
        default:
            return false
        }
    }
    
    var membersCount: Int {
        return members.count
    }
    
    var removeMembersList: [NIMTeamMember] {
        if myTeamInfo?.type == .manager {
            return allMembers.filter { $0.memberInfo?.type == .normal }.compactMap { $0.memberInfo }
        }
        
        if myTeamInfo?.type == .owner {
            return allMembers.filter { $0.memberInfo?.type != .owner }.compactMap { $0.memberInfo }
        }
        
        return []
    }
    
    var joinModeText: String {
        guard let team = team else { return "group_public".localized }
        
        switch team.joinMode {
        case .needAuth:
            return "group_ask_to_join".localized
        case .noAuth:
            return "group_public".localized
        default:
            return "group_private".localized
        }
    }
    
    var inviteModeText: String {
        guard let team = team else { return "unknown_permission".localized }
        
        switch team.inviteMode {
        case .manager:
            return "group_admin_only".localized
        case .all:
            return "group_anyone".localized
        default:
            return "unknown_permission".localized
        }
    }
    
    var updateInfoModeText: String {
        guard let team = team else { return "unknown_permission".localized }
        
        switch team.updateInfoMode {
        case .manager:
            return "group_admin_only".localized
        case .all:
            return "group_anyone".localized
        default:
            return "unknown_permission".localized
        }
    }
    
    var beInviteModeText: String {
        guard let team = team else { return "unknown".localized }
        
        switch team.beInviteMode {
        case .needAuth:
            return "group_required".localized
        case .noAuth:
            return "group_not_required".localized
        default:
            return "unknown".localized
        }
    }
    
    var isNotificationMuted: Bool {
        guard let team = team else { return false }
        return team.notifyStateForNewMsg == .none
    }
    
    var isPinnedToTop: Bool {
//        if let session = self.session, let recentSession = NIMSDK.shared().conversationManager.recentSession(by: session) {
//            return NTESSessionUtil.recentSessionIsMark(recentSession, type: .top)
//        }
        return false
    }
    
    /// To update invite mode to 'needAuth' whenever number of member achieve maximum amount. Only apply to owner/manager
    func beInviteModeChecker() -> Bool {
        if let team = self.team, team.memberNumber >= Constants.maximumTeamMemberAuthCompulsory && team.beInviteMode == .noAuth && self.hasPermission {
            NIMSDK.shared().teamManager.update(NIMTeamBeInviteMode.needAuth, teamId: teamId, completion: nil)
            return false
        }
        return true
    }
    
    /// Automatically change all 'beInviteMode' to needAuth
    func changeToNeedAuth () {
        if let team = self.team, team.beInviteMode == .noAuth && self.hasPermission {
            NIMSDK.shared().teamManager.update(NIMTeamBeInviteMode.needAuth, teamId: teamId, completion: nil)
        }
    }
    
    func deleteAllMessages() {
        guard let session = self.session else { return }
        let option = NIMDeleteMessagesOption()
        option.removeSession = BundleSetting.sharedConfig().removeSessionWhenDeleteMessages()
        option.removeTable = BundleSetting.sharedConfig().dropTableWhenDeleteMessages()
        DispatchQueue.main.async {
            NIMSDK.shared().conversationManager.deleteRemoteSessions([session], completion: nil)
           // NIMSDK.shared().conversationManager.deleteAllmessages(in: session, option: option)
            // 删除本地和云端
            let deleteOption = NIMSessionDeleteAllRemoteMessagesOptions()
            deleteOption.removeOtherClients = false
            NIMSDK.shared().conversationManager.deleteAllRemoteMessages(in: session, options: deleteOption) { error in
                
            }
        }
    }
    
    func setPinToTop(_ isPinned: Bool) {
        selectedType = .pinTop
        guard let session = self.session else { return }
//        if isPinned {
//            NTESSessionUtil.addRecentSessionMark(session, type: .top)
//        } else {
//            NTESSessionUtil.removeRecentSessionMark(session, type: .top)
//        }
    }
    
    func uploadGroupImage(_ uploadFilepath: String, onHideLoading: EmptyClosure?) {
        selectedType = .groupIcon
        NIMSDK.shared().resourceManager.upload(uploadFilepath, scene: NIMNOSSceneTypeAvatar, progress: nil) { (urlString, error) in
            
            onHideLoading?()
            
            if let url = urlString {
                NIMSDK.shared().teamManager.updateTeamAvatar(url, teamId: self.teamId, completion: { [weak self] error in
                    DispatchQueue.main.async {
                        if let _ = error {
                            self?.onShowFail?(nil)
                        } else {
                            self?.onShowSuccess?(nil)
                        }
                    }
                })
            }
            
            if let error = error {
                self.onShowFail?(error.localizedDescription)
            }
        }
        
    }
    
    func updateTeamName(_ name: String) {
        selectedType = .groupName
        if name.isEmpty {
            self.onShowFail?(String(format: "warning_cnt_empty".localized, "group_name".localized))
        } else {
            NIMSDK.shared().teamManager.updateTeamName(name, teamId: teamId, completion: { [weak self] error in
                if let error = error {
                    self?.onShowFail?(error.localizedDescription)
                } else {
                    self?.onShowSuccess?(nil)
                }
            })
        }
    }
    
    func updateTeamIntro(_ intro: String) {
        selectedType = .groupIntro
        NIMSDK.shared().teamManager.updateTeamIntro(intro, teamId: self.teamId, completion: { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.onShowFail?(error.localizedDescription)
                } else {
                    self?.onShowSuccess?(nil)
                }
            }
        })
    }
    
    func updateJoinMode(_ mode: NIMTeamJoinMode) {
        selectedType = .groupType
        NIMSDK.shared().teamManager.update(mode, teamId: teamId) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.onShowFail?(error.localizedDescription)
                } else {
                    self?.onShowSuccess?(nil)
                }
            }
        }
    }
    
    func updateInviteMode(_ mode: NIMTeamInviteMode) {
        selectedType = .groupWhoCanInvite
        NIMSDK.shared().teamManager.update(mode, teamId: teamId) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.onShowFail?(error.localizedDescription)
                } else {
                    self?.onShowSuccess?(nil)
                }
            }
        }
    }
    
    func updateBeInviteMode(_ mode: NIMTeamBeInviteMode) {
        selectedType = .groupInviteeApproval
        NIMSDK.shared().teamManager.update(mode, teamId: teamId, completion: { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.onShowFail?(error.localizedDescription)
                } else {
                    self?.onShowSuccess?(nil)
                }
            }
        })
    }
    
    func updateInfoMode(_ mode: NIMTeamUpdateInfoMode) {
        selectedType = .groupWhoCanEdit
        NIMSDK.shared().teamManager.update(mode, teamId: teamId) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.onShowFail?(error.localizedDescription)
                } else {
                    self?.onShowSuccess?(nil)
                }
            }
        }
    }
    
    func updateUserNickname(_ newNickName: String) {
        selectedType = .myNickname
        guard let myUserName = myTeamInfo?.userId else { return }
        NIMSDK.shared().teamManager.updateUserNick(myUserName, newNick: newNickName, inTeam: self.teamId, completion: { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.onShowFail?(error.localizedDescription)
                } else {
                    self?.onShowSuccess?(nil)
                }
            }
        })
    }
    
    func muteNotification(isMute: Bool, sessionId: String? = nil)  {
        selectedType = .muteNotification
        let notifyState: NIMTeamNotifyState = isMute ? NIMTeamNotifyState.none : NIMTeamNotifyState.all
        var inTeam: String
        if sessionId != nil {
            inTeam = sessionId!
        } else {
            inTeam = teamId
        }
        NIMSDK.shared().teamManager.update(notifyState, inTeam: inTeam, completion: { [weak self] (error) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let error = error {
                    self.onShowFail?(error.localizedDescription)
                } else {
                    self.onShowSuccess?(nil)
                }
            }
        })
    }
    
    func dismissGroup(onDismiss: @escaping EmptyClosure) {
        NIMSDK.shared().teamManager.dismissTeam(teamId, completion: { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.onShowFail?(error.localizedDescription)
                } else {
                    self?.onShowSuccess?(nil)
                    onDismiss()
                }
            }
        })
    }
    
    func quitGroup(onDismiss: @escaping EmptyClosure) {
        NIMSDK.shared().teamManager.quitTeam(teamId, completion: { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.onShowFail?(error.localizedDescription)
                } else {
                    self?.onShowSuccess?(nil)
                    onDismiss()
                }
            }
        })
    }
    
    func transferGroup(to userName: String, isLeaving: Bool, onDismiss: @escaping EmptyClosure) {
        NIMSDK.shared().teamManager.transferManager(withTeam: teamId, newOwnerId: userName, isLeave: isLeaving, completion: { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.onShowFail?(error.localizedDescription)
                } else {
                    self?.onShowSuccess?(nil)
                    onDismiss()
                }
            }
        })
    }
    
    func kickMember(_ memberId: String) {
        NIMSDK.shared().teamManager.kickUsers([memberId], fromTeam: self.teamId, completion: { error in
            guard error == nil else {
                self.onShowFail?("remove_member_failed".localized)
                return
            }
            self.onShowSuccess?(nil)
        })
    }
    
    func makeAdmin(_ memberId: String) {
        NIMSDK.shared().teamManager.addManagers(toTeam: self.teamId, users: [memberId]) { error in
            guard error == nil else {
                self.onShowFail?(nil)
                return
            }
            self.onShowSuccess?(nil)
        }
    }
    
    func removeAdmin(_ memberId: String) {
        NIMSDK.shared().teamManager.removeManagers(fromTeam: self.teamId, users: [memberId]) { error in
            guard error == nil else {
                self.onShowFail?(nil)
                return
            }
            self.onShowSuccess?(nil)
        }
    }
    
    func addMembers(_ members: [String]) {
        NIMSDK.shared().teamManager.addUsers(members, toTeam: self.teamId, postscript: "group_invite_you".localized, attach: "", completion: { (error, _) in
            if let error = error {
                self.onShowFail?(error.localizedDescription)
            } else {
                if let team = self.team, team.beInviteMode == .needAuth {
                    self.onShowSuccess?("team_invite_members_success".localized)
                } else {
                    self.onShowSuccess?("group_success_add_member".localized)
                }
            }
        })
    }
    
    func clearAndDelete(onDismiss: @escaping EmptyClosure) {
        guard let session = self.session else { return }
        TeamDetailHelper.shared.deleteAllMessages()
        guard let recentSession = NIMSDK.shared().conversationManager.recentSession(by: session) else { return }
        NIMSDK.shared().conversationManager.delete(recentSession)
        onDismiss()
    }
}
