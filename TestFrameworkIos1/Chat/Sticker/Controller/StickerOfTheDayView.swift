//
//  StickerOfTheDayView.swift
//  Yippi
//
//  Created by Yong Tze Ling on 22/12/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit


class StickerOfTheDayView: UIView {

    private let header = StickerMainSectionView()
    
    private let sotdView = StickerTopRankView()
    
    weak var delegate: StickerMainDelegate?
    
    private let stackview = UIStackView().configure {
        $0.axis = .vertical
        $0.distribution = .fillProportionally
        $0.alignment = .fill
        $0.spacing = 0
    }
    
    init() {
        super.init(frame: .zero)
        
        self.backgroundColor = .white
        
        self.addSubview(stackview)
        stackview.bindToEdges()
        
        stackview.addArrangedSubview(header)
        stackview.addArrangedSubview(sotdView)
        
        header.snp.makeConstraints {
            $0.height.equalTo(50)
        }
        
        sotdView.snp.makeConstraints {
            $0.height.equalTo(140)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func set(_ section: StickerCollectionSection?) {
        guard let section = section, section.data.count > 0 else {
            self.makeHidden()
            return
        }
        
        header.setTitle(section.title)
        self.makeVisible()
        
        sotdView.setData(section.data)
        
        sotdView.onTapItem = { [weak self] sticker in
            self?.delegate?.stickerResultDidTapped(sticker: sticker)
        }
        
        sotdView.onTapAvatar = { [weak self] sticker in
            self?.delegate?.stickerDidTapped(sticker: sticker)
        }
        
        header.seeAllButton.addAction { [weak self] in
            self?.delegate?.seeMoreButtonTapped(section: section)
        }
    }
}

class StickerTopRankItemView: RankingFirstThreeView {

    override var rankType: RankType { return .sticker }
    
    func updateSticker(_ model: Sticker?) {
        
        if let model = model {
            nameLabel.text = model.bundleName
            resultLabel.text = model.todayStats?.totalPoints.abbStartFrom5Digit
            pkIcon.image = UIImage.set_image(named: "icStickerPoint")
            emptyLabel.makeHidden()
            let avatarInfo = AvatarInfo()
            avatarInfo.avatarURL = model.bundleIcon.orEmpty
            avatarView.avatarInfo = avatarInfo
            avatarView.customAvatarPlaceholderImage = UIImage.set_image(named: "ic_profile")
        } else {
            emptyModel()
        }
    }
}

class StickerTopRankView: UIView {
    
    private var wrapper = UIStackView().configure {
        $0.backgroundColor = .clear
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.alignment = .leading
        $0.spacing = 6
    }
    
    private var firstView = StickerTopRankItemView(liveStarPlace: .first).configure {
        $0.backgroundColor = .clear
        $0.emptyModel()
    }
    
    private var secondView = StickerTopRankItemView(liveStarPlace: .second).configure {
        $0.backgroundColor = .clear
        $0.emptyModel()
    }
    
    private var thirdView = StickerTopRankItemView(liveStarPlace: .third).configure {
        $0.backgroundColor = .clear
        $0.emptyModel()
    }
    
    var onTapItem: ((Sticker) -> Void)?
    var onTapAvatar: ((Sticker) -> Void)?
    
    init() {
        super.init(frame: .zero)
        
        self.addSubview(wrapper)
        wrapper.addArrangedSubview(secondView)
        wrapper.addArrangedSubview(firstView)
        wrapper.addArrangedSubview(thirdView)
        
        firstView.snp.makeConstraints {
            $0.height.equalTo(sizeItemToFit(view: firstView).height)
            $0.width.equalTo(sizeItemToFit(view: firstView).width)
        }
        secondView.snp.makeConstraints {
            $0.height.equalTo(sizeItemToFit(view: secondView).height)
            $0.width.equalTo(sizeItemToFit(view: secondView).width)
        }
        thirdView.snp.makeConstraints {
            $0.height.equalTo(sizeItemToFit(view: thirdView).height)
            $0.width.equalTo(sizeItemToFit(view: thirdView).width)
        }
        wrapper.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func sizeItemToFit(view: UIView?) -> CGSize {
        guard let view = view else {
            return CGSize.zero
        }
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        let size = CGSize(width: view.bounds.width, height: view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height)
        
        return size
    }
    
    func setData(_ stickers: [Sticker]) {
        let views = [firstView, secondView, thirdView]
        stickers.enumerated().forEach { v in
            guard v.offset < views.count else {
                return
            }
            let view = views[v.offset]
            view.updateSticker(v.element)
            view.avatarView.buttonForAvatar.addAction { [weak self] in
                self?.onTapAvatar?(v.element)
            }
            view.addAction { [weak self] in
                self?.onTapItem?(v.element)
            }
        }
    }
}
