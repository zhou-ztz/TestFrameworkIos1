//
//  VoucherListViewCell.swift
//  RewardsLink
//
//  Created by Wong Jin Lun on 14/05/2024.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import UIKit

class VoucherListViewCell: TSPTableViewCell {
    @IBOutlet weak var wrapView: UIView!
    @IBOutlet weak var voucherImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var rebateOffsetView: OffsetRebateView!
    @IBOutlet weak var expiringView: UIView!
    @IBOutlet weak var expiringSoon: UILabel!
    
    deinit {
        if let indexPath = self.indexPath {
            stopStayEvent(indexPath: indexPath)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if let indexPath = self.indexPath {
            stopStayEvent(indexPath: indexPath)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        expiringView.layer.cornerRadius = expiringView.bounds.height/2
        expiringView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        expiringView.backgroundColor = UIColor(hex: 0xFFB516)
        
        wrapView.layer.cornerRadius = 12.0
        voucherImageView.layer.cornerRadius = 8.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    override func viewStayEvent(indexPath: IndexPath, itemId: Int) {
        stopStayEvent(indexPath: indexPath)
        
        let timer = Timer.scheduledTimer(timeInterval: Utils.getStayEventTimerValue(), target: self, selector: #selector(updateTimer), userInfo: indexPath, repeats: true)
        VoucherListViewCell.timerDictionary[indexPath] = DataCollectionDict(timer: timer, indexPath: indexPath, itemId: itemId, startTime: getCurrentTime())
    }
    
    override func stopStayEvent(indexPath: IndexPath) {
        if let dict = VoucherListViewCell.timerDictionary[indexPath] {
            dict.timer.invalidate()
            VoucherListViewCell.timerDictionary.removeValue(forKey: dict.indexPath)
            
            let stay = getCurrentTime() - dict.startTime
//            printIfDebug("\(VoucherListViewCell.cellIdentifier)'s timer for cell at indexPath: \(dict.indexPath), seconds: \(stay)")
            if Double(stay) >= Utils.getStayEventTimerValue() {
                printIfDebug("\(VoucherListViewCell.cellIdentifier)'s timer stopped for cell at indexPath: \(dict.indexPath), item Id: \(dict.itemId.stringValue), seconds: \(stay)")
                EventTrackingManager.instance.trackEvent(itemId: dict.itemId.stringValue, itemType: ItemType.voucherCategory.rawValue, behaviorType: BehaviorType.stay, sceneId: "", moduleId: ModuleId.voucher.rawValue, pageId: PageId.voucherCategoryListVoucher.rawValue, behaviorValue: stay.stringValue)
            }
        }
    }
    
    @objc func updateTimer(timer: Timer) {
        guard let indexPath = timer.userInfo as? IndexPath else { return }
        stopStayEvent(indexPath: indexPath)
    }
    
    func configureCell(_ model: VoucherSummaryData, expiringTag: Int, indexPath: IndexPath) {
        titleLabel.text = model.name
        if let descriptionLong = model.descriptionLong, !descriptionLong.isEmpty {
            descLabel.text = descriptionLong
        } else if let descriptionShort = model.description, !descriptionShort.isEmpty {
            descLabel.text = descriptionShort
        }
        
        rebateOffsetView.rebateLabel.text = String(format: "rw_merchant_rebate_ios".localized, model.rebatePercentage ?? "")
        rebateOffsetView.offsetLabel.text = String(format: "rw_merchant_offset_ios".localized, model.offsetPercentage ?? "")
        
        let imageUrlString = model.imageURL?.first ?? model.logoURL?.first ?? ""
        voucherImageView.sd_setImage(with: URL(string: imageUrlString), placeholderImage: UIImage.set_image(named: "icPicturePostPlaceholder"))
        
        self.expiringSoon.text = "rw_expiring_soon".localized
        
        expiringView.isHidden = (expiringTag == 0)
        
        self.indexPath = indexPath
    }
    
    func configureVoucherCell(_ provider: MyVoucherProvider, expiringTag: Int, isExpired: Bool, model: MyVoucherModel) {
        titleLabel.text = provider.name
        if let descriptionLong = model.descriptionLong?.trimmingCharacters(in: .newlines), !descriptionLong.isEmpty {
            descLabel.text = descriptionLong
        } else if let descriptionShort = model.description?.trimmingCharacters(in: .newlines), !descriptionShort.isEmpty {
            descLabel.text = descriptionShort
        }
        
        rebateOffsetView.rebateLabel.text = String(format: "rw_merchant_rebate_ios".localized, provider.package?.rebatePercentage ?? "")
        rebateOffsetView.offsetLabel.text = String(format: "rw_merchant_offset_ios".localized, provider.package?.offsetPercentage ?? "")
        
        let imageUrlString = provider.imageURL?.first ?? provider.logoURL?.first ?? ""
        voucherImageView.sd_setImage(with: URL(string: imageUrlString), placeholderImage: UIImage.set_image(named: "icPicturePostPlaceholder"))
        
        self.expiringSoon.text = isExpired ? "rw_expired".localized : "rw_expiring_soon".localized
       
        if isExpired {
            expiringView.isHidden = false
            expiringView.backgroundColor = UIColor(hex: 0x8B8B8B)
            expiringSoon.textColor = .white
        } else {
            expiringView.isHidden = (expiringTag == 0)
        }
    }
    
    func configureSearchCell(_ model: VoucherSearchData) {
        titleLabel.text = model.name
        if let descriptionLong = model.descriptionLong?.trimmingCharacters(in: .newlines), !descriptionLong.isEmpty {
            descLabel.text = descriptionLong
        } else if let descriptionShort = model.description?.trimmingCharacters(in: .newlines), !descriptionShort.isEmpty {
            descLabel.text = descriptionShort
        }
        rebateOffsetView.rebateLabel.text = String(format: "rw_merchant_rebate_ios".localized, model.packages?.first?.rebatePercentage ?? "")
        rebateOffsetView.offsetLabel.text = String(format: "rw_merchant_offset_ios".localized, model.packages?.first?.offsetPercentage ?? "")
        
        let imageUrlString = model.imageURL?.first ?? model.logoURL?.first ?? ""
        voucherImageView.sd_setImage(with: URL(string: imageUrlString), placeholderImage: UIImage.set_image(named: "icPicturePostPlaceholder"))
        
        expiringView.isHidden = true
    }
}
