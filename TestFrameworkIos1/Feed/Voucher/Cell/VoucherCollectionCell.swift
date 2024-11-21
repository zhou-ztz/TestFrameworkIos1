//
//  VoucherCollectionCell.swift
//  RewardsLink
//
//  Created by Wong Jin Lun on 14/05/2024.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import UIKit

class VoucherCollectionCell: TSCollectionViewCell {
    @IBOutlet weak var wrapView: UIView!
    @IBOutlet weak var voucherImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var rebateOffsetView: OffsetRebateView!
    
    deinit {
        if let indexPath = self.indexPath {
            stopStayEvent(indexPath: indexPath)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        wrapView.layer.cornerRadius = 16.0
//        wrapView.layer.shadowColor = UIColor.lightGray.cgColor
//        wrapView.layer.shadowOffset = CGSize(width: 0.0, height : 2.0)
//        wrapView.layer.shadowOpacity = 0.2
//        wrapView.layer.shadowRadius = 2
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if let indexPath = self.indexPath {
            stopStayEvent(indexPath: indexPath)
        }
    }
    
    override func layoutSubviews() {
        voucherImageView.layer.cornerRadius = 12.0
    }
    
    func setModel(_ model: VoucherSummaryData, indexPath: IndexPath) {
        titleLabel.text = model.name
        if let descriptionLong = model.descriptionLong?.trimmingCharacters(in: .newlines), !descriptionLong.isEmpty {
            descLabel.text = descriptionLong
        } else if let descriptionShort = model.description?.trimmingCharacters(in: .newlines), !descriptionShort.isEmpty {
            descLabel.text = descriptionShort
        }
        rebateOffsetView.rebate = model.rebatePercentage
        rebateOffsetView.offset = model.offsetPercentage
        
        let imageUrlString = model.imageURL?.first ?? model.logoURL?.first ?? ""
        voucherImageView.sd_setImage(with: URL(string: imageUrlString), placeholderImage: UIImage.set_image(named: "icPicturePostPlaceholder"))
        
        self.indexPath = indexPath
    }
    
    override func viewStayEvent(indexPath: IndexPath, itemId: Int) {
        stopStayEvent(indexPath: indexPath)
        
        let timer = Timer.scheduledTimer(timeInterval: Utils.getStayEventTimerValue(), target: self, selector: #selector(updateTimer), userInfo: indexPath, repeats: true)
        VoucherCollectionCell.timerDictionary[indexPath] = DataCollectionDict(timer: timer, indexPath: indexPath, itemId: itemId, startTime: getCurrentTime())
    }
    
    override func stopStayEvent(indexPath: IndexPath) {
        if let dict = VoucherCollectionCell.timerDictionary[indexPath] {
            dict.timer.invalidate()
            VoucherCollectionCell.timerDictionary.removeValue(forKey: dict.indexPath)
            
            let stay = getCurrentTime() - dict.startTime
//            printIfDebug("\(VoucherCollectionCell.cellIdentifier)'s timer for cell at indexPath: \(dict.indexPath), seconds: \(stay)")
            if Double(stay) >= Utils.getStayEventTimerValue() {
                printIfDebug("\(VoucherCollectionCell.cellIdentifier)'s timer stopped for cell at indexPath: \(dict.indexPath), item Id: \(dict.itemId.stringValue), seconds: \(stay)")
                EventTrackingManager.instance.trackEvent(itemId: dict.itemId.stringValue, itemType: ItemType.voucherDashboard.rawValue, behaviorType: BehaviorType.stay, sceneId: "", moduleId: ModuleId.voucher.rawValue, pageId: PageId.voucherDashboardVoucher.rawValue, behaviorValue: stay.stringValue)
            }
        }
    }
    
    @objc func updateTimer(timer: Timer) {
        guard let indexPath = timer.userInfo as? IndexPath else { return }
        stopStayEvent(indexPath: indexPath)
    }
}
