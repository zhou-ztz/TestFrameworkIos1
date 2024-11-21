//
//  TopicCollectionCell.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/7/23.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit
import SDWebImage

class TopicCollectionCell: UICollectionViewCell {

    let itemHeit: CGFloat = 180
    let itemLeftAndRightSpacing: CGFloat = 15
    static let identifier = "topicCell"
    var titleLabel: UILabel!
    var imageBg: FadeImageView!
    var imageShadow: FadeImageView!
    var followButton: UIButton!

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {
        imageBg = FadeImageView(frame: CGRect(x: itemLeftAndRightSpacing, y: 15, width: ScreenWidth - 2 * itemLeftAndRightSpacing, height: itemHeit))
        imageBg.layer.cornerRadius = CGFloat(6)
        imageBg.contentMode = UIView.ContentMode.scaleAspectFill
        imageBg.clipsToBounds = true
        imageShadow = FadeImageView(frame: CGRect(x: itemLeftAndRightSpacing, y:  15, width: ScreenWidth - 2 * itemLeftAndRightSpacing, height: itemHeit))
        imageShadow.layer.cornerRadius = CGFloat(6)
        imageShadow.backgroundColor = UIColor.black
        imageShadow.alpha = 0.2
        titleLabel = UILabel(frame: CGRect(x: 0, y: itemHeit/2, width: ScreenWidth - 3 * itemLeftAndRightSpacing, height: 18))
        titleLabel.font = UIFont(name: "PingFangSC-Medium", size: 18)
        titleLabel.textAlignment = .center
        titleLabel.centerX = imageBg.centerX
//        titleLabel.centerY = imageBg.centerY
        titleLabel.textColor = UIColor.white
        titleLabel.numberOfLines = 0
        /// 设置阴影颜色
        titleLabel.shadowColor = UIColor.black
        ///设置阴影大小
        titleLabel.shadowOffset = CGSize(width: 0.4, height: 0.4)
        followButton = UIButton(frame: CGRect(x: 0, y: titleLabel.bottom + 20, width: 73, height: 25))
        followButton.clipsToBounds = true
        followButton.layer.cornerRadius = 25 / 2.0
        followButton.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        followButton.titleLabel?.font = UIFont(name: "PingFangSC-Medium", size: 13)
        followButton.setTitleColor(UIColor.white, for: .normal)
        followButton.setTitle("add_follow".localized, for: .normal)
        followButton.centerX = titleLabel.centerX
        followButton.isHidden = true
        self.addSubview(imageBg)
        self.addSubview(imageShadow)
        self.addSubview(titleLabel)
        self.addSubview(followButton)
    }

    func setInfo(model: TopicListModel, index: IndexPath) {
        titleLabel.text = model.topicTitle
        imageBg.sd_setImage(with: URL(string: TSUtil.praseTSNetFileUrl(netFile: model.topicLogo).orEmpty),
                            placeholderImage: UIImage.set_image(named: "pic_cover"))
        followButton.setTitle(model.topicFollow ? "followed".localized : "add_follow".localized, for: .normal)
    }
}
