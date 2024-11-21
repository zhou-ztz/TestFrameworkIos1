//
//  AudioCollectView.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/4/13.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit

class AudioCollectView: BaseCollectView {
    lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 12
        return stackView
    }()
    
    lazy var imageView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage.set_image(named: "voice_play_gray")
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    lazy var contentLable: UILabel = {
        let name = UILabel()
        name.textColor = UIColor(red: 0, green: 0, blue: 0)
        name.font = UIFont.systemFont(ofSize: 14)
        name.textAlignment = .left
        name.numberOfLines = 1
        name.text = "01:20".localized
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
        self.audioAttachmentForJson(josnStr: self.collectModel.data)
     
        guard let model = self.dictModel else {return}
        self.nameLable.text = model.fromAccount
        self.avatarView.avatarInfo = NIMSDKManager.shared.getAvatarIcon(userId: model.fromAccount)
        
        var milliseconds = Float(self.audioAttachment?.dur ?? 0)
        milliseconds = milliseconds / 1000
        let currSeconds = Int(fmod(milliseconds, 60))
        let currMinute = Int(fmod((milliseconds / 60), 60))
        contentLable.text = String(format: "%d:%02d", currMinute, currSeconds)
            
        if model.sessionType == "Team" {
            self.contentStackView.addArrangedSubview(mainStackView)
            self.mainStackView.addArrangedSubview(imageView)
            self.mainStackView.addArrangedSubview(contentLable)
            self.contentStackView.addArrangedSubview(groupView)
        } else {
            self.contentStackView.addArrangedSubview(mainStackView)
            self.mainStackView.addArrangedSubview(imageView)
            self.mainStackView.addArrangedSubview(contentLable)
        }
        
        self.imageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(38)
        }
        self.addSubview(self.contentLable)
        self.contentLable.snp.makeConstraints { (make) in
            make.left.equalTo(self.imageView.snp_rightMargin).offset(20)
            make.centerY.equalTo(self.imageView)
        }
        
        self.contentStackView.snp.makeConstraints { (make) in
            make.top.left.equalTo(12)
            make.right.equalTo(-50)
            make.bottom.equalTo(-12)
        }
    }
}
