//
//  StickerCategoryView.swift
//  Yippi
//
//  Created by Yong Tze Ling on 22/12/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit


class StickerCategoryView: StickerSectionBaseView<StickerCategoryCell> {
    
    override var flowLayout: UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: (UIScreen.main.bounds.width - 38) / 2, height: 100)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        return layout
    }
    
    override var collectionHeight: CGFloat {
        return 230
    }
}

class StickerCategoryCell: StickerSectionBaseCell {
    
    private let image: UIImageView = UIImageView().configure {
        $0.contentMode = .scaleAspectFill
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.roundCorner(4)
        contentView.addSubview(image)
        image.bindToEdges()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setData(_ data: Sticker) {
        self.image.sd_setImage(with: URL(string: data.image.orEmpty), placeholderImage: UIImage.set_image(named: "feed_placeholder"), completed: nil)
    }
}
