//
//  BannerCollectionViewCell.swift
//  Yippi
//
//  Created by Wong Jin Lun on 28/09/2023.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit
import FSPagerView

class BannerCollectionViewCell: FSPagerViewCell, BaseCellProtocol {
    @IBOutlet weak var bannerImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }
    
    func setupImage(imageUrl: String?, isShared: Bool = true) {
        if isShared {
            bannerImage.backgroundColor = .white
        }
        
        if let imageUrl = imageUrl, imageUrl.contains("localhost") == false {
            bannerImage.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage.set_image(named: isShared ? "rl_placeholder_icon" : "rl_placeholder"))
            bannerImage.contentMode = .scaleAspectFill
        } else {
            bannerImage.image = UIImage.set_image(named: isShared ? "rl_placeholder_icon" : "rl_placeholder")
            bannerImage.contentMode = .scaleAspectFit
        }
    }
}
