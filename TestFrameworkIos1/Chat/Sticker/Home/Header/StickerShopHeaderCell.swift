//
//  StickerShopHeaderCell.swift
//  Yippi
//
//  Created by Yong Tze Ling on 05/12/2018.
//  Copyright © 2018 Toga Capital. All rights reserved.
//

import UIKit


protocol StickerShopHeaderDelegate: class {
    func showMoreStickers(section: StickerCollectionSection)
}

class StickerShopHeaderCell: UITableViewHeaderFooterView, BaseCellProtocol {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    private weak var delegate: StickerShopHeaderDelegate?
    private var homeSection: StickerCollectionSection?
    private var rankSection: StickerRankSection?
    private var paidSection: StickerPaidSection?

    @IBOutlet weak var titleLabelContainer: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        actionButton.applyStyle(.textButton(text: "sticker_see_all".localized, textColor: AppTheme.lightGrey))
        titleLabel.applyStyle(.bold(size: 14, color: .black))
    }
    
    func configure(_ section: StickerCollectionSection, delegate: StickerShopHeaderDelegate) {
        self.delegate = delegate
        self.homeSection = section
        self.actionButton.isHidden = (section.showScore && section.data.isEmpty)

        titleLabel.text = section.title
        titleLabel.applyStyle(.bold(size: 14, color: .black))
        titleLabel.textAlignment = .left
    }
    
    @IBAction func seeMoreButtonDidTapped(_ sender: Any) {
        self.delegate?.showMoreStickers(section: homeSection!)
    }
}

@IBDesignable
class customizedLabel: UILabel {
    
    @IBInspectable var inset:CGSize = CGSize(width: 0, height: 0)
    
    var padding: UIEdgeInsets {
        var hasText:Bool = false
        if let t = self.text?.count, t > 0 {
            hasText = true
        }
        else if let t = attributedText?.length, t > 0 {
            hasText = true
        }
        
        return hasText ? UIEdgeInsets(top: inset.height, left: inset.width, bottom: inset.height, right: inset.width) : UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }
    
    override var intrinsicContentSize: CGSize {
        let superContentSize = super.intrinsicContentSize
        let p = padding
        let width = superContentSize.width + p.left + p.right
        let heigth = superContentSize.height + p.top + p.bottom
        return CGSize(width: width, height: heigth)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let superSizeThatFits = super.sizeThatFits(size)
        let p = padding
        let width = superSizeThatFits.width + p.left + p.right
        let heigth = superSizeThatFits.height + p.top + p.bottom
        return CGSize(width: width, height: heigth)
    }
}
