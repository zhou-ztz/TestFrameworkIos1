//
//  LoginRequest.swift
//  Yippi
//
//  Created by Francis Yeap on 5/23/19.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation

enum LoginType {
    case phone, username
}


struct CheckUsernameRequestType: RequestType {
    typealias ResponseType = NoContentResponse?
    
    let username: String
    var data: YPRequestData {
        return YPRequestData(
            path: "/api/v2/validate-username",
            method: .post,
            params: [
                "username" : username
            ])
    }
}

struct CheckReferralNameRequestType: RequestType {
    typealias ResponseType = NoContentResponse?

    let username: String
    var data: YPRequestData {
        return YPRequestData(
            path: "/api/v2/validate-referral",
            method: .post,
            params: [
                "username" : username
        ])
    }
}


// Not using anymore
struct RegisterOTPRequestType: RequestType {
    typealias ResponseType = MessageArrayResponseType
    
    let phone: String
    let validateCode: String
    var data: YPRequestData {
        return YPRequestData(
            path: "/api/v2/yidun_verifycodes/register",
            method: .post,
            params: [
                "phone" : phone,
                "validate_code": validateCode
            ])
    }
}


struct LoginRequestType: RequestType {
    typealias ResponseType = LoginResponse
    
    let logType: LoginType
    let id: String
    let pass: String
    var verifiable_code: String?
    
    var data: YPRequestData {
        var params: [String: Any]
        
        switch logType {
        case .phone:
            params = [
                "phone": id,
                "password": pass
            ]
            
        case .username:
            params = [
                "username": id,
                "password": pass
            ]
        }
        
        if let code = verifiable_code {
            params["verifiable_code"] = code
        }
        
        return YPRequestData(
            path: "/api/v2/auth/user/login",
            method: .post, params: params)
    }
}

//struct BackdoorRequestType: RequestType {
//    typealias ResponseType = LoginResponse
//    
//    let socialToken: String
//
//    var data: YPRequestData {
//        let params: [String: Any] = [
//            "se_token": socialToken
//        ]
//        return YPRequestData(path: "/api/v2/auth/login",
//                             method: .post, params: params)
//    }
//}
