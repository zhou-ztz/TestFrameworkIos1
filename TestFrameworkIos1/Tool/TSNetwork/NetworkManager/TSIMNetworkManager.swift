//
//  TSIMNetworkManager.swift
//  Thinksns Plus
//
//  Created by lip on 2017/2/22.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  即时聊天网络通讯请求管理

import UIKit

enum TSConversationType: Int {
    /// 私有会话
    case privately = 0
    /// 群会话
    case group = 1
    /// 聊天室
    case room = 2
}

class TSIMNetworkManager: NSObject {
    
    /// 创建会话
    ///
    /// - Parameters:
    ///   - withName: 会话名称
    ///   - type: 会话类型
    ///   - password: 会话密码
    ///   - users: 会话初始成员
    ///   - complete: 会话创建结果
    class func createConversation(with type: TSConversationType, name: String? = nil, password: String? = nil, users: Array<Int>? = nil, complete: @escaping ((_ resultModel: TSConversationModel?, _ error: NSError?) -> Void)) {
        var parameters = [String: Any]()
        if let name = name {
            parameters.updateValue(name, forKey: "name")
        }
        if let pwd = password {
            parameters.updateValue(pwd, forKey: "pwd")
        }
        if let uids = users {
            parameters.updateValue(uids, forKey: "uids")
        }

        switch type {
        case .privately:
            assert((users?.count)! == 2, "创建私聊是,初始成员必须等于 2")
        case .group:
            assert((users?.count)! > 1, "创建群会话是,初始成员必须大于 1")
        case .room:
            // 创建聊天室时,该值无效
            break
        }
        parameters.updateValue(type.rawValue, forKey: "type")

