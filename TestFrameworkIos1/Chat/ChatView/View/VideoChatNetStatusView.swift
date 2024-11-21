//
//  VideoChatNetStatusView.swift
//  Yippi
//
//  Created by Khoo on 25/06/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import UIKit

class VideoChatNetStatusView: UIView {
    
    var statusImageView: UIImageView?
    var statusLabel: UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    func setup () {
        self.backgroundColor = .clear
        statusImageView = UIImageView(frame: CGRect(x: 0,y: 0,width: 50,height: 50))
        statusImageView?.contentMode = .scaleAspectFit
        statusImageView?.isHidden = true
        statusLabel = UILabel(frame: .zero)
        statusLabel?.isHidden = true
        statusLabel?.backgroundColor = .clear
        statusLabel?.textColor =  UIColor(hexString: "#ffffff")
        self.addSubview(statusImageView!)
    }
    
//    func refresh(withNetState status: NIMNetCallNetStatus) {
//        let prefix = "netstat_"
//        var status = status
//        
//        switch status.rawValue {
//        case 0:
//            status = NIMNetCallNetStatus.bad
//            break
//        case 5:
//            status = NIMNetCallNetStatus.good
//            break
//        default:
//            break
//        }
//        
//        let imageName = String(format: "%@%zd", prefix, status.rawValue)
//        self.statusImageView?.image = UIImage.set_image(named: imageName)
//        self.statusLabel?.isHidden = true
//        self.statusImageView?.isHidden = false
//        
//        var netState = ""
//        switch status {
//        case .good:
//            netState = "avchat_network_grade_1".localized
//        case .poor:
//            netState = "avchat_network_grade_2".localized
//        case .bad:
//            netState = "avchat_network_grade_3".localized
//        default:
//            break
//        }
//        
//        self.statusLabel?.text = netState
//        self.statusLabel?.sizeToFit()
//    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.statusImageView?.center = CGPoint(x: self.width/2, y: self.height/2)
    }
}
