//
//  StickerCollectView.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/4/13.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit
import SDWebImage

class StickerCollectView: BaseCollectView {
    lazy var imageView: SDAnimatedImageView = {
        let image = SDAnimatedImageView()
        image.image = UIImage.set_image(named: "")
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    lazy var contentLable: UILabel = {
        let name = UILabel()
        name.textColor = UIColor(red: 0, green: 0, blue: 0)
        name.font = UIFont.systemFont(ofSize: 16)
        name.textAlignment = .left
        name.numberOfLines = 1
        name.text = "Suria KLCC, Kuala Lumpur"
        return name
    }()
    
    lazy var desLable: UILabel = {
        let name = UILabel()
        name.textColor = UIColor(red: 109, green: 114, blue: 120)
        name.font = UIFont.systemFont(ofSize: 12)
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
        self.contactAttachmentForJson(josnStr: self.collectModel.data)
        self.nameLable.text = self.dictModel?.fromAccount
        if let dict = self.attchDict?[CMData] as? [String: Any]{
            imageView.sd_setImage(with: URL(string: dict[CMStickerIconImage] as? String ?? "" ), completed: nil)
            contentLable.text = dict[CMStickerName] as? String ?? ""
            desLable.text = dict[CMStickerDiscription] as? String ?? ""
        }
    
        self.addSubview(self.imageView)
        self.imageView.snp.makeConstraints { (make) in
            make.left.equalTo(12)
            make.top.equalTo(12)
            make.height.equalTo(64)
            make.width.equalTo(64)
        }
        
        self.addSubview(self.contentLable)
        self.contentLable.snp.makeConstraints { (make) in
            make.left.equalTo(self.imageView.snp_rightMargin).offset(12)
            make.top.equalTo(22)
            make.right.equalTo(-60)
        }
        
        self.addSubview(self.desLable)
        self.desLable.snp.makeConstraints { (make) in
            make.left.equalTo(self.imageView.snp_rightMargin).offset(12)
            make.top.equalTo(51)
            make.right.equalTo(-60)
        }
    
        self.contentStackView.snp.makeConstraints { (make) in
            make.left.equalTo(12)
            make.bottom.equalTo(-12)
            make.right.equalTo(-50)
            make.top.equalTo(self.imageView.snp_bottomMargin).offset(13)
        }
    }
}
