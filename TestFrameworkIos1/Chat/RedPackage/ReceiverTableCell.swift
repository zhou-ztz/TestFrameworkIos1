//
//  ReceiverItemView.swift
//  Yippi
//
//  Created by Francis Yeap on 5/29/19.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation
import UIKit

class ReceiverTableCell: UITableViewCell, BaseCellProtocol {
    static let cellReuseIdentifier = "ReceiverTableCell"
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var luckyStarLabel: UILabel!
    @IBOutlet weak var luckyStackView: UIStackView!

    class func nib() -> UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none
        
        // Initialization code
        nameLabel.text = ""
        noteLabel.text = ""
        amountLabel.text = ""
        currencyLabel.text = ""
        luckyStarLabel.text = ""
        
        avatarImageView.circleCorner()
        luckyStarLabel.textColor = TSColor.main.theme
        backgroundColor = .white
    }
    
    func configureData(with imagePath: String, userId:Int, name: String, date: String, amount: String, currency: String? = nil, luckyStar: Int) {
        avatarImageView.sd_setImage(with: URL(string: imagePath), placeholderImage: UIImage.set_image(named: "IMG_pic_default_secret"))
    
        LocalRemarkName.getRemarkName(userId: "\(userId)", username: nil, originalName: name, label: nameLabel)
    
        noteLabel.text = date.toDate(from: "yyyy-MM-dd'T'HH:mm:ss.ssssssZ", to: "yyyy-MM-dd HH:mm:ss")
        amountLabel.text = amount
        currencyLabel.text = currency ?? "rewards_link_point_short".localized
        luckyStarLabel.text = "viewholder_lucky_star".localized
        if luckyStar == 1 {
            luckyStackView.isHidden = false
        } else {
            luckyStackView.isHidden = true
        }
    }
}
