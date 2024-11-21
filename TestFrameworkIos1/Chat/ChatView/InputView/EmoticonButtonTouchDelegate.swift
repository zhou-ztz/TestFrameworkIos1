//
//  EmoticonButtonTouchDelegate.swift
//  Yippi
//
//  Created by Khoo on 13/07/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import UIKit
protocol EmoticonButtonTouchDelegate {
    func selectedEmoticon (emoticon:String, catalogID: String, stickerId: String)
    func addCustomerSticker()
}

class InputEmoticonButton: UIButton {
    var emoticonData: InputEmoticon? = nil
    var catalogID: String = ""
    var delegate: EmoticonButtonTouchDelegate?
    var stickerId: String = ""
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func iconButtonWithData(data: InputEmoticon, catalogID: String, delegate:EmoticonButtonTouchDelegate) -> InputEmoticonButton {
        let icon = InputEmoticonButton(frame: .zero)
        icon.addTarget(self, action: #selector(onIconSelected(_:)), for: .touchUpInside)
        
        icon.emoticonData = data
        icon.catalogID = catalogID
        icon.isUserInteractionEnabled = true
        icon.isExclusiveTouch = true
        icon.contentMode = .scaleToFill
        icon.delegate = delegate
        
        if let unicode = data.unicode, unicode.count > 0 {
            icon.setTitle(unicode, for: .normal)
            icon.setTitle(unicode, for: .highlighted)
            icon.titleLabel?.font = UIFont.systemFont(ofSize: 32)
        } else if let filename = data.filename, filename.count > 0 {
            let image = UIImage.set_image(named: filename)
            icon.setImage(image, for: .normal)
            icon.setImage(image, for: .highlighted)
        }
            
        return icon
    }
    
    @objc func onIconSelected (_ sender: Any) {
        delegate?.selectedEmoticon(emoticon: self.emoticonData?.emoticonID ?? "", catalogID: self.catalogID, stickerId: self.stickerId)
    }
}
