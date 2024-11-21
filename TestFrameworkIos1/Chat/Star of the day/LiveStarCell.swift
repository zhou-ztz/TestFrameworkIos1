//
//  LiveStarCell.swift
//  Yippi
//
//  Created by Yong Tze Ling on 03/04/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit
import SDWebImage
import FLAnimatedImage

class LiveStarCell: UITableViewCell, BaseCellProtocol {

    @IBOutlet weak var rankButton: RankButton!
    @IBOutlet weak var avatarView: AvatarView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var liveStatusLabel: LiveStatusLabel!
    @IBOutlet weak var rankPointLabel: UILabel!
    @IBOutlet weak var pkIcon: UIImageView!
    @IBOutlet weak var periodLabel: UILabel!
    @IBOutlet weak var onLiveIndicator: FLAnimatedImageView!
    @IBOutlet weak var rankChangedIcon: UIImageView!
    @IBOutlet weak var rankChangedLabel: UILabel!
    @IBOutlet weak var rankChangeNewIcon: UIImageView!
    @IBOutlet weak var rankChangeContainer: UIView!
    @IBOutlet weak var rankChangeStackView: UIStackView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        onLiveIndicator.sd_setImage(with: Bundle.main.url(forResource: "blue-v3", withExtension: ".gif"), completed: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        avatarView.backgroundColor = .clear
        avatarView.isUserInteractionEnabled = true
        nicknameLabel.applyStyle(.regular(size: 14, color: UIColor.black.withAlphaComponent(0.85)))
        rankPointLabel.applyStyle(.regular(size: 14, color: UIColor(hex: 0x888888)))
        periodLabel.font = UIFont.systemMediumFont(ofSize: 10)
        periodLabel.textColor = UIColor(hex: 0x888888)?.withAlphaComponent(1.00)
        periodLabel.makeHidden()
    }
    
    func setupRankModel(_ model: SlotRankModel?, row: Int) {        
        defer { self.layoutIfNeeded() }
        
        if let rank = model, rank.score != 0, row > 0 {
            rankPointLabel.text = rank.score.abbStartFrom5Digit
            rankButton.setRow(row)
        } else {
            rankPointLabel.text = "live_slot_unranking".localized
            rankButton.setImage(nil, for: .normal)
            rankButton.setTitle("-", for: .normal)
        }
        if let rankModel = model {
            rankChangeContainer.isHidden = false
            if rankModel.previousLevel == 0 {
                rankChangeStackView.isHidden = true
                rankChangeNewIcon.isHidden = false
            } else if rankModel.level < rankModel.previousLevel {
                rankChangeNewIcon.isHidden = true
                rankChangeStackView.isHidden = false
                rankChangedIcon.image = UIImage.set_image(named: "icSOTDRankUp")
                rankChangedLabel.text = "\(rankModel.previousLevel - rankModel.level)"
                rankChangedLabel.applyStyle(.regular(size: 12, color: UIColor(red: 44/255, green: 204/255, blue: 53/255, alpha: 1.0)))
            } else if rankModel.level > rankModel.previousLevel {
                rankChangeNewIcon.isHidden = true
                rankChangeStackView.isHidden = false
                rankChangedIcon.image = UIImage.set_image(named: "icSOTDRankDown")
                rankChangedLabel.text = "\(rankModel.level - rankModel.previousLevel)"
                rankChangedLabel.applyStyle(.regular(size: 12, color: UIColor(red: 244/255, green: 87/255, blue: 87/255, alpha: 1.0)))
            }
        } else {
            rankChangeContainer.isHidden = true
        }
    }
    
    func setEventModel(_ model: StarSlotModel, at row: Int, timePeriod: String = "", iconUrl: String = "") {
        defer { self.layoutIfNeeded() }
        
        rankChangeContainer.isHidden = true
        nicknameLabel.text = model.name
        avatarView.avatarInfo = model.avatarInfo()

        pkIcon.sd_setImage(with: URL(string: iconUrl), completed: nil)
        
        periodLabel.makeVisible()
        periodLabel.text = model.slotTimePeriod
        
        liveStatusLabel.makeVisible()
        let isActive = model.status == YPLiveStatus.onlive.rawValue
        liveStatusLabel.isActive = isActive
        
        if isActive == false {
            onLiveIndicator.image = nil
        }
        
        onLiveIndicator.makeHidden()
        
        setupRankModel(model.rank, row: row)
    }
    
