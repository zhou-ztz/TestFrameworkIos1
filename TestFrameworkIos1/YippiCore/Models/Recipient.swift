// 
// Copyright © 2018 Toga Capital. All rights reserved.
//


import Foundation

@objcMembers
public class Recipient: NSObject, Codable {
    public let uid: String
    public let displayName: String
    public let profilePictureURL: String

    public init(uid: String, displayName: String, profilePictureURL: String) {
        self.uid = uid
        self.displayName = displayName
        self.profilePictureURL = profilePictureURL
    }
}
