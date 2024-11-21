//
//  ContactTableViewCell.swift
//  Yippi
//
//  Created by Wong Jin Lun on 22/02/2023.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell, BaseCellProtocol {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupView()
    }
    
    private func setupView() {
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width / 2
        self.avatarImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
