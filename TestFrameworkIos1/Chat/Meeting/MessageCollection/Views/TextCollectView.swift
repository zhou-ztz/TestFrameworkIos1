//
//  TextCollectView.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/4/13.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit


class TextCollectView: BaseCollectView {
    lazy var contentLable: UILabel = {
        let name = UILabel()
        name.textColor = UIColor(red: 0, green: 0, blue: 0)
        name.font = UIFont.systemFont(ofSize: 16)
        name.textAlignment = .left
        name.numberOfLines = 3
        name.text = "想做你的太阳🌞，你的太阳🌞，在你的心里呀"
        return name
    }()
    
    var type: String? = ""
    
    override init(collectModel: FavoriteMsgModel, indexPath: IndexPath) {
        super.init(collectModel: collectModel, indexPath: indexPath)
        self.commitUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commitUI() {
        if let model = self.textForJson(josnStr: self.collectModel.data) {
            self.contentLable.text = model.content
            self.nameLable.text = model.fromAccount
            self.avatarView.avatarInfo = NIMSDKManager.shared.getAvatarIcon(userId: model.fromAccount)
            type = model.sessionType
        }
        
        contentView.backgroundColor = UIColor(hex: 0xF5F5F5)
        contentView.layer.cornerRadius = 5.0
      
        if type == "Team" {
            contentStackView.addArrangedSubview(self.contentView)
            self.contentView.addSubview(self.contentLable)
            contentStackView.addArrangedSubview(self.groupView)
        } else {
            contentStackView.addArrangedSubview(self.contentView)
            self.contentView.addSubview(self.contentLable)
        }
        
        self.contentStackView.snp.makeConstraints { (make) in
            make.left.equalTo(12)
            make.top.equalTo(12)
            make.right.equalTo(-60)
            make.bottom.equalTo(-12)
        }
        
        self.contentLable.snp.makeConstraints { (make) in
            make.left.bottom.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-15)
            make.top.equalToSuperview().offset(-10)
        }
        
        self.contentView.snp.makeConstraints { (make) in
            make.height.equalTo(75)
            make.right.equalToSuperview()
        }
    }
}
