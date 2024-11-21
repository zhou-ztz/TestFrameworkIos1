//
//  PackageCollectionViewCell.swift
//  AppsFlyer
//
//  Created by Kit Foong on 29/05/2024.
//

import Foundation
import UIKit

class PackageCollectionViewCell: UICollectionViewCell, BaseCellProtocol {
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.preferredMaxLayoutWidth = 60
    }
    
    func updateUI(package: VoucherPackage) {
        if let price = package.price {
            self.titleLabel.text = price
        } else if let price = package.minAmount {
            self.titleLabel.text = price
        } else {
            self.titleLabel.text = package.maxAmount
        }
        
        if package.isDisable {
            self.titleLabel.textColor = UIColor(red: 115/255, green: 115/255, blue: 115/255, alpha: 0.5)
            self.isUserInteractionEnabled = false
        } else {
            self.titleLabel.textColor = UIColor(red: 36/255, green: 36/255, blue: 36/255, alpha: 1)
            self.isUserInteractionEnabled = true
        }
        
        self.titleView.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: package.isDisable ? 0.5 : 1)
        
        updateSelectedView(package: package)
    }
    
    func updateSelectedView(package: VoucherPackage) {
        if package.isSelected {
            titleLabel.font = .systemFont(ofSize: 12, weight: .bold)
            titleView.layer.borderWidth = 1
            titleView.layer.borderColor = UIColor(red: 237/255, green: 26/255, blue: 59/255, alpha: 1).cgColor
        } else {
            titleLabel.font = .systemFont(ofSize: 12, weight: .regular)
            titleView.layer.borderColor = UIColor.clear.cgColor
        }
    }
}
