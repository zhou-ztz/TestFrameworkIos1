//
//  MyVoucherListViewCell.swift
//  RewardsLink
//
//  Created by Wong Jin Lun on 15/08/2024.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import UIKit

protocol MyVoucherListViewCellDelegate: class {
    func onCopyClicked(trxNo: String)
}

class MyVoucherListViewCell: UITableViewCell, BaseCellProtocol {
    
    @IBOutlet weak var infoStackView: UIStackView!
    @IBOutlet weak var expiringSoon: UILabel!
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var expiringView: UIView!
    @IBOutlet weak var offsetView: OffsetRebateView!
    @IBOutlet weak var voucherLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var voucherImage: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var wrapView: UIView!
    @IBOutlet weak var transNoLabel: UILabel!
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var transView: UIView!
    
    var delegate: MyVoucherListViewCellDelegate?
    var trxNo: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        expiringView.layer.cornerRadius = expiringView.bounds.height/2
        expiringView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        expiringView.clipsToBounds = true
        expiringView.backgroundColor = UIColor(hex: 0xFFB516)
        
        wrapView.layer.cornerRadius = 12.0
        voucherImage.layer.cornerRadius = 8.0
        
        let image = UIImage.set_image(named: "ic_rl_copy_grey")?.withRenderingMode(.alwaysTemplate)
        copyButton.setImage(image, for: .normal)
        copyButton.contentVerticalAlignment = .fill
        copyButton.contentHorizontalAlignment = .fill
        copyButton.tintColor = AppTheme.red
        copyButton.setTitle("", for: .normal)
        copyButton.isUserInteractionEnabled = false
        
        transView.addAction { [weak self] in
            if let trxNo = self?.trxNo {
                self?.delegate?.onCopyClicked(trxNo: trxNo)
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configureCell(_ provider: MyVoucherProvider, expiringTag: Int, isExpired: Bool, model: MyVoucherModel, fromExpired: Bool) {
        let imageUrlString = provider.imageURL?.first ?? provider.logoURL?.first ?? ""
        voucherImage.sd_setImage(with: URL(string: imageUrlString), placeholderImage: UIImage.set_image(named: "icPicturePostPlaceholder"))
        
        offsetView.rebateLabel.text = String(format: "rw_merchant_rebate_ios".localized, provider.package?.rebatePercentage ?? "")
        offsetView.offsetLabel.text = String(format: "rw_merchant_offset_ios".localized, provider.package?.offsetPercentage ?? "")
       
        expiringSoon.text = isExpired ? "rw_expired".localized : "rw_expiring_soon".localized
        quantityLabel.text = String(format: "rw_text_my_voucher_qty".localized, model.quantity ?? 0)
        totalLabel.text = String(format: "rw_text_my_voucher_total".localized, model.quantity ?? 0)
      
        voucherLabel.text = provider.name
        trxNo = model.orderNo ?? ""
        transNoLabel.text = String(format: "rw_transaction_id_value_ios".localized, trxNo)
        
        expiringView.isHidden = !isExpired && expiringTag == 0
        expiringView.backgroundColor = isExpired ? UIColor(hex: 0x8B8B8B) : UIColor(hex: 0xFFB516)
        expiringSoon.textColor = isExpired ? .white : expiringSoon.textColor
        
        if let package = provider.package, let currency = package.currency {
            let amount = package.price ?? package.minAmount
            if let amount = amount {
                priceLabel.text = String(format: "%@ %@", currency, amount)
            }
        }
        
        if let totalPrice = model.credits,  let currency = model.targetCurrency {
            totalPriceLabel.text = String(format: "%@ %@", currency, totalPrice)
        }
        
        if let isRedeemed = model.isRedeemed, isRedeemed == 1 {
            statusLabel.text = "rw_text_redeemed".localized.uppercased()
            statusLabel.textColor = UIColor(hex: 0x808080)
        } else {
            statusLabel.text = "rw_text_active".localized.uppercased()
            statusLabel.textColor = UIColor(hex: 0x9BCF53)
        }
        
        if fromExpired {
            statusLabel.text = "rw_expired".localized
            statusLabel.textColor = UIColor(hex: 0x808080)
            expiringView.isHidden = true
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.ssssssZ"
        let date = dateFormatter.date(from: model.createdAt ?? "")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let resultString = dateFormatter.string(from: date ?? Date())
        self.dateTimeLabel.text =  String(format: "rw_text_my_voucher_date".localized, resultString)
    }
    
}
