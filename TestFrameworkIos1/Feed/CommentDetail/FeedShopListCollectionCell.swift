//
//  FeedShopListCollectionCell.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2023/10/12.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit
import SDWebImage


class FeedShopListCollectionCell: UICollectionViewCell, BaseCellProtocol {

    private let stackView: UIStackView = UIStackView().configure {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .fill
        //$0.backgroundColor = AppTheme.primaryLightGreyColor
        $0.spacing = 8
    }
    
    //头像
    private let avatarImageView = UIImageView().configure {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        
    }
    //认证标识
    private let certificationImageView = UIImageView().configure {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    //商店名称
    private let nameLabel: UILabel = UILabel().configure {
        $0.numberOfLines = 1
        $0.textColor = UIColor(hex: 0x004FFF)
        $0.text = "-"
        $0.setFontSize(with: 14, weight: .medium)
    }
    //商店评分
    private let scoreLabel: UILabel = UILabel().configure {
        $0.numberOfLines = 1
        $0.textColor = UIColor(hex: 0x737373)
        $0.text = "-"
        $0.setFontSize(with: 10, weight: .norm)
    }
    //商店优惠
    private let saleLabel: UILabel = UILabel().configure {
        $0.numberOfLines = 2
        $0.textColor = UIColor(hex: 0x242424)
        $0.text = "-"
        $0.setFontSize(with: 12, weight: .norm)
    }
    private lazy var shopProfileBtn: FeedShopButton = {
        let button = FeedShopButton()
        button.imageView.image = UIImage.set_image(named: "ic_feed_shop_info_icon")
        button.imageView.image = button.imageView.image?.withRenderingMode(.alwaysTemplate)
        button.imageView.tintColor = .black
        button.titleLabel.text = "dashboard_profile".localized
        button.addAction { [weak self] in
            guard TSCurrentUserInfo.share.isLogin else {
                TSRootViewController.share.guestJoinLandingVC()
                return
            }
            guard let self = self else { return }
//            self.delegate?.rewardDidTapped(view: self)
        }
        return button
    }()
    public lazy var shopInfoBtn: FeedShopButton = {
        let button = FeedShopButton()
        button.imageView.image = UIImage.set_image(named: "ic_feed_shop_icon")
        button.imageView.image = button.imageView.image?.withRenderingMode(.alwaysTemplate)
        button.titleLabel.text = "profile_tab_shop".localized
        return button
    }()
    
    let rebateOffsetView = OffsetRebateView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.masksToBounds = false
        //contentView.backgroundColor = AppTheme.primaryLightGreyColor
        contentView.roundCorner()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.bindToEdges()
        
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        let avatarView = UIView(frame: .zero)
        avatarView.addSubViews([avatarImageView,certificationImageView])
        
        
        stackView.addArrangedSubview(avatarView)
        avatarView.snp.makeConstraints {
            $0.width.equalTo(60)
        }
        
        avatarImageView.roundCorner(25)
        avatarImageView.snp.makeConstraints {
            $0.height.width.equalTo(50)
            $0.centerX.centerY.equalToSuperview()
        }
        
        certificationImageView.snp.makeConstraints {
            $0.trailing.bottom.equalTo(avatarImageView)
            $0.height.width.equalTo(24)
        }
        
        let labelStackView = UIStackView(frame: .zero)
        labelStackView.axis = .vertical
        labelStackView.distribution = .fill
        labelStackView.alignment = .fill
        labelStackView.spacing = 5
        
        labelStackView.addArrangedSubview(nameLabel)
        labelStackView.addArrangedSubview(scoreLabel)
        //labelStackView.addArrangedSubview(saleLabel)
        
        let offsetOuterView = UIView()
        labelStackView.addArrangedSubview(offsetOuterView)
        
        offsetOuterView.snp.makeConstraints {
            $0.height.equalTo(25)
        }
        
        offsetOuterView.addSubview(rebateOffsetView)
        rebateOffsetView.snp.makeConstraints {
            $0.top.left.bottom.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.8)
        }
        
//        labelStackView.addArrangedSubview(rebateOffsetView)
//        
//        rebateOffsetView.snp.makeConstraints {
//            $0.height.equalTo(25)
//        }
        
