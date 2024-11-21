//
//  MsgCollectionViewCell.swift
//  Yippi
//
//  Created by Wong Jin Lun on 12/06/2023.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit

class MsgCollectionViewCell: UICollectionViewCell, BaseCellProtocol {

    @IBOutlet weak var cateLabel: UILabel!
    @IBOutlet weak var cateImageView: UIImageView!
    var categoryList = [CategoryMsgModel]()
    
    override var isSelected: Bool {
        didSet {
            self.contentView.backgroundColor = isSelected ? AppTheme.red : UIColor(hex: 0xededed)
            self.cateLabel.textColor = isSelected ? .white : .lightGray
            self.cateImageView.image = self.cateImageView.image?.withRenderingMode(.alwaysTemplate)
            self.cateImageView.tintColor = isSelected ? .white : .lightGray
           
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        layer.cornerRadius = 5.0
        
    }
    
    func setData(data: CategoryMsgModel){
        if data.type == .all {
            cateImageView.isHidden = true
        } else {
            cateImageView.isHidden = false
        }
        cateLabel.text = data.name
        cateImageView.image = data.image
    }
    
}
