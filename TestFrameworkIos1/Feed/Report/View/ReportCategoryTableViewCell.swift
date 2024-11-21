//
//  ReportCategoryTableViewCell.swift
//  Yippi
//
//  Created by Ng Kit Foong on 21/09/2022.
//  Copyright © 2022 Toga Capital. All rights reserved.
//

import UIKit

class ReportCategoryTableViewCell: UITableViewCell {
    static let cellIdentifier = "reportCell"
    
    @IBOutlet weak var categoryTitle: UILabel!
    
    public func configure(with title: String) {
        categoryTitle.text = title.localized
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
