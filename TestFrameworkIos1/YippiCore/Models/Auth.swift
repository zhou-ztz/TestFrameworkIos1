// 
// Copyright © 2018 Toga Capital. All rights reserved.
//


import Foundation

public struct ActivationCode: Decodable {
    public let to: String?
    public let requestId: String
    public let resendTimer: NSInteger
    
    enum CodingKeys: String, CodingKey {
        case to
        case requestId = "request_id"
        case resendTimer = "resend_timer"
    }
}

public struct VerifyCodeResponse: Decodable {
    public let requestId, status: String
    public let errorText: String?
    
    enum CodingKeys: String, CodingKey {
        case requestId = "request_id"
        case errorText = "error_text"
        case status
    }
}
