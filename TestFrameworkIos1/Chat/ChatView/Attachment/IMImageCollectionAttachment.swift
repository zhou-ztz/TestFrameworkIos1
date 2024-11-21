//
//  IMImageCollectionAttachment.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/4/12.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit

class IMImageCollectionAttachment: NSObject , Codable{
    
    var md5: String = ""
    var url: String = ""
    var ext: String = ""
    var name: String = ""
    var size: Int64 = 0
    var h: CGFloat = 0
    var w: CGFloat = 0
    var sen: String? = ""
    var path: String? = ""
    var force_upload: Bool? = false
    
    enum CodingKeys: String, CodingKey {
        case md5 = "md5"
        case url = "url"
        case ext = "ext"
        case size = "size"
        case name = "name"
        case h = "h"
        case w = "w"
        case sen = "sen"
        case path = "path"
        case force_upload = "force_upload"
    }
    
    init(md5: String, url: String, size: Int64, h: CGFloat, w: CGFloat, name: String, ext: String, sen: String, path: String, force_upload: Bool) {
        self.md5 = md5
        self.url = url
        self.size = size
        self.h = h
        self.w = w
        self.name = name
        self.ext = ext
        self.sen = sen
        self.path = path
        self.force_upload = force_upload
        super.init()
    }
  
    func encode() -> String {
        
        let dictContent: [String : Any] = ["md5": self.md5,
                                           "url": self.url,
                                           "ext": self.ext,
                                           "name": self.name,
                                           "size" : self.size,
                                           "h": self.h,
                                           "w": self.w,
                                           "sen": self.sen,
                                            "path": self.path,
                                            "force_upload": self.force_upload]
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
