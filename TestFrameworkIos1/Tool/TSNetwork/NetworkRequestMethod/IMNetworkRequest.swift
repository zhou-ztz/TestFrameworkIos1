//
//  IMNetworkRequest.swift
//  ThinkSNS +
//
//  Created by lip on 2017/8/29.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  即时聊天网络请求

import UIKit
import ObjectMapper


struct IMNetworkRequest {
    /// 白板创建房间
    let whiteboardCreate = Request<WhiteBoardModel>(method: .post, path: "whiteboard/g2", replacers: [])
    /// 获取白板房间鉴权
    let getwhiteboardAuth = Request<WhiteBoardAuth>(method: .get, path: "auth/whiteboard", replacers: [])
    
    // MARK: - 口令
    /// 获取口令
    ///
    /// - RouteParameter: None
    /// - RequestParameter: None
    let token = Request<IMTokenModel>(method: .get, path: "im/users", replacers: [])
    /// 刷新口令
    ///
    /// - RouteParameter: None
    /// - RequestParameter:
    ///    - password: string, **必传** 旧的授权码(im_password)
    let refreshToken = Request<IMTokenModel>(method: .patch, path: "im/users", replacers: [])
    // MARK: - 会话
    /// 创建会话
    ///
    /// - RouteParameter: None
    /// - RequestParameter:
    ///    - type: int,yes.会话类型 0 私有会话 1 群组会话 2聊天室会话
    ///    - name: string,no.会话名称
    ///    - pwd: string,no.会话加入密码,type=0时该参数无效
    ///    - uids: (array string),no.会话初始成员，数组集合或字符串列表``"1,2,3,4"type=0`时需要两个uid、type=`1`时需要至少一个、type=`2`时此参数将忽略;注意：如果不合法的uid或uid未注册到IM,将直接忽略
    let createConversation = Request<TSConversationModel>(method: .post, path: "im/conversations", replacers: [])
    /// 获取会话信息
    ///
    /// - RouteParameter:
    ///    - cid: 会话标识
    /// - RequestParameter: None
    let conversationInfo = Request<TSConversationModel>(method: .get, path: "im/conversations/{cid}", replacers: ["{cid}"])
    /// 当前登录用户的会话列表
    ///
    /// - RouteParameter: None
    /// - RequestParameter: None
    let conversationList = Request<TSConversationModel>(method: .get, path: "im/conversations/list/all", replacers: [])
    ///meetingkit 查询账号信息
    ///- RouteParameter: none
    ///- RequestParameter: None
    let quertMeetingKitAccount = Request<TSMeetingKitAccountModel>(method: .post, path: "netease/meeting", replacers: [])
    
    ///meetingkit 查询会议
    ///- RouteParameter: none
    ///- RequestParameter: None  meeting/get?meetingId=136584&meetingNum=544280172
    let quertMeetingInfo = Request<QuertMeetingInfoModel>(method: .get, path: "meeting/get?meetingNum={meetingNum}", replacers:  ["{meetingNum}"])
    
    ///meetingkit 查询用户会议列表
    ///- RouteParameter: none
    ///- RequestParameter: None
    let quertUserMeetingList = Request<QuertMeetingListModel>(method: .get, path: "meeting/list?perPage={perPage}&page={page}", replacers: ["{perPage}", "{page}"])
    
    ///获取用户会议付费信息
    ///
    let quertUserMeetingPayInfo = Request<MeetingPayInfo>(method: .get, path: "meeting/paid/info", replacers: [])
    
    ///购买meeting付费版
    ///
    let meetingPayment = Request<MeetingPayment>(method: .post, path: "meeting/payment?pin={pin}", replacers: ["{pin}"])
    
    /// 获取 pinned message list
    let getPinnedList = Request<PinnedMessageModel>(method: .get, path: "user/pinned_message", replacers: [])
    
    /// show pinned message p2p
    let showPinnedMessage = Request<PinnedMessageModel>(method: .get, path: "user/pinned_message/{id}", replacers: ["{id}"])
    
    /// show pinned message group
    let showGroupPinnedMessage = Request<PinnedMessageModel>(method: .get, path: "user/pinned_message/group/{group_id}", replacers: ["{group_id}"])
    
