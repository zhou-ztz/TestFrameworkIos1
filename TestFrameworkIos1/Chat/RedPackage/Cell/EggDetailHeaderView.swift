// 
// Copyright © 2018 Toga Capital. All rights reserved.
//


import UIKit
import SDWebImage

class EggDetailHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var ypointAmountLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var pointTitleLabel: UILabel!
    
    var dismissViewHandler: EmptyClosure?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.tintColor = AppTheme.white
        self.contentView.backgroundColor = AppTheme.red
        profileImageView.roundCorner(profileImageView.bounds.height / 2 )
        profileImageView.layer.masksToBounds = true
        
        nickNameLabel.applyStyle(.semibold(size: 14, color: AppTheme.white))
        ypointAmountLabel.applyStyle(.bold(size: 12, color: AppTheme.white))
        pointTitleLabel.applyStyle(.bold(size: 30, color: AppTheme.white))
        pointTitleLabel.text = Constants.YippiWallet
        closeButton.setImage(UIImage.set_image(named: "icon_cross") , for: .normal)
    }
    
    func configure(info: EggInfo) {
        profileImageView.sd_setImage(with: URL(string: info.headsmall), placeholderImage: UIImage.set_image(named: "defaultNewHeadImage"), context: [.storeCacheType : SDImageCacheType.memory.rawValue])
        
        ypointAmountLabel.text = info.remarks
        nickNameLabel.text = info.nickname
        pointTitleLabel.text = info.points.appending(" \(Constants.YippiWallet)")
    }
    
    func configurePersonalHeaderView(info: EggInfo, isOpen:String) {
        profileImageView.sd_setImage(with: URL(string: info.headsmall), placeholderImage: UIImage.set_image(named: "defaultNewHeadImage"), context: [.storeCacheType : SDImageCacheType.memory.rawValue])
        
        if isOpen == "1" {
            ypointAmountLabel.text = String(format: "opened_count".localized, Int(isOpen)!,"1")
        } else {
            ypointAmountLabel.text = String(format: "opened_count".localized, Int(isOpen)!,"1")
        }
        
        nickNameLabel.text = info.nickname
        pointTitleLabel.text = info.points.appending(" \(Constants.YippiWallet)")
    }
    
    @IBAction func closeDidTapped(_ sender: Any) {
        self.dismissViewHandler?()
    }
}
