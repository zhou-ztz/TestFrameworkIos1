// 
// Copyright © 2018 Toga Capital. All rights reserved.
//

import Foundation

@objcMembers
public class TransferRecipient: NSObject, Codable {
    public let uid: String
    public let username: String
    public let receiver: String
    public let displayName: String
    public let profilePictureURL: String
    
    public init(uid: String, displayName: String, profilePictureURL: String, username: String, receiver: String) {
        self.uid = uid
        self.username = username
        self.receiver = receiver
        self.displayName = displayName
        self.profilePictureURL = profilePictureURL
    }
}

@objcMembers
public class TransferResponse: NSObject, APIResponseType {
    public let state: ApiState
    public let message: String?
    
    enum CodingKeys: String, CodingKey {
        case state = "state"
        case message = "message"
    }
}