    /// delete pinned message
    let deletePinnedMessage = Request<PinnedMessageModel>(method: .delete, path: "user/pinned_message/{id}", replacers: ["{id}"])
    
    /// store pinned message
    let storePinnedMessage = Request<PinnedMessageModel>(method: .post, path: "user/pinned_message", replacers: [])
    
    /// update pinned message
    let updatePinnedMessage = Request<PinnedMessageModel>(method: .put, path: "user/pinned_message", replacers: [])
    
}

struct WhiteBoardModel:  Mappable{
    var message: String = ""
    var code: Int = 0
    var data: WhiteBoardRoom?
    init?(map: Map) {

    }
    mutating func mapping(map: Map) {
        message <- map["message"]
        code <- map["code"]
        data <- map["data"]
    }
}
struct WhiteBoardRoom:  Mappable{
    var cid: Int = 0
    init?(map: Map) {

    }
    mutating func mapping(map: Map) {
        cid <- map["cid"]
    }
}
struct WhiteBoardAuth:  Mappable{
    var nonce: String = ""
    var checksum: String = ""
    var curTime: String = ""
    init?(map: Map) {

    }
    mutating func mapping(map: Map) {
        nonce <- map["nonce"]
        checksum <- map["checksum"]
        curTime <- map["curTime"]
    }
}


struct TSConversationModel: Mappable {
    /// 会话创建者唯一标识
    var createUserId: Int!
    /// 会话唯一标识
    var identity: Int!
    /// 会话名称
    var name: String?
    /// 会话密码
    var password: String!
    /// 会话类型
    var type: TSConversationType = .privately
    /// 会话成员
    var member: Array<Int> = []
    init?(map: Map) {
    }
    mutating func mapping(map: Map) {
        createUserId <- map["user_id"]
        identity <- map["cid"]
        name <- map["name"]
        password <- map["pwd"]
        member <- (map["uids"], StringIntArrayTransformer)
    }
    /// 获取单一会话的接收消息对象
    func getIncomingUserId() -> Int {
        guard let userIdentity = CurrentUserSessionInfo?.userIdentity else {
            fatalError("获取聊天信息失败")
        }
        assert(self.member.count == 2, "只能获取私聊时,接收消息对象的 id")
        for value in member {
            if value != userIdentity {
                return value
            }
        }
        fatalError("无法查询到发送用户的ID")
    }
}

struct IMTokenModel: Mappable {
    static let TSIMAccountTokenModelSaveKey = "IMTokenModelSaveKey"
    /// 即时聊天登录口令
    var imToken: String!
    /// 用户标识
    var userIdentity: Int?

    init?(map: Map) {
    }
    mutating func mapping(map: Map) {
        imToken <- map["im_password"]
        userIdentity <- map["user_id"]
    }
    /// 快速构造器
    init(token imToken: String) {
        self.imToken = imToken
    }
    /// 通过沙盒内数据初始化
    init?() {
        guard let imToken = UserDefaults.standard.string(forKey: IMTokenModel.TSIMAccountTokenModelSaveKey) else {
            return nil
        }
        self.imToken = imToken
    }

    /// 持久化相关信息
    func save() {
        UserDefaults.standard.set(self.imToken, forKey: IMTokenModel.TSIMAccountTokenModelSaveKey)
        UserDefaults.standard.synchronize()
    }

    /// 重置相关信息
    static func reset() {
        UserDefaults.standard.removeObject(forKey: IMTokenModel.TSIMAccountTokenModelSaveKey)
        UserDefaults.standard.synchronize()
    }
}

struct TSMeetingKitAccountModel: Mappable {
    
    var appKey: String = ""
    var createdAt: String = ""
    var id: Int = 0
    var privateMeetingNum: Int = 0
    var settings: String = ""
    var shortMeetingNum: Int = 0
    var updatedAt: String = ""
    var userToken: String = ""
    var userUuid: String = ""
    var userId: String = ""
   
    init?(map: Map) {

    }
    
