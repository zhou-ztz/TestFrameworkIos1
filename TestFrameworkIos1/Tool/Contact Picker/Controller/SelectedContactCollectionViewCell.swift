//
//  SelectedContactCollectionViewCell.swift
//  Yippi
//
//  Created by Wong Jin Lun on 23/02/2023.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit

class SelectedContactCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var cancelView: UIView!
    
    static let cellIdentifier = "SelectedContactCollectionViewCell"
    class func nib() -> UINib {
        return UINib(nibName: cellIdentifier, bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupView()
    }
    
    private func setupView() {
        cancelView.layer.cornerRadius = self.avatarImageView.frame.size.width / 2
        cancelView.clipsToBounds = true
        
        avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width / 2
        avatarImageView.clipsToBounds = true
    
    }

}
