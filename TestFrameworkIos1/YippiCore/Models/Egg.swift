// 
// Copyright © 2018 Toga Capital. All rights reserved.
//

import Foundation

@objc public enum TransferType: Int {
    case personal
    case group
    case reward
    case transfer
}

@objcMembers
public class SendEggResult: NSObject, APIResponseType {
    public let state: ApiState
    public let data: SendEggData
    public let message: String?
}

@objcMembers
public class SendEggData: NSObject, Decodable {
    public var eggId: Int?
    
    public var _eggId: NSNumber? {
        return eggId as NSNumber?
    }
    
    enum CodingKeys: String, CodingKey {
        case eggId = "egg_id"
    }
}

@objcMembers
public class ClaimEggResponse: NSObject, Decodable {
    public let header: EggHeader
    public let sender: EggUser
    public let receivers: [EggReceivers]
    public let eggInfo: ClaimEggInfo

    enum CodingKeys: String, CodingKey {
        case header
        case sender
        case receivers
        case eggInfo = "egg_info"
    }

    public class EggHeader: NSObject, Decodable {
        public let wishes: String
        public let amount: String?
        public let yippsMsg: String?
        public let messages: String?
        public let needSubscribe: Bool

        enum CodingKeys: String, CodingKey {
            case wishes = "wishes_message"
            case amount
            case yippsMsg = "yipps_messages"
            case messages
            case needSubscribe = "need_subscribe"
        }
    }

    public class EggUser: NSObject, Decodable {
        public let uid: Int
        public let name: String
        public let username: String
        public let avatar: Avatar?

        enum CodingKeys: String, CodingKey {
            case uid = "id"
            case name
            case username
            case avatar
        }
    }

    public class EggReceivers: NSObject, Decodable {
        public let user: EggUser
        public let amount: String
        public let redeemTime: String
        public var luckyStar: Int? = 0

        enum CodingKeys: String, CodingKey {
            case user
            case amount
            case redeemTime = "redeemed_time"
            case luckyStar = "lucky_star"
        }
    }

    public class ClaimEggInfo:  NSObject, Decodable {
        public let amount: String?
        public let amountRemaining: String?
        public let quantity: Int?
        public let quantityRemaining: Int?
        public let isRandom: Int?
        public let eggId: Int
        public let treasureTheme: TreasureTheme?
        public let type: Int?
        public let subscriberOnly: Bool?

        enum CodingKeys: String, CodingKey {
            case amount
            case amountRemaining = "amount_remaining"
            case quantity
            case quantityRemaining = "quantity_remaining"
            case isRandom = "is_random_amount"
            case eggId = "redpacket_id"
            case treasureTheme
            case type
            case subscriberOnly = "subscriber_only"
        }

        public class TreasureTheme: NSObject, Decodable {
            public let id: Int?
            public let title, boxImage, backgroundImagePortrait, backgroundImageLandscape: String?

            enum CodingKeys: String, CodingKey {
                case title, id
                case boxImage = "treasure_box_open_url"
                case backgroundImagePortrait = "treasure_box_background_portrait_url"
                case backgroundImageLandscape = "treasure_box_background_landscape_url"
            }
        }
    }

}

@objcMembers
public class EggResponseModel: NSObject, Decodable {
    public let isGroup: Bool?
    public let owner: Owner
    public let egg: Egg
    public let liveEgg: LiveEgg?
    public let receiver: [Owner]?
    public let isFirstAttempt: Bool?
    
    enum CodingKeys: String, CodingKey {
        case isGroup = "is_group"
        case owner, receiver, egg, liveEgg
        case isFirstAttempt = "first_attempt"
    }
    
    public class Owner: NSObject, Decodable {
        public let id: Int
        public let ownerID: Int?
        public let title, body: String
        public let type: Int
        public let targetType:String?
        public let targetID: String?
        public let currency: Int
        public let amount: String
        public let state: Int
        public let redpacketID: Int
        public let amountRemaining: String
        public let quantity, isRandomAmount, quantityRemaining: Int
        public let groupID: String?
        public let user: User
        public let createdAt: String
        
        enum CodingKeys: String, CodingKey {
            case id
            case ownerID = "owner_id"
            case title, body, type
            case targetType = "target_type"
            case targetID = "target_id"
            case currency, amount, state
            case redpacketID = "redpacket_id"
            case amountRemaining = "amount_remaining"
            case quantity
            case isRandomAmount = "is_random_amount"
            case quantityRemaining = "quantity_remaining"
            case groupID = "group_id"
            case user
            case createdAt = "created_at"
        }
    }
    
    // MARK: - User
    public class User: NSObject, Decodable {
        public let id: Int
        public let name: String
        public let avatar: Avatar?
        public let official: Int
        public let extra: Extra
        
        enum CodingKeys: String, CodingKey {
            case id, name, official, extra, avatar
        }
    }
    
    public class Egg: Codable {
        public let yipps: String?
        public let yippsMessage: String
        public let msg: String
        public let isExpired: Bool
        
