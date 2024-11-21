//
//  MeetingListViewCell.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2023/3/2.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit

class MeetingListViewCell: UITableViewCell {
    
    lazy var timeL: UILabel = {
        let lab = UILabel()
        lab.textColor = UIColor(hex: "#212121")
        lab.font = UIFont.systemRegularFont(ofSize: 14)
        return lab
    }()
    lazy var nameL: UILabel = {
        let lab = UILabel()
        lab.textColor = UIColor(hex: "#212121")
        lab.font = UIFont.boldSystemFont(ofSize: 14)
        return lab
    }()
    
    static let cellIdentifier = "MeetingListViewCell"
    class func nib() -> UINib {
        return UINib(nibName: cellIdentifier, bundle: nil)
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .white
        self.setUI()
    }
  
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setUI(){
        self.addSubview(timeL)
        self.addSubview(nameL)
        timeL.snp.makeConstraints { make in
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.top.equalTo(16)
            make.height.equalTo(21)
        }
        nameL.snp.makeConstraints { make in
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.height.equalTo(21)
            make.top.equalTo(timeL.snp.bottom).offset(0)
        }
        let line = UIView()
        line.backgroundColor = UIColor(hex: "#F5F5F5")
        self.addSubview(line)
        line.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(0.7)
            make.bottom.equalTo(-0.7)
        }
    }
    
    func setData(model: QuertMeetingListDetailModel?){
        self.timeL.text = (model?.created_at ?? "").toDate(from: "yyyy-MM-dd'T'HH:mm:ss.ssssssZ", to: "yyyy-MM-dd HH:mm")
        
        let string = "meeting_created_by".localized + " "
        let name = (model?.ownerNickname ?? "")
    
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemRegularFont(ofSize: 14),
            .foregroundColor: UIColor(hex: "#212121")
        ]
        
        let attr = NSMutableAttributedString(string: string + name)
        attr.addAttributes(attributes, range: NSRange(location: 0, length: string.count))
        self.nameL.attributedText = attr
        //self.nameL.text = "meeting_created_by".localized + " " + (model?.ownerNickname ?? "")
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
