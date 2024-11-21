//
//  TSNoticeRejectedTableViewCell.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2023/7/31.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit

class TSNoticeRejectedTableViewCell: UITableViewCell {
    static let identifier = "NoticeRejectedListCell"
    
    private let logoContainer = UIView().configure {
        $0.backgroundColor = .clear
    }
    
    private let logoImageView = UIImageView().configure {
        $0.backgroundColor = .clear
        $0.image = UIImage.set_image(named: "ic_rejected_logo_icon")
    }
    
    private let iconImageView = UIImageView().configure {
        $0.backgroundColor = .clear
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = false
    }
    
    private let labelForRejectInfo = UILabel().configure {
        $0.setFontSize(with: 12, weight: .norm)
        $0.textColor = UIColor(red: 0, green: 0, blue: 0)
        $0.numberOfLines = 2
    }
    
    private let labelForFeedInfo = UILabel().configure {
        $0.setFontSize(with: 12, weight: .norm)
        $0.textColor = UIColor(hex: 0x808080)
    }
    
    
    private let labelForTime = UILabel().configure {
        $0.setFontSize(with: 10, weight: .norm)
        $0.textColor = UIColor(red: 128, green: 128, blue: 128)
    }
    private let detailButton = UIButton().configure {
        $0.applyStyle(.custom(text: "view".localized, textColor: AppTheme.dodgerBlue, backgroundColor: .white, cornerRadius: 0, fontWeight: .regular))
        $0.isUserInteractionEnabled = false
        $0.titleLabel?.font = UIFont.systemRegularFont(ofSize: 12)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupUI() {
        
        let feedInfoView = UIView()
        feedInfoView.backgroundColor = UIColor(hex: 0xf9f9f9)
 
        let feedStackView = UIStackView()
        feedStackView.axis = .horizontal
        feedStackView.distribution = .fill
        feedStackView.spacing = 5
        
        contentView.addSubview(logoImageView)
        contentView.addSubview(labelForRejectInfo)
        contentView.addSubview(labelForTime)

        contentView.addSubview(detailButton)
        
   
        contentView.addSubview(feedInfoView)
        feedInfoView.addSubview(feedStackView)
        feedStackView.addArrangedSubview(iconImageView)
        feedStackView.addArrangedSubview(labelForFeedInfo)
        
        logoImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.left.equalToSuperview().offset(10)
            $0.size.equalTo(CGSize(width: 30, height: 30))
        }
        
        iconImageView.snp.makeConstraints {
            $0.width.equalTo(36)
        }
        
        labelForRejectInfo.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.top)
            $0.left.equalTo(logoImageView.snp.right).offset(11)
            $0.right.equalToSuperview().offset(-70)
        }
        labelForTime.snp.makeConstraints {
            $0.top.equalTo(labelForRejectInfo.snp.bottom).offset(2)
            $0.left.equalTo(labelForRejectInfo.snp.left)
        }
        
        detailButton.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-15)
            $0.centerY.equalTo(labelForRejectInfo)
        }
        
        feedInfoView.snp.makeConstraints {
            $0.left.equalTo(labelForRejectInfo.snp.left)
            $0.right.equalTo(detailButton.snp.right)
            $0.top.equalTo(labelForTime.snp.bottom).offset(13)
            $0.height.equalTo(48)
            $0.bottom.equalToSuperview().offset(0)
        }
        
        feedStackView.snp.makeConstraints {
            $0.left.top.equalToSuperview().offset(5)
            $0.right.bottom.equalToSuperview().offset(-5)
        }
    }
    public func setNoticeReject(data: ReceiveCommentModel){
        // 时间
        labelForRejectInfo.text = "rejected_string".localized
        
        labelForTime.text = TSDate().dateString(.normal, nDate: data.createDate ?? Date())
        iconImageView.sd_setImage(with: URL(string: data.exten?.coverPath ?? ""), placeholderImage: UIImage.set_image(named: "post_placeholder"))
        labelForFeedInfo.text = data.exten?.content ?? ""
        
        if data.exten?.coverPath == "" {
            iconImageView.isHidden = true
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
