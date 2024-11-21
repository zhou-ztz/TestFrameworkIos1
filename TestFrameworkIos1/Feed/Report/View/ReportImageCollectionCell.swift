//
//  ReportImageCollectionCell.swift
//  Yippi
//
//  Created by Ng Kit Foong on 23/09/2022.
//  Copyright © 2022 Toga Capital. All rights reserved.
//

import UIKit

protocol ReportItemTappedDelegate: class {
  func reportItemTapped(indexPath: IndexPath?)
}

class ReportImageCollectionCell: UICollectionViewCell {
    static let identifier = "cell"
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    
    weak var delegate : ReportItemTappedDelegate?
    var selectedAtIndex: IndexPath?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setData(iconName: UIImage?) {
        contentView.isUserInteractionEnabled = true
        imageView.isUserInteractionEnabled = false
        deleteButton.setTitle("", for: .normal)
        deleteButton.setImage(UIImage.set_image(named: "iconsCloseSolid"), for: .normal)
        deleteButton.imageView?.contentMode = .scaleAspectFit
        deleteButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:))))

        if iconName == nil {
            deleteButton.isHidden = true
            deleteButton.isUserInteractionEnabled = false
            imageView.addDashedBorder(TSColor.normal.minor)
            imageView.contentMode = .center
            imageView.image = UIImage.set_image(named: "add_sticker")
        } else {
            deleteButton.isHidden = false
            deleteButton.isUserInteractionEnabled = true
            imageView.layer.sublayers = nil
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.image = iconName!
        }
    }
    
    @objc func handleTap(recognizer: UITapGestureRecognizer){
        delegate?.reportItemTapped(indexPath: selectedAtIndex)
    }
}
