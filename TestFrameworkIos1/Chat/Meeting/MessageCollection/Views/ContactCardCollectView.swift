//
//  ContactCardCollectView.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/4/13.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit


class ContactCardCollectView: BaseCollectView {
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 16
        return stackView
    }()
    
    lazy var imageView: AvatarView = {
        let view = AvatarView(type: .width43(showBorderLine: false))
        view.avatarPlaceholderType = .unknown
        return view
    }()
    
    lazy var contentLable: UILabel = {
        let name = UILabel()
        name.textColor = UIColor(red: 0, green: 0, blue: 0)
        name.font = UIFont.boldSystemFont(ofSize: 15)
        name.textAlignment = .left
        name.numberOfLines = 1
        name.text = "Suria KLCC, Kuala Lumpur"
        return name
    }()

    override init(collectModel: FavoriteMsgModel, indexPath: IndexPath) {
        super.init(collectModel: collectModel, indexPath: indexPath)
        self.commitUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commitUI() {
        self.contactAttachmentForJson(josnStr: self.collectModel.data)
        if let dict = self.attchDict?[CMData] as? [String: String], let memberId = dict[CMContactCard] {
            
            guard let model = self.dictModel else {return}
            self.nameLable.text = model.fromAccount
            // self.contentLable.text = self.locationAttachment?.title ?? ""
            
            self.avatarView.avatarInfo = NIMSDKManager.shared.getAvatarIcon(userId: model.fromAccount)
            
            let contactAvatarinfo = NIMSDKManager.shared.getAvatarIcon(userId: memberId)
            imageView.avatarInfo = contactAvatarinfo
                        
            LocalRemarkName.getRemarkName(userId: nil, username: NIMSDKManager.shared.getNimKitInfo(userId: memberId), originalName: contactAvatarinfo.nickname ?? memberId, label: self.contentLable)
            
            if contactAvatarinfo.nickname == nil {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                    self.showHeaderImage(memberId: memberId)
                }
            }
            
            if model.sessionType == "Team" {
                self.contentStackView.addArrangedSubview(stackView)
                self.stackView.addArrangedSubview(imageView)
                self.stackView.addArrangedSubview(contentLable)
                self.contentStackView.addArrangedSubview(groupView)
            } else {
                self.contentStackView.addArrangedSubview(stackView)
                self.stackView.addArrangedSubview(imageView)
                self.stackView.addArrangedSubview(contentLable)
            }
            
            self.stackView.snp.makeConstraints { (make) in
                make.height.equalTo(43)
            }
            
            self.contentLable.snp.makeConstraints { (make) in
                make.height.equalTo(25)
            }
            
            self.contentStackView.snp.makeConstraints { (make) in
                make.top.left.equalTo(12)
                make.bottom.equalTo(-12)
                make.right.equalTo(-50)
            }
        }
    }
    
    // TODO: 头像及名字不显示问题临时解决方法 ，多调用一次
    func showHeaderImage(memberId: String) {
        let avatarInfo = NIMSDKManager.shared.getAvatarIcon(userId: memberId)
        imageView.avatarInfo = avatarInfo
                    
        LocalRemarkName.getRemarkName(userId: nil, username: NIMSDKManager.shared.getNimKitInfo(userId: memberId), originalName: avatarInfo.nickname ?? memberId, label: self.contentLable)
    }
}
