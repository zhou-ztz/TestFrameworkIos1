//
//  IMLocationCollectionAttachment.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/4/12.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit

class IMLocationCollectionAttachment: NSObject, Codable {

    var title: String = ""
    var lat: Double = 0
    var lng: Double = 0
    
    enum CodingKeys: String, CodingKey {
        case title = "title"
        case lat = "lat"
        case lng = "lng"
    }
    
    init(title: String, lat: Double, lng: Double) {
        self.title = title
        self.lat = lat
        self.lng = lng
        super.init()
    }
  
    func encode() -> String {
        
        let dictContent: [String : Any] = ["title": self.title,
                                           "lat": self.lat,
                                           "lng": self.lng]
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
