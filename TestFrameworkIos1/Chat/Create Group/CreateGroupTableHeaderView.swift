//
//  CreateGroupTableHeaderView.swift
//  Yippi
//
//  Created by TinnoLab on 12/07/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import UIKit

class CreateGroupTableHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var iconView: UIView!
    @IBOutlet weak var bottomHeaderView: UIView!
    @IBOutlet weak var coverView: UIView!
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var memberCountLabel: UILabel!
    @IBOutlet weak var groupIcon: UIImageView!
    @IBOutlet weak var cameraIcon: UIImageView!
    @IBOutlet weak var groupName: UITextField!

    var groupIconHandler: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        headerLabel.text = "title_create_group_header".localized
        headerLabel.textColor = UIColor(hexString: "#9a9a9a")
        memberCountLabel.textColor = UIColor(hexString: "#9a9a9a")
        headerView.backgroundColor = TSColor.inconspicuous.background
        bottomHeaderView.backgroundColor = TSColor.inconspicuous.background
        groupIcon.circleCorner()
        groupIcon.clipsToBounds = true
        groupIcon.image = UIImage.set_image(named: "ic_rl_default_group")
        groupIcon.contentMode = .scaleToFill
        cameraIcon.circleCorner()
        cameraIcon.clipsToBounds = true
        cameraIcon.image = UIImage.set_image(named: "icRedcamera")
        groupName.placeholder = "group_name".localized
        let tap = UITapGestureRecognizer(target: self, action: #selector(iconViewDidTapped(_:)))
        iconView.addGestureRecognizer(tap)
    }

    @objc func iconViewDidTapped(_ tapped: UITapGestureRecognizer) {
        self.groupIconHandler?()
    }

    func setBottomHeader(count: Int) {
        memberCountLabel.text = String(format: "member_count".localized, count)
    }

}
