//
//  StickerRecommendView.swift
//  Yippi
//
//  Created by Yong Tze Ling on 22/12/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit


class StickerRecommendView: StickerSectionBaseView<StickerRecommendCell> {

    override var flowLayout: UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width * 0.85 , height: 200)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
        return layout
    }
    
    override var collectionHeight: CGFloat {
        return 230
    }
}

class StickerRecommendCell: StickerSectionBaseCell {
    
    private let coverImage: UIImageView = UIImageView().configure {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    private let stackview: UIStackView = UIStackView().configure {
        $0.axis = .vertical
        $0.distribution = .fillProportionally
        $0.alignment = .leading
        $0.spacing = 4
    }
    
    private let avatar = UIImageView().configure {
        $0.contentMode = .scaleAspectFit
        $0.roundCorner(32)
        $0.applyBorder(color: AppTheme.softBlue, width: 2)
    }
    
    private let nameLabel = UILabel().configure {
        $0.applyStyle(.semibold(size: 16, color: .black))
    }
    
    private let descLabel = UILabel().configure {
        $0.applyStyle(.regular(size: 12, color: .darkGray))
    }
    
    private let container = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        contentView.addSubview(container)
        container.bindToEdges()
        container.clipsToBounds = true
        container.roundCorner(6)
//        container.clipsToBounds = true
        
        container.addSubview(coverImage)
        container.addSubview(avatar)
        container.addSubview(stackview)
        
        stackview.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(26)
            $0.bottom.equalToSuperview().inset(12)
            $0.top.equalTo(avatar.snp.bottom).offset(8)
        }
        coverImage.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.5)
        }
        avatar.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(64)
            $0.leading.equalToSuperview().inset(26)
        }
        stackview.addArrangedSubview(nameLabel)
        stackview.addArrangedSubview(descLabel)
        
        contentView.dropShadow(shadowColor: .black, opacity: 0.17, height: 5, shadowRadius: 7)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setData(_ data: Sticker) {
        avatar.sd_setImage(with: URL(string: data.icon.orEmpty), placeholderImage: UIImage.set_image(named: "IMG_pic_default_secret"), completed: nil)
        coverImage.sd_setImage(with: URL(string: data.banner.orEmpty), placeholderImage: UIImage.set_image(named: "feed_placeholder"), completed: nil)
        nameLabel.text = data.artistName
        descLabel.text = String(format: "text_total_sticker_set".localized, data.stickerSet.orZero.stringValue)
    }
}
