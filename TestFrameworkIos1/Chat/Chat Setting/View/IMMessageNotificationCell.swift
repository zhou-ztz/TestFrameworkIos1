//
//  IMMessageNotificationCell.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/3/25.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit

class IMMessageNotificationCell: UITableViewCell {
    
    var titleL = UILabel()
    var contentL = UILabel()
    var switchBtn: UISwitch!
    var imageIcon = UIImageView().configure {
        $0.image = UIImage.set_image(named: "icon_accessory_normal")
        $0.isHidden = true
    }
    static let cellIdentifier = "IMMessageNotificationCell"
    class func nib() -> UINib {
        return UINib(nibName: cellIdentifier, bundle: nil)
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setUI()
    }
  
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setUI(){
        titleL.textColor = .black
        self.contentView.addSubview(titleL)
        titleL.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.right.equalTo(-45)
            make.bottom.top.equalTo(0)
        }
        
        contentL.textColor = .black
        contentL.textAlignment = .right
        self.contentView.addSubview(contentL)
        contentL.snp.makeConstraints { (make) in
            make.right.equalTo(-16)
            make.bottom.top.equalTo(0)
        }
        contentL.isHidden = true
        self.switchBtn = UISwitch()
        self.contentView.addSubview(switchBtn)
        switchBtn.transform = CGAffineTransform( scaleX: 0.8, y: 0.78)
        switchBtn.onTintColor = TSColor.main.theme
        switchBtn.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(-12)
            
        }
        switchBtn.isHidden = true
        titleL.font = UIFont.systemFont(ofSize: 16)
        contentL.font = UIFont.systemFont(ofSize: 14)
        
        self.contentView.addSubview(imageIcon)
        imageIcon.snp.makeConstraints { make in
            make.height.width.equalTo(20)
            make.centerY.equalToSuperview()
            make.right.equalTo(-16)
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
