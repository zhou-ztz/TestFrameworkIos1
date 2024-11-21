//
//  IMFileCollectionAttachment.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/4/12.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit

class IMFileCollectionAttachment: NSObject , Codable{

    var md5: String = ""
    var url: String = ""
    var ext: String = ""
    var name: String = ""
    var size: Int64 = 0
    var sence: String? = ""
    
    enum CodingKeys: String, CodingKey {
        case md5 = "md5"
        case url = "url"
        case ext = "ext"
        case size = "size"
        case name = "name"
        case sence = "sence"
    }
    
    init(md5: String, url: String, size: Int64, sence: String, name: String, ext: String) {
        self.md5 = md5
        self.url = url
        self.size = size
        self.sence = sence
        self.name = name
        self.ext = ext
        super.init()
    }
  
    func encode() -> String {
        
        let dictContent: [String : Any] = ["md5": self.md5,
                                           "url": self.url,
                                           "ext": self.ext,
                                           "name": self.name,
                                           "sence": self.sence,
                                           "size" : self.size]
        var stringToReturn = "{}"
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dictContent)
            stringToReturn = String(data: jsonData, encoding: .utf8) ?? ""
        } catch let error {
            print(error.localizedDescription)
        }
        return stringToReturn
        
    }
}
