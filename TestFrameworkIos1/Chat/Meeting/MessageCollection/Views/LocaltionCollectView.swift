//
//  LocaltionCollectView.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/4/13.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit


class LocaltionCollectView: BaseCollectView {
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        return stackView
    }()
    
    lazy var descStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        return stackView
    }()
    
    lazy var imageView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage.set_image(named: "rectangle")
       // image.contentMode = .scaleAspectFill
        return image
    }()
    
    lazy var contentLable: UILabel = {
        let name = UILabel()
        name.textColor = UIColor(red: 0, green: 0, blue: 0)
        name.font = UIFont.systemFont(ofSize: 14)
        name.textAlignment = .left
        name.numberOfLines = 2
        name.text = "Suria KLCC, Kuala Lumpur"
        return name
    }()
    
    lazy var dateTimeLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.regular(9)
        label.textColor = UIColor(hexString: "#808080")
        label.text = "00:00"
        return label
    }()
    
    lazy var tickImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.set_image(named: "readTick")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var timeTickStackView: UIStackView = {
        let stackView = UIStackView().configure { (stack) in
            stack.axis = .horizontal
            stack.spacing = 5
            stack.distribution = .fill
            stack.alignment = .bottom
        }
        return stackView
    }()
    
    lazy var desLable: UILabel = {
        let name = UILabel()
        name.textColor = UIColor(red: 74, green: 74, blue: 74)
        name.font = UIFont.systemFont(ofSize: 10)
        name.textAlignment = .left
        name.numberOfLines = 1
        name.text = "Kuala Lumpur"
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
        self.locationAttachmentForJson(josnStr: self.collectModel.data)
        guard let model = self.dictModel else {return}
        self.nameLable.text = model.fromAccount
        self.contentLable.text = self.locationAttachment?.title ?? ""
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm a"
        let dataString = formatter.string(from: NSDate(timeIntervalSince1970: self.collectModel.updateTime) as Date)
        self.dateTimeLabel.text = dataString
        self.avatarView.avatarInfo = NIMSDKManager.shared.getAvatarIcon(userId: model.fromAccount)
        
        contentView.backgroundColor = UIColor(hex: 0x99E0FF)
        contentView.layer.cornerRadius = 8.0
        
        if model.sessionType == "Team" {
            self.contentStackView.addArrangedSubview(contentView)
            self.contentView.addSubview(stackView)
            self.stackView.addArrangedSubview(imageView)
            self.stackView.addArrangedSubview(descStackView)
            self.descStackView.addArrangedSubview(contentLable)
            self.descStackView.addArrangedSubview(timeTickStackView)
            self.timeTickStackView.addArrangedSubview(dateTimeLabel)
            self.timeTickStackView.addArrangedSubview(tickImage)
            self.contentStackView.addArrangedSubview(groupView)
        } else {
            self.contentStackView.addArrangedSubview(contentView)
            self.contentView.addSubview(stackView)
            self.stackView.addArrangedSubview(imageView)
            self.stackView.addArrangedSubview(descStackView)
            self.descStackView.addArrangedSubview(contentLable)
            self.descStackView.addArrangedSubview(timeTickStackView)
            self.timeTickStackView.addArrangedSubview(dateTimeLabel)
            self.timeTickStackView.addArrangedSubview(tickImage)
        }
        
        self.stackView.bindToEdges(inset: 8)
        self.contentView.snp.makeConstraints { (make) in
            make.height.equalTo(170)
            make.right.equalTo(-50)
        }
        
        self.imageView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
        }
        
        self.descStackView.snp.makeConstraints { (make) in
            make.height.equalTo(40)
        }
        
        self.tickImage.snp.makeConstraints { make in
            make.width.height.equalTo(15)
        }
        
        self.timeTickStackView.snp.makeConstraints { (make) in
            make.width.equalTo(65)
        }
       
        self.contentStackView.snp.makeConstraints { (make) in
            make.top.left.equalTo(12)
            make.right.equalTo(-10)
            make.bottom.equalTo(-12)
        }
    }    
}
