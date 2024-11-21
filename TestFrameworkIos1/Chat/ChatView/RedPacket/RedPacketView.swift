//
//  RedPacketView.swift
//  Yippi
//
//  Created by Kit Foong on 23/05/2023.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import Foundation
import UIKit
import NIMSDK

class RedPacketView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var openEggView: UIView!
    @IBOutlet weak var eggImageView: UIImageView!
    @IBOutlet weak var avatarView: AvatarView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    private var openEggTapGesture : UITapGestureRecognizer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    private func setupUI() {
        Bundle.main.loadNibNamed(String(describing: RedPacketView.self), owner: self, options: nil)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        self.addSubview(contentView)
        
        avatarView.avatarPlaceholderType = .unknown
        
        nameLabel.font = AppFonts.Headline.bold12.font
        nameLabel.numberOfLines = 1
        descriptionLabel.font = AppFonts.Body.regular12.font
        descriptionLabel.numberOfLines = 3
        descriptionLabel.sizeToFit()
        
        openEggView.roundCorner(55)
    }
    
    func updateInfo(avatarInfo: AvatarInfo, name: String, message: String, uids: NSArray? = nil, completion: (() -> Void)? = nil) {
        avatarView.avatarInfo = avatarInfo
        nameLabel.text = "title_sender_send_packet".localized.replacingFirstOccurrence(of: "%s", with: name)

        if let uids = uids, uids.count > 0, let uidsList = uids as? [String] {
            if uidsList.contains(NIMSDK.shared().loginManager.currentAccount()) {
                eggImageView.image = UIImage.set_image(named: "open_egg_icon")
                openEggView.isUserInteractionEnabled = true
                
                if message.isEmpty {
                    descriptionLabel.text = "rw_red_packet_best_wishes".localized
                } else {
                    descriptionLabel.text = message
                }
            } else {
                eggImageView.image = UIImage.set_image(named: "unable_open_egg_icon")
                openEggView.isUserInteractionEnabled = false
                descriptionLabel.text = "title_specific_packet_title".localized.replacingFirstOccurrence(of: "%s", with: uidsList.first ?? "")
            }
        } else {
            eggImageView.image = UIImage.set_image(named: "open_egg_icon")
            openEggView.isUserInteractionEnabled = true
            
            if message.isEmpty {
                descriptionLabel.text = "rw_red_packet_best_wishes".localized
            } else {
                descriptionLabel.text = message
            }
        }
        
        completion?()
    }
}