    mutating func mapping(map: Map) {
        appKey <- map["app_key"]
        createdAt <- map["created_at"]
        privateMeetingNum <- map["privateMeetingNum"]
        settings <- map["settings"]
        shortMeetingNum <- map["shortMeetingNum"]
        updatedAt <- map["updated_at"]
        userToken <- map["userToken"]
        userUuid <- map["userUuid"]
        userId <- map["user_id"]
    }
}

struct QuertMeetingInfoModel:  Mappable{
    
    var meetingId: Int?
    var meetingNum: String?
    var type: Int?
    var state: Int?
    var startTime: Int?
    var endTime: Int?
    var roomArchiveId: String?
    var meeting_level: Int = 0
    var meeting_member_limit: Int = 0
    var meeting_time_limit: Int = 0
    var status: Int?
    var meeting_start_at: Int = 0
    var meeting_end_at: Int = 0
    
    var roomUuid: String?
    var subject: String = ""
    var password: String?
    var isPrivate: Int = 0 //是否私密会议
    var privateOption: PrivateOptionModel?
    
    init?(map: Map) {

    }
    
    mutating func mapping(map: Map) {
        meetingId <- map["meetingId"]
        meetingNum <- map["meetingNum"]
        type <- map["type"]
        state <- map["state"]
        startTime <- map["startTime"]
        endTime <- map["endTime"]
        roomArchiveId <- map["roomArchiveId"]
        
        meeting_level <- map["meeting_level"]
        meeting_member_limit <- map["meeting_member_limit"]
        meeting_time_limit <- map["meeting_time_limit"]
        status <- map["status"]
        meeting_start_at <- map["meeting_start_at"]
        meeting_end_at <- map["meeting_end_at"]
        roomUuid <- map["roomUuid"]
        subject <- map["subject"]
        password <- map["password"]
        isPrivate <- map["isPrivate"]
        privateOption <- map["privateOption"]
    }
}

struct PrivateOptionModel:  Mappable{
    
    var members: [String] = []
    var groupIds: [String] = []
    
    init?(map: Map) {

    }
    
    mutating func mapping(map: Map) {
        members <- map["members"]
        groupIds <- map["groupIds"]
    }
}


struct CreateMeetingRequest: RequestType {
    
    typealias ResponseType = CreateMeetingResponse

    var params: [String: Any]?

    var data: YPRequestData {
        var path = TSURLPathV2.path.rawValue + "meeting/create"
        
        return YPRequestData(path: path, method: .post, params: params)
    }

}
/*"Response:{\n  \"message\" : \"Operation successful\",\n  \"data\" : {\n    \"subject\" : \"Meeting created by\",\n    \"meetingId\" : 704619,\n    \"roleBinds\" : {\n      \"preprodtester2\" : \"member\",\n      \"zhoutingzhi\" : \"host\",\n      \"preprodtester3\" : \"member\"\n    },\n    \"ownerUserUuid\" : \"zhoutingzhi\",\n    \"settings\" : {\n      \"roomInfo\" : {\n        \"roleBinds\" : {\n          \"preprodtester2\" : \"member\",\n          \"zhoutingzhi\" : \"host\",\n          \"preprodtester3\" : \"member\"\n        },\n        \"roomConfigId\" : 40,\n        \"roomProperties\" : {\n          \"videoOff\" : {\n            \"value\" : \"offAllowSelfOn\"\n          },\n          \"audioOff\" : {\n            \"value\" : \"offAllowSelfOn\"\n          }\n        },\n        \"roomConfig\" : {\n          \"resource\" : {\n            \"whiteboard\" : true,\n            \"sip\" : false,\n            \"rtc\" : true,\n            \"live\" : false,\n            \"record\" : false,\n            \"chatroom\" : true\n          }\n        }\n      }\n    },\n    \"type\" : 1,\n    \"roomConfigId\" : 40,\n    \"password\" : \"\",\n    \"endTime\" : 1678421250893,\n    \"roomConfig\" : {\n      \"resource\" : {\n        \"live\" : false,\n        \"chatroom\" : true,\n        \"rtc\" : true,\n        \"sip\" : false,\n        \"record\" : false,\n        \"whiteboard\" : true\n      }\n    },\n    \"meetingNum\" : \"446850238\",\n    \"meetingShortNum\" : \"\",\n    \"roomArchiveId\" : \"750847\",\n    \"startTime\" : 1678334850893,\n    \"status\" : 1,\n    \"ownerNickname\" : \"无敌的燕子\"\n  }\n}"*/
///
struct CreateMeetingResponse: Decodable {
    let data: CreateMeetingInfo
    enum CodingKeys: String, CodingKey {
        case data
    }
}
struct CreateMeetingInfo: Decodable {
    let subject: String
    let meetingId: Int
    let meetingNum: String
    var meetingShortNum: String
    var password: String
    var status: Int
    var type: Int = 0
    var roomArchiveId: String
    var roomUuid: String = ""
    var settings: SettingsInfo?
    enum CodingKeys: String, CodingKey {
        case subject
        case meetingId
        case meetingNum
        case meetingShortNum
        case password
        case type
        case status
        case roomArchiveId
        case roomUuid
        case settings
    }
    
   
}
struct SettingsInfo: Decodable {
    var roomInfo: RoomInfo?
    enum CodingKeys: String, CodingKey {
        case roomInfo
    }
}
struct RoomInfo: Decodable {
    var password: String?
    enum CodingKeys: String, CodingKey {
        case password
    }
}

