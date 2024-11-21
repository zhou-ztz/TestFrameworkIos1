//
//  DiscoverUserTableViewCell.swift
//  Yippi
//
//  Created by Jerry Ng on 29/04/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit
import SnapKit

class DiscoverUserTableViewCell: UITableViewCell {
    
    static let identifier = "DiscoverUserCell"
    
    private let avatarContainerView = UIView()
    private let avatarView = AvatarView(type: .width38(showBorderLine: false))
    let relationshipButton = UIButton()
    private let labelForName = UILabel().configure {
        $0.setFontSize(with: 15, weight: .norm)
        $0.textColor = UIColor(red: 0, green: 0, blue: 0)
    }
    private let labelForIntro = UILabel().configure {
        $0.setFontSize(with: 14, weight: .norm)
        $0.textColor = UIColor(red: 157, green: 157, blue: 157)
    }
    private let bottomSeparator = UIView().configure {
        $0.backgroundColor = UIColor(red: 237, green: 237, blue: 237)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(bottomSeparator)
        
        let mainStackView = UIStackView()
        let labelStackView = UIStackView()
        
        labelStackView.axis = .vertical
        labelStackView.distribution = .fillEqually
        
        labelStackView.addArrangedSubview(labelForName)
        labelStackView.addArrangedSubview(labelForIntro)
        
        mainStackView.axis = .horizontal
        mainStackView.distribution = .fill
        mainStackView.spacing = 8
        
        avatarContainerView.addSubview(avatarView)
        
        mainStackView.addArrangedSubview(avatarContainerView)
        mainStackView.addArrangedSubview(labelStackView)
        mainStackView.addArrangedSubview(relationshipButton)
        contentView.addSubview(mainStackView)
        
        avatarContainerView.addConstraint(NSLayoutConstraint(item: avatarContainerView, attribute: .height, relatedBy: .equal, toItem: avatarContainerView, attribute: .width, multiplier: 1, constant: 0))
        relationshipButton.addConstraint(NSLayoutConstraint(item: relationshipButton, attribute: .height, relatedBy: .equal, toItem: relationshipButton, attribute: .width, multiplier: 1, constant: 0))
        mainStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.left.equalToSuperview().offset(5)
            $0.bottom.equalToSuperview().offset(-10)
            $0.right.equalToSuperview().offset(-5)
        }
        avatarView.snp.makeConstraints {
            $0.top.left.equalToSuperview().offset(8)
            $0.bottom.right.equalToSuperview().offset(-8)
        }
        bottomSeparator.snp.makeConstraints {
            $0.bottom.left.right.equalToSuperview()
            $0.height.equalTo(1)
        }
    }

    func hideBottomSeparator() {
        bottomSeparator.makeHidden()
    }
    
    func setInfo(model: UserInfoModel) {
        // 头像
        DispatchQueue.main.async {
            self.avatarView.avatarPlaceholderType = AvatarView.PlaceholderType(sexNumber: model.sex)
            self.avatarView.avatarInfo = model.avatarInfo()
            self.avatarView.setNeedsLayout()
            self.avatarView.layoutIfNeeded()
        }
        
        let notFollowingImage = UIImage.set_image(named: "icProfileNotFollowing")?.withRenderingMode(.alwaysTemplate)
        
        if model.relationshipWithCurrentUser?.texts.localizedString != nil {
            self.relationshipButton.isHidden = false
            guard let relationship = model.relationshipWithCurrentUser else {
                TSRootViewController.share.guestJoinLandingVC()
                return
            }
            switch relationship.status {
            case .follow:
                self.relationshipButton.setImage(UIImage.set_image(named: "icProfileFollowing"), for: .normal)
            case .eachOther:
                self.relationshipButton.setImage(UIImage.set_image(named: "icProfileChat"), for: .normal)
            case .unfollow:
                self.relationshipButton.setImage(notFollowingImage, for: .normal)
                self.relationshipButton.tintColor = AppTheme.red
            default: self.relationshipButton.isHidden = true
            }
        } else {
            self.relationshipButton.setImage(notFollowingImage, for: .normal)
            self.relationshipButton.tintColor = AppTheme.red
        }
        
        // MARK: REMARK NAME
        LocalRemarkName.getRemarkName(userId: "\(model.userIdentity)", username: nil, originalName: model.name, label: labelForName)
        // 简介
        labelForIntro.text = model.shortDesc
        
        if model.isBannedUser {
            labelForName.text = String(format: "user_deleted_displayname".localized, model.name)
            enable(on: false)
        }  else{
            enable(on: true)
        }
    }
    
    func enable(on: Bool) {
        for view in self.subviews {
            view.isUserInteractionEnabled = on
            view.alpha = on ? 1 : 0.5
        }
        self.relationshipButton.isHidden = !on
    }
}
