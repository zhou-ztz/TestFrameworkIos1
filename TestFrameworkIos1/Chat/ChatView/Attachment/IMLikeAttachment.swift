//
//  IMLikeAttachment.swift
//  Yippi
//
//  Created by Tinnolab on 14/07/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK
class IMLikeAttachment: NSObject, NIMCustomAttachment {
    
    func encode() -> String {

        let dict: [String : Any] = [CMType: CustomMessageType.Like.rawValue]
        var stringToReturn = "{}"
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict)
            stringToReturn = String(data: jsonData, encoding: .utf8) ?? ""
        } catch let error {
            print(error.localizedDescription)
        }
        return stringToReturn
    }
}