struct QuertMeetingListModel:  Mappable{
    var data: MeetingSettingModel?
    var massage: String = ""
    
    init?(map: Map) {

    }
    
    mutating func mapping(map: Map) {
        data <- map["data"]
        massage <- map["massage"]
    }
}

struct MeetingSettingModel:  Mappable{
    var data: [QuertMeetingListDetailModel]?
    var currentPage: Int = 0
    
    init?(map: Map) {

    }
    
    mutating func mapping(map: Map) {
        data <- map["data"]
        currentPage <- map["current_page"]
    }
}



struct QuertMeetingListDetailModel:  Mappable{
    var id: Int = 0
    var type: Int = 0
    var meetingId: Int = 0
    var password: String = ""
    var meetingNum: Int = 0
    var subject: String = ""
    var startTime: String = ""
    var endTime: String = ""
    //var settings: MeetingSettingModel?
    var roleBinds: [String : Any] = [:]
    var status: String = ""
    var meetingShortNum: String = ""
    var deletedAt: String?
    var created_at: String = ""
    var updated_at: String = ""
    var ownerUserUuid: String = ""
    var ownerNickname: String = ""
    var roomArchiveId: String = ""
    var meeting_start_at: String?
    var meeting_end_at: String?
    var members_count: Int = 0
    var members: [MeetingMemberModel]?
    init?(map: Map) {

    }
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        type <- map["type"]
        meetingId <- map["meetingId"]
        password <- map["password"]
        meetingNum <- map["meetingNum"]
        subject <- map["subject"]
        startTime <- map["startTime"]
        endTime <- map["endTime"]
        //settings <- map["settings"]
        roleBinds <- map["roleBinds"]
        status <- map["status"]
        meetingShortNum <- map["meetingShortNum"]
        deletedAt <- map["deleted_at"]
        created_at <- map["created_at"]
        updated_at <- map["updated_at"]
        ownerUserUuid <- map["ownerUserUuid"]
        ownerNickname <- map["ownerNickname"]
        roomArchiveId <- map["roomArchiveId"]
        meeting_start_at <- map["meeting_start_at"]
        meeting_end_at <- map["meeting_end_at"]
        members_count <- map["members_count"]
        members <- map["members"]
    }
}

struct MeetingRoleBindsModel:  Mappable{
    
    var currentPage: Int = 0
    
    init?(map: Map) {

    }
    
    mutating func mapping(map: Map) {
        
        currentPage <- map["current_page"]
    }
}

struct MeetingMemberModel:  Mappable{
    var id: Int = 0
    var meeting_id: Int = 0
    var userUuid: String = ""
    var role_type: String = ""
    init?(map: Map) {

    }
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        meeting_id <- map["meeting_id"]
        userUuid <- map["userUuid"]
        role_type <- map["role_type"]
    }
}


