//
//  InputLocalContainerCell.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2020/12/10.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit

class InputLocalContainerCell: UITableViewCell {
    @IBOutlet weak var localImg: UIImageView!
    @IBOutlet weak var nameLab: UILabel!
    @IBOutlet weak var contentLab: UILabel!
    @IBOutlet weak var icon: UIImageView!
    
    
    static let cellIdentifier = "InputLocalContainerCell"
    class func nib() -> UINib {
        return UINib(nibName: cellIdentifier, bundle: nil)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        localImg.image = UIImage.set_image(named: "rectangle")
        self.icon.image = UIImage.set_image(named: "ic_rl_checkbox_selected")
        self.icon.roundCorner(8) 
        self.icon.isHidden = true
    }
    public func setData(data: TSPostLocationObject?){
        nameLab.text = data?.locationName
        contentLab.text = data?.address
    }

    
}
