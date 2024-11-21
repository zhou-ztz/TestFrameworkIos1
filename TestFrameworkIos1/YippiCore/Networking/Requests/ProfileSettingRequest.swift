// 
// Copyright © 2018 Toga Capital. All rights reserved.
//


import Foundation

struct TypedFile {
    let binaryData: Data
    let fileName: String
    let mimeType: String
    
}

struct EditProfile: APIRequest {
    typealias Response = ProfileSetting
    
    var resourceName: String {
        return "user/api/edit"
    }
    
    var requestMethod: RequestMethod {
        return .post
    }
    
    let nickname: String?
    let gender: String?
    let sign: String?
    let province: String?
    let city: String?
    let email: String?
    let birthday: String?
    let image: Data?
    
    var file: TypedFile? {
        guard let fileData = image  else { return nil }
        return TypedFile(binaryData: fileData, fileName: "avatar.jpg", mimeType: "image/jpg")
    }
    
    var excludedEncodeKeys: [String]? {
        return ["image"]
    }
    
    init(
        image: Data? = nil,
        nickname: String? = nil,
        gender: String? = nil,
        sign: String? = nil,
        province: String? = nil,
        city: String? = nil,
        email: String? = nil,
        birthday: String? = nil) {
            self.nickname = nickname
            self.gender = gender
            self.sign = sign
            self.province = province
            self.city = city
            self.email = email
            self.birthday = birthday
            self.image = image
        }
}

struct UploadProfileImage: APIRequest {
    
    typealias Response = ProfileSetting
    
    var resourceName: String {
        return "user/api/edit"
    }
    
    var requestMethod: RequestMethod {
        return .post
    }
    
    var binaryData: Data? {
        return imageData
    }
    
    let imageData: Data?
    
    init(data: Data? = nil) {
        self.imageData = data
    }
}
