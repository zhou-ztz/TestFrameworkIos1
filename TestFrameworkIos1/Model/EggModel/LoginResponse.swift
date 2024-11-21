//
//  LoginResponse.swift
//  Yippi
//
//  Created by Francis Yeap on 5/23/19.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation

struct LoginResponse: Codable {
    let neteaseToken, username: String?
    let accessToken, tokenType: String?
    let expireIn, refreshTTL: Int?
    let message: LoginMessage?
    let code: Int?
    let data: LoginOtpInfo?
    
    enum CodingKeys: String, CodingKey {
        case neteaseToken = "netease_token"
        case username = "username"
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expireIn = "expires_in"
        case refreshTTL = "refresh_ttl"
        case message = "message"
        case code = "code"
        case data = "data"
    }
    
    struct LoginOtpInfo: Codable {
        let number: String
        let remainingSeconds: Int
        
        enum CodingKeys: String, CodingKey {
            case number = "number"
            case remainingSeconds = "remaining_seconds"
        }
    }
    
    enum LoginMessage: Codable {
        case single(String)
        case array([String])
        case empty(String)

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let x = try? container.decode(String.self) {
                self = .single(x)
                return
            }
            if let x = try? container.decode([String].self) {
                self = .array(x)
                return
            }
            self = .empty("")
        }
        
        func encode(to encoder: Encoder) throws {
             var container = encoder.singleValueContainer()
             switch self {
             case .single(let x):
                 try container.encode(x)
             case .array(let x):
                 try container.encode(x)
             case .empty(let x):
                 try container.encode(x)
             }
         }
    }
}


struct MessageOnlyResponseType: Codable {
    let message: String
}

struct MessageArrayResponseType: Codable {
    let message: [String]
}

struct NoContentResponse: Codable {}