        var request = IMNetworkRequest().createConversation
        request.urlPath = request.fullPathWith(replacers: [])
        request.parameter = parameters
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_), .failure(_):
                complete(nil, TSErrorCenter.create(With: TSErrorCode.unrecognizedData))
            case .success(let response):
                if let model = response.model {
                    complete(model, nil)
                    return
                }
                assert(false, "不能识别的数据")
                complete(nil, TSErrorCenter.create(With: TSErrorCode.unrecognizedData))
            }
        }
    }

    /// 获取聊天会话信息
    ///
    /// - Parameters:
    ///   - conversationIdentity: 聊天会话唯一标识
    ///   - complete: 获取结果
    class func getConversationInfo(_ conversationIdentity: Int, complete: @escaping (_ resultModel: TSConversationModel?, _ error: NSError?) -> Swift.Void) {
        assert(conversationIdentity > 0, "会话ID不能小于0")
        var request = IMNetworkRequest().conversationInfo
        request.urlPath = request.fullPathWith(replacers: ["\(conversationIdentity)"])

        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_), .failure(_):
                complete(nil, TSErrorCenter.create(With: TSErrorCode.unrecognizedData))
            case .success(let response):
                if let model = response.model {
                    complete(model, nil)
                }
            }
        }
    }

    /// 获取所有聊天会话信息
    ///
    /// - Parameter complete: 获取结果
    class func getConversationInfoList(complete: @escaping ((_ resultModelArray: [TSConversationModel]?, _ error: NSError?) -> Swift.Void)) {
        var request = IMNetworkRequest().conversationList
        request.urlPath = request.fullPathWith(replacers: [])

        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_), .failure(_):
                complete(nil, TSErrorCenter.create(With: TSErrorCode.unrecognizedData))
            case .success(let response):
                complete(response.models, nil)
            }
        }
    }
    
    ///meetingkit 查询账号信息
    ///
    /// - Parameter complete: 获取结果
    class func quertMeetingKitAccountInfo(complete: @escaping ((_ resultModel: TSMeetingKitAccountModel?, _ error: NSError?) -> Swift.Void)) {
        var request = IMNetworkRequest().quertMeetingKitAccount
        request.urlPath = request.fullPathWith(replacers: [])

        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_), .failure(_):
                complete(nil, TSErrorCenter.create(With: TSErrorCode.unrecognizedData))
            case .success(let response):
                if let model = response.model {
                    complete(model, nil)
                }
            }
        }
    }
    
    ///meetingkit 查询会议信息
    ///
    /// - Parameter complete: 获取结果
    class func quertMeetingInfo(meetingId: Int, meetingNum: String, complete: @escaping ((_ resultModel: QuertMeetingInfoModel?, _ error: NSError?) -> Swift.Void)) {
        var request = IMNetworkRequest().quertMeetingInfo
        request.urlPath = request.fullPathWith(replacers: ["\(meetingNum)"])

        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_), .failure(_):
                complete(nil, TSErrorCenter.create(With: TSErrorCode.unrecognizedData))
            case .success(let response):
                if let model = response.model {
                    complete(model, nil)
                }
            }
        }
    }
    
    ///meetingkit 查询会议记录列表
    ///
    /// - Parameter complete: 获取结果
    class func quertMeetingList(perPage: String = "15", page: String, complete: @escaping ((_ resultModel: QuertMeetingListModel?, _ error: NSError?) -> Swift.Void)) {
        var request = IMNetworkRequest().quertUserMeetingList
        request.urlPath = request.fullPathWith(replacers: ["\(perPage)","\(page)"])

        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_), .failure(_):
                complete(nil, TSErrorCenter.create(With: TSErrorCode.unrecognizedData))
            case .success(let response):
                if let model = response.model {
                    complete(model, nil)
                }
            }
        }
    }
    
    //meetingkit 查询会议记录列表
    ///
    /// - Parameter complete: 获取结果
    class func quertMeetingPayInfo(complete: @escaping ((_ resultModel: MeetingPayInfo?, _ error: NSError?) -> Swift.Void)) {
        var request = IMNetworkRequest().quertUserMeetingPayInfo
        request.urlPath = request.fullPathWith(replacers: [])
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_), .failure(_):
                complete(nil, TSErrorCenter.create(With: TSErrorCode.unrecognizedData))
            case .success(let response):
                if let model = response.model {
                    complete(model, nil)
                }
            }
        }
    }
    
    //购买meeting付费版
    ///
    /// - Parameter complete: 获取结果
    class func payMeetingFee(pin: String,  complete: @escaping ((_ resultModel: MeetingPayment?, _ error: NSError?) -> Swift.Void)) {
        var request = IMNetworkRequest().meetingPayment
        request.urlPath = request.fullPathWith(replacers: ["\(pin)"])
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_), .failure(_):
                complete(nil, TSErrorCenter.create(With: TSErrorCode.unrecognizedData))
            case .success(let response):
                if let model = response.model {
                    complete(model, nil)
                }
            }
        }
    }
    
    // pinned message list
    class func getPinnedMessageList(complete: @escaping ((_ resultModel: [PinnedMessageModel]?, _ error: NSError?) -> Swift.Void)){
        var request = IMNetworkRequest().getPinnedList
        request.urlPath = request.fullPathWith(replacers: [])
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_), .failure(_):
                complete(nil, TSErrorCenter.create(With: TSErrorCode.unrecognizedData))
            case .success(let response):
                complete(response.models, nil)
            }
        }
    }
    
    // store pinned message list
    class func storePinnedMessage(imMsgId: String, imGroupId: String = "", content: String = "", deleteFlag: Bool = false, complete: @escaping ((_ resultModel: PinnedMessageModel?, _ error: NSError?) -> Swift.Void)){
        var request = IMNetworkRequest().storePinnedMessage
        request.urlPath = request.fullPathWith(replacers: [])
        request.parameter = ["im_msg_id": "\(imMsgId)", "im_group_id": "\(imGroupId)", "content": "\(content)", "delete_flag": deleteFlag]
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_), .failure(_):
                complete(nil, TSErrorCenter.create(With: TSErrorCode.unrecognizedData))
            case .success(let response):
                if let model = response.model {
                    complete(model, nil)
                }
            }
        }
    }

    ///创建白板房间
    class func createWhiteboard(roomName: String,  complete: @escaping ((_ resultModel: WhiteBoardModel?, _ error: NSError?) -> Swift.Void)) {
        var request = IMNetworkRequest().whiteboardCreate
        request.urlPath = request.fullPathWith(replacers: [])
        request.parameter = ["channel_name": roomName]
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_), .failure(_):
                complete(nil, TSErrorCenter.create(With: TSErrorCode.unrecognizedData))
            case .success(let response):
                if let model = response.model {
                    complete(model, nil)
                }
            }
        }
    }
    
    class func showGroupPinnedMessage(group_id: String, complete: @escaping ((_ resultModel: [PinnedMessageModel]?, _ error: NSError?) -> Swift.Void)){
        var request = IMNetworkRequest().showGroupPinnedMessage
        request.urlPath = request.fullPathWith(replacers: ["\(group_id)"])
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_), .failure(_):
                complete(nil, TSErrorCenter.create(With: TSErrorCode.unrecognizedData))
            case .success(let response):
                complete(response.models, nil)
            }
        }
    }

    ///获取白板房间鉴权
    class func getwhiteboardAuth( complete: @escaping ((_ resultModel: WhiteBoardAuth?, _ error: NSError?) -> Swift.Void)) {
        var request = IMNetworkRequest().getwhiteboardAuth
        request.urlPath = request.fullPathWith(replacers: [])

        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_), .failure(_):
                complete(nil, TSErrorCenter.create(With: TSErrorCode.unrecognizedData))
            case .success(let response):
                complete(response.model, nil)
            }
        }
    }
    
    class func deletePinnedMessage(id: Int, complete: @escaping ((_ resultModel: PinnedMessageModel?, _ error: NSError?) -> Swift.Void)){
        var request = IMNetworkRequest().deletePinnedMessage
        request.urlPath = request.fullPathWith(replacers: ["\(id)"])
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_), .failure(_):
                complete(nil, TSErrorCenter.create(With: TSErrorCode.unrecognizedData))
            case .success(let response):
                complete(response.model, nil)
            }
        }
    }
    
    class func updatePinnedMessage(id: Int, imMsgId: String, imGroupId: String = "", content: String = "", complete: @escaping ((_ resultModel: PinnedMessageModel?, _ error: NSError?) -> Swift.Void)){
        var request = IMNetworkRequest().updatePinnedMessage
        request.urlPath = request.fullPathWith(replacers: [])
        request.parameter = ["id": id, "im_msg_id": "\(imMsgId)", "im_group_id": "\(imGroupId)", "content": "\(content)"]
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_), .failure(_):
                complete(nil, TSErrorCenter.create(With: TSErrorCode.unrecognizedData))
            case .success(let response):
                if let model = response.model {
                    complete(model, nil)
                }
            }
        }
    }
}
