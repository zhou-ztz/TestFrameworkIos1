//
//  RedPacketBottomSheetCell.swift
//  Yippi
//
//  Created by Wong Jin Lun on 19/04/2023.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit

class RedPacketBottomSheetCell: UITableViewCell {

    static let cellIdentifier = "RedPacketBottomSheetCell"
    
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var redPacketModeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        lineView.backgroundColor = UIColor(hex: 0xF5F5F5)
        redPacketModeLabel.font = AppTheme.Font.semibold(16)
    }
    
    func configure(title: String) {
        redPacketModeLabel?.text = title
    }
    
}
