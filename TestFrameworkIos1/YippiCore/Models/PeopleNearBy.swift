// 
// Copyright © 2018 Toga Capital. All rights reserved.
//

public struct PeopleNearBy: Decodable {
    let distance: String
    public let gender: String
    public let nickname: String
    public let phone: String
    public let remark: String?
    public let username: String
    public let uid: String
    let headsmall: String?
    
    public var distanceToDisplay: String {
        let disFloat = Double(distance) ?? 0
        var disInt:Int
        
        if disFloat < 1.0 {
            disInt = Int(disFloat * 1000)
        }else {
            disInt = Int(disFloat)
        }
        
        return String(disInt)
    }
    
    public var showKM: Bool {
        let disFloat = Double(distance) ?? 0
        
        if disFloat < 1.0 {
            return false
        }else {
            return true
        }
    }
    
    public var profileImgUrl: String {
        if headsmall != nil {
            return headsmall ?? ""
        }else {
            return ""
        }
    }
    
}
