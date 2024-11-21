//
//  LiveStarListFirstThreeView.swift
//  Yippi
//
//  Created by CC Teoh on 10/08/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit
import SnapKit
import FLAnimatedImage

enum LiveStarPlace {
    case first
    case second
    case third
}

enum RankType {
    case sticker
    case live
}

class RankingFirstThreeView: UIView {
    let pkIconImage = UIImage.set_image(named: "ic_pk")

    var liveStarPlace: LiveStarPlace?

    var rankType: RankType { return .live }
    
    private let bgView = UIView().configure {
        let img = UIImage.set_image(named: "icTopThreeBg")
        $0.layer.contents = img?.cgImage
    }

    private var viewContainer = UIStackView().configure {
        $0.backgroundColor = .clear
        $0.axis = .vertical
        $0.spacing = 8
        $0.alignment = .center
        $0.distribution = .fill
    }
    
    var emptyLabel = UILabel().configure {
        $0.backgroundColor = .clear
        $0.applyStyle(.regular(size: 10, color: UIColor(hex: 0x0091E0)))
        $0.text = "sotd_top_rank_placeholder_text".localized
        $0.textAlignment = .center
    }

    
    var nameLabel = UILabel().configure {
        $0.backgroundColor = .clear
        $0.applyStyle(.regular(size: 14, color: UIColor.black.withAlphaComponent(0.85)))
        $0.text = ""
        $0.textAlignment = .center
        $0.bounds.inset(by: UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16))

    }

    var resultView = UIStackView().configure {
        $0.axis = .horizontal
        $0.distribution = .fill
        $0.spacing = 4
        $0.backgroundColor = .clear
    }
    
    var crownImageView = UIImageView().configure {
        $0.backgroundColor = .clear
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = false
    }
    
    var resultLabel = UILabel().configure {
        $0.text = ""
        $0.applyStyle(.regular(size: 14, color: UIColor(hex: 0x888888)))
    }
    
    var pkIcon = UIImageView().configure {
        $0.backgroundColor = .clear
        $0.contentMode = .scaleAspectFit
    }

    var statusView = FLAnimatedImageView().configure {
        $0.backgroundColor = .clear
        $0.sd_setImage(with: Bundle.main.url(forResource: "blue-v3", withExtension: ".gif"), completed: nil)
    }
    
    private var avatarContainer = UIView().configure {
        $0.backgroundColor = .green
        $0.contentMode = .scaleAspectFill
    }

    var avatarView = AvatarView(type: .width70(showBorderLine: false))
    
    init(liveStarPlace: LiveStarPlace = .second) {
        self.liveStarPlace = liveStarPlace
        super.init(frame: CGRect.zero)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        
        switch self.liveStarPlace {
        case .first:
            avatarContainer.backgroundColor = UIColor(hex: 0xFED03C)
            
            crownImageView.image = UIImage.set_image(named: "icFirstPlace")?.rotatedImage(with: 220)
            avatarView = AvatarView(type: .width70(showBorderLine: false))
        case .second:
            avatarContainer.backgroundColor = UIColor(hex: 0xDCDCDC)
            crownImageView.image = UIImage.set_image(named: "icSecondPlace")?.rotatedImage(with: 220)
            avatarView = AvatarView(type: .width60(showBorderLine: false))
        case .third:
            avatarContainer.backgroundColor = UIColor(hex: 0xFCC9C1)
            crownImageView.image = UIImage.set_image(named: "icThirdPlace")?.rotatedImage(with: 220)
            avatarView = AvatarView(type: .width60(showBorderLine: false))
            default: break
        }
        avatarView.backgroundColor = .clear
        avatarView.clipsToBounds = true

        avatarContainer.addSubview(avatarView)

        resultView.addArrangedSubview(resultLabel)
        resultView.addArrangedSubview(pkIcon)

        viewContainer.addArrangedSubview(avatarContainer)
        viewContainer.addArrangedSubview(nameLabel)
        viewContainer.addArrangedSubview(resultView)
        viewContainer.addArrangedSubview(statusView)
        
        bgView.addSubview(emptyLabel)
        
        addSubview(bgView)
        addSubview(viewContainer)
        addSubview(crownImageView)

        updateConstraint()
        
        emptyLabel.makeHidden()
    }
    
    func emptyModel() {
        let info = AvatarInfo(avatarURL: "", verifiedInfo: nil)
        info.avatarPlaceholderType = .liveAvatar
        avatarView.avatarInfo = info
        nameLabel.text = ""
        resultLabel.text = ""
        statusView.alpha = 0
        pkIcon.image = nil
        emptyLabel.makeVisible()
    }
    
    func updateModel(_ model: StarSlotModel?) {
        
        if let model = model {

            avatarView.avatarInfo = model.avatarInfo()
            nameLabel.text = model.name
            resultLabel.text = model.rank?.score.abbStartFrom5Digit
            pkIcon.image = pkIconImage
            emptyLabel.makeHidden()

            if model.status != YPLiveStatus.onlive.rawValue {
                statusView.alpha = 0
            } else {
                statusView.alpha = 1
            }
            
        } else {
            emptyModel()
        }
    }
    
    private func updateConstraint() {
        
        crownImageView.snp.makeConstraints {
            $0.right.equalTo(avatarContainer.snp.right).offset(0)
            $0.top.equalTo(avatarContainer.snp.top).offset(-10)
            $0.height.width.equalTo(24)
        }
        
        avatarView.snp.makeConstraints {
            switch self.liveStarPlace {
            case .first:
                $0.height.width.equalTo(70)
            default:
                $0.height.width.equalTo(60)
            }
            $0.left.right.top.bottom.equalToSuperview().inset(2)
        }
        
        avatarContainer.snp.makeConstraints {
            switch self.liveStarPlace {
            case .first:
                $0.height.width.equalTo(70)
            default:
                $0.height.width.equalTo(60)
            }
        }
        
        resultLabel.snp.makeConstraints {
            $0.height.equalTo(15)
        }
        
        pkIcon.snp.makeConstraints {
            $0.height.width.equalTo(22)
        }
        
        nameLabel.snp.makeConstraints {
            $0.height.equalTo(17)
            $0.left.right.equalToSuperview().inset(4)
        }

        resultView.snp.makeConstraints {
            $0.height.equalTo(15)
        }

        statusView.snp.makeConstraints {
            $0.width.equalTo(13)
            $0.height.equalTo(13)
        }
        
        emptyLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            switch self.liveStarPlace {
            case .first:
                $0.centerY.equalToSuperview().offset(-10)
            case .second:
                $0.centerY.equalToSuperview().offset(-10)
            case .third:
                $0.centerY.equalToSuperview().offset(-15)
            default:break
            }

        }
        
        bgView.snp.makeConstraints {
            switch self.liveStarPlace {
            case .first:
                $0.top.equalToSuperview().offset(35)
            case .second:
                $0.top.equalToSuperview().offset(40)
            case .third:
                $0.top.equalToSuperview().offset(45)
            default:break
            }
            
            $0.left.right.bottom.equalToSuperview()
        }
        
        viewContainer.snp.makeConstraints {
            
            if self.liveStarPlace == .first {
                $0.top.equalToSuperview()
            } else {
                $0.top.equalToSuperview().offset(10)
            }
            
            $0.left.right.equalToSuperview()

            if self.rankType == .live {
                $0.bottom.equalToSuperview().offset(-50)
            } else {
                $0.bottom.equalToSuperview()
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        avatarContainer.roundCorner(avatarContainer.bounds.height / 2)
        switch self.liveStarPlace {
        case .first:
            avatarView.buttonForAvatar.roundCorner(35)
        default:
            avatarView.buttonForAvatar.roundCorner(30)
        }
        switch rankType {
            case .live:
                avatarContainer.clipsToBounds = false
                crownImageView.clipsToBounds = false
                avatarView.clipsToBounds = false
            case .sticker:
                avatarContainer.clipsToBounds = true
                crownImageView.clipsToBounds = true
                avatarView.clipsToBounds = true
        }

    }
    
    override class var requiresConstraintBasedLayout: Bool {
      return true
    }
}
