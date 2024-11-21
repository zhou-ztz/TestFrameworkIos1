//
//  TSMomentDetailNavTitle.swift
//  Yippi
//
//  Created by francis on 18/10/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation
import SnapKit


class TSMomentDetailNavTitle: UIView {
        
    let avatar: AvatarView = AvatarView(type: .width33(showBorderLine: false), animation: true)
    private var nameLabel = UILabel().configure {
        $0.setFontSize(with: 15.0, weight: .norm)
        $0.numberOfLines = 1
        $0.lineBreakMode = .byTruncatingTail
    }
    
    private var sponsorLabel = UILabel().configure {
        $0.setFontSize(with: 12.0, weight: .norm)
        $0.numberOfLines = 1
        $0.lineBreakMode = .byTruncatingTail
        $0.textColor = UIColor(hex: 0x808080)
        $0.text = "sponsored".localized
    }
    
    private let avatarAndNameStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .fill
        stack.spacing = 5
        return stack
    }()
    
    private let nameStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 0
        return stack
    }()
    
    private let mainItemsView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .fill
        stack.spacing = 5
        return stack
    }()

    var name: String {
        get {
            return nameLabel.text.orEmpty
        }
        set {
            nameLabel.text = newValue
        }
    }
    
    init() {
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(model object: UserInfoModel) {
        LocalRemarkName.getRemarkName(userId: "\(object.userIdentity)", username: nil, originalName: object.name, label: nameLabel)
        avatar.avatarPlaceholderType = AvatarView.PlaceholderType(sexNumber: object.sex)
        avatar.avatarInfo = object.avatarInfo()
        
        removeGestures()
        
        addTap { (_) in
            NotificationCenter.default.post(name: NSNotification.Name.AvatarButton.DidClick, object: nil, userInfo: ["uid": object.userIdentity])
        }
        
        layoutIfNeeded()
    }
   
    private func setupView() {
        addSubview(mainItemsView)
        avatarAndNameStackView.addArrangedSubview(avatar)
        avatarAndNameStackView.addArrangedSubview(nameStackView)
        
        nameStackView.addArrangedSubview(nameLabel)
        sponsorLabel.isHidden = true
        nameStackView.addArrangedSubview(sponsorLabel)
        
        mainItemsView.addArrangedSubview(avatarAndNameStackView)
        
        avatar.snp.makeConstraints {
            $0.height.width.equalTo(33)
        }
        mainItemsView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    func updateSponsorStatus(_ isShow: Bool) {
        if UserDefaults.sponsoredEnabled {
            sponsorLabel.isHidden = !isShow
        }
    }
}
