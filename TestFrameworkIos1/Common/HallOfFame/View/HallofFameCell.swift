//
//  HallofFameCell.swift
//  Yippi
//
//  Created by ChuenWai on 13/02/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit

import SDWebImage

class HallofFameCell: UICollectionViewCell {
    static let badgeIdentifier = "badgeCellIdentifier"

    private let iconView = UIImageView()
    private let titleLabel = UILabel()

    private var onFirstLayout = true

    override func layoutSubviews() {
        super.layoutSubviews()

        guard onFirstLayout == true else { return }

        /// Configure Badge Icon View
        iconView.clipsToBounds = true
        iconView.contentMode = .scaleAspectFit
        self.contentView.addSubview(iconView)

        /// Configure Title Label View
        titleLabel.font = UIFont.systemFont(ofSize: TSFont.Button.toolbarTop.rawValue, weight: .medium)
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.sizeToFit()
        self.contentView.addSubview(titleLabel)

        iconView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.width.height.equalTo(self.contentView.snp.width).offset(-10)
            $0.centerX.equalTo(self.contentView.snp.centerX)
        }

        titleLabel.snp.makeConstraints {
            $0.right.left.equalToSuperview()
            $0.top.equalTo(iconView.snp.bottom).offset(5)
            $0.bottom.lessThanOrEqualToSuperview()
            $0.centerX.equalTo(self.contentView.snp.centerX)
        }

        onFirstLayout = false
        layoutSubviews()
    }

    func setData(title: String, icon: String) {
        titleLabel.text = title
        guard let cacheImage = SDImageCache.shared.imageFromCache(forKey: icon)
            else {
                iconView.sd_setImage(with: URL(string: icon), placeholderImage: UIImage.set_image(named: "ic_badge_coming_soon"), options: .progressiveLoad)
                
                return
        }
        
        iconView.sd_setImage(with: URL(string: icon), placeholderImage: cacheImage, options: .progressiveLoad)

        
        
    }
}
