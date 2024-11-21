//
//  FileCollectView.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/4/13.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit


class FileCollectView: BaseCollectView {
    lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 12
        return stackView
    }()
    
    lazy var descStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 1
        return stackView
    }()
    
    lazy var imageView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage.set_image(named: "icUnknownL")
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    lazy var contentLable: UILabel = {
        let name = UILabel()
        name.textColor = UIColor(red: 0, green: 0, blue: 0)
        name.font = UIFont.systemFont(ofSize: 14)
        name.textAlignment = .left
        name.numberOfLines = 1
        name.text = "holiday-guide-2019.zip".localized
        return name
    }()
    
    lazy var desLable: UILabel = {
        let name = UILabel()
        name.textColor = UIColor(red: 109, green: 114, blue: 120)
        name.font = UIFont.systemFont(ofSize: 10)
        name.textAlignment = .left
        name.numberOfLines = 1
        name.text = "567kb"
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
        self.fileAttachmentForJson(josnStr: self.collectModel.data)
        guard let model = self.dictModel else {return}
        self.nameLable.text = model.fromAccount
        self.avatarView.avatarInfo = NIMSDKManager.shared.getAvatarIcon(userId: model.fromAccount)
        
        imageView.image = SendFileManager.fileIcon(with:self.fileAttachment?.ext ?? "docx").icon
        self.contentLable.text = self.fileAttachment?.name ?? ""
        
        let size: Int64 = (self.fileAttachment?.size ?? 0) / 1024
        self.desLable.text = String(format: "%lldKB", size)
        
        if model.sessionType == "Team" {
            contentStackView.addArrangedSubview(mainStackView)
            mainStackView.addArrangedSubview(self.imageView)
            mainStackView.addArrangedSubview(self.descStackView)
            descStackView.addArrangedSubview(self.contentLable)
            descStackView.addArrangedSubview(self.desLable)
            contentStackView.addArrangedSubview(groupView)
        } else {
            contentStackView.addArrangedSubview(mainStackView)
            mainStackView.addArrangedSubview(self.imageView)
            mainStackView.addArrangedSubview(self.descStackView)
            descStackView.addArrangedSubview(self.contentLable)
            descStackView.addArrangedSubview(self.desLable)
        }
       
        self.contentStackView.snp.makeConstraints { (make) in
            make.top.left.equalTo(12)
            make.right.equalTo(-50)
            make.bottom.equalTo(-12)
        }
        
        self.imageView.snp.makeConstraints { (make) in
            make.width.equalTo(31)
            make.height.equalTo(38)
        }
    }
}