struct JoinMeetingRequest: RequestType {
    
    typealias ResponseType = JoinMeetingResponse

    var params: [String: Any]?

    var data: YPRequestData {
        var path = TSURLPathV2.path.rawValue + "meeting/member/join"
        
        return YPRequestData(path: path, method: .post, params: params)
    }

}

struct JoinMeetingResponse: Decodable {
    //let massage: String = ""
    let data: JoinInfo
    enum CodingKeys: String, CodingKey {
        //case massage
        case data
    }
}
struct JoinInfo: Decodable{
    var meetingLevel: Int = 0
    var meetingTimeLimit: Int = 0
    var meetingMemberLimit: Int = 0
    var roomUuid: Int = 0
    var meetingInfo: MeetingInfo?
    enum CodingKeys: String, CodingKey {
        case meetingLevel = "meeting_level"
        case meetingTimeLimit = "meeting_time_limit"
        case meetingMemberLimit = "meeting_member_limit"
        case roomUuid
        case meetingInfo = "meeting_info"
    }
}

struct MeetingInfo: Decodable{
    var startTime: String = ""
    var endTime: String = ""
    var isPrivate: Int = 0
    
    enum CodingKeys: String, CodingKey {
        case startTime
        case endTime
        case isPrivate
    }
}



struct MeetingPayInfo:  Mappable{
    
    var data: PayInfo?
    var massage: String = ""
    init?(map: Map) {

    }
    
    mutating func mapping(map: Map) {
        data <- map["data"]
        massage <- map["massage"]
    }
    
    
}

struct PayInfo: Mappable {
    var level: Int = 0 // 0 未付费 ，1 付过年费
    var meetingTimeLimit: String = ""
    var meetingMemberLimit: String = ""
    var meetingVipAt: String? = ""
    var meetingPrice: String = ""
    var freeMemberLimit: String = ""
    var freeTimeLimit: String = ""
    //var vipMeetingTimeLimit: String = ""
    var vipMeetingMemberLimit: String = ""
    
    init?(map: Map) {

    }
    
    mutating func mapping(map: Map) {
        level <- map["meeting_level"]
        meetingTimeLimit <- map["meeting_time_limit"]
        meetingMemberLimit <- map["meeting_member_limit"]
        meetingVipAt <- map["meeting_vip_at"]
        meetingPrice <- map["meeting_price"]
        freeMemberLimit <- map["free_member_limit"]
        freeTimeLimit <- map["free_time_limit"]
        //vipMeetingTimeLimit <- map["vip_time_limit"]
        vipMeetingMemberLimit <- map["vip_member_limit"]
    }
}

struct MeetingPayment:  Mappable{
    var data: Payment?
    var code: Int = 0
    var message: String = ""
    init?(map: Map) {

    }
    
    mutating func mapping(map: Map) {
        data <- map["data"]
        code <- map["code"]
        message <- map["message"]
    }
    
}
struct Payment:  Mappable{
    var expiredAt: String?
    var residue: Int?
    init?(map: Map) {

    }
    
    mutating func mapping(map: Map) {
        expiredAt <- map["expired_at"]
        residue <- map["residue"]
    }
}

struct MeetingInvitedRequest: RequestType {
    
    typealias ResponseType = MeetingInvitedResponse

    var params: [String: Any]?

    var data: YPRequestData {
        var path = TSURLPathV2.path.rawValue + "meeting/up_member"
        
        return YPRequestData(path: path, method: .post, params: params)
    }

}

struct MeetingInvitedResponse: Decodable {
    var code: Int?
    enum CodingKeys: String, CodingKey {
        case code
    }
}

struct PinnedMessageModel:  Mappable{
    var content: String?
    var id: Int = 0
    var im_group_id: String = ""
    var im_msg_id: String = ""
    var created_at: String?
    var updated_at: String?
    init?(map: Map) {

    }
    
    mutating func mapping(map: Map) {
        content <- map["content"]
        id <- map["id"]
        im_group_id <- map["im_group_id"]
        im_msg_id <- map["im_msg_id"]
        created_at <- map["created_at"]
        updated_at <- map["updated_at"]
    }
    
}

