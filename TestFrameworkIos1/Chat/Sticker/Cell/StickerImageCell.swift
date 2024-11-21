//
//  StickerImageCell.swift
//  Yippi
//
//  Created by Yong Tze Ling on 06/12/2018.
//  Copyright © 2018 Toga Capital. All rights reserved.
//

import UIKit
import SDWebImage

class StickerImageCell: UICollectionViewCell, BaseCellProtocol {

    @IBOutlet weak var iconImageView: SDAnimatedImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
    }
    
    func configure(_ url: String) {
        iconImageView.sd_imageIndicator?.startAnimatingIndicator()
        iconImageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage.set_image(named: "rl_placeholder")) { (_, _, _, _) in
            self.iconImageView.sd_imageIndicator?.stopAnimatingIndicator()
        }
        iconImageView.shouldCustomLoopCount = true
        iconImageView.animationRepeatCount = 0
    }
    
}
