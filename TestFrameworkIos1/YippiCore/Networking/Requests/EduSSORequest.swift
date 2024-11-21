// 
// Copyright © 2018 Toga Capital. All rights reserved.
//


import Foundation

struct EduSSOResponse: Codable {
    let educationURL: String
    
    enum CodingKeys: String, CodingKey {
        case educationURL = "education_url"
    }
}

struct EduSSORequest: APIRequest {
    typealias Response = EduSSOResponse
    
    var resourceName: String {
        return "user/api/tloSignOn"
    }
    
    var requestMethod: RequestMethod {
        return .post
    }
    
    let lang: String
    
    init(lang: String) {
        self.lang = lang
    }
}
