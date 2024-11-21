//
//  ChatSettingButton.swift
//  Yippi
//
//  Created by Yong Tze Ling on 06/05/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import UIKit

class ChatSettingButton: UITableViewCell {

    static let cellIdentifier = "ChatSettingButton"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: ChatSettingButton.cellIdentifier)
        self.textLabel?.textAlignment = .center
        self.textLabel?.textColor = TSColor.main.warn
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTitle(_ title: String) {
        self.textLabel?.text = title
    }
}
