//
//  UnkonwCollectView.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/4/13.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit

class UnkonwCollectView: BaseCollectView {
    lazy var downloadView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var downloadImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage.set_image(named: "ic_version_update")
        return view
    }()
    
    lazy var contentLabel: UILabel = {
        let infoLbl = UILabel()
        infoLbl.textColor = AppTheme.UIColorFromRGB(red: 51, green: 51, blue: 51)
        infoLbl.text = "rw_viewholder_defcustom_unknown_msg".localized
        infoLbl.textAlignment = .left
        infoLbl.numberOfLines = 0
        infoLbl.font = UIFont(name: "PingFang-SC-Regular", size: 12)
        infoLbl.transform = CGAffineTransform(a: 1, b: 0, c: -0.2, d: 1, tx: 0, ty: 0)
        return infoLbl
    }()
    
    lazy var updateLabel: UILabel = {
        let infoLbl = UILabel()
        infoLbl.textColor = .black
        infoLbl.text = ""
        infoLbl.textAlignment = .left
        infoLbl.numberOfLines = 1
        infoLbl.setUnderlinedText(text: "rw_update_new_version".localized)
        infoLbl.setFontSize(with: 12, weight: .norm)
        return infoLbl
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
        self.moreBtn.isHidden = true
        
        if let model = self.textForJson(josnStr: self.collectModel.data) {
            nameLable.text = model.fromAccount
            self.avatarView.avatarInfo = NIMSDKManager.shared.getAvatarIcon(userId: model.fromAccount)
            type = model.sessionType
        }
        
        contentView.backgroundColor = UIColor(hex: 0xF5F5F5)
        contentView.layer.cornerRadius = 5.0
        
        let wholeStackView = UIStackView().configure { (stack) in
            stack.axis = .vertical
            stack.spacing = 8
        }
        
        if type == "Team" {
            contentStackView.addArrangedSubview(contentView)
            contentStackView.addArrangedSubview(groupView)
            contentView.addSubview(wholeStackView)
        } else {
            contentStackView.addArrangedSubview(contentView)
            contentView.addSubview(wholeStackView)
        }
        
        self.contentStackView.snp.makeConstraints { (make) in
            make.left.equalTo(12)
            make.top.equalTo(12)
            make.right.equalTo(-60)
            make.bottom.equalTo(-12)
        }
        
        self.contentView.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
        }
        
        wholeStackView.bindToEdges(inset: 10)
        
        let contentStackView = UIStackView().configure { (stack) in
            stack.axis = .horizontal
            stack.spacing = 3
            stack.alignment = .fill
        }
        
        wholeStackView.addArrangedSubview(contentLabel)
        wholeStackView.addArrangedSubview(contentStackView)
        
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        contentStackView.addArrangedSubview(downloadView)
        contentStackView.addArrangedSubview(updateLabel)
        
        downloadView.snp.makeConstraints { make in
            make.width.equalTo(18)
        }
        
        downloadView.addSubview(downloadImage)
        downloadImage.snp.makeConstraints { make in
            make.height.width.equalTo(18)
            make.center.equalToSuperview()
        }
        
        self.layoutIfNeeded()
    }
}
