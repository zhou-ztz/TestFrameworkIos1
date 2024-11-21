//
//  InputNearLocalContainerCell.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2020/12/15.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit

class InputNearLocalContainerCell: UITableViewCell {

    @IBOutlet weak var titleLab: UILabel!
    @IBOutlet weak var contentLab: UILabel!
    @IBOutlet weak var icon: UIImageView!
    
    static let cellIdentifier = "InputNearLocalContainerCell"
    class func nib() -> UINib {
        return UINib(nibName: cellIdentifier, bundle: nil)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.icon.image = UIImage.set_image(named: "ic_rl_checkbox_selected")
        self.icon.roundCorner(8)
        self.icon.isHidden = true
    }

    public func setData(data: TSPostLocationObject?){
        titleLab.text = data?.locationName
        contentLab.text = data?.address
    }
    
    
}
