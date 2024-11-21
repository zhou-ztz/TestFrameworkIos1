// 
// Copyright © 2018 Toga Capital. All rights reserved.
//


import Foundation

struct transferPoints: APIRequest {
    typealias Response = TransferResponse
    
    var resourceName: String {
        return "/reward/api/transfer"
    }
    
    var requestMethod: RequestMethod {
        return .post
    }
    
    let username: String
    let receiver: String
    let amount: String
    let note: String
    let password: String
    
    
    init(username: String, receiver: String, amount: String, note: String, password: String) {
        self.username = username
        self.receiver = receiver
        self.amount = amount
        self.note = note
        self.password = password
    }
    
    enum CodingKeys: String, CodingKey {
        case username = "username"
        case receiver = "receiver"
        case amount = "amount"
        case note = "note"
        case password = "password"
    }
}
