//
//  StickerNewArtistView.swift
//  Yippi
//
//  Created by Yong Tze Ling on 22/12/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit


class StickerNewArtistView: StickerSectionBaseView<StickerNewArtistCell> {
   
    override var flowLayout: UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width * 0.85, height: 64)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        return layout
    }

    override var collectionHeight: CGFloat {
        return 216
    }
    
}

class StickerNewArtistCell: StickerSectionBaseCell {
    
    private let avatarImage: UIImageView = UIImageView().configure {
        $0.contentMode = .scaleAspectFit
    }
    
    private let stackview: UIStackView = UIStackView().configure {
        $0.axis = .vertical
        $0.distribution = .fill
        $0.alignment = .fill
        $0.spacing = 4
    }
    
    private let nameLabel = UILabel().configure {
        $0.applyStyle(.semibold(size: 16, color: .black))
    }
    
    private let descLabel = UILabel().configure {
        $0.applyStyle(.regular(size: 12, color: .darkGray))
    }
    
    private let mainStackview: UIStackView = UIStackView().configure {
        $0.axis = .horizontal
        $0.distribution = .fillProportionally
        $0.alignment = .center
        $0.spacing = 12
    }
    
    private let nextIcon: UIButton = UIButton().configure {
        $0.setImage(UIImage.set_image(named: "ic_arrow_next"), for: .normal)
        $0.tintColor = .darkGray
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        contentView.addSubview(mainStackview)
        mainStackview.addArrangedSubview(avatarImage)
        mainStackview.addArrangedSubview(stackview)
        mainStackview.addArrangedSubview(nextIcon)
        
        mainStackview.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(6)
            $0.top.bottom.equalToSuperview()
        }
        
        avatarImage.snp.makeConstraints {
            $0.width.height.equalTo(56)
        }
        
        nextIcon.snp.makeConstraints {
            $0.width.height.equalTo(30)
        }
        
        stackview.addArrangedSubview(nameLabel)
        stackview.addArrangedSubview(descLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setData(_ data: Sticker) {
        avatarImage.sd_setImage(with: URL(string: data.icon.orEmpty), placeholderImage: UIImage.set_image(named: "icLiveAvatarPlaceholder"), completed: nil)
        nameLabel.text = data.artistName
        descLabel.text = data.description
    }
}
