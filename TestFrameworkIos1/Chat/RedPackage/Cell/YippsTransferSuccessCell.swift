//
//  YippsTransferSuccessCell.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/7/5.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit

class YippsTransferSuccessCell: UITableViewCell {

    let titleL = UILabel().configure {
        $0.textColor = UIColor(red: 136, green: 136, blue: 136)
        $0.font = UIFont.systemFont(ofSize: 14)
    }
    let contentL = UILabel().configure {
        $0.textColor = .black
        $0.font = UIFont.systemFont(ofSize: 16)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI(){
        addSubview(titleL)
        addSubview(contentL)
        titleL.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(15)
            make.height.equalTo(16)
        }
        contentL.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(titleL.snp.bottom).offset(4)
            make.height.equalTo(22)
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
