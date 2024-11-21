//
//  ProfileLanguageListCell.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2022/8/11.
//  Copyright © 2022 Toga Capital. All rights reserved.
//

import UIKit

class ProfileLanguageListCell: UITableViewCell, BaseCellProtocol {

    static let identifier = "ProfileLanguageListCell"
    
    lazy var languageNameLabel: UILabel = {
        let languageNameLabel = UILabel()
        languageNameLabel.font = .systemFont(ofSize: 14)
        languageNameLabel.textColor = AppTheme.black
        return languageNameLabel
    }()
    
    lazy var selectImageBtn: UIButton = {
        let selectImageBtn = UIButton()
        selectImageBtn.isUserInteractionEnabled = false
        selectImageBtn.setImage(UIImage.set_image(named: "ic_checkbox_normal"), for: .normal)
        selectImageBtn.setImage(UIImage.set_image(named: "ic_rl_checkbox_selected"), for: .selected)
        return selectImageBtn
    }()
    
    lazy var bottomSeparator = UIView().configure {
        $0.backgroundColor = UIColor(red: 237, green: 237, blue: 237)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(languageNameLabel)
        contentView.addSubview(selectImageBtn)
        contentView.addSubview(bottomSeparator)
        
        languageNameLabel.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.centerY.equalToSuperview()
        }
        selectImageBtn.snp.makeConstraints { make in
            make.right.equalTo(-16)
            make.centerY.equalToSuperview()
        }
        bottomSeparator.snp.makeConstraints {
            $0.bottom.left.right.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
