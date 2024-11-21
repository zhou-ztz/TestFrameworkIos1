//
//  RedeemVoucherCell.swift
//  RewardsLink
//
//  Created by Kit Foong on 20/06/2024.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import Foundation
import UIKit

protocol RedeemVoucherCellDelegate: AnyObject {
    func copy(_ content: String?)
    func share(_ content: String?)
}

class RedeemVoucherTableViewCell: UITableViewCell, BaseCellProtocol {
    @IBOutlet weak var voucherTitle: UILabel!
    @IBOutlet weak var contentStackView: UIStackView!
    
    weak var delegate: RedeemVoucherCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let margins = UIEdgeInsets(top: 0, left: 15, bottom: 15, right: 15)
        contentView.frame = contentView.frame.inset(by: margins)
        
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor(hex: 0xEAEAEA).cgColor
    }
    
    func set(content: RedeemVoucherModel) {
        voucherTitle.text = "rw_voucher_index".localized.replacingOccurrences(of: "%s", with: content.index.stringValue)
        
        for item in content.content {
            let voucherContent = RedeemVoucherContentUIView()
            voucherContent.titleLabel.text = item.title
            voucherContent.contentLabel.text = item.content
            
            if let content = voucherContent.contentLabel.text {
                if content.hasPrefix("http://") || content.hasPrefix("https://") {
                    voucherContent.isShare = true
                    voucherContent.voucherBtnView.addTap(action: { _ in
                        self.delegate?.share(voucherContent.contentLabel.text)
                    })
                } else {
                    voucherContent.isShare = false
                    voucherContent.voucherBtnView.addTap(action: { _ in
                        self.delegate?.copy(voucherContent.contentLabel.text)
                    })
                }
            } else {
                voucherContent.isShare = false
                voucherContent.voucherBtnView.addTap(action: { _ in
                    self.delegate?.copy(voucherContent.contentLabel.text)
                })
            }
            
            contentStackView.addArrangedSubview(voucherContent)
            
            voucherContent.snp.makeConstraints {
                $0.height.equalTo(65)
            }
        }
    }
}
