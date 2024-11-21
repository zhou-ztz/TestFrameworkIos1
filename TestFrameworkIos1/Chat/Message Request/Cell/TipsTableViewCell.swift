//
//  TipsTableViewCell.swift
//  Yippi
//
//  Created by Tinnolab on 23/08/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import UIKit


class TipsTableViewCell: UITableViewCell, BaseCellProtocol {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var backgroundVw: UIView!
    
    static let cellReuseIdentifier = "TipsTableViewCell"
    
    class func nib() -> UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundVw.layer.cornerRadius = backgroundVw.height*0.25
        
        titleLbl.font = UIFont.systemFont(ofSize: YPCustomizer.FontSize.verySmall)
        titleLbl.numberOfLines = 0
    }
    
}
