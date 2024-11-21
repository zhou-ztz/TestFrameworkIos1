//
//  VoucherViewCell.swift
//  RewardsLink
//
//  Created by Wong Jin Lun on 13/05/2024.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import UIKit

protocol VoucherDelegate: class {
    func onMoreAction(_ categoryName: String)
}

class VoucherViewCell: TSPTableViewCell {
    @IBOutlet weak var lineView: UIView! {
        didSet {
            lineView.backgroundColor = TSColor.small.repostBackground
        }
    }
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var moreStackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var moreView: UIStackView!
    @IBOutlet weak var moreLabel: UILabel!
    
    var navigateToVoucherDetail: ((_ voucherId: Int) -> Void)?
    var moreButtonCallBack: (() -> Void)?
    
    var delegate: VoucherDelegate?
    var voucherResponse: VoucherSummaryResponse?
    var voucherData: [VoucherSummaryData] = []
    
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
        moreLabel.text = "more".localized
        moreView.addAction(action: { [weak self] in
            guard let self = self else { return }
            self.delegate?.onMoreAction(self.voucherResponse?.categoryName ?? "")
        })
    }
    
    override func viewStayEvent(indexPath: IndexPath, itemId: Int) {
        stopStayEvent(indexPath: indexPath)
        
        let timer = Timer.scheduledTimer(timeInterval: Utils.getStayEventTimerValue(), target: self, selector: #selector(updateTimer), userInfo: indexPath, repeats: true)
        VoucherViewCell.timerDictionary[indexPath] = DataCollectionDict(timer: timer, indexPath: indexPath, itemId: itemId, startTime: getCurrentTime())
    }
    
    override func stopStayEvent(indexPath: IndexPath) {
        if let dict = VoucherViewCell.timerDictionary[indexPath] {
            dict.timer.invalidate()
            VoucherViewCell.timerDictionary.removeValue(forKey: dict.indexPath)
            
            let stay = getCurrentTime() - dict.startTime
//            printIfDebug("\(VoucherViewCell.cellIdentifier)'s timer for cell at indexPath: \(dict.indexPath), current time: \(getCurrentTime()), start time \(dict.startTime),  seconds: \(stay)")
            if Double(stay) >= Utils.getStayEventTimerValue() {
                printIfDebug("\(VoucherViewCell.cellIdentifier)'s timer stopped for cell at indexPath: \(dict.indexPath), item Id: \(dict.itemId.stringValue), seconds: \(stay)")
                EventTrackingManager.instance.trackEvent(itemId: dict.itemId.stringValue, itemType: ItemType.voucherDashboard.rawValue, behaviorType: BehaviorType.stay, sceneId: "", moduleId: ModuleId.voucher.rawValue, pageId: PageId.voucherDashboardCategory.rawValue, behaviorValue: stay.stringValue)
            }
        }
    }
    
    @objc func updateTimer(timer: Timer) {
        guard let indexPath = timer.userInfo as? IndexPath else { return }
        stopStayEvent(indexPath: indexPath)
    }
    
    func configureCell(voucher: VoucherSummaryResponse, indexPath: IndexPath) {
        titleLabel.text = voucher.categoryName
        voucherResponse = voucher
        voucherData = voucherResponse?.data ?? []
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(VoucherCollectionCell.nib(), forCellWithReuseIdentifier: VoucherCollectionCell.cellIdentifier)
        collectionView.reloadData()
    
        resetCollectionViewOffset()
        
        self.indexPath = indexPath
    }
    
    func resetCollectionViewOffset() {
        collectionView.setContentOffset(.zero, animated: false)
    }
}

extension VoucherViewCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return voucherData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VoucherCollectionCell.cellIdentifier, for: indexPath) as? VoucherCollectionCell, let model = voucherData[safe: indexPath.row] {
            cell.setModel(model, indexPath: indexPath)
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let voucher = voucherData[safe: indexPath.row] {
            self.navigateToVoucherDetail?(voucher.id ?? 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? VoucherCollectionCell, let model = voucherData[safe: indexPath.row] else { return }
//        printIfDebug("\(VoucherCollectionCell.cellIdentifier) will display at \(indexPath)")
        EventTrackingManager.instance.trackEvent(
            itemId: (model.id ?? 0).stringValue,
            itemType: ItemType.voucherDashboard.rawValue,
            behaviorType: BehaviorType.expose,
            sceneId: "",
            moduleId: ModuleId.voucher.rawValue,
            pageId: PageId.voucherDashboardVoucher.rawValue)
        cell.viewStayEvent(indexPath: indexPath, itemId: model.id ?? 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? VoucherCollectionCell else { return }
//        printIfDebug("\(VoucherCollectionCell.cellIdentifier) did end displaying at \(indexPath)")
        cell.stopStayEvent(indexPath: indexPath)
    }
}

// MARK: Collection View Delegate
extension VoucherViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width : CGFloat = ScreenWidth * 0.65
        var imageHeight : CGFloat = (width * 30) / 45
        return CGSize(width: width, height: imageHeight + 91)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
}


