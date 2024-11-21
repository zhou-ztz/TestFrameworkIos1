//
//  MedalRankCell.swift
//  Yippi
//
//  Created by Khoo on 04/06/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//
//

import UIKit

import SDWebImage

class MedalRankCell: UICollectionViewCell {
    static let identifier = "medalCellIdentifier"

    private let iconView = UIImageView()

    private var onFirstLayout = true

    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.contentView.addSubview(iconView)
        
        iconView.contentMode = .scaleAspectFit

        iconView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func loadMedal (icon: String) {
        iconView.sd_setImage(with: URL(string: icon), placeholderImage: UIImage.set_image(named: "ic_badge_coming_soon"), options: .progressiveLoad)
    }
    
    func makeArrow () {
        iconView.image = UIImage.set_image(named: "ic_squareNext")
    }
}
