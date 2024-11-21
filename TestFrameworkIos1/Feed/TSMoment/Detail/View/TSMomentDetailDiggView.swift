//
//  TSMomentDetailDiggView.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/3/16.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

protocol TSMomentDetailDiggViewDelegate: class {
    func diggViewTaped(_ diggView: TSMomentDetailDiggView)
}

class TSMomentDetailDiggView: UIView {
    /// 动态 id
    let object: FeedListCellModel
    /// 头像 tag
    var avatars: [AvatarView] = []
    /// 点赞人数
    let labelForDigg = TSLabel()
    /// 点赞头像按钮 tag
    let tagForAvatarButton = 200
    /// 当前用户的点赞排行
    var diggData: [TSLikeUserModel] = []
    /// 代理
    weak var delegate: TSMomentDetailDiggViewDelegate?

    // MARK: - Lifecycle
    init(_ object: FeedListCellModel) {
        self.object = object
        super.init(frame: CGRect(x: 0, y: 0, width: 115, height: 28))
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        object = FeedListCellModel()
        super.init(coder: aDecoder)
    }

    // MARK: - Custom user interface
    private func setUI() {
        // avatar
        var avatarCount = object.toolModel?.diggCount ?? 0
        if avatarCount > 5 {
            avatarCount = 5
        }
        for index in 0..<avatarCount {
            let button = AvatarView(type: AvatarType.width26(showBorderLine: false))
            button.buttonForAvatar.isUserInteractionEnabled = false
            button.frame = CGRect(x: 16 * index, y: 0, width: 26, height: 26)
            button.tag = tagForAvatarButton + index
            addSubview(button)
            // 更新 digg label 的位置
            if index == avatarCount - 1 {
            labelForDigg.frame = CGRect(x: button.frame.origin.x, y: button.frame.size.height + 5, width: labelForDigg.frame.width, height: labelForDigg.frame.height)
            }
            avatars.append(button)
        }
        // 调整头像的层次顺序，让第一张在最上面
        avatars.reverse()
        for button in avatars {
            bringSubviewToFront( button)
        }
        avatars.reverse()
        // digg label
        labelForDigg.font = UIFont.systemFont(ofSize: TSFont.SubText.subContent.rawValue)
        labelForDigg.textColor = TSColor.main.theme
        updateDiggLabelFrame()
        addSubview(labelForDigg)
        // gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewTaped))
        addGestureRecognizer(tap)
    }

    /// 用户点击了点赞按钮
    func updateDiggView() {
        var haveCurrentUserIcon = false
        var currentUserIconIndex = -1
        let count = diggData.count > 5 ? 5 : diggData.count
        for index in 0..<count {
            let model = diggData[index]
            if model.userDetail.userIdentity == CurrentUserSessionInfo?.userIdentity {
                haveCurrentUserIcon = true
                currentUserIconIndex = index
            }
        }
        if object.toolModel?.isDigg == true && haveCurrentUserIcon { // 取消点赞
            diggData.remove(at: currentUserIconIndex)
            deleteIcon(at: currentUserIconIndex)
        } else if object.toolModel?.isDigg == false && !haveCurrentUserIcon { // 点赞
            let model = TSLikeUserModel()
            var user = UserInfoModel()
            var currentUser = CurrentUserSessionInfo!
            user.userIdentity = currentUser.userIdentity
            model.userDetail = user
            diggData.insert(model, at: 0)
            inserIcon(at: 0, storageIdentity: model.userDetail.userIdentity, avatar: currentUser.avatarUrl.orEmpty, sex: model.userDetail.sex)
        }
        updateDiggLabelFrame()
    }

    // MARK: - Button click
    @objc func viewTaped() {
        if self.avatars.isEmpty {
            return
        }
        if let delegate = delegate {
            delegate.diggViewTaped(self)
        }
    }

