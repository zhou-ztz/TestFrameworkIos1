//
//  CreateGroupTableViewCell.swift
//  Yippi
//
//  Created by Liew Chuen Wai on 12/07/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import UIKit


class CreateGroupTableViewCell: UITableViewCell {

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        avatar.circleCorner()
        avatar.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(name: String, username: String, avatarUrl: String) {
        LocalRemarkName.getRemarkName(userId: nil, username: username, originalName: name, label: self.name)
        if avatarUrl.isEmpty {
            avatar.image = UIImage.set_image(named: "IMG_pic_default_secret")
        } else {
            let url = URL(string: avatarUrl)
            avatar!.sd_setImage(with: url, completed: nil)
        }
    }
    
}
