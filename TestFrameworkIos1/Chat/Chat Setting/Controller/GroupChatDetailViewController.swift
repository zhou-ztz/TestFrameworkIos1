//
//  GroupChatDetailViewController.swift
//  Yippi
//
//  Created by Yong Tze Ling on 20/08/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import UIKit
import SnapKit
import Toast
import MJRefresh
import NIMSDK

class GroupChatDetailViewController: TSViewController {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var memberCollection: UICollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var isActionSuccess: Bool = false
    var isLeavedMember: Bool = false
    private(set) var teamId: String
    private var _session: NIMRecentSession?
    var clearGroupMessageCall: (() -> ())?
    private lazy var groupDataView: UIStackView = {
        let view = UIStackView()
        view.spacing = 1
        view.axis = .vertical
        view.alignment = .fill
        view.distribution = .fillEqually
        return view
    }()
    
    private lazy var groupInfoView: UIStackView = {
        let view = UIStackView()
        view.spacing = 1
        view.axis = .vertical
        view.alignment = .fill
        view.distribution = .fillEqually
        return view
    }()
    
    private lazy var groupSensitiveView: UIStackView = {
        let view = UIStackView()
        view.spacing = 1
        view.axis = .vertical
        view.alignment = .fill
        view.distribution = .fillEqually
        return view
    }()
    
    private lazy var preferencesView: UIStackView = {
        let view = UIStackView()
        view.spacing = 1
        view.axis = .vertical
        view.alignment = .fill
        view.distribution = .fillEqually
        return view
    }()
    
