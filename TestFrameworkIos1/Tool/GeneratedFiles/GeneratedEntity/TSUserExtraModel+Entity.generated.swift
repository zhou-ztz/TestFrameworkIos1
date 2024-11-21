// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


import Foundation
import RealmSwift

class EntityUserExtra: Object {
    @objc dynamic var userId: Int = 0
    @objc dynamic var likesCount: Int = 0
    @objc dynamic var commentsCount: Int = 0
    @objc dynamic var followersCount: Int = 0
    @objc dynamic var followingsCount: Int = 0
    @objc dynamic var feedsCount: Int = 0
    @objc dynamic var updateDate: String = ""
    @objc dynamic var checkinCount: Int = 0
    @objc dynamic var lastCheckinCount: Int = 0
    @objc dynamic var qustionsCount: Int = 0
    @objc dynamic var answersCount: Int = 0
    @objc dynamic var count: Int = 0
    @objc dynamic var rank: Int = 0
    @objc dynamic var canAcceptReward: Int = 0
    @objc dynamic var isMiniVideoEnabled: Int = 0

    convenience init?(model: TSUserExtraModel?) {
        guard let model = model else { return nil }

        self.init()

        // Int
        self.userId = model.userId
        // Int
        self.likesCount = model.likesCount
        // Int
        self.commentsCount = model.commentsCount
        // Int
        self.followersCount = model.followersCount
        // Int
        self.followingsCount = model.followingsCount
        // Int
        self.feedsCount = model.feedsCount
        // String
        self.updateDate = model.updateDate
        // Int
        self.checkinCount = model.checkinCount
        // Int
        self.lastCheckinCount = model.lastCheckinCount
        // Int
        self.qustionsCount = model.qustionsCount
        // Int
        self.answersCount = model.answersCount
        // Int
        self.count = model.count
        // Int
        self.rank = model.rank
        // Int
        self.canAcceptReward = model.canAcceptReward

        self.isMiniVideoEnabled = model.isMiniVideoEnabled
    }

}
