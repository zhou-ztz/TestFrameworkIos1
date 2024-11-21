//
//  ProfileInfoListCell.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2022/8/12.
//  Copyright © 2022 Toga Capital. All rights reserved.
//

import UIKit

class ProfileInfoListCell: UITableViewCell, BaseCellProtocol {

    static let identifier = "ProfileInfoListCell"
    
    lazy var nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.font = .systemFont(ofSize: 14)
        nameLabel.textColor = AppTheme.black
        return nameLabel
    }()
    
    lazy var bottomSeparator = UIView().configure {
        $0.backgroundColor = UIColor(red: 237, green: 237, blue: 237)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(nameLabel)
        contentView.addSubview(bottomSeparator)
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.centerY.equalToSuperview()
        }
        bottomSeparator.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.left.equalTo(nameLabel.snp.left)
            $0.right.equalToSuperview().inset(14)
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