    private lazy var leavedView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0xFFE0AD)
        
        let label = UILabel()
        label.text = "team_no_longer_in_group".localized
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        view.addSubview(label)
        label.snp.makeConstraints({
            $0.height.equalTo(50)
            $0.width.equalTo(UIScreen.main.bounds.width - 28)
            $0.left.equalTo(view.snp.left).inset(14)
            $0.centerY.equalTo(view.snp.centerY)

        })
        return view
    }()
    
    private lazy var groupDataInfo: [ChatSettingView] = {
        return [SettingData(type: .mediaDocuments, selector: #selector(self.onClickMedia)).toSettingView(self),
                SettingData(type: .searchMessage, selector: #selector(self.onClickSearchMessages)).toSettingView(self)]
    }()
    
    private lazy var groupBasicInfo: [ChatSettingView] = {
        guard let team = TeamDetailHelper.shared.team, let myTeamInfo = TeamDetailHelper.shared.myTeamInfo else { return [] }
        return [SettingData(type: .groupIcon, selector: #selector(self.onClickGroupImage), imageUrl: team.thumbAvatarUrl).toSettingView(self),
                SettingData(type: .groupName, selector: #selector(self.onClickGroupName), detailValue: TeamDetailHelper.shared.getValue(for: .groupName)).toSettingView(self),
                SettingData(type: .groupIntro, selector: #selector(self.onClickGroupIntro), detailValue: TeamDetailHelper.shared.getValue(for: .groupIntro)).toSettingView(self),
                SettingData(type: .myNickname, selector: #selector(self.onClickGroupNickname), detailValue: TeamDetailHelper.shared.getValue(for: .myNickname)).toSettingView(self)]
    }()
    
    private lazy var groupSensitiveInfo: [ChatSettingView] = {
        return [SettingData(type: .groupType, selector: #selector(self.onClickGroupType), detailValue: TeamDetailHelper.shared.joinModeText, clickable: TeamDetailHelper.shared.hasPermission).toSettingView(self),
                SettingData(type: .groupWhoCanInvite, selector: #selector(self.onClickInvitor), detailValue: TeamDetailHelper.shared.inviteModeText, clickable: TeamDetailHelper.shared.hasPermission).toSettingView(self),
                SettingData(type: .groupWhoCanEdit, selector: #selector(self.onClickEditPermission), detailValue: TeamDetailHelper.shared.updateInfoModeText, clickable: TeamDetailHelper.shared.hasPermission).toSettingView(self)]
    }()
    
    private lazy var preferencesInfo: [ChatSettingView] = {
        return [SettingData(type: .chatWallpaper, selector: #selector(self.onClickChatWallpaper)).toSettingView(self),
                SettingData(type: .muteNotification, selector: #selector(self.onMuteNotification(_:)), switchValue: TeamDetailHelper.shared.isNotificationMuted).toSettingView(self),
                SettingData(type: .pinTop, selector: #selector(self.onSetTopValueChange(_:)), switchValue:TeamDetailHelper.shared.isPinnedToTop).toSettingView(self)]
    }()
    
    private lazy var ownerButtons: [UIButton] = {
        return [SettingData(type: .transferGroup, selector: #selector(self.onClickTransferGroup)).toButton(self),
                SettingData(type: .dismissGroup, selector: #selector(self.onClickDismissTeam)).toButton(self)]
    }()
    
    private lazy var leaveButton: UIButton = {
        return SettingData(type: .leaveGroup, selector: #selector(self.onClickQuitTeam)).toButton(self)
    }()
    
    private lazy var clearAndDeleteButton: UIButton = {
        return SettingData(type: .clearAndDeleteChat, selector: #selector(self.onClickClearDeleteTeam)).toButton(self)
    }()
    
    var loadingAlert: TSIndicatorWindowTop?
    
    init(teamId: String) {
        self.teamId = teamId
        super.init(nibName: "GroupChatDetailViewController", bundle: nil)
        TeamDetailHelper.shared.setTeamId(self.teamId, delegate: self)
    }
    
    deinit {
        TeamDetailHelper.shared.remove(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)]
        
        if let team = TeamDetailHelper.shared.team, let teamName = team.teamName {
            setCloseButton(backImage: true, titleStr: teamName + "(\(team.memberNumber))")
        } else {
            setCloseButton(backImage: true, titleStr: "title_group_chat_info".localized)
        }
        
        contentStackView.spacing = 8
        contentStackView.backgroundColor = .clear
        scrollView.backgroundColor = .clear
        contentView.backgroundColor = .clear
        self.view.backgroundColor = TSColor.inconspicuous.background
                
        helperCallback()
        setupCollection()
        
        TeamDetailHelper.shared.getMembers() { [weak self] done in
            guard let self = self else { return }
            if done {
                self.isLeavedMember = false
                self.leaveButton.isHidden = TeamDetailHelper.shared.isOwner
                self.leavedView.isHidden = true
            } else {
                self.isLeavedMember = true
                self.memberCollection.isHidden = true
                self.groupDataView.isHidden = false
                self.groupInfoView.isHidden = true
                self.groupSensitiveView.isHidden = true
                self.preferencesView.isHidden = true
                self.leaveButton.isHidden = true
                self.leavedView.isHidden = false
            }
    
            self.checkMemberPermission()
            self.setupGroupInfoContent()
        }
        
        scrollView.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        
        TeamDetailHelper.shared.changeToNeedAuth()
    }
    
    // By Kit Foong (Check member permission to hide qr code)
    private func checkMemberPermission(_ canRetrieveTeamInfo: Bool = true) {
        TeamDetailHelper.shared.getMyTeamInfo()
        if canRetrieveTeamInfo {
            TeamDetailHelper.shared.getTeamInfo()
        }
        
        var isAdmin = TeamDetailHelper.shared.hasPermission
        
        for var item in groupSensitiveInfo {
            item.isUserInteractionEnabled = isAdmin
        }
        
        if isAdmin {
            guard let team =  TeamDetailHelper.shared.team else {
                self.setupRightBarButton()
                return
            }
            
            if team.joinMode == .needAuth || team.joinMode == .noAuth {
                self.setupRightBarButton()
            } else {
                self.setupRightBarButton(true)
            }
        } else {
            // Normal Member
            guard let team =  TeamDetailHelper.shared.team else { return }
            
            if team.joinMode == .needAuth {
                // Private Group
                if team.inviteMode == .all {
                    self.setupRightBarButton()
                } else {
                    self.setupRightBarButton(true)
                }
            } else if team.joinMode == .noAuth {
                // Public Group
                if team.inviteMode == .all {
                    self.setupRightBarButton()
                } else {
                    self.setupRightBarButton(true)
                }
            } else {
                // Secret Group
                self.setupRightBarButton(true)
            }
        }
        
        if TeamDetailHelper.shared.selectedType == .none {
            self.updateAllInfo()
        } else {
            self.updateDataContent(for: TeamDetailHelper.shared.selectedType)
        }
        
        TeamDetailHelper.shared.updateTeamMembers();
        
        self.view.layoutSubviews()
        self.view.layoutIfNeeded()
    }
    
    private func setupRightBarButton(_ needHide: Bool = false) {
        if needHide {
            self.navigationItem.rightBarButtonItem = nil
        } else {
            let rightButton = UIButton(frame: CGRect(x: 0, y: 0, width: TSViewRightCustomViewUX.MinWidth, height: 44))
            rightButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -10)
            rightButton.setImage(UIImage.set_image(named: "iconsQrcodeBlack"), for: .normal)
            rightButton.addTarget(self, action: #selector(onClickQRCode), for: UIControl.Event.touchUpInside)
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
            rightButton.isHidden = memberCollection.isHidden
        }
    }
    
    @objc func refresh() {
        TeamDetailHelper.shared.getMembers() { [weak self] done in
            guard let self = self else { return }
            self.checkMemberPermission()
        }
    }
    
    private func helperCallback() {
        TeamDetailHelper.shared.onShowSuccess = { [weak self] msg in
        guard let self = self else { return }
            DispatchQueue.main.async {
                self.scrollView.mj_header.endRefreshing()
                self.showSuccess(msg)
                // By Kit Foong (added refresh when any action trigger)
                self.refresh()
            }
        }
        
        if !(self.isActionSuccess) {
            TeamDetailHelper.shared.onShowFail = { [weak self] msg in
                guard let self = self, self.isLeavedMember != false else { return }
                self.scrollView.mj_header.endRefreshing()
                self.showFail(msg)
            }
        }
        
        TeamDetailHelper.shared.onReloadMembers = { [weak self] in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.scrollView.mj_header.endRefreshing()
                self.memberCollection.reloadData()
                let height = self.memberCollection.collectionViewLayout.collectionViewContentSize.height
                self.collectionViewHeight.constant = height
                self.view.setNeedsLayout()
            }
        }
        
        TeamDetailHelper.shared.onReloadData = { type in
            //self.updateDataContent(for: type)
            self.checkMemberPermission(false)
        }
    }
    
    private func setupCollection() {
        memberCollection.register(ChatMemberCell.nib(), forCellWithReuseIdentifier: ChatMemberCell.cellIdentifier)
        memberCollection.delegate = self
        memberCollection.dataSource = self
        memberCollection.isScrollEnabled = false
    }
    
    func setupGroupInfoContent() {
        contentStackView.addArrangedSubview(leavedView)
        leavedView.snp.makeConstraints({
            $0.height.equalTo(50)
        })

        groupDataInfo.forEach { view in
            groupDataView.addArrangedSubview(view)
        }
        contentStackView.addArrangedSubview(groupDataView)
        
        groupBasicInfo.forEach { view in
            groupInfoView.addArrangedSubview(view)
        }
        contentStackView.addArrangedSubview(groupInfoView)
        
        groupSensitiveInfo.forEach { view in
            groupSensitiveView.addArrangedSubview(view)
        }
        contentStackView.addArrangedSubview(groupSensitiveView)
                
        preferencesInfo.forEach { view in
            preferencesView.addArrangedSubview(view)
        }
        contentStackView.addArrangedSubview(preferencesView)
        
        if (isLeavedMember) {
            contentStackView.addArrangedSubview(SettingData(type: .clearAndDeleteChat, selector: #selector(self.onClickClearDeleteTeam), titleColor: .red).toSettingView(self))
        } else {
            contentStackView.addArrangedSubview(SettingData(type: .clearChat, selector: #selector(self.onClickClearChat), titleColor: .red).toSettingView(self))
        }
        
        ownerButtons.forEach { view in
            contentStackView.addArrangedSubview(view)
            view.isHidden = !TeamDetailHelper.shared.isOwner
            view.snp.makeConstraints({
                $0.height.equalTo(40)
            })
        }
        
        contentStackView.addArrangedSubview(leaveButton)
        leaveButton.snp.makeConstraints {
            $0.height.equalTo(40)
        }
    }
    
    func updateDataContent(for type: SettingType) {
        switch type {
        case .groupName, .groupIntro, .groupAnnouncement, .myNickname:
            groupBasicInfo.filter { $0.type == type }.first?.setValue(TeamDetailHelper.shared.getValue(for: type))
        case .groupIcon:
            groupBasicInfo.filter { $0.type == type }.first?.setImageUrl(TeamDetailHelper.shared.getValue(for: type))
        case .groupInviteeApproval, .groupWhoCanInvite, .groupWhoCanEdit, .groupType:
            groupSensitiveInfo.filter { $0.type == type }.first?.setValue(TeamDetailHelper.shared.getValue(for: type))
        case .muteNotification, .pinTop:
            preferencesInfo.filter { $0.type == type }.first?.setSwitchValue(TeamDetailHelper.shared.getBoolValue(for: type))
        default:
            break
        }
                
        ownerButtons.forEach { button in
            button.isHidden = !TeamDetailHelper.shared.isOwner
        }
    }
    
    // By Kit Foong (Update All info, when the Setting Type is .none)
    func updateAllInfo() {
        for var item in groupBasicInfo {
            self.updateDataContent(for: item.type)
        }

        for var item in groupSensitiveInfo {
            self.updateDataContent(for: item.type)
        }

        for var item in preferencesInfo {
            self.updateDataContent(for: item.type)
        }
    }
    
    func showFail(_ msg: String? = nil) {
        if (self.isActionSuccess == false) {
            loadingAlert = TSIndicatorWindowTop(state: .faild, title: msg ?? "error_tips_fail".localized)
            loadingAlert?.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
        }
    }
    
    func showSuccess(_ msg: String? = nil) {
        self.isActionSuccess = true
        loadingAlert = TSIndicatorWindowTop(state: .success, title: msg ?? "change_success".localized)
        loadingAlert?.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
    }
    
    func showLoading() {
        loadingAlert = TSIndicatorWindowTop(state: .loading, title: "uploading".localized)
        loadingAlert?.show()
    }
     
    func dismissAlert() {
        loadingAlert?.dismiss()
    }
}

extension GroupChatDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return TeamDetailHelper.shared.membersCount
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChatMemberCell.cellIdentifier, for: indexPath) as! ChatMemberCell
        if TeamDetailHelper.shared.members.indices.contains(indexPath.row) {
            cell.setData(TeamDetailHelper.shared.members[indexPath.row])
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let member = TeamDetailHelper.shared.members[indexPath.row]
        if member.isAdd {
            self.showContactsPicker()
        } else if member.isReduce {
            self.showRemoveMemberSelector()
        } else if member.isViewMore {
            self.showViewMoreMembers()
        } else {
            onTapMember(at: indexPath.row)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.bounds.width / 5, height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension GroupChatDetailViewController {
    func presentInputDialog(title: String, placeholder: String, value: String?, completion: @escaping ((String) -> Void)) {
        let dialog = TSAlertController(title: title, message: nil, style: .alert)
        
        dialog.addTextField { textfield in
            textfield.placeholder = placeholder
            textfield.text = value
        }
        
        dialog.addAction(TSAlertAction(title: "confirm".localized, style: TSAlertActionStyle.default, handler: { _ in
            let textfield = dialog.textFields![0]
            if let text = textfield.text, text.count > 0 {
                completion(text)
            }
        }))
        
        dialog.addAction(TSAlertAction(title: "cancel".localized, style: TSAlertActionStyle.destructive, handler: nil))
        
        self.presentPopup(alert: dialog)
    }
    
    func uploadImage(_ image: UIImage) {
        let fileName = NSUUID().uuidString.lowercased() + ".jpg"
        let filepath = NSURL.fileURL(withPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        
        let data = image.jpegData(compressionQuality: 0.6)
        
        do {
            try data?.write(to: filepath, options: .atomic)
        } catch {
            self.showFail("unable to write data")
            return
        }
        
        self.showLoading()
        
        let uploadFilepath = filepath.absoluteString.replacingOccurrences(of: "file:///", with: "", options: .literal, range: nil)
        
        TeamDetailHelper.shared.uploadGroupImage(uploadFilepath, onHideLoading: {
            self.dismissAlert()
        })
    }
    
    func showContactsPicker() {
        let config = ContactsPickerConfig(title: "group_add_new_member".localized, rightButtonTitle: "add".localized, allowMultiSelect: true, maximumSelectCount: Constants.maximumTeamMemberAuthCompulsory, excludeIds: TeamDetailHelper.shared.allTeamMembers)
        let vc = ContactsPickerViewController(configuration: config, finishClosure: nil)
        vc.finishClosure = { users in
            vc.navigationController?.popViewController(animated: true)
            let usernames = users.compactMap { $0.userName }
            TeamDetailHelper.shared.addMembers(usernames)
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showRemoveMemberSelector() {
        TeamDetailHelper.shared.getMembers { (success) in
            let vc = RemoveMemberTableViewController(self.teamId)
            vc.members = TeamDetailHelper.shared.removeMembersList
            weak var wself = self
            vc.membersDidRemovedHandler = {
                TeamDetailHelper.shared.getMembers()
                if let team = TeamDetailHelper.shared.team, let teamName = team.teamName {
                    wself?.title = teamName + "(\(team.memberNumber))"
                }
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func showViewMoreMembers() {
        let vc = MembersViewController(teamId: self.teamId, canEditTeamInfo: TeamDetailHelper.shared.canEditTeamInfo)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func onTapMember(at index: Int) {
        guard let member: NIMTeamMember = TeamDetailHelper.shared.members[index].memberInfo, let memberId = member.userId, let userId = CurrentUserSessionInfo?.userIdentity else { return }
        
        /// Show user profile if self is tapped
        if memberId == CurrentUserSessionInfo?.username {
            FeedIMSDKManager.shared.delegate?.didClickHomePage(userId: userId, username: memberId, nickname: nil, shouldShowTab: false, isFromReactionList: false, isTeam: false)
//            let vc = HomePageViewController(userId: userId, username: memberId)
//            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
        
        self.loadingOverlay()
        
        TSUserNetworkingManager().getUsersInfo(usersId: [], names: [], userNames: [memberId]) { (models, msg, status) in
            self.endLoading()
            guard let model = models?.first else {
                self.showError(message: "text_user_suspended".localized)
                return
            }
            
            var titles = [model.name, "group_view_profile".localized]
            
            if model.followStatus == .eachOther {
                titles.append("group_member_info_send_message".localized)
            }
            
            if TeamDetailHelper.shared.canEditTeamInfo {
                // By Kit Foong (Updated roles action)
                if TeamDetailHelper.shared.isOwner {
                    if member.type == .normal {
                        titles.append("group_make_admin".localized)
                    }
                    
                    if member.type == .manager {
                        titles.append("group_remove_admin".localized)
                    }
                    
                    titles.append("group_remove_member".localized)
                } else if TeamDetailHelper.shared.isManager {
                    if member.type == .normal {
                        titles.append("group_remove_member".localized)
                    }
                }
            }
            
            let actionsheetView = TSCustomActionsheetView(titles: titles)
            if TeamDetailHelper.shared.canEditTeamInfo {
                actionsheetView.setColor(color: TSColor.main.warn, index: titles.count - 1)
            }
            actionsheetView.setColor(color: TSColor.normal.minor, index: 0)
            actionsheetView.tag = 1
            actionsheetView.notClickIndexs = [0]
            actionsheetView.show()
            actionsheetView.finishBlock = { [weak self] _, title, _ in
                guard let self = self else { return }
                switch title {
                case "group_view_profile".localized:
                    FeedIMSDKManager.shared.delegate?.didClickHomePage(userId: model.userIdentity, username: memberId, nickname: nil, shouldShowTab: false, isFromReactionList: false, isTeam: false)
//                    let vc = HomePageViewController(userId: model.userIdentity, username: memberId)
//                    self.navigationController?.pushViewController(vc, animated: true)
                case "group_member_info_send_message".localized:
                    let vc = IMChatViewController(session: NIMSession(memberId, type: .P2P), unread: 0)
                    self.navigationController?.pushViewController(vc, animated: true)
                case "group_make_admin".localized:
                    TeamDetailHelper.shared.makeAdmin(memberId)
                case "group_remove_admin".localized:
                    TeamDetailHelper.shared.removeAdmin(memberId)
                case "group_remove_member".localized:
                    self.showAlert(title: nil, message: "team_member_remove_confirm".localized, buttonTitle: "confirm".localized, defaultAction: { _ in
                        TeamDetailHelper.shared.kickMember(memberId)
                    }, cancelTitle: "cancel".localized, cancelAction: nil)
                default:
                    break
                }
            }
        }
    }
}

extension GroupChatDetailViewController: NIMTeamManagerDelegate {
    func onTeamMemberChanged(_ team: NIMTeam) {
        TeamDetailHelper.shared.team = team
        
        if TeamDetailHelper.shared.beInviteModeChecker() {
            if !(self.isActionSuccess) {
                TeamDetailHelper.shared.getMembers()
            }
        }
    }
    
    func onTeamUpdated(_ team: NIMTeam) {
        TeamDetailHelper.shared.team = team
    }
}

extension GroupChatDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            picker.dismiss(animated: true) {
                self.uploadImage(image)
            }
        }
    }
}

extension GroupChatDetailViewController {
    // Selectors
    @objc func onClickSearchMessages() {
        if let session = TeamDetailHelper.shared.session {
            let vc = SearchChatHistoryTableViewController(session: session)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func onClickClearChat() {
        let alert = TSAlertController(title: "confirm_delete_record".localized, message: nil, style: .alert)
        alert.addAction(TSAlertAction(title: "confirm".localized, style: TSAlertActionStyle.destructive, handler: { _ in
            TeamDetailHelper.shared.deleteAllMessages()
            self.clearGroupMessageCall?()
        }))
        self.presentPopup(alert: alert)
    }
    
    @objc func onSetTopValueChange(_ sender: UISwitch) {
        TeamDetailHelper.shared.setPinToTop(sender.isOn)
    }
    
    @objc func onClickGroupNickname() {
        guard let info = TeamDetailHelper.shared.myTeamInfo else { return }
        let vc = GroupInfoEditViewController.init(editType: .nickname, editText: info.nickname ?? "", canEdit: true)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func onClickGroupImage() {
        guard TeamDetailHelper.shared.canEditTeamInfo else {
            self.view.makeToast("group_admin_edit_only".localized, duration: 0.5, position: CSToastPositionBottom)
            return
        }
        
        func showImagePicker(type: UIImagePickerController.SourceType, alert: TSAlertController) {
            alert.dismiss(animated: true, completion: {
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.sourceType = type
                picker.allowsEditing = true
                self.present(picker, animated: true, completion: nil)
            })
        }
        
        let alert = TSAlertController(title: nil, message: "set_group_avatar".localized, style: .actionsheet, sheetCancelTitle: "cancel".localized)
        
        alert.addAction(TSAlertAction(title: "choose_from_camera".localized, style: TSAlertSheetActionStyle.default, handler: { _ in
            showImagePicker(type: .camera, alert: alert)
        }))
        
        alert.addAction(TSAlertAction(title: "choose_from_photo".localized, style: TSAlertSheetActionStyle.default, handler: { _ in
            showImagePicker(type: .photoLibrary, alert: alert)
        }))
        
        self.presentPopup(alert: alert)
    }
    
    @objc func onClickGroupName() {
        guard let team = TeamDetailHelper.shared.team else { return }
        let vc = GroupInfoEditViewController.init(editType: .name, editText: team.teamName ?? "",canEdit: TeamDetailHelper.shared.canEditTeamInfo)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func onClickQRCode() {
        guard let team = TeamDetailHelper.shared.team else { return }
        let teamId = team.teamId ?? "0"
//        let qrCodeVC = TSQRCodeVC(qrType: .group, qrContent: teamId, descStr: "group_scan_qr_to_join_group".localized)
//        qrCodeVC.avatarString = team.avatarUrl
//        qrCodeVC.nameString = team.teamName
//        qrCodeVC.introString = team.intro
//        qrCodeVC.uidStirng = Int(teamId) ?? 0
//        qrCodeVC.isIMorProfile = true
//        self.navigationController?.pushViewController(qrCodeVC, animated: true)
    }
    
    @objc func onClickGroupIntro() {
        let vc = GroupInfoEditViewController.init(editType: .description, editText: TeamDetailHelper.shared.team?.intro.orEmpty ?? "",canEdit: TeamDetailHelper.shared.canEditTeamInfo)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func onClickGroupAnnouncement() {
        TeamDetailHelper.shared.selectedType = .groupAnnouncement
//        let vc = NTESTeamAnnouncementListViewController()
//        vc.team = TeamDetailHelper.shared.team
//        vc.canCreateAnnouncement = TeamDetailHelper.shared.canEditTeamInfo
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func onClickGroupType() {
        let alert = TSAlertController(title: nil, message: "group_verify_method".localized, style: .actionsheet, sheetCancelTitle: "cancel".localized)
        
        alert.addAction(TSAlertAction(title: "group_public".localized, style: TSAlertSheetActionStyle.default, handler: { _ in
            TeamDetailHelper.shared.updateJoinMode(.noAuth)
        }))
        
        alert.addAction(TSAlertAction(title: "group_ask_to_join".localized, style: TSAlertSheetActionStyle.default, handler: { _ in
            TeamDetailHelper.shared.updateJoinMode(.needAuth)
        }))
        
        alert.addAction(TSAlertAction(title: "group_private".localized, style: TSAlertSheetActionStyle.default, handler: { _ in
            TeamDetailHelper.shared.updateJoinMode(.rejectAll)
        }))
        
        self.presentPopup(alert: alert)
    }
    
    @objc func onClickInvitor() {
        let alert = TSAlertController(title: nil, message: "group_invite_others".localized, style: .actionsheet, sheetCancelTitle: "cancel".localized)
        
        alert.addAction(TSAlertAction(title: "group_admin_only".localized, style: TSAlertSheetActionStyle.default, handler: { _ in
            TeamDetailHelper.shared.updateInviteMode(.manager)
        }))
        
        alert.addAction(TSAlertAction(title: "group_anyone".localized, style: TSAlertSheetActionStyle.default, handler: { _ in
            TeamDetailHelper.shared.updateInviteMode(.all)
        }))
        
        self.presentPopup(alert: alert)
    }
    
    @objc func onClickEditPermission() {
        let alert = TSAlertController(title: nil, message: "group_who_can_edit".localized, style: .actionsheet, sheetCancelTitle: "cancel".localized)
        
        alert.addAction(TSAlertAction(title: "group_admin_only".localized, style: TSAlertSheetActionStyle.default, handler: { _ in
            TeamDetailHelper.shared.updateInfoMode(.manager)
        }))
        
        alert.addAction(TSAlertAction(title: "group_anyone".localized, style: TSAlertSheetActionStyle.default, handler: { _ in
            TeamDetailHelper.shared.updateInfoMode(.all)
        }))
        
        self.presentPopup(alert: alert)
    }
    
    @objc func onClickInviteeApproval() {
        if TeamDetailHelper.shared.membersCount > Constants.maximumTeamMemberAuthCompulsory {
            self.showError(message: String(format: "text_chage_verification_mode_not_allow".localized, "\(Constants.maximumTeamMemberAuthCompulsory)"))
            return
        }
        
        let alert = TSAlertController(title: nil, message: "group_invitee_approval".localized, style: .actionsheet, sheetCancelTitle: "cancel".localized)
        
        alert.addAction(TSAlertAction(title: "group_required".localized, style: TSAlertSheetActionStyle.default, handler: { _ in
            TeamDetailHelper.shared.updateBeInviteMode(.needAuth)
        }))
        
        alert.addAction(TSAlertAction(title: "group_not_required".localized, style: TSAlertSheetActionStyle.default, handler: { _ in
            TeamDetailHelper.shared.updateBeInviteMode(.noAuth)
        }))
        
        self.presentPopup(alert: alert)
    }
    
    @objc func onClickMedia() {
        let vc = ChatMediaViewController.init(session: TeamDetailHelper.shared.session!)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func onClickChatWallpaper() {
        navigationController?.pushViewController(IMChatWallpaperViewController(), animated: true)
    }
    
    @objc func onMuteNotification(_ sender: UISwitch) {
        TeamDetailHelper.shared.muteNotification(isMute: sender.isOn)
    }
    
    @objc func onClickTransferGroup() {
        func transferGroup(_ isLeaving: Bool) {
            let config = ContactsPickerConfig(title: "group_transfer".localized, rightButtonTitle: "transfer".localized, members: TeamDetailHelper.shared.members.compactMap { member in
                if member.memberInfo?.userId != CurrentUserSessionInfo?.username {
                    return member.memberInfo?.userId
                }
                return nil
            })
            
            let vc = ContactsPickerViewController(configuration: config, finishClosure: nil)
            vc.finishClosure = { users in
                guard let newOwner = users.first else { return }
                
                if TeamDetailHelper.shared.team!.beInviteMode == .noAuth {
                    TeamDetailHelper.shared.updateBeInviteMode(.needAuth)
                }
                
                TeamDetailHelper.shared.transferGroup(to: newOwner.userName, isLeaving: isLeaving, onDismiss: { [weak self] in
                guard let self = self else { return }
                    self.isActionSuccess = true
                    if isLeaving {
                        self.navigationController?.popToRootViewController(animated: true)
                    } else {
                        vc.navigationController?.popViewController(animated: true)
                        self.updateDataContent(for: .groupAnnouncement)
                        self.updateDataContent(for: .groupIntro)
                    }
                })
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        let alert = TSAlertController(title: nil, message: "group_transfer".localized, style: .actionsheet, sheetCancelTitle: "cancel".localized)
        
        alert.addAction(TSAlertAction(title: "group_transfer".localized, style: TSAlertSheetActionStyle.default, handler: { _ in
            self.leaveButton.isHidden = false
            transferGroup(false)
        }))
        
        alert.addAction(TSAlertAction(title: "group_transfer_group_exit".localized, style: TSAlertSheetActionStyle.default, handler: { _ in
            transferGroup(true)
        }))
        
        self.presentPopup(alert: alert)
    }
    
    @objc func onClickDismissTeam() {
        let alert = TSAlertController(title: nil, message: "group_confirm_dismiss".localized, style: .actionsheet, sheetCancelTitle: "cancel".localized)
        alert.addAction(TSAlertAction(title: "confirm".localized, style: TSAlertSheetActionStyle.destructive, handler: { _ in
            TeamDetailHelper.shared.dismissGroup(onDismiss: {
                self.isActionSuccess = true
                self.navigationController?.popToRootViewController(animated: true)
            })
        }))
        self.presentPopup(alert: alert)
    }
    
    @objc func onClickQuitTeam() {
        let alert = UIAlertController(title: "group_confirm_to_leave".localized, message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "confirm".localized, style: UIAlertAction.Style.default, handler: { [weak self] action in
            guard let self = self else { return }
            TeamDetailHelper.shared.quitGroup {
                DispatchQueue.main.async {
                    self.isActionSuccess = true
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "cancel".localized, style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func onClickClearDeleteTeam() {
        let alert = UIAlertController(title: "group_confirm_clear_delete".localized, message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "confirm".localized, style: UIAlertAction.Style.default, handler: { [weak self] action in
            guard let self = self else { return }
            TeamDetailHelper.shared.clearAndDelete(onDismiss: {
                DispatchQueue.main.async {
                    self.isActionSuccess = true
                    self.navigationController?.popToRootViewController(animated: true)
                }
            })
        }))
        alert.addAction(UIAlertAction(title: "cancel".localized, style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
