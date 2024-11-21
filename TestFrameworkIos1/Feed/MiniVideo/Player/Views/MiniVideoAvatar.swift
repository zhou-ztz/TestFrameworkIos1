//
//  MiniVideoAvatar.swift
//  Yippi
//
//  Created by Yong Tze Ling on 04/09/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit


class MiniVideoAvatar: UIView {

    private lazy var avatar: AvatarView = {
        let imageView = AvatarView(type: .width43(showBorderLine: false), animation: true)
        imageView.buttonForAvatar.addAction { [weak self] in
            self?.profileDidTapped?()
        }
        return imageView
    }()

    
    private lazy var followBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage.set_image(named: "IMG_channel_ico_added_wihte"), for: .normal)
        btn.isHidden = true
        btn.setBackgroundColor(TSColor.main.theme, for: .normal)
        btn.addAction { [weak self] in
            guard TSCurrentUserInfo.share.isLogin else {
                TSRootViewController.share.guestJoinLandingVC()
                return
            }
            self?.followDidTapped?()
        }
        btn.roundCorner(10)
        return btn
    }()
    
    var followDidTapped: EmptyClosure?
    var profileDidTapped: EmptyClosure?
    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = .clear
        
        self.addSubview(avatar)
        self.addSubview(followBtn)
        
        avatar.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        followBtn.snp.makeConstraints {
            $0.height.width.equalTo(22)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    func set(user: UserInfoModel) {
        let avatarInfo = AvatarInfo(userModel: user)
        avatarInfo.verifiedType = ""
        avatarInfo.verifiedIcon = ""
        avatar.avatarInfo = avatarInfo
        switch user.followStatus {
        case .eachOther, .follow, .oneself:
            followBtn.isHidden = true
        default:
            followBtn.isHidden = false
        }
    }
    
    func onFollowUser(_ status: FollowStatus) {
        followBtn.isHidden = status != .unfollow
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