    func setStarModel(_ model: StarSlotModel, at row: Int, timePeriod: String = "", iconUrl: String = "") {
        defer { self.layoutIfNeeded() }
        
        nicknameLabel.text = model.name
        avatarView.avatarInfo = model.avatarInfo()
    
        if (model.status == YPLiveStatus.onlive.rawValue) {
            onLiveIndicator.makeVisible()
        } else {
            onLiveIndicator.image = nil
            onLiveIndicator.makeHidden()
        }
        pkIcon.image = UIImage.set_image(named: "ic_pk")
        liveStatusLabel.makeHidden()
        periodLabel.makeHidden()
        
        setupRankModel(model.rank, row: row)
        if let rankModel = model.rank {
            rankChangeContainer.isHidden = false
            if rankModel.previousLevel == 0 {
                rankChangeStackView.isHidden = true
                rankChangeNewIcon.isHidden = false
            } else if rankModel.level < rankModel.previousLevel {
                rankChangeNewIcon.isHidden = true
                rankChangeStackView.isHidden = false
                rankChangedIcon.image = UIImage.set_image(named: "icSOTDRankUp")
                rankChangedLabel.text = "\(rankModel.previousLevel - rankModel.level)"
                rankChangedLabel.applyStyle(.regular(size: 12, color: UIColor(red: 44/255, green: 204/255, blue: 53/255, alpha: 1.0)))
            } else if rankModel.level > rankModel.previousLevel {
                rankChangeNewIcon.isHidden = true
                rankChangeStackView.isHidden = false
                rankChangedIcon.image = UIImage.set_image(named: "icSOTDRankDown")
                rankChangedLabel.text = "\(rankModel.level - rankModel.previousLevel)"
                rankChangedLabel.applyStyle(.regular(size: 12, color: UIColor(red: 244/255, green: 87/255, blue: 87/255, alpha: 1.0)))
            }
        } else {
            rankChangeContainer.isHidden = true
        }
    }

    
    func setModel(_ model: StarSlotModel, at row: Int, type: LiveType = .starOfTheDay, timePeriod: String = "", iconUrl: String = "") {
        defer { self.layoutIfNeeded() }
        
        nicknameLabel.text = model.name
        avatarView.avatarInfo = model.avatarInfo()
        
        if type == .starOfTheDay {
            pkIcon.image = UIImage.set_image(named: "ic_pk")
            liveStatusLabel.makeHidden()
            periodLabel.makeHidden()
            if model.status == YPLiveStatus.onlive.rawValue {
                onLiveIndicator.makeVisible()
            } else {
                onLiveIndicator.makeHidden()
                onLiveIndicator.image = nil
            }
        } else {
            liveStatusLabel.isActive = model.status == YPLiveStatus.onlive.rawValue
            pkIcon.sd_setImage(with: URL(string: iconUrl), completed: nil)
            periodLabel.text = model.slotTimePeriod
            liveStatusLabel.makeVisible()
            periodLabel.makeVisible()
            onLiveIndicator.image = nil
            onLiveIndicator.makeHidden()
        }
        
        setupRankModel(model.rank, row: row)
        if let rankModel = model.rank {
            rankChangeContainer.isHidden = false
            if rankModel.previousLevel == 0 {
                rankChangeStackView.isHidden = true
                rankChangeNewIcon.isHidden = false
            } else if rankModel.level < rankModel.previousLevel {
                rankChangeNewIcon.isHidden = true
                rankChangeStackView.isHidden = false
                rankChangedIcon.image = UIImage.set_image(named: "icSOTDRankUp")
                rankChangedLabel.text = "\(rankModel.previousLevel - rankModel.level)"
                rankChangedLabel.applyStyle(.regular(size: 12, color: UIColor(red: 44/255, green: 204/255, blue: 53/255, alpha: 1.0)))
            } else if rankModel.level > rankModel.previousLevel {
                rankChangeNewIcon.isHidden = true
                rankChangeStackView.isHidden = false
                rankChangedIcon.image = UIImage.set_image(named: "icSOTDRankDown")
                rankChangedLabel.text = "\(rankModel.level - rankModel.previousLevel)"
                rankChangedLabel.applyStyle(.regular(size: 12, color: UIColor(red: 244/255, green: 87/255, blue: 87/255, alpha: 1.0)))
            }
        } else {
            rankChangeContainer.isHidden = true
        }
    }
    
