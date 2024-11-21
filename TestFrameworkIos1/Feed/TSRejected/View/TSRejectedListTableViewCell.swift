//
//  TSRejectedListTableViewCell.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2023/7/21.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit

class TSRejectedListTableViewCell: UITableViewCell {
    static let identifier = "RejectedListCell"
    
    private let iconImageView = UIImageView().configure {
        $0.backgroundColor = .clear
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    private let labelForRejectInfo = UILabel().configure {
        $0.setFontSize(with: 12, weight: .norm)
        $0.textColor = UIColor(red: 0, green: 0, blue: 0)
    }
    
    private let labelForTime = UILabel().configure {
        $0.setFontSize(with: 10, weight: .norm)
        $0.textColor = UIColor(red: 128, green: 128, blue: 128)
    }
    private let detailButton = UIButton().configure {
        $0.applyStyle(.custom(text: "view".localized, textColor: AppTheme.red, backgroundColor: .white, cornerRadius: 0, fontWeight: .regular))
        $0.titleLabel?.font = UIFont.systemRegularFont(ofSize: 12)
        $0.isUserInteractionEnabled = false
    }
    
    // video 图标
    private let videoIconView = UIImageView().configure {
        $0.isHidden = true
        $0.image = UIImage.set_image(named: "ic_feed_video_icon")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        let mainStackView = UIStackView()
        let labelView = UIView()
        
      
        labelView.addSubview(labelForRejectInfo)
        labelView.addSubview(labelForTime)

        mainStackView.axis = .horizontal
        mainStackView.distribution = .fill
        mainStackView.spacing = 8

        mainStackView.addArrangedSubview(iconImageView)
        mainStackView.addArrangedSubview(labelView)
        
        iconImageView.addSubview(videoIconView)
        labelView.addSubview(detailButton)
        
        contentView.addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.left.equalToSuperview().offset(13)
            $0.bottom.equalToSuperview().offset(-13)
            $0.right.equalToSuperview().offset(-5)
        }
        
        iconImageView.snp.makeConstraints {
            $0.width.equalTo(40)
        }
        
        labelForRejectInfo.snp.makeConstraints {
            $0.top.equalTo(5)
            $0.left.right.equalToSuperview()
        }
        labelForTime.snp.makeConstraints {
            $0.top.equalTo(labelForRejectInfo.snp.bottom).offset(5)
            $0.left.right.equalToSuperview()
        }
        detailButton.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-10)
            $0.centerY.equalTo(labelForRejectInfo)
        }
        videoIconView.snp.makeConstraints {
            $0.width.equalTo(16)
            $0.height.equalTo(18)
            $0.top.right.equalToSuperview().offset(0)
        }
    }
    public func setReject(data: RejectListModel){
        // 时间
        labelForRejectInfo.text = "rejected_string".localized
        labelForTime.text = TSDate().dateString(.normal, nDate: data.createdAt)
        iconImageView.sd_setImage(with: URL(string: data.cover), placeholderImage: UIImage.set_image(named: "ic_rejected_default"))
        videoIconView.isHidden = !data.isVideo
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
