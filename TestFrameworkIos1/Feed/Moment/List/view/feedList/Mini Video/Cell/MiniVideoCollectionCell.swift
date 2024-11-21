//
//  MiniVideoCollectionCell.swift
//  Yippi
//
//  Created by Yong Tze Ling on 07/09/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit

class MiniVideoCollectionCell: UICollectionViewCell {

    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var viewerLabel: UILabel!
    @IBOutlet weak var contentLabel: VerticalAlignLabel!
    @IBOutlet weak var thumbnailHolder: UIView!
    @IBOutlet weak var gradientView: UIView!
    
    static let identifier = "MiniVideoCollectionCell"
    private let gradientLayer = CAGradientLayer().configure {
        $0.colors = [UIColor.black.withAlphaComponent(0.7).cgColor, UIColor.clear.cgColor, UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.7).cgColor]
        $0.locations = [0, 0.2, 0.6, 1]
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        nameLabel.applyStyle(.regular(size: 10, color: .white))
        viewerLabel.applyStyle(.regular(size: 8, color: .white))
        contentLabel.applyStyle(.regular(size: 12, color: .black))
        contentLabel.verticalAlignment = .top
        thumbnailHolder.roundCorner(4)
        gradientLayer.frame = thumbnail.bounds
        thumbnail.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = thumbnail.layer.bounds
    }
    
    func set(model: FeedListCellModel) {
        nameLabel.text = model.userInfo?.displayName
        viewerLabel.text = model.toolModel?.viewCount.stringValue
        contentLabel.text = model.content
        
        if let url = model.pictures.first?.url {
            thumbnail.sd_setImage(with: URL(string: url), placeholderImage: UIImage.set_image(named: "rl_placeholder"), options: [.continueInBackground], completed: nil)
        }
        thumbnail.hero.id = model.idindex.stringValue
    }
}
