//
//  TSChooseViewCell.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2020/12/3.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit

class TSChooseViewCell: UITableViewCell {

    public static let cellIdentifier = "TSChooseViewCell"
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var titleLab: UILabel!
    @IBOutlet weak var redLab: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        icon.contentMode = .scaleAspectFit
        titleLab.textColor = .white
        titleLab.numberOfLines = 2
        redLab.backgroundColor = .red
        redLab.roundCorner(3.5)
        redLab.isHidden = true
        self.layoutIfNeeded()
        redLab.snp.makeConstraints { make in
            make.width.height.equalTo(7)
            make.top.equalTo(self.icon.snp_topMargin).offset(-7)
            make.left.equalTo(self.icon.snp_rightMargin).offset(3.5)
        }
    }

   
    
}
