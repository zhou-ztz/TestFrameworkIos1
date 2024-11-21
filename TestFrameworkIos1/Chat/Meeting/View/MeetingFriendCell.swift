//
//  MeetingFriendCell.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2023/3/3.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit


protocol MeetingFriendtCellDelegate: class {
    func deleteButtonClick(model: ContactData)
}

class MeetingFriendCell: UICollectionViewCell, BaseCellProtocol {
    weak var delegate: MeetingFriendtCellDelegate?
    var avatarImageView: AvatarView!
    var model: ContactData!
    private let titleLabel = UILabel().configure {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textAlignment = .center
        $0.textColor = UIColor(hex: "#212121")
    }
    
    
    let delete = UIButton().configure {
        $0.setImage(UIImage.set_image(named: "iconsCloseSolid"), for: .normal)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        avatarImageView = AvatarView(type: .width48(showBorderLine: false), animation: false)
        self.addSubview(avatarImageView)
        avatarImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.width.equalTo(48)
            make.top.equalTo(0)
        }
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(avatarImageView.snp_bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
        }
        
        self.addSubview(delete)
        delete.snp.makeConstraints {
            $0.top.right.equalTo(0)
            $0.height.width.equalTo(18)
        }
        delete.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
    }
    
    func setData(model: ContactData){
        self.model = model
        let avatarInfo = AvatarInfo()
        avatarInfo.avatarURL = model.imageUrl
        avatarInfo.verifiedIcon = model.verifiedIcon
        avatarInfo.verifiedType = model.verifiedType
        avatarInfo.avatarPlaceholderType = model.isTeam ? .group : .unknown
        avatarInfo.type = .normal(userId: model.userId)
        avatarImageView.avatarPlaceholderType = model.isTeam ? .group : .unknown
        avatarImageView.avatarInfo = avatarInfo
        if model.isTeam {
            titleLabel.text = model.displayname
        }else {
            // MARK: REMARK NAME
            if model.userId == -1 {
                LocalRemarkName.getRemarkName(userId: nil, username: model.userName, originalName: model.displayname, label: titleLabel)
            } else {
                LocalRemarkName.getRemarkName(userId: String(model.userId), username: nil, originalName: model.displayname, label: titleLabel)
            }
        }
    }
    
    @objc func deleteAction(){
        self.delegate?.deleteButtonClick(model: model)
    }
    
}

