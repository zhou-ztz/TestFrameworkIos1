//
//  ExpandableTableViewCell.swift
//  RewardsLink
//
//  Created by Eric Low on 30/05/2024.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import UIKit

class ExpandableTableViewCell: UITableViewCell , BaseCellProtocol{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var iconImg: UIImageView!
    
    @IBOutlet weak var roundedView: UIView!
    @IBOutlet weak var expandedView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        roundedView.layer.masksToBounds = true
        selectionStyle = .none
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        roundedView.layer.cornerRadius = 10
        roundedView.backgroundColor = UIColor(hex: "#F7F7F7")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func set(content: ExpandableContentSection) {
        self.titleLabel.text = content.title
        //self.contentLabel.attributedText = content.isExpanded ?  content.content?.toHTMLString(size: "12.0", color: "#737373") : "".attributonString()
        self.contentLabel.text = content.content
        self.contentLabel.sizeToFit()
        self.expandedView.isHidden = content.isExpanded ? false : true
        self.iconImg.image = content.isExpanded ? UIImage(systemName:  "chevron.up") : UIImage(systemName:  "chevron.down")
    }
    
}
