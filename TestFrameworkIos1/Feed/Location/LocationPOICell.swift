//
//  LocationPOICell.swift
//  Yippi
//
//  Created by francis on 31/07/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation
import UIKit

class LocationPOICell: UITableViewCell {
    
    @IBOutlet weak var primaryLabel: UILabel!
    @IBOutlet weak var secondaryLabel: UILabel!
    
    func configure(primary:String?, secondary: String?) {
        primaryLabel.text = primary.orEmpty
        secondaryLabel.text = secondary.orEmpty
    }
}
