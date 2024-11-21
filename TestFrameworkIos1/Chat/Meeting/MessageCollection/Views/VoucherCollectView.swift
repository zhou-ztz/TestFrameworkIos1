//
//  VoucherCollectionView.swift
//  RewardsLink
//
//  Created by Kit Foong on 18/07/2024.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import Foundation
import UIKit

class VoucherCollectView: BaseCollectView {
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
        stackView.alignment = .fill
        stackView.spacing = 1
        return stackView
    }()
    
    lazy var imageView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage.set_image(named: "rectangle")
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        return image
    }()
    
    lazy var urlLabel: UILabel = {
        let url = UILabel()
        url.textColor = UIColor(hex: 0x808080)
        url.font = UIFont.systemFont(ofSize: 16)
        url.textAlignment = .left
        url.numberOfLines = 1
        return url
    }()
    
    lazy var contentLable: UILabel = {
        let name = UILabel()
        name.textColor = UIColor(hex: 0x808080)
        name.font = AppTheme.Font.semibold(12)
        name.textAlignment = .left
        name.numberOfLines = 1
        name.text = "Suria KLCC, Kuala Lumpur"
        return name
    }()
    
    lazy var desLable: UILabel = {
        let name = UILabel()
        name.textColor = UIColor(hex: 0x808080)
        name.font = UIFont.systemFont(ofSize: 9)
        name.textAlignment = .left
        name.numberOfLines = 3
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
        self.imageView.image = UIImage.set_image(named: "default_image")
        self.contentLable.text = ""
        self.desLable.text = ""
        
        self.contactAttachmentForJson(josnStr: self.collectModel.data)
        guard let model = self.dictModel else {return}
        self.nameLable.text = model.fromAccount
        
        self.avatarView.avatarInfo = NIMSDKManager.shared.getAvatarIcon(userId: model.fromAccount)
        
        if let dict = self.attchDict?[CMData] as? [String: Any] {
            if let url = dict[CMShareURL] as? String, let title = dict[CMShareTitle] as? String, let desc = dict[CMShareDescription] as? String, let image = dict[CMShareImage] as? String {
                if title != "" || desc != "" || image != "" {
                    self.updateUI(url: url, image: image ?? "", title: title ?? "", desc: desc ?? "")
                } else {
                    URLParser.parse(dict[CMShareURL] as? String ?? "", completion: { title, description, imageUrl in
                        DispatchQueue.main.async {
                            self.updateUI(url: url, image: imageUrl, title: title, desc: description)
                        }
                    })
                }
            }
        }
        
        contentView.backgroundColor = UIColor(hex: 0xF5F5F5)
        contentView.layer.cornerRadius = 5.0
        
        if model.sessionType == "Team" {
            contentStackView.addArrangedSubview(urlLabel)
            contentStackView.addArrangedSubview(contentView)
            contentView.addSubview(mainStackView)
            mainStackView.addArrangedSubview(self.imageView)
            mainStackView.addArrangedSubview(self.descStackView)
            descStackView.addArrangedSubview(self.contentLable)
            descStackView.addArrangedSubview(self.desLable)
            contentStackView.addArrangedSubview(groupView)
        } else {
            contentStackView.addArrangedSubview(urlLabel)
            contentStackView.addArrangedSubview(contentView)
            contentView.addSubview(mainStackView)
            mainStackView.addArrangedSubview(self.imageView)
            mainStackView.addArrangedSubview(self.descStackView)
            descStackView.addArrangedSubview(self.contentLable)
            descStackView.addArrangedSubview(self.desLable)
        }
        
        self.urlLabel.snp.makeConstraints { (make) in
            make.height.equalTo(25)
        }
        
        self.imageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(80)
        }
        
        self.contentStackView.snp.makeConstraints { (make) in
            make.top.left.equalTo(12)
            make.right.equalTo(-50)
            make.bottom.equalTo(-12)
        }
        
        self.mainStackView.bindToEdges()
        self.contentView.snp.makeConstraints { (make) in
            make.height.equalTo(80)
            make.right.equalTo(-12)
        }
        
        self.descStackView.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(imageView.snp.right).offset(12)
        }
        
        self.contentLable.snp.makeConstraints { (make) in
            make.height.equalTo(25)
        }
    }
    
    func updateUI(url: String, image: String, title: String, desc: String) {
        self.imageView.sd_setImage(with: URL(string: image),placeholderImage: UIImage.set_image(named: "default_image"), completed: nil)
        self.contentLable.text = title
        self.desLable.text = desc
        self.urlLabel.setUnderlinedText(text: url)
    }
}
