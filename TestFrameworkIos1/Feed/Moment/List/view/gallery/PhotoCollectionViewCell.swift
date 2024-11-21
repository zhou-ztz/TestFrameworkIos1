//
//  PhotoCollectionViewCell.swift
//  SquareFlowLayout
//
//  Created by Taras Chernyshenko on 11/11/18.
//  Copyright © 2018 Taras Chernyshenko. All rights reserved.
//

import UIKit
import Hero


final class PhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: FadeImageView!
    @IBOutlet weak var playPlaceholderImageView: UIImageView!
    
    private lazy var pinnedIcon: UIImageView = UIImageView(image: UIImage.set_image(named: "icGalleryPinned"))
    private lazy var pinnedLabel: UILabel = UILabel(frame: .zero).configure {
        $0.text = "live_tab_filter_pinned".localized
        $0.font = AppFonts.Tag.medium10.font
        $0.textColor = .white
    }
    
    private(set) var transitionId = UUID().uuidString
    
    public var pinnedIconContainner: UIView = UIView().configure {
        $0.backgroundColor = .black.withAlphaComponent(0.5)
    }
    public lazy var typeIconView: UIView = UIView().configure {
        $0.backgroundColor = .clear
    }
    public lazy var typeIcon: UIImageView = UIImageView(frame: .zero).configure {
        $0.contentMode = .scaleAspectFit
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        pinnedIconContainner.isHidden = true
        typeIcon.isHidden = true
        typeIcon.image = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        pinnedIconContainner.roundCorner(5)
    }
    
    private func setupUI() {
        pinnedIconContainner.addSubview(pinnedIcon)
        pinnedIconContainner.addSubview(pinnedLabel)
        contentView.addSubview(pinnedIconContainner)
        contentView.addSubview(typeIcon)
        
        pinnedIconContainner.isHidden = true
        typeIcon.isHidden = true
        
        pinnedIcon.snp.makeConstraints {
            $0.width.height.equalTo(15)
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview().inset(8)
        }
        
        pinnedLabel.snp.makeConstraints {
            $0.left.equalTo(pinnedIcon.snp.right).offset(6)
            $0.top.bottom.equalToSuperview().inset(5)
            $0.right.equalToSuperview().inset(8)
        }
        
        pinnedIconContainner.snp.makeConstraints {
            $0.top.left.equalToSuperview().inset(8)
        }
        
        typeIcon.snp.makeConstraints {
            $0.width.height.equalTo(25)
            $0.centerY.equalTo(pinnedIconContainner.snp.centerY)
            $0.right.equalToSuperview()
        }
    }
}
