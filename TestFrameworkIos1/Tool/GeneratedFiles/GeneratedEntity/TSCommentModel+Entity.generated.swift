// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


import Foundation
import RealmSwift

class EntityComment: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var userId: Int = 0
    @objc dynamic var targetUserId: Int = 0
    var replyUserId = RealmOptional<Int>()
    @objc dynamic var body: String = ""
    @objc dynamic var commentTableId: Int = 0
    @objc dynamic var commentTableType: String = ""
    @objc dynamic var updateDate: Date? = nil
    @objc dynamic var createDate: Date? = nil
    @objc dynamic var contentType: String = ""
    @objc dynamic var isTop: Bool = false
    var user: UserInfoModel? = nil    
    var targetUser: UserInfoModel? = nil    
    var replyUser: UserInfoModel? = nil    


    convenience init?(model: TSCommentModel?) {
        guard let model = model else { return nil }

        self.init()

        // Int
        self.id = model.id
        // Int
        self.userId = model.userId
        // Int
        self.targetUserId = model.targetUserId
        // Int?
        self.replyUserId = RealmOptional<Int>()
        // String
        self.body = model.body
        // Int
        self.commentTableId = model.commentTableId
        // String
        self.commentTableType = model.commentTableType
        // Date?
        self.updateDate = model.updateDate
        // Date?
        self.createDate = model.createDate
        // String
        self.contentType = model.contentType
        // Bool
        self.isTop = model.isTop
        // UserInfoModel?
        self.user = model.user
        // UserInfoModel?
        self.targetUser = model.targetUser
        // UserInfoModel?
        self.replyUser = model.replyUser

    }

}
