//
//  ChatSettingMemberCell.swift
//  Yippi
//
//  Created by Yong Tze Ling on 02/05/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import UIKit


class ChatSettingMemberCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    static let cellIdentifier = "ChatSettingMemberCell"
    
    class func nib() -> UINib {
        return UINib(nibName: cellIdentifier, bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        collectionView.register(ChatMemberCell.nib(), forCellWithReuseIdentifier: ChatMemberCell.cellIdentifier)
        collectionView.isScrollEnabled = false
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        collectionView.layoutIfNeeded()

        let topConstraintConstant = contentView.constraint(byIdentifier: "topAnchor")?.constant ?? 0
        let bottomConstraintConstant = contentView.constraint(byIdentifier: "bottomAnchor")?.constant ?? 0
        let trailingConstraintConstant = contentView.constraint(byIdentifier: "trailingAnchor")?.constant ?? 0
        let leadingConstraintConstant = contentView.constraint(byIdentifier: "leadingAnchor")?.constant ?? 0
        
        collectionView.frame = CGRect(x: 0, y: 0, width: targetSize.width - trailingConstraintConstant - leadingConstraintConstant, height: 1)
        
        let size = collectionView.collectionViewLayout.collectionViewContentSize
        let newSize = CGSize(width: size.width, height: size.height + topConstraintConstant + bottomConstraintConstant)
        return newSize
    }
}

extension UIView {
    func constraint(byIdentifier identifier: String) -> NSLayoutConstraint? {
        return constraints.first(where: { $0.identifier == identifier })
    }
}
