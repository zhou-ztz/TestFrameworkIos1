//
//  TSMomentDetailNavView.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/3/14.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import RealmSwift
import ObjectMapper

protocol TSMomentDetailNavViewDelegate: class {
    /// 返回按钮点击事件
    func navView(_ navView: TSMomentDetailNavView, didSelectedLeftButton: TSButton)
}

class TSMomentDetailNavView: UIView {
    
    /// 返回按钮
    let buttonAtLeft = TSButton(type: .custom)
    /// 关注
    let buttonAtRight = TSButton(type: .custom)
    /// 标题
    let labelForName = TSLabel(frame: .zero)
    /// 头像
    var buttonForAvatar = AvatarView(type: AvatarType.width70(showBorderLine: false))
    
    /// 数据模型
    var object: UserInfoModel
    
    /// 代理
    weak var delegate: TSMomentDetailNavViewDelegate?
    
    // MARK: - Lifecycle
    init(_ model: UserInfoModel) {
        self.object = model
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: TSNavigationBarHeight))
        addNotification()
        self.buttonForAvatar = AvatarView(type: AvatarType.width26(showBorderLine: false))
        let avatarInfo = AvatarInfo(userModel: model)
        buttonForAvatar.avatarInfo = avatarInfo
        setUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.object = UserInfoModel()
        super.init(coder: aDecoder)
        addNotification()
        setUI()
    }
    
    deinit {
        // 移除检测音乐按钮的通知
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Custom user interface
    func setUI() {
        backgroundColor = UIColor.white
        // back button
        buttonAtLeft.setImage(UIImage.set_image(named: "iconsArrowCaretleftBlack"), for: .normal)
        buttonAtLeft.addTarget(self, action: #selector(leftButtonTaped), for: .touchUpInside)
        
        // avatar
        buttonForAvatar.avatarPlaceholderType = AvatarView.PlaceholderType(sexNumber: object.sex)
        buttonForAvatar.avatarInfo = object.avatarInfo()
        // name
        labelForName.font = UIFont.systemFont(ofSize: TSFont.SubUserName.home.rawValue)
        labelForName.textColor = TSColor.normal.blackTitle
        
        // MARK: REMARK NAME
        LocalRemarkName.getRemarkName(userId: "\(object.userIdentity)", username: nil, originalName: object.name, label: labelForName)
        
        labelForName.sizeToFit()
        
        buttonAtLeft.frame = CGRect(x: 5, y:(frame.height - 44 + TSStatusBarHeight) / 2.0, width: 44, height: 44)
        buttonForAvatar.frame = CGRect(x: (UIScreen.main.bounds.width - 26 - 5 - labelForName.frame.width) / 2.0, y: frame.height - 10 - 26, width: 26, height: 26)
        buttonForAvatar.layer.cornerRadius = 13
        labelForName.frame = CGRect(x: buttonForAvatar.frame.maxX + 5, y: buttonForAvatar.frame.midY - labelForName.frame.height / 2.0, width: labelForName.frame.width, height: labelForName.frame.height)
        // line
        let line = UIView(frame: CGRect(x: 0, y: TSNavigationBarHeight - 1, width: UIScreen.main.bounds.width, height: 1))
        line.backgroundColor = TSColor.inconspicuous.disabled
        
        addSubview(buttonAtLeft)
        addSubview(buttonAtRight)
        addSubview(buttonForAvatar)
        addSubview(labelForName)
        addSubview(line)
        // 用户名点击
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelClick(_:)))
        labelForName.addGestureRecognizer(tapGesture)
        labelForName.isUserInteractionEnabled = true
        
        // 判断是否为当前用户
        let isCurrentUser = (CurrentUserSessionInfo?.userIdentity) ?? 0 == object.userIdentity
        if isCurrentUser {
            return
        }
        // follow button
        buttonAtRight.frame = CGRect(x: UIScreen.main.bounds.width - 44, y:(frame.height - 44 + TSStatusBarHeight) / 2.0, width: 44, height: 44)
        buttonAtRight.addTarget(self, action: #selector(rightButtonTaped), for: .touchUpInside)
        // 切换视图
        update(model: object)
    }
    
    @objc func labelClick(_ sender: Any) {
        buttonForAvatar.normalUserTaped()
    }
    
    // 补丁方法：更新关注按钮状态
    func update(model: UserInfoModel) {
        object = model
        guard let relationship = object.relationshipWithCurrentUser else { return }
        
        var imageName = ""
        switch relationship.status {
        case nil:
            fallthrough
        case .unfollow:
            buttonAtRight.isHidden = false
            imageName = "IMG_ico_me_follow"
        case .follow:
            buttonAtRight.isHidden = false
            imageName = "IMG_ico_me_followed"
        case .eachOther:
            buttonAtRight.isHidden = false
            imageName = "IMG_ico_me_followed_eachother"
        case .oneself:
            buttonAtRight.isHidden = true
            imageName = ""
        }
        buttonAtRight.setImage(UIImage.set_image(named: imageName), for: .normal)
    }
    
    // MARK: - Button click
    /// 点击了返回按钮
    @objc func leftButtonTaped() {
        if let delegate = delegate {
            delegate.navView(self, didSelectedLeftButton: buttonAtLeft)
        }
    }
    
    /// 点击了关注按钮
    @objc func rightButtonTaped() {
        // 切换关注状态
        object.follower = !object.follower
        guard let relationship = object.relationshipWithCurrentUser else {
            TSRootViewController.share.guestJoinLandingVC()
                     return
        }
        let followstatus: FollowStatus = object.follower == true ? .follow : .unfollow
        // 修改用户的粉丝数
        if followstatus == .follow {
            object.followersCount = object.followersCount + 1
            object.save()
        } else if followstatus == .unfollow {
            object.followersCount = object.followersCount - 1
            object.followersCount = max(0, object.followersCount)
            object.save()
        }
        // 调用关注接口
//        TSDataQueueManager.share.moment.start(follow: object.userIdentity, isFollow: object.follower)
        TSUserNetworkingManager().operateWithClosure(followstatus, userID: object.userIdentity) { (result) in
            if result == true {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newChangeFollowStatus"), object: nil, userInfo: ["follow": followstatus,"userid": "\(self.object.userIdentity)"])
            }
        }
        // 切换视图
        var imageName = ""
        switch relationship.status {
        case .unfollow:
            buttonAtRight.isHidden = false
            imageName = "IMG_ico_me_follow"
        case .follow:
            buttonAtRight.isHidden = false
            imageName = "IMG_ico_me_followed"
        case .eachOther:
            buttonAtRight.isHidden = false
            imageName = "IMG_ico_me_followed_eachother"
        case .oneself:
            buttonAtRight.isHidden = true
            imageName = ""
        }
        buttonAtRight.setImage(UIImage.set_image(named: imageName), for: .normal)
//        DatabaseUser().saveUserInfo(object)
    }
    
    /// 根据音乐按钮是否显示，更新右边按钮的位置
//    @objc func updateRightButtonFrame() {
//        let isMusicButtonShow = TSMusicPlayStatusView.shareView.isShow
//        // 判断音乐按钮是否显示
//        if isMusicButtonShow {
//            TSMusicPlayStatusView.shareView.reSetImage(white: false)
//            // 调整分享按钮的位置
//            buttonAtRight.frame = CGRect(x: UIScreen.main.bounds.width - 44 - 44, y:(frame.height + 44 - TSStatusBarHeight) / 2.0, width: 44, height: 44)
//        } else {
//            buttonAtRight.frame = CGRect(x: UIScreen.main.bounds.width - 44, y:(frame.height - 44 + TSStatusBarHeight) / 2.0, width: 44, height: 44)
//        }
//    }
    
    /// 滑动效果动画
    func scrollowAnimation(_ offset: CGFloat) {
        let topY = -frame.height + TSStatusBarHeight + 1
        let bottomY: CGFloat = 0
        let isAtTop = frame.minY == topY
        let isAtBottom = frame.minY == bottomY
        let isScrollowUp = offset > 0
        let isScrollowDown = offset < 0
        
        if (isAtTop && isScrollowUp) || (isAtBottom && isScrollowDown) {
            return
        }
        var frameY = frame.minY - offset
        if isScrollowUp && frameY < topY { // 上滑
            frameY = topY
        }
        if isScrollowDown && frameY > bottomY {
            frameY = bottomY
        }
        frame = CGRect(x: 0, y: frameY, width: frame.width, height: frame.height)
    }
    
    // MARK: - Notification
    func addNotification() {

        
    }
    @objc func refreshRemarkName () {
        LocalRemarkName.getRemarkName(userId: "\(object.userIdentity)", username: nil, originalName: object.name, label: labelForName)
        labelForName.sizeToFit()
    }
}
