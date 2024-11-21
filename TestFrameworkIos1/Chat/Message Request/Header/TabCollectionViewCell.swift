//
//  TabCollectionViewCell.swift
//  Yippi
//
//  Created by Kit Foong on 02/03/2023.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit

class TabHeaderdModal {
    var titleString: String
    var messageCount: Int
    var bubbleColor: UIColor
    var isSelected: Bool

    init(titleString: String, messageCount: Int, bubbleColor: UIColor, isSelected: Bool) {
        self.titleString = titleString
        self.messageCount = messageCount
        self.bubbleColor = bubbleColor
        self.isSelected = isSelected
    }
}

class TabCollectionViewCell: UICollectionViewCell, BaseCellProtocol, UIGestureRecognizerDelegate {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countView: UIView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var countLabelWidth: NSLayoutConstraint!
    @IBOutlet weak var selectedView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isUserInteractionEnabled = true
    }
    
    func updateUI(tab: TabHeaderdModal) {
        selectedView.isHidden = false
        selectedView.backgroundColor = TSColor.main.theme
        selectedView.layer.masksToBounds = true
        selectedView.layer.cornerRadius = 2
        
        titleLabel.text = tab.titleString
        
        if tab.messageCount > 0 {
            countView.isHidden = false
            
            var countString: String = ""
            
            if tab.messageCount > 99 {
                countString = "99+"
            } else {
                countString = String(tab.messageCount)
            }
            
            countLabel.textColor = .white
            countLabel.backgroundColor = tab.bubbleColor
            
            countLabel.text = countString
            countLabelWidth.constant = tab.messageCount > 99 ? 30 : 20
            countLabel.roundCorner(8)
        } else {
            countView.isHidden = true
        }
        
        updateSelectedView(tab: tab)
    }
    
    func updateSelectedView(tab: TabHeaderdModal) {
        if tab.isSelected {
            titleLabel.font =  .systemFont(ofSize: 14, weight: .regular)
            titleLabel.textColor = UIColor(hex: 0x242424)
            selectedView.isHidden = false
        } else {
            titleLabel.font =  .systemFont(ofSize: 14, weight: .regular)
            titleLabel.textColor = UIColor(hex: 0xA5A5A5)
            selectedView.isHidden = true
        }
    }
}
