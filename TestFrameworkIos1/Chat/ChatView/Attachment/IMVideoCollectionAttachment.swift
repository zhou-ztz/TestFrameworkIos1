//
//  IMVideoCollectionAttachment.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/4/12.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit

class IMVideoCollectionAttachment: NSObject, Codable {

    var md5: String = ""
    var url: String = ""
    var ext: String = ""
    var size: Int64 = 0
    var dur: Int = 0 //duration
    var h: CGFloat = 0
    var w: CGFloat = 0
    var name: String = ""
    var coverUrl: String? //本地封面
    
    enum CodingKeys: String, CodingKey {
        case md5 = "md5"
        case url = "url"
        case ext = "ext"
        case size = "size"
        case name = "name"
        case h = "h"
        case w = "w"
        case dur = "dur"
        case coverUrl = "coverUrl"
    }
    
    init(md5: String, url: String, size: Int64, dur: Int, h: CGFloat, w: CGFloat, name: String, ext: String, coverUrl: String) {
        self.md5 = md5
        self.url = url
        self.size = size
        self.h = h
        self.w = w
        self.name = name
        self.dur = dur
        self.ext = ext
        self.coverUrl = coverUrl
        super.init()
    }
  
    func encode() -> String {
        
        let dictContent: [String : Any] = ["md5": self.md5,
                                           "url": self.url,
                                           "ext": self.ext,
                                           "h": self.h,
                                           "w": self.w,
                                           "name": self.name,
                                           "dur": self.dur,
                                           "size" : self.size,
                                           "coverUrl" : self.coverUrl]
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
