//
//  TipMessageCell.swift
//  Yippi
//
//  Created by Tinnolab on 27/05/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit


class TipMessageCell: UITableViewCell, BaseCellProtocol {

    @IBOutlet weak var tipLabel: TSLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tipLabel.backgroundColor = UIColor(red: 230, green: 230, blue: 230)
        tipLabel.roundCorner(tipLabel.height/2.5)
        tipLabel.textInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        tipLabel.font = UIFont.systemFont(ofSize: 10.0)
        tipLabel.textColor = .black
        tipLabel.textAlignment = .center
    }
}