        enum CodingKeys: String, CodingKey {
            case yipps, msg
            case yippsMessage = "yipps_message"
            case isExpired = "is_expired"
        }
    }
    
    public class Avatar: Codable {
        public let url: String
        public let size: Int
        
        enum CodingKeys: String, CodingKey {
            case url, size
        }
    }
    
    // MARK: - Extra
    public class Extra: NSObject, Decodable {
        public let userID, likesCount, commentsCount, followersCount: Int
        public let followingsCount: Int
        public let updatedAt: String
        public let feedsCount, questionsCount, answersCount, checkinCount: Int
        public let lastCheckinCount: Int
        
        enum CodingKeys: String, CodingKey {
            case userID = "user_id"
            case likesCount = "likes_count"
            case commentsCount = "comments_count"
            case followersCount = "followers_count"
            case followingsCount = "followings_count"
            case updatedAt = "updated_at"
            case feedsCount = "feeds_count"
            case questionsCount = "questions_count"
            case answersCount = "answers_count"
            case checkinCount = "checkin_count"
            case lastCheckinCount = "last_checkin_count"
        }
    }

    public class LiveEgg: Codable {
        public let treasureTheme: TreasureTheme?
        
        enum CodingKeys: String, CodingKey {
            case treasureTheme
        }
    }
    
    public class TreasureTheme: Codable {
        public let id: Int?
        public let title, boxImage, backgroundImagePortrait, backgroundImageLandscape: String?
        
        enum CodingKeys: String, CodingKey {
            case title, id
            case boxImage = "treasure_box_open_url"
            case backgroundImagePortrait = "treasure_box_background_portrait_url"
            case backgroundImageLandscape = "treasure_box_background_landscape_url"
        }
    }
}


@objcMembers
public class GroupEggResponse: NSObject, APIResponseType {
    public let state: ApiState
    public let data: GroupEggData
    public let message: String?
    
    enum CodingKeys: String, CodingKey {
        case data = "data"
        case state = "state"
        case message = "message"
    }
}

@objcMembers
public class EggInfo: NSObject {
    public let nickname, points, headsmall, remarks: String
    
    public init(nickname: String, points: String, headsmall: String, remarks: String)
    {
        self.nickname = nickname
        self.points = points
        self.headsmall = headsmall
        self.remarks = remarks
    }
}

@objcMembers
public class Detail: NSObject, Codable {
    public let headsmall: String?
    public let uid, username, nickname, points, opentime : String
    public let fuid, friend, fnickname, fheadsmall, is_open: String?

    public init(uid: String, username: String, nickname: String, headsmall: String?, points: String, opentime: String, fuid: String, friend: String, fnickname: String, fheadsmall: String, is_open: String) {
        self.uid = uid
        self.username = username
        self.nickname = nickname
        self.headsmall = headsmall
        self.points = points
        self.opentime = opentime
        self.fuid = fuid
        self.friend = friend
        self.fnickname = fnickname
        self.fheadsmall = fheadsmall
        self.is_open = is_open
    }
}

@objcMembers
public class GroupEgg: NSObject, Codable {
    public let rid, uid, username, tid: String
    public let points, pointsrmng, qty, remaining, timecreated: String
    public let isRand, isRefund: String
    
    
    enum CodingKeys: String, CodingKey {
        case uid="uid", username="username", tid="tid", points="points", pointsrmng="pointsrmng", qty="qty", remaining="remaining"
        case isRefund = "is_refund"
        case isRand = "is_rand"
        case timecreated = "timecreated"
        case rid = "id"
    }
}

@objcMembers
public class PersonalEggData: NSObject, Decodable {
    public let eggs: [PersonalEgg]?
    
    enum CodingKeys: String, CodingKey {
        case eggs = "eggs"
    }
}

@objcMembers
public class GroupEggData: NSObject, Decodable {
    public let eggs: [GroupEgg]?
    public let detail: [Detail]?
    
    enum CodingKeys: String, CodingKey {
        case eggs = "eggs"
        case detail = "detail"
    }
}

@objcMembers
@objc public class PersonalEgg: NSObject, Codable {
    public let uid: String
    public let username: String
    public var nickname: String?
    public let headsmall: String
    public let fuid: String
    public let friend: String
    public let fnickname: String
    public let fheadsmall: String?
    public let points: String
    public let remarks: String
    public let isOpen: String
    public let isRefund: String
    public let timecreated: String?

    
    enum CodingKeys: String, CodingKey {
        case uid
        case username = "user"
        case nickname = "nickname"
        case headsmall = "headsmall"
        case fuid = "fuid"
        case friend = "friend"
        case fnickname = "fnickname"
        case fheadsmall = "fheadsmall"
        case points = "points"
        case remarks = "remarks"
        case isOpen = "is_open"
        case isRefund = "is_refund"
        case timecreated = "timecreated"
    }
}

@objcMembers
@objc public class ApiState: NSObject,Codable {
    public let code: Int
    public let msg, debugMsg, url: String
    
    enum CodingKeys: String, CodingKey {
        case code
        case msg
        case debugMsg
        case url
    }
}
