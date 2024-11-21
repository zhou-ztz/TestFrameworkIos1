// 
// Copyright © 2018 Toga Capital. All rights reserved.
//


import Foundation

struct GetNearbyUser: APIRequest {
    typealias Response = [PeopleNearBy]
    
    var resourceName: String {
        return "PeopleNearby/api/getNearbyUser"
    }
    
    var requestMethod: RequestMethod {
        return .post
    }
    
    let latitude: String
    let longitude: String
    let radius: String
    
    init(latitude: String, longitude: String, radius: String) {
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
    }
    
    enum CodingKeys: String, CodingKey {
        case latitude = "lat"
        case longitude = "lng"
        case radius
    }
}

struct UpdateUserLocation: APIRequest {
    typealias Response = [String:String]
    
    var resourceName: String {
        return "user/api/updateUserLocation"
    }
    
    var requestMethod: RequestMethod {
        return .post
    }
    
    let latitude: String
    let longitude: String
    
    init(latitude: String, longitude: String) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    enum CodingKeys: String, CodingKey {
        case latitude = "lat"
        case longitude = "lng"
    }
}