        stackView.addArrangedSubview(labelStackView)
        
        nameLabel.snp.makeConstraints {
            $0.height.equalTo(20)
        }
        scoreLabel.snp.makeConstraints {
            $0.height.equalTo(20)
        }
//        labelStackView.snp.makeConstraints {
//            $0.top.bottom.equalToSuperview().inset(10)
//        }
        
        let dummyViewOne = UIView()
        let dummyViewTwo = UIView()
        let buttonStackView = UIStackView(frame: .zero)
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
        buttonStackView.alignment = .center
        buttonStackView.spacing = 10
        buttonStackView.addArrangedSubview(shopProfileBtn)
        buttonStackView.addArrangedSubview(shopInfoBtn)
        
        //stackView.addArrangedSubview(dummyViewOne)
        stackView.addArrangedSubview(buttonStackView)
        //stackView.addArrangedSubview(dummyViewTwo)
        
        buttonStackView.snp.makeConstraints {
            $0.width.equalTo(100)
        }
        
//        dummyViewOne.snp.makeConstraints {
//            $0.width.equalTo(5)
//        }
//        
//        dummyViewTwo.snp.makeConstraints {
//            $0.width.equalTo(5)
//        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setData(merchant: TSRewardsLinkMerchantUserModel, isDarkBackground: Bool = false) {
        nameLabel.text = merchant.userName
        scoreLabel.text = "\(merchant.rating) \("rewardslink_rating".localized)"
        saleLabel.text = merchant.desc
    
        rebateOffsetView.rebate = merchant.merchantRebate
        rebateOffsetView.offset = merchant.merchantOffset
        
        self.avatarImageView.sd_setImage(with: URL(string: merchant.avatar), placeholderImage: UIImage.set_image(named: "icPicturePostPlaceholder"), options: [SDWebImageOptions.lowPriority, .refreshCached], completed: nil)
        
        self.certificationImageView.sd_setImage(with: URL(string: merchant.certificationIconUrl), placeholderImage: nil)
        
        shopProfileBtn.addAction { [weak self] in
            guard TSCurrentUserInfo.share.isLogin else {
                TSRootViewController.share.guestJoinLandingVC()
                return
            }
            guard let self = self else { return }
         
            NotificationCenter.default.post(name: NSNotification.Name.AvatarButton.DidClick, object: nil, userInfo: ["uid": merchant.merchantId.stringValue])
        }
        
        if isDarkBackground {
            nameLabel.textColor = .white
            scoreLabel.textColor = .white
            saleLabel.textColor = .white
            shopProfileBtn.imageView.tintColor = .white
            shopProfileBtn.titleLabel.textColor = .white
            shopInfoBtn.imageView.tintColor = .white
            shopInfoBtn.titleLabel.textColor = .white
        } else {
            nameLabel.textColor = UIColor(hex: 0x242424)
            scoreLabel.textColor = UIColor(hex: 0x737373)
            saleLabel.textColor = UIColor(hex: 0x737373)
            shopProfileBtn.imageView.tintColor = UIColor(hex: 0x737373)
            shopProfileBtn.titleLabel.textColor = UIColor(hex: 0x242424)
            shopInfoBtn.imageView.tintColor = UIColor(hex: 0x737373)
            shopInfoBtn.titleLabel.textColor = UIColor(hex: 0x242424)
        }
    }
}

class FeedShopButton: UIView {
    let imageView: UIImageView = UIImageView(frame: .zero).configure {
        $0.contentMode = .scaleAspectFit
    }
    let titleLabel: UILabel = UILabel().configure {
        $0.applyStyle(.regular(size: 10, color: UIColor(hex: 0x242424)))
    }
    private let stackview = UIStackView().configure {
        $0.axis = .vertical
        $0.distribution = .fill
        $0.alignment = .center
        $0.spacing = 3
    }
    
    init() {
        super.init(frame: .zero)
        addSubview(stackview)
        
        stackview.bindToEdges()
        
        stackview.addArrangedSubview(imageView)
        stackview.addArrangedSubview(titleLabel)
        
        imageView.snp.makeConstraints {
            $0.width.height.equalTo(30)
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
