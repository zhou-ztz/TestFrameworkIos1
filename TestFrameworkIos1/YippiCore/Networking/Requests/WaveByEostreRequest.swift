// 
// Copyright © 2018 Toga Capital. All rights reserved.
//


import Foundation

struct GetPackageCode: APIRequest {
    typealias Response = [Package]
    
    var resourceName: String {
        return "user/api/getPackagecode"
    }
    
    var requestMethod: RequestMethod {
        return .post
    }
    
    let packageId: String
    
    init(packageId: String) {
        self.packageId = packageId
    }
    
    enum CodingKeys: String, CodingKey {
        case packageId = "package_id"
    }
}

struct GetEostreWave: APIRequest {
    typealias Response = EostreState
    
    var resourceName: String {
        return "user/api/getEostreWave"
    }
    
    var requestMethod: RequestMethod {
        return .post
    }
    
    let username: String
    let password: String
    
    init(username: String, password: String) {
        self.username = username
        self.password = password
    }
}

struct GetTrialEostre: APIRequest {
    typealias Response = [EostreTrialCode]
    
    var resourceName: String {
        return "user/api/getTrialEos"
    }
    
    var requestMethod: RequestMethod {
        return .post
    }
    
    init() {
    }
    
}
