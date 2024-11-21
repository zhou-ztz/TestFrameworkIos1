// 
// Copyright © 2018 Toga Capital. All rights reserved.
//


import UIKit
import FSPagerView


class FeaturedStickerFSPagerViewCell: FSPagerViewCell, BaseCellProtocol {

    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var bundleName: UILabel!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var stickersView: UIStackView!
    @IBOutlet weak var containerView: UIView!
    private var sticker: Sticker?
    private var showDetailHandler: ((Sticker) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        iconImageView.contentMode = .scaleAspectFit
        mainImageView.contentMode = .scaleAspectFit
        bundleName.applyStyle(.regular(size: 18, color: AppTheme.black))
        artistName.applyStyle(.regular(size: 12, color: AppTheme.lightGrey))
        containerView.backgroundColor = AppTheme.Sticker.lightBlue
        
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(showDetail))
        self.containerView.addGestureRecognizer(tapgesture)
    }

    func configure(sticker: Sticker, showDetailHandler: ((Sticker) -> Void)?) {
        self.sticker = sticker
        self.showDetailHandler = showDetailHandler
        bundleName.text = sticker.bundleName
        artistName.text = sticker.artist?.artistName
        
        let stickerCount = sticker.stickerList?.count ?? 3
        if let stickers = sticker.stickerList?.prefix(upTo: stickerCount) {
            stickersView.arrangedSubviews.enumerated().forEach { item in
                guard item.offset < stickerCount else {
                    return
                }
                (item.element as! UIImageView).sd_setImage(with: URL(string: stickers[item.offset].stickerIcon), completed: nil)
            }
        }
        
        mainImageView.sd_setImage(with: URL(string: sticker.bundleIcon.orEmpty), completed: nil)
    }
    
    @objc func showDetail() {
        if let sticker = sticker {
            showDetailHandler?(sticker)
        }
    }
}
