//
//  File.swift
//  Yippi
//
//  Created by Francis Yeap on 18/02/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation


struct SocialTokenApplySlotRequestType: RequestType {
    typealias ResponseType = SocialTokenBalanceModel
    
    var id: Int
    
    var data: YPRequestData {
        return YPRequestData(
            path: "/api/v2/event-slot/applyToken",
            method: .post, params: ["slot_id": id])
    }
}