    func setupFooterModel(_ model: UserInfoModel, slotRankInfo: SlotRankModel, type: LiveType = .starOfTheDay, timePeriod: String = "-", iconUrl: String = "", entryType: LiveListEntryType = .live) {
        
        defer { self.layoutIfNeeded() }
        nicknameLabel.text = model.name
        avatarView.avatarInfo = AvatarInfo(userModel: model)
        
        if type == .starOfTheDay {
            pkIcon.image = UIImage.set_image(named: "ic_pk")
            periodLabel.makeHidden()
            liveStatusLabel.makeHidden()
            if entryType == .live {
                onLiveIndicator.makeVisible()
            } else {
                onLiveIndicator.makeHidden()
                onLiveIndicator.image = nil
            }
        } else {
            pkIcon.sd_setImage(with: URL(string: iconUrl), completed: nil)
            periodLabel.text = timePeriod
            periodLabel.makeVisible()
            liveStatusLabel.makeVisible()
            liveStatusLabel.isActive = true
            onLiveIndicator.makeHidden()
            onLiveIndicator.image = nil
        }
        
        rankPointLabel.text = slotRankInfo.score == 0 ? "live_slot_unranking".localized : slotRankInfo.score.abbStartFrom5Digit
        
        if slotRankInfo.score != 0, slotRankInfo.level > 0 {
            rankButton.setRow(slotRankInfo.level)
        } else {
            rankButton.setImage(nil, for: .normal)
            rankButton.setTitle("-", for: .normal)
        }
        
        rankChangeContainer.isHidden = false
        if slotRankInfo.previousLevel == 0 {
            rankChangeStackView.isHidden = true
            rankChangeNewIcon.isHidden = false
        } else if slotRankInfo.level < slotRankInfo.previousLevel {
            rankChangeNewIcon.isHidden = true
            rankChangeStackView.isHidden = false
            rankChangedIcon.image = UIImage.set_image(named: "icSOTDRankUp")
            rankChangedLabel.text = "\(slotRankInfo.previousLevel - slotRankInfo.level)"
            rankChangedLabel.applyStyle(.regular(size: 12, color: UIColor(red: 44/255, green: 204/255, blue: 53/255, alpha: 1.0)))
        } else if slotRankInfo.level > slotRankInfo.previousLevel {
            rankChangeNewIcon.isHidden = true
            rankChangeStackView.isHidden = false
            rankChangedIcon.image = UIImage.set_image(named: "icSOTDRankDown")
            rankChangedLabel.text = "\(slotRankInfo.level - slotRankInfo.previousLevel)"
            rankChangedLabel.applyStyle(.regular(size: 12, color: UIColor(red: 244/255, green: 87/255, blue: 87/255, alpha: 1.0)))
        }
    }
    
    func setHostModel(_ model: UserInfoModel, rank: SlotRankModel, at row: Int, type: LiveType = .starOfTheDay, iconUrl: String = "", timePeriod: String = "-") {
        
        defer { self.layoutIfNeeded() }
        liveStatusLabel.isActive = true
        nicknameLabel.text = model.name
        

        if type == .starOfTheDay {
            liveStatusLabel.makeHidden()
            onLiveIndicator.makeVisible()
        } else {
            liveStatusLabel.makeVisible()
            onLiveIndicator.makeHidden()
            onLiveIndicator.image = nil
        }
        
        avatarView.avatarInfo = model.avatarInfo()
        
        setupRankModel(rank, row: row)
        
        rankChangeContainer.isHidden = false
        if rank.previousLevel == 0 {
            rankChangeStackView.isHidden = true
            rankChangeNewIcon.isHidden = false
        } else if rank.level < rank.previousLevel {
            rankChangeNewIcon.isHidden = true
            rankChangeStackView.isHidden = false
            rankChangedIcon.image = UIImage.set_image(named: "icSOTDRankUp")
            rankChangedLabel.text = "\(rank.previousLevel - rank.level)"
            rankChangedLabel.applyStyle(.regular(size: 12, color: UIColor(red: 44/255, green: 204/255, blue: 53/255, alpha: 1.0)))
        } else if rank.level > rank.previousLevel {
            rankChangeNewIcon.isHidden = true
            rankChangeStackView.isHidden = false
            rankChangedIcon.image = UIImage.set_image(named: "icSOTDRankDown")
            rankChangedLabel.text = "\(rank.level - rank.previousLevel)"
            rankChangedLabel.applyStyle(.regular(size: 12, color: UIColor(red: 244/255, green: 87/255, blue: 87/255, alpha: 1.0)))
        }
    }
}


class RankButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        self.titleLabel?.textColor = .white
        self.titleLabel?.font = AppTheme.Font.semibold(12)
    }
    
    func setRow(_ row: Int, type: LiveType = .event) {
        switch row {
        case 1...3:
            self.setTitle(nil, for: .normal)
            let imageName = "ic_tipper_\(row)"
            self.setImage(UIImage.set_image(named: imageName), for: .normal)
        default:
            self.setImage(nil, for: .normal)
            self.setTitle(row.stringValue, for: .normal)
        }
    }
}

class LiveStatusLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        self.font = UIFont.systemMediumFont(ofSize: 10)
    }
    
    var isActive: Bool = false {
        didSet {
            if self.isActive {
                self.text = "text_live_now".localized.uppercased()
                self.textColor = UIColor(hex: 0xff4545)?.withAlphaComponent(0.85)
            } else {
                self.text = "text_offline".localized.uppercased()
                self.textColor = UIColor(hex: 0xcbcbcb)?.withAlphaComponent(0.85)
            }
        }
    }
    
}
