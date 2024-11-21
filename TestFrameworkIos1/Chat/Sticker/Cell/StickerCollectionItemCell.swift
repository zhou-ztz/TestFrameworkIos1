//
//  StickerCollectionItemCell.swift
//  Yippi
//
//  Created by Yong Tze Ling on 06/12/2018.
//  Copyright © 2018 Toga Capital. All rights reserved.
//

import UIKit


class StickerCollectionItemCell: UICollectionViewCell, BaseCellProtocol {

    @IBOutlet weak var stickerIcon: UIImageView!
    @IBOutlet weak var stickerName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        stickerIcon.contentMode = .scaleAspectFit
        stickerName.applyStyle(.regular(size: 14, color: .black))
        stickerName.numberOfLines = 2
        stickerName.textAlignment = .center
    }

    func configure(_ sticker: Sticker) {
        stickerIcon.sd_setImage(with: URL(string: sticker.bundleIcon.orEmpty), completed: nil)
        stickerName.text = sticker.bundleName
    }
}