    /// 插入某个头像
    func inserIcon(at index: Int, storageIdentity: Int, avatar: String?, sex: Int?) {
        for avatarIndex in index..<avatars.count {
            let avatar = avatars[avatarIndex]
            avatar.tag = tagForAvatarButton + avatarIndex + 1
            avatar.frame = CGRect(x: 16 * (avatarIndex + 1), y: 0, width: 26, height: 26)
        }
        let button = AvatarView(type: AvatarType.width26(showBorderLine: false))
        button.isUserInteractionEnabled = false
        button.avatarPlaceholderType = AvatarView.PlaceholderType(sexNumber: sex)
        let avatarInfo = AvatarInfo()
        avatarInfo.avatarURL = avatar
        avatarInfo.type = .normal(userId: storageIdentity)
        button.avatarInfo = avatarInfo
        button.tag = tagForAvatarButton + index
        button.frame = CGRect(x: 16 * index, y: 0, width: 26, height: 26)
        addSubview(button)
        avatars.insert(button, at: index)
        if avatars.count > 5 {
            let avatar = avatars.last!
            avatar.removeFromSuperview()
            avatars.removeLast()
        }
    }

    /// 移除某个头像
    func deleteIcon(at index: Int) {
        guard index < avatars.count else {
            return
        }
        for avatarIndex in index..<avatars.count {
            let avatar = avatars[avatarIndex]
            if avatarIndex == index {
                avatar.removeFromSuperview()
            }
            if avatarIndex > index {
                avatar.tag = tagForAvatarButton + avatarIndex - 1
                avatar.frame = CGRect(x: 16 * (avatarIndex - 1), y: 0, width: 26, height: 26)
            }
        }
        avatars.remove(at: index)
        if diggData.count > 4 {
            inserIcon(at: 4, storageIdentity: diggData[4].userDetail.userIdentity, avatar: diggData[4].userDetail.avatarUrl,
                      sex: diggData[4].userDetail.sex)
            insertSubview(viewWithTag(tagForAvatarButton + 4)!, belowSubview: viewWithTag(tagForAvatarButton + 3)!)
        }
        updateDiggLabelFrame()
    }

    /// 更新点赞人数 label
    func updateDiggLabelFrame() {
        labelForDigg.text = object.toolModel?.diggCount.abbreviated ?? "" + "event_detail_people_like".localized
        labelForDigg.sizeToFit()
        let lastAvatar = avatars.last
        if let lastAvatar = lastAvatar {
            labelForDigg.isHidden = false
            labelForDigg.frame = CGRect(x: 0, y: lastAvatar.frame.size.height + 5, width: labelForDigg.frame.width, height: labelForDigg.frame.height)

        } else {
            labelForDigg.isHidden = true
            labelForDigg.frame = CGRect(x: 0, y: labelForDigg.frame.size.height + 5, width: labelForDigg.frame.width, height: labelForDigg.frame.height)
        }
    }

    /// 获取点赞头像信息
    func getDiggData(complete: @escaping (_ isSuccess: Bool, _ momentIsDeleted: Bool) -> Void) {
        TSMomentNetworkManager().getLikeList(feedId: object.idindex) { [weak self] (userInfos, error) in
            // [长期注释] 此处暂时无法对 "查询时,动态被删除的状态做处理",新的网络请求提供后,可以修正这个问题 2017年08月18日10:29:22
            if error != nil {
                complete(false, false)
                return
            }
            guard let userInfos = userInfos, let toolModel = self?.object.toolModel, let weakSelf = self else {
                complete(false, false)
                return
            }
            var count = toolModel.diggCount > 5 ? 5 : toolModel.diggCount
            weakSelf.diggData = userInfos
            count = min(count, userInfos.count)
            for index in 0..<count {
                let model = userInfos[index]
                if let avatarButton = weakSelf.viewWithTag(weakSelf.tagForAvatarButton + index) as? AvatarView {
                    avatarButton.avatarInfo = model.userDetail.avatarInfo()
                }
            }
            complete(true, false)
        }
    }
}
