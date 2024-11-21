//
//  IMTranslate.swift
//  Yippi
//
//  Created by Francis Yeap on 14/09/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation

struct IMTranslateRequestType: RequestType {
    typealias ResponseType = IMTranslateModel
    
    var text: String = ""
    
    var data: YPRequestData {
        return YPRequestData(
            path: "/api/v2/translates/text",
            method: .post, params: [
                "text": "\(text)"
        ])
    }
}

struct IMTranslateModel : Codable {
    let text : String?

    enum CodingKeys: String, CodingKey {
        case text = "message"
    }
}
