////
////  ChatSettingCell.swift
////  Yippi
////
////  Created by Yong Tze Ling on 02/05/2019.
////  Copyright © 2019 Toga Capital. All rights reserved.
////
//
//import UIKit
//
//class ChatSettingCell: UITableViewCell {
//
//    static let cellIdentifier = "ChatSettingCell"
//
//    let switchControl = UISwitch(frame: .zero)
//    var chatSetting: SettingData?
//
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: .value1, reuseIdentifier: ChatSettingCell.cellIdentifier)
//        self.textLabel?.font = UIFont.systemFont(ofSize: 14)
//        self.textLabel?.textColor = TSColor.normal.blackTitle
//        self.textLabel?.textAlignment = .left
//        self.detailTextLabel?.font = UIFont.systemFont(ofSize: 14)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    func setInfo(_ setting: SettingData?, isGroup: Bool = false, delegate: UIViewController) {
//        guard let setting = setting else {
//            return
//        }
//        self.textLabel?.text = setting.name
//
//        self.accessoryView = nil
//
//        if setting.showSwitch {
//            switchControl.isOn = setting.switchValue ?? false
//            switchControl.addTarget(delegate, action: setting.selector, for: .valueChanged)
//            self.accessoryView = switchControl
//        }
//
//        if let detail = setting.detailValue {
//            self.detailTextLabel?.text = detail
//        } else {
//            self.detailTextLabel?.text = nil
//        }
//
//        if setting.showImage {
//            let avatarinfo = AvatarInfo()
//            avatarinfo.avatarURL = setting.imageUrl
//            let avatarView = AvatarView(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
//            avatarView.avatarInfo = avatarinfo
//            avatarView.avatarPlaceholderType = isGroup ? .group : .unknown
//            self.accessoryView = avatarView
//        }
//
//        self.accessoryType = setting.showDisclosureIndicator ? .disclosureIndicator : .none
//    }
//}
