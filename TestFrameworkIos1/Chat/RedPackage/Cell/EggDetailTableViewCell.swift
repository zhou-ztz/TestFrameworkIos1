// 
// Copyright © 2018 Toga Capital. All rights reserved.
//


import UIKit
import SDWebImage

class EggDetailTableViewCell: UITableViewCell, BaseCellProtocol {

    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var pointLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nicknameLabel.applyStyle(.bold(size: 14, color: AppTheme.twilightBlue))
        pointLabel.applyStyle(.bold(size: 16, color: AppTheme.black))
        userImageView.roundCorner(userImageView.bounds.height / 2)
        userImageView.layer.masksToBounds = true
        dateLabel.applyStyle(.regular(size: 13, color: AppTheme.lightGrey))
    }

    func configure(egg: Detail) {
        nicknameLabel.text = egg.nickname
        pointLabel.text = egg.points.appending(" \(Constants.YippiWallet)")
        userImageView.sd_setImage(with: URL(string: egg.headsmall.orEmpty), placeholderImage: UIImage.set_image(named: "defaultNewHeadImage"), context: [.storeCacheType : SDImageCacheType.memory.rawValue])
        dateLabel.text = egg.opentime
    }
    
    func configureOwnPersonal(egg: Detail) {
        nicknameLabel.text = egg.fnickname
        pointLabel.text = egg.points.appending(" Yipps")
        userImageView.sd_setImage(with: URL(string: egg.fheadsmall.orEmpty), placeholderImage: UIImage.set_image(named: "defaultNewHeadImage"), context: [.storeCacheType : SDImageCacheType.memory.rawValue])
        dateLabel.text = egg.opentime
    }
}
