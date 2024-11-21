// 
// Copyright © 2018 Toga Capital. All rights reserved.
//


import Foundation


struct LoginByUsernameOrPhoneNumber: APIRequest {
    typealias Response = TSUser
    
    var resourceName: String {
        return "user/api/login"
    }
    
    var requestMethod: RequestMethod {
        return .post
    }
    
    let device: String = "ios"
    let username: String?
    let phone: String?
    let password: String
    let version: String = AppEnvironment.current.appVersion
    
    init(username: String? = nil,
         phone: String? = nil,
         password: String) {
        self.username = username
        self.phone = phone
        self.password = password
    }
    
    enum CodingKeys: String, CodingKey {
        case device = "os"
        case username
        case phone
        case password
        case version
    }
}

struct ValidateUsername: APIRequest {
    
    typealias Response = [String: String]?
    
    var resourceName: String {
        return "user/api/validateUsername2"
    }
    
    var requestMethod: RequestMethod {
        return .post
    }
    
    let username: String
    let version: String
    
    init(username: String,
         version: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "") {
        self.username = username
        self.version = version
    }
}

struct SendCodeForResetPassword: APIRequest {
    
    typealias Response = ActivationCode
    
    var resourceName: String {
        return "user/api/sendCodeForResetPassword"
    }
    
    var requestMethod: RequestMethod {
        return .post
    }
    
    let username: String
    
    init(username: String) {
        self.username = username
    }
}

struct SendActivationCode: APIRequest {
    
    typealias Response = ActivationCode
    
    var resourceName: String {
        return "user/api/sendCode"
    }
    
    var requestMethod: RequestMethod {
        return .post
    }
    
    let phone: String
    let requestId: String
    
    init(phone: String, requestId: String = "") {
        self.phone = phone
        self.requestId = requestId
    }
    
    enum CodingKeys: String, CodingKey {
        case phone
        case requestId = "request_id"
    }
}

struct VerifyActivationCode: APIRequest {
    
    typealias Response = VerifyCodeResponse
    
    var resourceName: String {
        return "user/api/verifyCode"
    }
    
    var requestMethod: RequestMethod {
        return .post
    }
    
    let code: String
    let requestId: String
    
    init(code: String, requestId: String = "") {
        self.code = code
        self.requestId = requestId
    }
    
    enum CodingKeys: String, CodingKey {
        case code
        case requestId = "request_id"
    }
}


struct Register: APIRequest {
    typealias Response = TSUser
    
    var resourceName: String {
        return "user/api/register"
    }
    
    var requestMethod: RequestMethod {
        return .post
    }
    
    let code: String
    let phone: String
    let password: String
    let upline: String
    let username: String
    
    init(code: String,
         username: String,
         phone: String,
         password: String,
         upline: String = "") {
        self.code = code
        self.phone = phone
        self.username = username
        self.password = password
        self.upline = upline
    }
    
    enum CodingKeys: String, CodingKey {
        case code
        case phone
        case password
        case username
        case upline
    }
}

struct ForgetPassword: APIRequest {
    typealias Response = [String: String]
    
    var resourceName: String {
        return "user/api/forgetPassword"
    }
    
    var requestMethod: RequestMethod {
        return .post
    }
    
    let username: String
    let password: String
    
    init(username: String,
         password: String) {
        self.username = username
        self.password = password
    }
    
    enum CodingKeys: String, CodingKey {
        case username
        case password
    }
}

struct ChangePassword: APIRequest {
    typealias Response = [String: String]
    
    var resourceName: String {
        return "user/api/editPassword"
    }
    
    var requestMethod: RequestMethod {
        return .post
    }
    
    let oldPasword: String
    let newPassword: String
    
    init(oldPasword: String,
         newPassword: String) {
        self.oldPasword = oldPasword
        self.newPassword = newPassword
    }
    
    enum CodingKeys: String, CodingKey {
        case oldPasword = "oldpassword"
        case newPassword = "newpassword"
    }
}
