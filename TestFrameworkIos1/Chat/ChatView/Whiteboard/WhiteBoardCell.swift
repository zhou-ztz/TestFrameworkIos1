//
//  WhiteBoardCell.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/3/1.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit

class WhiteBoardCell: UICollectionViewCell {
    
    @IBOutlet weak var headImage: UIImageView!
    
    static let cellIdentifier = "WhiteBoardCell"
    class func nib() -> UINib {
        return UINib(nibName: cellIdentifier, bundle: nil)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.headImage.contentMode = .scaleAspectFill
        self.headImage.layer.cornerRadius = self.width / 2.0
        self.headImage.layer.masksToBounds = true
    }

}
