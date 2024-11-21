//
//  HallofFameSectionHeaderView.swift
//  Yippi
//
//  Created by ChuenWai on 17/02/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit

class HallofFameSectionHeaderView: UICollectionReusableView {
    static let sectionIdentifier = "fameHeader"

    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.baselineAdjustment = UIBaselineAdjustment.alignBaselines
        titleLabel.textAlignment = NSTextAlignment.left
        titleLabel.font = UIFont.systemFont(ofSize: TSFont.SubText.subContent.rawValue, weight: UIFont.Weight.semibold)
    }

    func setTitle(title: String) {
        titleLabel.text = title
    }
}
