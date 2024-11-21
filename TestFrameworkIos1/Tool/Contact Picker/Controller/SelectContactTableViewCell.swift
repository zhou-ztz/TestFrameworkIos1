//
//  SelectContactTableViewCell.swift
//  Yippi
//
//  Created by Wong Jin Lun on 22/02/2023.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit

class SelectContactTableViewCell: UITableViewCell, BaseCellProtocol{

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var checkButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.checkButton.contentMode = .scaleAspectFit
        self.checkButton.setTitle("", for: .normal)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
