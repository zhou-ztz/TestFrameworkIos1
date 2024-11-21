//
//  TSUserNetworkingManager.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/2/18.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  用户相关网络请求

import UIKit
import Combine
import RealmSwift
import ObjectMapper
import Alamofire

import SwiftyUserDefaults

enum TSUserRelationType {
    /// 关注
    case follow
    /// 粉丝
    case fans
    
    case friends
}

enum TSUserIsCancelFollow {
    /// 关注
    case follow
    /// 取消关注
    case cancel
}

enum TSUserManagerAuthority: String {
    /// 删除动态权限
    case deleteFeed = "[feed] Delete Feed"
    /// 删除问题
    case deleteQuestion = "[Q&A] Manage Questions"
    /// 删除回答
    case deleteAnswer = "[Q&A] Manage Answers"
    /// 删除资讯
    case deleteNew = "[News] Delete News Post"
}

class TSUserNetworkingManager: NSObject {
    /// send user session duration
    /// - Parameters:
    ///     - star_time: User launch app time
    ///     - end_time: Duration limit to update user session duration
    func sendUserSessionDuration(duration: [[String:Any]], complete: @escaping ((_ treasureBox: Int?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        let path = TSURLPathV2.path.rawValue + TSURLPathV2.User.userSessionDuration.rawValue

        let parameters: [String: Any] = [
            "duration" : duration.toAES256Encryption()
        ]

        try! RequestNetworkData.share.textRequest(method: .post, path: path, parameter: parameters, complete: { (response, result) in
            // 请求失败处理
            guard result else {
                // 解析错误原因
                guard let responseDic = response as? Dictionary<String, Any> else {
                    failure(TSErrorCenter.create(With: TSErrorCode.networkError))
                    return
                }
                // 正常数据解析
                let message = responseDic["message"] as? String
                failure(NSError(domain: "TSNormalErrorDomain", code: 999, userInfo: ["NSLocalizedDescription": message ?? "发送失败"]))
                return
            }
            // 服务器数据异常处理
            guard let responseDic = response as? Dictionary<String, Any> else {
                failure(TSErrorCenter.create(With: TSErrorCode.networkError))
                return
            }
            // 正常数据解析
            if let data = responseDic["treasure_box"] as? Int  {
                let treasureNum = data
                complete(treasureNum)
            } else {
                failure(TSErrorCenter.create(With: TSErrorCode.unrecognizedData))
            }
        })
    }
    
    func checkCertificate(id: String, complete: ((_ status: Bool, _ message: String) -> Void)? = nil) {
        let path = TSURLPathV2.path.rawValue + TSURLPathV2.User.certificateCheckId.rawValue
        
        let parameters: [String: Any] = [
            "certification_ID": id
        ]
        
        try! RequestNetworkData.share.textRequest(method: .post, path: path, parameter: parameters, complete: { (response: NetworkResponse?, status: Bool) in
            var message: String
            if status {
                message = TSCommonNetworkManager.getNetworkSuccessMessage(with: response) ?? "success".localized
            } else {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: response) ?? "network_problem".localized
            }
            complete?(status, message)
        })
    }
    
    
    func updateCurrentUserCertification(type: String, files: [Int], name: String,
                                                phone: String, number: String,
                                                bday: String, holderName: String, bankAcc: String,
                                                bankName: String, bankBranch: String, bankSwift: String,
                                                taxid: String, desc: String,
                                                additionalParams: [String: String]? = nil,
                                                complete: @escaping (Bool, String) -> Void) {
        
        guard let user = CurrentUserSessionInfo else { return }
        
        func onUpdateComplete(isSuccess: Bool, message: String){
            guard isSuccess == true else {
                complete(false, message)
                return
            }
            
            guard var user = CurrentUserSessionInfo else {
                TSRootViewController.share.guestJoinLandingVC()
                return
            }
            
            user.certificationStatus = 0
            user.save()
            complete(true, message)
        }
        
        if user.verificationIcon.orEmpty.isEmpty == true {
            if user.certificationStatus == 2 {
                self.updateCertificate(type: type, files: files, name: name, phone: phone, number: number, bday: bday, holderName: holderName,
                                       bankAcc: bankAcc, bankName: bankName, bankBranch: bankBranch, bankSwift: bankSwift, taxid: taxid, desc: desc, additionalParams: additionalParams, complete: onUpdateComplete)
            } else {
                self.certificate(type: type, files: files, name: name, phone: phone, number: number, bday: bday, holderName: holderName,
                                 bankAcc: bankAcc, bankName: bankName, bankBranch: bankBranch, bankSwift: bankSwift, taxid: taxid, desc: desc, additionalParams: additionalParams, complete: onUpdateComplete   )
            }
        } else {
            self.updateCertificate(type: type, files: files, name: name, phone: phone, number: number, bday: bday, holderName: holderName,
                                   bankAcc: bankAcc, bankName: bankName, bankBranch: bankBranch, bankSwift: bankSwift, taxid: taxid, desc: desc, additionalParams: additionalParams, complete: onUpdateComplete)
        }
    }

    /// 上传用户/企业认证
    ///
    /// - Parameters:
    ///   - type: 认证类型，必须是 personal 或者 enterprise
    ///   - files: 认证材料文件。必须是数组或者对象，value 为 文件ID
    ///   - name: 如果 type 是 enterprise 那么就是负责人名字，如果 type 是 personal 则为用户真实姓名
    ///   - phone: 如果 type 是 enterprise 则为负责人联系方式，如果 type 是 personal 则为用户联系方式
    ///   - number: 如果 type 是 enterprise 则为营业执照注册号，如果 type 是 personal 则为用户身份证号码
    ///   - desc: 认证描述
    ///   - org_name: type 为 enterprise 则必须，企业或机构名称
    ///   - org_address: type 为 enterprise 则必须，企业或机构地址
    private func certificate(type: String,
                     files: [Int],
                     name: String,
                     phone: String,
                     number: String,
                     bday: String,
                     holderName: String,
                     bankAcc: String,
                     bankName: String,
                     bankBranch: String,
                     bankSwift: String,
                     taxid: String,
                     desc: String,
                     additionalParams: [String: String]? = nil,
                     complete: @escaping (Bool, String) -> Void) {
        // TODO: 暂时屏蔽掉未登录用户调用该接口导致的验证错误
        if TSCurrentUserInfo.share.isLogin == false {
            complete(false, "network_problem".localized)
            return
        }
        // 1.配置路径
        let path = TSURLPathV2.path.rawValue + TSURLPathV2.User.certificate.rawValue
        // 2.配置参数
        var parameters: [String: Any] = ["type": type,
                                         "files": files,
                                         "name": name,
                                         "phone": phone,
                                         "number": number,
                                         "birthdate": bday,
                                         "desc": desc]
        
        if holderName.isEmpty == false && bankAcc.isEmpty == false && bankName.isEmpty == false && bankBranch.isEmpty == false && bankSwift.isEmpty == false {
            parameters.updateValue(holderName, forKey: "bank_holder")
            parameters.updateValue(bankAcc, forKey: "bank_account")
            parameters.updateValue(bankName, forKey: "bank_name")
            parameters.updateValue(bankBranch, forKey: "bank_branch")
            parameters.updateValue(bankSwift, forKey: "bank_swift")
        }
        
        if taxid.isEmpty == false {
            parameters.updateValue(taxid, forKey: "tax_id")
        }
        
        
        if let addParams = additionalParams {
            for (key, value) in addParams {
                parameters.updateValue(value, forKey: key)
            }
        }
                
        // 3.发起请求
        try! RequestNetworkData.share.textRequest(method: .post, path: path, parameter: parameters, complete: { (response: NetworkResponse?, status: Bool) in
            var message: String
            if status {
                message =  "upload_success".localized
            } else {
                message =  "upload_fail".localized
                if let serverMsg = TSCommonNetworkManager.getNetworkErrorMessage(with: response) {
                    message += serverMsg
                }
            }
            complete(status, message)
        })
    }

    /// 更新用户/企业认证
    ///
    /// - Parameters:
    ///   - type: 认证类型，必须是 personal 或者 enterprise
    ///   - files: 认证材料文件。必须是数组或者对象，value 为 文件ID
    ///   - name: 如果 type 是 enterprise 那么就是负责人名字，如果 type 是 personal 则为用户真实姓名
    ///   - phone: 如果 type 是 enterprise 则为负责人联系方式，如果 type 是 personal 则为用户联系方式
    ///   - number: 如果 type 是 enterprise 则为营业执照注册号，如果 type 是 personal 则为用户身份证号码
    ///   - desc: 认证描述
    ///   - org_name: type 为 enterprise 则必须，企业或机构名称
    ///   - org_address: type 为 enterprise 则必须，企业或机构地址
    private func updateCertificate(type: String,
                           files: [Int],
                           name: String,
                           phone: String,
                           number: String,
                           bday: String,
                           holderName: String,
                           bankAcc: String,
                           bankName: String,
                           bankBranch: String,
                           bankSwift: String,
                           taxid: String,
                           desc: String,
                           additionalParams: [String: String]? = nil,
                           complete: @escaping (Bool, String) -> Void) {
        // TODO: 暂时屏蔽掉未登录用户调用该接口导致的验证错误
        if TSCurrentUserInfo.share.isLogin == false {
            complete(false, "network_problem".localized)
            return
        }
        // 1.配置路径
        var request = UserNetworkRequest.updateVerified
        request.urlPath = request.fullPathWith(replacers: [])
        // 2.配置参数
        var parameters: [String: Any] = ["type": type,
                                         "files": files,
                                         "name": name,
                                         "phone": phone,
                                         "number": number,
                                         "birthdate": bday,
                                         "desc": desc]
        if holderName.isEmpty == false && bankAcc.isEmpty == false && bankName.isEmpty == false && bankBranch.isEmpty == false && bankSwift.isEmpty == false {
            parameters.updateValue(holderName, forKey: "bank_holder")
            parameters.updateValue(bankAcc, forKey: "bank_account")
            parameters.updateValue(bankName, forKey: "bank_name")
            parameters.updateValue(bankBranch, forKey: "bank_branch")
            parameters.updateValue(bankSwift, forKey: "bank_swift")
        }
        
        if taxid.isEmpty == false {
            parameters.updateValue(taxid, forKey: "tax_id")
        }
        
        if let addParams = additionalParams {
            for (key, value) in addParams {
                parameters.updateValue(value, forKey: key)
            }
        }
        
        request.parameter = parameters
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (result) in
            switch result {
            case .error(_):
                complete(false, "network_problem".localized)
            case .failure(let failure):
                complete(false, failure.message ??  "upload_fail".localized)
            case .success(let data):
                complete(true, data.message ??  "upload_success".localized)
            }
        }
    }

    /// 获取用户认证信息
//    func getUserCertificate(complete: @escaping (EntityCertification?) -> Void) {
//        // TODO: 暂时屏蔽掉未登录用户调用该接口导致的验证错误
//        if TSCurrentUserInfo.share.isLogin == false {
//            complete(nil)
//            return
//        }
//        let path = TSURLPathV2.path.rawValue + TSURLPathV2.User.certificate.rawValue
//        try! RequestNetworkData.share.textRequest(method: .get, path: path, parameter: nil, complete: { (response: NetworkResponse?, status: Bool) in
//            guard status, let object = Mapper<CertificateResponseModel>().map(JSONObject: response) else {
//                complete(nil)
//                return
//            }
//            
//            complete(EntityCertification(model: object))
//        })
//    }

    /// 获取用户的粉丝或者关注列表
    ///
    /// - Parameters:
    ///   - identity: 被查询者的用户标识
    ///   - fansOrFollowList: 粉丝或者关注
    ///   - maxID: 最大的ID，查询更多时使用
    ///   - isAuth: 查询者是否是认证（登录）用户
    ///   - complete: 查询到的用户信息组；网络错误；当两个值都未空表示服务器响应错误
    func user(identity: Int, fansOrFollowList: TSUserRelationType, offset: Int? = nil, keyword: String? = nil, extra: String? = nil, complete: @escaping ((_ users: [UserInfoModel]?, _ error: NetworkError?) -> Void)) {
        let requestMethod: TSNetworkRequestMethod
        let fullPath: String
        
        switch fansOrFollowList {
        case .follow:
            requestMethod = TSNetworkRequest().followingsList
            fullPath = requestMethod.fullPathWith(replace: "\(identity)")
        case .fans:
            requestMethod = TSNetworkRequest().followersList
            fullPath = requestMethod.fullPathWith(replace: "\(identity)")
        case .friends:
            requestMethod = TSNetworkRequest().searchMyFriend
            fullPath = requestMethod.fullPath()
        }
        
        var parameter: [String: Any] = ["limit": TSAppConfig.share.localInfo.limit]
        if let offset = offset {
            parameter["offset"] = offset
        }
        
        if let keyword = keyword {
            parameter["keyword"] = keyword
        }
        
        if let extra = extra {
            parameter["extras"] = extra
        }
        
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: fullPath, parameter: parameter, complete: { (networkResponse, result) in
            // 网络请求失败处理
            guard result else {
                //let message = TSCommonNetworkManager.getNetworkErrorMessage(with: networkResponse)
                switch networkResponse {
                case let networkResponse as NetworkError:
                    complete(nil, networkResponse)
                case let responseInfo as String: break
                default:
                    complete(nil, nil)
                }
                return
            }
            // 请求成功处理
            let users = Mapper<UserInfoModel>().mapArray(JSONObject: networkResponse)
            complete(users, nil)
        })
    }

    /// 获取用户搜索好友列表
    ///
    /// - Parameters:
    ///   - identity: 被查询者的用户标识
    ///   - offset: 分页
    ///   - keyWordString: 搜索关键字
    ///   - complete: 查询到的用户信息组；网络错误；当两个值都未空表示服务器响应错误
    func friendList(offset: Int?, keyWordString: String?, extras:String = "", filterMerchants: String = "", complete: @escaping ((_ users: [UserInfoModel]?, _ error: NetworkError?) -> Void)) {
        let requestMethod: TSNetworkRequestMethod
        let fullPath: String
        requestMethod = TSNetworkRequest().searchMyFriend
        fullPath = requestMethod.fullPath()
        
        var parameter: [String: Any] = ["offset": 0, "extras":extras]
        parameter["keyword"] = keyWordString
        if let offset = offset {
            parameter["offset"] = offset
        }
        if filterMerchants.count > 0 {
            parameter["filterMerchants"] = filterMerchants
        }
    
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: fullPath, parameter: parameter, complete: { (networkResponse, result) in
            // 网络请求失败处理
            guard result else {
                //let message = TSCommonNetworkManager.getNetworkErrorMessage(with: networkResponse)
                switch networkResponse {
                case let networkResponse as NetworkError:
                    complete(nil, networkResponse)
                case let responseInfo as String: break
                default:
                    complete(nil, nil)
                }
                return
            }
            // 请求成功处理
            let users = Mapper<UserInfoModel>().mapArray(JSONObject: networkResponse)
            complete(users, nil)
        })
    }
    
    
    func invitedFriendList(limit: Int, offset: Int?, complete: @escaping ((_ model: InvitedFriendsListModel?, _ error: NetworkError?) -> Void)) {
        let requestMethod: TSNetworkRequestMethod
        let fullPath: String
        requestMethod = TSNetworkRequest().invitedFriends
        fullPath = requestMethod.fullPath()
        
        var parameter: [String: Any] = ["limit": limit]
        if let offset = offset {
            parameter["offset"] = offset
        }
    
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: fullPath, parameter: parameter, complete: { (networkResponse, result) in
            // 网络请求失败处理
            guard result else {
                switch networkResponse {
                case let networkResponse as NetworkError:
                    complete(nil, networkResponse)
                case let responseInfo as String: break
                default:
                    complete(nil, nil)
                }
                return
            }
            // 请求成功处理
            let model = Mapper<InvitedFriendsListModel>().map(JSONObject: networkResponse)
            complete(model, nil)
        })
    }
    
    /// 获取关注商家用户，搜索商家用户列表
    ///
    /// - Parameters:
    ///   - identity: 被查询者的用户标识
    ///   - offset: 分页
    ///   - keyWordString: 搜索关键字
    ///   - complete: 查询到的用户信息组；网络错误；当两个值都未空表示服务器响应错误
    func mechantList(offset: Int?, keyWordString: String?, extras:String = "", filterMerchants: String = "", limit: Int = TSNewFriendsNetworkManager.limit, complete: @escaping ((_ users: [UserInfoModel]?, _ error: NetworkError?) -> Void)) {
        let requestMethod: TSNetworkRequestMethod
        let fullPath: String
        requestMethod = TSNetworkRequest().mechantFriends
        fullPath = requestMethod.fullPath()
        
        var parameter: [String: Any] = ["offset": 0, "extras":extras, "limit": limit]
        parameter["keyword"] = keyWordString
        
        if let offset = offset {
            parameter["offset"] = offset
        }
        if filterMerchants.count > 0 {
            parameter["filterMerchants"] = filterMerchants
        }
    
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: fullPath, parameter: parameter, complete: { (networkResponse, result) in
            // 网络请求失败处理
            guard result else {
                //let message = TSCommonNetworkManager.getNetworkErrorMessage(with: networkResponse)
                switch networkResponse {
                case let networkResponse as NetworkError:
                    complete(nil, networkResponse)
                case let responseInfo as String: break
                default:
                    complete(nil, nil)
                }
                return
            }
            // 请求成功处理
            let users = Mapper<UserInfoModel>().mapArray(JSONObject: networkResponse)
            complete(users, nil)
        })
    }

    /// 获取话题列表(联想)
    ///
    /// - Parameters:
    ///  - index:
    ///  - keyWordString: 关键词
    ///  - limit: 每页多少条数据
    ///  - direction: 排序
    ///  - only: 热门，当有only的时候其他参数全部失效，只会返回热门数据
    func getTopicListThink(index: Int?, keyWordString: String?, limit: Int?, direction: String?, only: String?, complete: @escaping ((_ topicList: [TopicListModel]?, _ error: NetworkError?) -> Void)) -> DataRequest {
        let requestMethod: TSNetworkRequestMethod
        let fullPath: String
        requestMethod = TSTopicNetworkRequest().topicList
        fullPath = requestMethod.fullPath()
        var parameter: [String: Any] = ["direction": "desc"]
        if let index = index {
            parameter["index"] = index
        }
        if let keyWordString = keyWordString {
            parameter["q"] = keyWordString
        }
        if let limit = limit {
            parameter["limit"] = limit
        }
        if let direction = direction {
            parameter["direction"] = direction
        }
        if let only = only {
            parameter.removeAll()
            parameter["only"] = only
        }
        return try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: fullPath, parameter: parameter, complete: { (networkResponse, result) in
            // 网络请求失败处理
            guard result else {
                //let message = TSCommonNetworkManager.getNetworkErrorMessage(with: networkResponse)
                switch networkResponse {
                case let networkResponse as NetworkError:
                    complete(nil, networkResponse)
                case let responseInfo as String: break
                default: complete(nil, nil)
                }
                return
            }
            // 请求成功处理
            let users = Mapper<TopicListModel>().mapArray(JSONObject: networkResponse)
            complete(users, nil)
        })
    }

    /// 获取话题列表
    ///
    /// - Parameters:
    ///  - index:
    ///  - keyWordString: 关键词
    ///  - limit: 每页多少条数据
    ///  - direction: 排序
    ///  - only: 热门，当有only的时候其他参数全部失效，只会返回热门数据
    func getTopicList(index: Int?, keyWordString: String?, limit: Int?, direction: String?, only: String?, complete: @escaping ((_ topicList: [TopicListModel]?, _ error: NetworkError?) -> Void)) {
        let requestMethod: TSNetworkRequestMethod
        let fullPath: String
        requestMethod = TSTopicNetworkRequest().topicList
        fullPath = requestMethod.fullPath()
        var parameter: [String: Any] = ["direction": "desc"]
        if let index = index {
            parameter["index"] = index
        }
        if let keyWordString = keyWordString {
            parameter["q"] = keyWordString
        }
        if let limit = limit {
            parameter["limit"] = limit
        }
        if let direction = direction {
            parameter["direction"] = direction
        }
        if let only = only {
            parameter.removeAll()
            parameter["only"] = only
        }
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: fullPath, parameter: parameter, complete: { (networkResponse, result) in
            // 网络请求失败处理
            guard result else {
                //let message = TSCommonNetworkManager.getNetworkErrorMessage(with: networkResponse)
                switch networkResponse {
                case let networkResponse as NetworkError:
                    complete(nil, networkResponse)
                case let responseInfo as String: break
                default:
                    complete(nil, nil)
                }
                return
            }
            // 请求成功处理
            let users = Mapper<TopicListModel>().mapArray(JSONObject: networkResponse)
            complete(users, nil)
        })
    }

    /// 话题详情信息
    func getTopicInfo(groupId: Int, complete: @escaping (TopicModel?, String?, Bool) -> Void) {
        // 1.请求 url
        let requestMethod: TSNetworkRequestMethod
        let fullPath: String
        requestMethod = TSTopicNetworkRequest().detailTopic
        fullPath = requestMethod.fullPathWith(replace: "\(groupId)")
        // 3.发起请求
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: fullPath, parameter: nil, complete: { (networkResponse, result) in
            // 网络请求失败处理
            guard result else {
                //let message = TSCommonNetworkManager.getNetworkErrorMessage(with: networkResponse)
                switch networkResponse {
                case let networkResponse as NetworkError:
                    complete(nil, nil, result)
                case let responseInfo as String: break
                default:
                    complete(nil, nil, result)
                }
                return
            }
            let model = Mapper<TopicModel>().map(JSONObject: networkResponse)
            var userIds: [Int] = (model?.menberID)!
            userIds.insert((model?.userId)!, at: 0)
            // 2.发起网络请求
            TSUserNetworkingManager().getUserInfo(userIds) { (_, models, _) in
                guard var models = models else {
                    // TODO: 错误信息应该使用后台返回信息，但由于这个 API 没有处理用户信息接口错误信息。
                    // 当然更不应该在调用 API 的地方处理后台返回错误信息。
                    // 就先写一个假的数据，等这 API 更新后再替换
                    complete(nil,  "network_problem".localized, false)
                    return
                }
                // 3.将用户信息和动态信息匹配
                for (index, item) in models.enumerated() {
                    if item.userIdentity == model?.userId {
                        model?.setUserInfo(user: item)
                        /// 排序 将发布者的用户信息排在最前面
                        models.remove(at: index)
                        models.insert((model?.userInfo)!, at: 0)
                        break
                    }
                }
                model?.setMenber(menber: models)
                complete(model, nil, true)
            }
        })
    }

    /// 话题参与者列表(返回的是用户id数组)
    func getTopicMenberList(groupId: Int, limit: Int?, offset: Int?, complete: @escaping ([UserInfoModel]?, String?, Bool) -> Void) {
        // 1.请求 url
        let requestMethod: TSNetworkRequestMethod
        let fullPath: String
        requestMethod = TSTopicNetworkRequest().topicMenberList
        fullPath = requestMethod.fullPathWith(replace: "\(groupId)")
        var parameter = ["limit": 15]
        if let offset = offset {
            parameter["offset"] = offset
        }
        if let limit = limit {
            parameter["limit"] = limit
        }
        // 3.发起请求
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: fullPath, parameter: parameter, complete: { (networkResponse, result) in
            // 网络请求失败处理
            guard result else {
                //let message = TSCommonNetworkManager.getNetworkErrorMessage(with: networkResponse)
                switch networkResponse {
                case let networkResponse as NetworkError:
                    complete(nil, nil, result)
                case let responseInfo as String: break
                default:
                    complete(nil, nil, result)
                }
                return
            }
            let userIds: [Int] = networkResponse as! [Int]
            // 2.发起网络请求
            TSUserNetworkingManager().getUserInfo(userIds) { (_, models, _) in
                guard let models = models else {
                    // TODO: 错误信息应该使用后台返回信息，但由于这个 API 没有处理用户信息接口错误信息。
                    // 当然更不应该在调用 API 的地方处理后台返回错误信息。
                    // 就先写一个假的数据，等这 API 更新后再替换
                    complete(nil,  "network_problem".localized, false)
                    return
                }
                complete(models, nil, true)
            }
        })
    }

    /// 上传话题封面图
    func uploadTopicFace(_ bgData: Data, complete: @escaping ((_ faceNode: String?, _ msg: String?, _ status: Bool) -> Void)) -> Void {
        TSGlobalNetManager.uploadImage(data: bgData, progressHandler: nil) { (node, msg, status) in
            complete(node, msg, status)
        }
    }

    /// 话题下的动态列表
    func getTopicMomentList(topicID: Int, limit: Int = TSAppConfig.share.localInfo.limit, offset: Int?, complete: @escaping ([FeedListModel]?, String?, Bool) -> Void) {
        // 1.请求 url
        var request = TSTopicNetworkRequest().topicMomentList
        request.urlPath = request.fullPathWith(replacers: ["\(topicID)"] )
        // 2.配置参数
        var parameters: [String: Any] = ["limit": limit, "direction": "desc"]
        if let offset = offset {
            parameters.updateValue(offset, forKey: "index")
        }
        request.parameter = parameters
        // 3.发起请求
          RequestNetworkData.share.text(request: request) { (networkResult) in
                switch networkResult {
                case .error(_):
                    complete(nil, "network_problem".localized, false)
                case .failure(let failure):
                    complete(nil, failure.message, false)
                case .success(let data):
                    // 需要组装转发的数据
                    // 分类整理
                    let feeds = data.models
                    // 乱序
                    let repostFeedsListModelIDs: [Int] = feeds.filter { $0.repostId > 0 && $0.repostType != nil }.compactMap { $0.repostId }

                    /// 通过模块逐个去请求转发的信息，动态需要的原作者的用户信息也返回了的开森
                    let group = DispatchGroup()
                    if repostFeedsListModelIDs.count > 0 {
                        group.enter()
                        FeedListNetworkManager.requestRepostFeedInfo(feedIDs: repostFeedsListModelIDs) { _ in
                            group.leave()
                        }
                    }
                    /// 全部请求完毕
                    group.notify(queue: .main) {
                        complete(feeds, nil, true)
                    }
            }
        }
}
    ///创建话题
    func createTopic(faceNode: String?, topicTitle: String, topicIntro: String?, complete: @escaping ((_ topicId: Int?, _ msg: String?, _ status: Bool, _ needReview: Bool) -> Void)) -> Void {
        let requestMethod: TSNetworkRequestMethod
        let fullPath: String
        requestMethod = TSTopicNetworkRequest().createTopic
        fullPath = requestMethod.fullPath()
        var parameter: [String: Any] = ["name": topicTitle]
        if let faceNode = faceNode {
            parameter["logo"] = faceNode
        }
        if let topicIntro = topicIntro {
            parameter["desc"] = topicIntro
        }
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: fullPath, parameter: parameter, complete: { (networkResponse, result) in
            // 网络请求失败处理
            guard result else {
                let message = TSCommonNetworkManager.getNetworkErrorMessage(with: networkResponse)
                switch networkResponse {
                case let networkResponse as NetworkError:
                    complete(nil, message, false, false)
                case let responseInfo as String: break
                default:
                    complete(nil, message, false, false)
                }
                return
            }
            let resultDict = networkResponse as! Dictionary<String, Any>
            let topicOfId = resultDict["id"] as! Int
            if let needView = resultDict["need_review"] {
                // 请求成功处理
                complete(topicOfId, (needView as! Bool) ?  "create_topic_success_wait".localized :  "create_team_success".localized, true, needView as! Bool)
            } else {
                complete(topicOfId,  "create_team_success".localized, true, false)
            }
        })
    }

    ///编辑一个话题
    func editTopic(faceNode: String?, topicIntro: String?, topicId: Int, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        let requestMethod: TSNetworkRequestMethod
        let fullPath: String
        requestMethod = TSTopicNetworkRequest().editTopic
        fullPath = requestMethod.fullPathWith(replace: "\(topicId)")
        var parameter: [String: Any] = ["desc": ""]
        if let faceNode = faceNode {
            parameter["logo"] = faceNode
        }
        if let topicIntro = topicIntro {
            parameter["desc"] = topicIntro
        }
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: fullPath, parameter: parameter, complete: { (networkResponse, result) in
            // 网络请求失败处理
            guard result else {
                let message = TSCommonNetworkManager.getNetworkErrorMessage(with: networkResponse)
                switch networkResponse {
                case let networkResponse as NetworkError:
                    complete(message, false)
                case let responseInfo as String: break
                default:
                    complete(message, false)
                }
                return
            }
            // 请求成功处理
            complete("save_topic_success".localized, true)
        })
    }

    /// 举报一个话题
    func reportATopic(topicId: Int, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void )) -> Void {
        let requestMethod: TSNetworkRequestMethod
        let fullPath: String
        requestMethod = TSTopicNetworkRequest().reportTopic
        fullPath = requestMethod.fullPathWith(replace: "\(topicId)")
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: fullPath, parameter: nil, complete: { (networkResponse, result) in
            // 网络请求失败处理
            guard result else {
                let message = TSCommonNetworkManager.getNetworkErrorMessage(with: networkResponse)
                switch networkResponse {
                case let networkResponse as NetworkError:
                    complete(message, false)
                case let responseInfo as String: break
                default:
                    complete(message, false)
                }
                return
            }
            // 请求成功处理
            complete("report_success".localized, true)
        })
    }

    /// 关注、取消关注话题
    func followOrUnfollowTopic(topicId: Int, follow: Bool, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void )) -> Void {
        let requestMethod: TSNetworkRequestMethod
        let fullPath: String
        if follow {
            requestMethod = TSTopicNetworkRequest().followTopic
        } else {
            requestMethod = TSTopicNetworkRequest().unFollowTopic
        }
        fullPath = requestMethod.fullPathWith(replace: "\(topicId)")
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: fullPath, parameter: nil, complete: { (networkResponse, result) in
            // 网络请求失败处理
            guard result else {
                let message = TSCommonNetworkManager.getNetworkErrorMessage(with: networkResponse)
                switch networkResponse {
                case let networkResponse as NetworkError:
                    complete(message, false)
                case let responseInfo as String: break
                default:
                    complete(message, false)
                }
                return
            }
            // 请求成功处理
            complete(follow ? "follow_topic_success".localized : "unfollow_topic_success".localized, true)
        })
    }

    /// 操作用户关系
    ///
    /// - Parameters:
    ///   - type: 将当前登录用户和指定用户的关系修改为该类型
    ///   - userID: 操作的用户标识
    /// - Note: 该操作无任何响应
    func operate(_ type: FollowStatus, userID: Int) {
        assert(type != .oneself || type != .eachOther, "操作用户关系时，不能切换为自己活着相互关注")
        let requestMethod: TSNetworkRequestMethod
        let fullPath: String
        if type == .follow {
            requestMethod = TSNetworkRequest().followUser
        } else {
            requestMethod = TSNetworkRequest().unfollowUser
        }
        fullPath = requestMethod.fullPath().replacingOccurrences(of: requestMethod.replace!, with: "\(userID)")
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: fullPath, parameter: nil, complete: { _, _ in
        })
    }
    
    func operateWithClosure(_ type: FollowStatus, userID: Int ,completion: @escaping (_ status: Bool) -> Void) {
        assert(type != .oneself || type != .eachOther, "操作用户关系时，不能切换为自己活着相互关注")
        let requestMethod: TSNetworkRequestMethod
        let fullPath: String
        if type == .follow {
            requestMethod = TSNetworkRequest().followUser
        } else {
            requestMethod = TSNetworkRequest().unfollowUser
        }
        fullPath = requestMethod.fullPath().replacingOccurrences(of: requestMethod.replace!, with: "\(userID)")
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: fullPath, parameter: nil, complete: { data, status in
            completion(status)
        })
    }


}

// MARK: - 获取用户信息

extension TSUserNetworkingManager {
    /// 获取用户信息
    ///
    /// - Parameters:
    ///   - userIdentities: 用户标识数组
    ///   - complete: 结果
    func getUserInfo(_ userIdentities: [Int], complete: @escaping ((_ info: Any?, _ userInfoModels: [UserInfoModel]?, _ error: NSError?) -> Void)) {
        //assert(!userIdentities.isEmpty, "查询用户信息数组为空")
        if userIdentities.isEmpty {
            complete(nil, nil, NSError(domain: "查询用户信息数组为空", code: -1, userInfo: nil))
            return
        }
        var path = TSURLPathV2.path.rawValue
        path = path + TSURLPathV2.User.users.rawValue + "?id=" + userIdentities.convertToString()! + "&limit=50"
        try! RequestNetworkData.share.textRequest(method: .get, path: path, parameter: nil, complete: { (networkResponse, result) in
            guard result == true else {
                switch networkResponse {
                case _ as NetworkError:
                    let error = TSErrorCenter.create(With: .networkError)
                    complete(nil, nil, error)
                case let responseInfo as String:
                    complete(responseInfo, nil, nil)
                case let responseDic as Dictionary<String, Array<String>>:
                    complete(responseDic, nil, nil)
                default:
                    print("服务器响应了无法解析的数据")
                    complete(nil, nil, NSError(domain: "服务器响应了无法解析的数据", code: -1, userInfo: nil))
//                    assert(false, "服务器响应了无法解析的数据")
                }
                return
            }
            var tempUserInfoModels = [UserInfoModel]()
            if let datas = networkResponse as? [Any] {
                if let modelList = Mapper<UserInfoModel>().mapArray(JSONObject: datas) {
                    tempUserInfoModels.append(contentsOf: modelList)
                }
            }

            if let data = networkResponse as? [String: Any] {
                if let userModel = Mapper<UserInfoModel>().map(JSON: data) {
                    tempUserInfoModels.append(userModel)
                }
            }
            DispatchQueue.global().async {
                tempUserInfoModels.forEach { user in
                    user.save()
                }
            }
           
            complete(networkResponse, tempUserInfoModels, nil)
        })
    }

    // 获取当前用户信息
    func getCurrentUserInfo(complete: @escaping ((_ userModel: UserSessionInfo?, _ msg: String?, _ status: Bool) -> Void)) -> Void {
        let path = TSURLPathV2.path.rawValue + TSURLPathV2.User.user.rawValue
        try! RequestNetworkData.share.textRequest(method: .get, path: path, parameter: nil, complete: { (data, status) in
            var message: String?
            if status {
                let userModel = Mapper<UserSessionInfo>().map(JSONObject: data)
                if let userModel = userModel {
                    let user = TSUser(uid: userModel.userIdentity.stringValue,
                                    username: userModel.username,
                                    phone: userModel.phone.orEmpty,
                                    nickname: userModel.name,
                                    displayname: "")
                    Defaults.currentUser = user
                    TSCurrentUserInfo.share._userInfo = userModel
                    
                }
                userModel?.save()
                complete(userModel, message, status)
                
            } else {
                
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
                complete(nil, message, false)
                
            }
        })
    }
    // 获取当前用户所知道的语言 （单独获取）
    func getCurrentUserPersonalLanguage(complete: @escaping ((_ languages: [ProfileInfoListModel]?, _ msg: String?, _ status: Bool) -> Void)) -> Void {
        let path = TSURLPathV2.path.rawValue + TSURLPathV2.User.user.rawValue
        try! RequestNetworkData.share.textRequest(method: .get, path: path, parameter: nil, complete: { (data, status) in
            var message: String?
            if status {
                let dic = data as? Dictionary<String, Any>
                let resultArray = dic?["personal_language"]
                let languageList = Mapper<ProfileInfoListModel>().mapArray(JSONObject: resultArray)
                complete(languageList, message, status)
                
            } else {
                
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
                complete(nil, message, false)
                
            }
        })
    }
    // 获取指定的单个用户信息
    ///
    /// - Parameters:
    ///   - userId: 用户标识数组
    ///   - needLimitParameter: 默认是false, true limit 会传送给后端
    ///   - complete: 请求回调
    func getUserInfo(userId: Int, needLimitParameter: Bool = false,  complete: @escaping ((_ userModel: UserInfoModel?, _ msg: String?, _ status: Bool) -> Void)) {
        var path = TSURLPathV2.path.rawValue + TSURLPathV2.User.users.rawValue + "?id=\(userId)"

        if needLimitParameter {
            path += "&limit=1"
        }
        
        try! RequestNetworkData.share.textRequest(method: .get, path: path, parameter: nil, complete: { (data, status) in
            var message: String?
            if status {
                let userModel = Mapper<UserInfoModel>().mapArray(JSONObject: data)
                complete(userModel?.first, message, status)
            } else {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
                complete(nil, message, false)
            }
        })
    }
    
    // 更改用户一次性密码设定
    ///
    /// - Parameters:
    ///   - otp_device: 用户一次性密码关闭/开启 (true/false)
    ///   - complete: 请求回调
    func updateUserOtpSettings(otp_device: Bool = false,  complete: @escaping ((_ userModel: UserInfoModel?, _ msg: String?, _ status: Bool) -> Void)) {
        let path = TSURLPathV2.path.rawValue + TSURLPathV2.User.updateUserOtpSettings.rawValue + "?otp_device=\(otp_device ? "1" : "0")"
        
        try! RequestNetworkData.share.textRequest(method: .patch, path: path, parameter: nil, complete: { (data, status) in
            var message: String?
            if status {
                let userModel = Mapper<UserInfoModel>().map(JSONObject: data)
                complete(userModel, message, status)
            } else {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
                complete(nil, message, false)
            }
        })
    }

    // 获取指定的多个用户信息
    ///
    /// - Parameters:
    ///   - userId: 用户标识数组
    ///   - complete: 请求回调
    func getUsersInfo(usersId: [Int], names: [String] = [], userNames: [String] = [], complete: @escaping ((_ usersModel: [UserInfoModel]?, _ msg: String?, _ status: Bool) -> Void)) -> Void {
        let usersId = usersId.filter { $0 > 0 }
        let names = names.filter { return $0.isEmpty == false }
        let userNames = userNames.filter { return $0.isEmpty == false }
        if usersId.isEmpty && userNames.isEmpty && names.isEmpty {
            complete(nil, nil, false)
            return
        }
        // 应对usersId进行判断处理
        var path = ""
        if usersId.count > 0 {
            path = TSURLPathV2.path.rawValue + TSURLPathV2.User.users.rawValue + "?id=" + (usersId.convertToString() ?? "")
        } else if names.count > 0 {
            path = TSURLPathV2.path.rawValue + TSURLPathV2.User.users.rawValue + "?name=" + (names.convertToString() ?? "") + "&fetch_by=name"
            path = path.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        } else if userNames.count > 0 {
            path = TSURLPathV2.path.rawValue + TSURLPathV2.User.users.rawValue + "?username=" + (userNames.convertToString() ?? "") + "&fetch_by=username&limit=\(userNames.count)"
            path = path.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        }
        
        try! RequestNetworkData.share.textRequest(method: .get, path: path, parameter: nil, complete: { (data, status) in
            guard status else {
                let message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
                complete(nil, message, false)
                return
            }
            
            if let userList = Mapper<UserInfoModel>().mapArray(JSONObject: data) {
                userList.forEach({ user in
                    user.save()
                })
                complete(userList, nil, status)
            } else {
                let message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
                complete(nil, message, false)
            }
        })
    }
    
    
    // MARK: - 检查当前电话号码是否已经注册
    func phoneDidRegister(number: String, complete: @escaping ((_ didRegister: Bool) -> Void)) {
        let path = TSURLPathV2.path.rawValue + TSURLPathV2.User.users.rawValue + "/" + number
        try! RequestNetworkData.share.textRequest(method: .get, path: path, parameter: nil, complete: { (data, status) in
            /// 如果注册了 就返回用户信息，否者404
            complete(status)
        })
    }
    
    
    /// 获得用户头像的网址
    func profileImageURL(_ username: String) -> String {
        return TSAppConfig.share.rootServerAddress + TSURLPathV2.path.rawValue + TSURLPathV2.User.user.rawValue + "/" + username + "/picture?filter_type=username&app=rl"
    }
    
    /// 获取当前用户yipps信息
    func getWalletYipps(complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) {
        let request = UserNetworkRequest().wallet
        
        do {
            try RequestNetworkData.share.textRequest(method: request.method, path: request.fullPathWith(replacers: []), parameter: nil, complete: { (data, status) in
                var message: String?
                if status {
                    let modelList = Mapper<UserWalletIntegrationModel>().mapArray(JSONObject: data)
                    var user = CurrentUserSessionInfo
                    
                    if let _modelList = modelList {
                        user?.updateWallet(_modelList)
                    }
                    
                    complete(nil, status)
                } else {
                    message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
                    complete(message, status)
                }
            })
            
        } catch let error {
            LogManager.Log("\(#function) \(#file):\(#line): Fail to get currency: \(error.localizedDescription)\n", loggingType: .networkError)
        }
    }
    
    // 获取所有国家列表
    ///
    /// - Parameters:
    ///   - complete: 请求回调
    func getAllCountries(complete: @escaping ((_ countries: [ProfileInfoListModel]?, _ msg: String?, _ status: Bool) -> Void)) -> Void {

        let path = TSURLPathV2.path.rawValue + TSURLPathV2.User.getAllCountry.rawValue
        
        try! RequestNetworkData.share.textRequest(method: .get, path: path, parameter: nil, complete: { (data, status) in
            guard status else {
                let message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
                complete(nil, message, false)
                return
            }
            let dic = data as? Dictionary<String, Any>
            let resultArray = dic?["country"]
            
            if let countryList = Mapper<ProfileInfoListModel>().mapArray(JSONObject: resultArray) {
                complete(countryList, nil, status)
            } else {
                let message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
                complete(nil, message, false)
            }
        })
    }
    // 获取省份列表
    ///
    /// - Parameters:
    ///   - keyword_country: 国家ID
    ///   - complete: 请求回调
    func getProvincesWithCountry(keyword_country: String, complete: @escaping ((_ cities: [ProfileInfoListModel]?, _ msg: String?, _ status: Bool) -> Void)) -> Void {

        let path = TSURLPathV2.path.rawValue + TSURLPathV2.User.getProvince.rawValue + "?keyword_country=" + keyword_country
        
        try! RequestNetworkData.share.textRequest(method: .get, path: path, parameter: nil, complete: { (data, status) in
            guard status else {
                let message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
                complete(nil, message, false)
                return
            }
            let dic = data as? Dictionary<String, Any>
            let resultArray = dic?["state"]
            
            if let countryList = Mapper<ProfileInfoListModel>().mapArray(JSONObject: resultArray) {
                complete(countryList, nil, status)
            } else {
                let message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
                complete(nil, message, false)
            }
        })
    }
    
    // 获取城市列表
    ///
    /// - Parameters:
    ///   - keyword_state: 州省name
    ///   - complete: 请求回调
    func getCitiesWithProvince(keyword_state: String, complete: @escaping ((_ cities: [ProfileInfoListModel]?, _ msg: String?, _ status: Bool) -> Void)) -> Void {

        let path = TSURLPathV2.path.rawValue + TSURLPathV2.User.getCity.rawValue + "?keyword_state=" + keyword_state
        
        try! RequestNetworkData.share.textRequest(method: .get, path: path, parameter: nil, complete: { (data, status) in
            guard status else {
                let message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
                complete(nil, message, false)
                return
            }
            let dic = data as? Dictionary<String, Any>
            let resultArray = dic?["city"]
            
            if let countryList = Mapper<ProfileInfoListModel>().mapArray(JSONObject: resultArray) {
                complete(countryList, nil, status)
            } else {
                let message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
                complete(nil, message, false)
            }
        })
    }
    // 获取填写个人资料所需数据 - relationship & language & work industry
    ///
    /// - Parameters:
    ///   - complete: 请求回调
    func getProfileInfoData(complete: @escaping ((_ infoModel: ProfileInfoModel?, _ msg: String?, _ status: Bool) -> Void)) -> Void {

        let path = TSURLPathV2.path.rawValue + TSURLPathV2.User.getProfileInfoData.rawValue
        
        try! RequestNetworkData.share.textRequest(method: .get, path: path, parameter: nil, complete: { (data, status) in
            guard status else {
                let message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
                complete(nil, message, false)
                return
            }
            guard let result = Mapper<ProfileInfoModel>().map(JSONObject: data) else {
                assert(false, "服务器响应了不能解析的数据")
                complete(nil, "network_problem".localized, status)
                return
            }
            complete(result, nil , status)
            
//            if let countryList = Mapper<ProfileInfoListModel>().mapArray(JSONObject: resultArray) {
//                complete(countryList, nil, status)
//            } else {
//                let message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
//                complete(nil, message, false)
//            }
        })
    }
    // 获取兴趣标签列表
    ///
    /// - Parameters:
    ///   - complete: 请求回调
    func getTagsData(complete: @escaping ((_ allTags: [FeedTagListModel]?, _ msg: String?, _ status: Bool) -> Void)) -> Void {

        let path = TSURLPathV2.path.rawValue + TSURLPathV2.User.getTags.rawValue
        
        try! RequestNetworkData.share.textRequest(method: .get, path: path, parameter: nil, complete: { (data, status) in
            guard status else {
                let message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
                complete(nil, message, false)
                return
            }
            
            if let tagList = Mapper<FeedTagListModel>().mapArray(JSONObject: data) {
                complete(tagList, nil, status)
            } else {
                let message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
                complete(nil, message, false)
            }
        })
    }
    
    // 获取当前用户的兴趣标签列表
    ///
    /// - Parameters:
    ///   - complete: 请求回调
    func getUserTagsData(complete: @escaping ((_ allTags: [FeedsTagModel]?, _ msg: String?, _ status: Bool) -> Void)) -> Void {

        let path = TSURLPathV2.path.rawValue + TSURLPathV2.User.getUserTags.rawValue
        
        try! RequestNetworkData.share.textRequest(method: .get, path: path, parameter: nil, complete: { (data, status) in
            guard status else {
                let message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
                complete(nil, message, false)
                return
            }
            
            if let tagList = Mapper<FeedsTagModel>().mapArray(JSONObject: data) {
                complete(tagList, nil, status)
            } else {
                let message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
                complete(nil, message, false)
            }
        })
    }
    
    
    /// 用户首次添加Tags或者修改Tags
    /// - Parameters:
    ///   - isSignUp: 是否为注册时添加
    ///   - tagids: tagids
    ///   - complete: -// MARK: - 
    /// - Returns: 
    func editUserTags(isSignUp: Bool = false, tagids: String = "", complete: @escaping ((_ msg: String?, _ status: Bool) -> Void )) -> Void {

        let path: String
        if isSignUp {
            path = TSURLPathV2.path.rawValue + TSURLPathV2.User.addTags.rawValue
        }else{
            path = TSURLPathV2.path.rawValue + TSURLPathV2.User.updateTags.rawValue
        }
        var parameter: [String: Any] = ["tag_id": tagids]
  
        try! RequestNetworkData.share.textRequest(method: .post, path: path, parameter: parameter, complete: { (networkResponse, result) in
            // 网络请求失败处理
            guard result else {
                let message = TSCommonNetworkManager.getNetworkErrorMessage(with: networkResponse)
                switch networkResponse {
                case let networkResponse as NetworkError:
                    complete(message, false)
                case let responseInfo as String: break
                default:
                    complete(message, false)
                }
                return
            }
            // 请求成功处理
            complete("", true)
        })
    }

}

// MARK: - 修改用户信息

extension TSUserNetworkingManager {
    
//    func getUserAddressForms() -> Future<TSVerifyAddressFormsModel, YPErrorType> {
//        
//        return Future() { promise in
//            
//            let path = TSURLPathV2.path.rawValue + TSURLPathV2.User.residentialInput.rawValue
//            
//            try! RequestNetworkData.share.textRequest(method: .get, path: path, parameter: nil, complete: { (data, status) in
//                var message: String?
//                if status,
//                    let modelList = Mapper<TSVerifyAddressFormsModel>().map(JSONObject: data) {
//                    promise(.success(modelList))
//                } else {
//                    message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
//                    promise(.failure(YPErrorType.carriesMessage(message.orEmpty, code: -999, errCode: nil)))
//                }
//            })
//        }
//        
//    }

    /// 修改用户的基本信息
    func updateUserBaseInfo(name: String, sex: Int? = nil, bio: String, location: String, birthday: String? = nil, email: String? = nil, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        let path = TSURLPathV2.path.rawValue + TSURLPathV2.User.user.rawValue
        var params: [String: Any] = ["name": name,  "bio": bio]
        if birthday.orEmpty != "" {
            params["birthdate"] = birthday
        }
        if sex != nil {
            params["sex"] = sex.stringValue
        }
        params["email"] = email
        try! RequestNetworkData.share.textRequest(method: .patch, path: path, parameter: params, complete: { (data, status) in
            var message: String?
            if !status {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
            }
            complete(message, status)
        })
    }
    
    /// 修改用户的个人信息
    /// - Parameters:
    ///   - sex: 性别
    ///   - birthdate: 生日
    ///   - language: 语言
    ///   - relationship_status: 关系状态
    ///   - website: 网站
    ///   - work_industry: 工作性质
    ///   - location_country: 国家
    ///   - location_city: 城市
    ///   - complete: -
    /// - Returns:
    func updateUserPersonalInfo(sex: Int? = nil, birthdate: String? = nil, language: String? = nil, relationship_status: String? = nil, website: String? = nil, work_industry: String? = nil, location_country: String? = nil, location_province: String? = nil, location_city: String? = nil, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        let path = TSURLPathV2.path.rawValue + TSURLPathV2.User.updateUserInfo.rawValue
        var params: [String: Any] = [:]
        if sex != nil {
            params["sex"] = sex.stringValue
        }
        if birthdate != nil {
            params["birthdate"] = birthdate
        }
        if language != nil {
            params["personal_language"] = language
        }
        if relationship_status != nil {
            params["relationship_status"] = relationship_status
        }
        if website != nil {
            params["website"] = website
        }
        if work_industry != nil {
            params["work_industry"] = work_industry
        }
        if location_country.orEmpty != "" {
            params["location_country"] = location_country
        }
        if location_province.orEmpty != "" {
            params["location_state"] = location_province
        }
        if location_city.orEmpty != "" {
            params["location_city"] = location_city
        }
        try! RequestNetworkData.share.textRequest(method: .post, path: path, parameter: params, complete: { (data, status) in
            var message: String?
            if !status {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
            }
            complete(message, status)
        })
    }
    /// 修改用户头像
    func updateUserAvatar(_ avatar: Data, fileName: String = "plus.jpeg", mimeType: String = "image/jpeg", progressHandler: ((_ progress:Progress)->())?, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        TSGlobalNetManager.uploadImage(data: avatar, fileName: fileName, mimeType: mimeType, progressHandler: { (progress) in
            progressHandler?(progress)
        }) { (node, message, status) in
            if status == true {
                let path = TSURLPathV2.path.rawValue + TSURLPathV2.User.user.rawValue
                let params: [String: Any] = ["avatar": node!]
                try! RequestNetworkData.share.textRequest(method: .patch, path: path, parameter: params, complete: { (data, status) in
                    var message: String?
                    if !status {
                        message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
                    }
                    complete(message, status)
                })
            } else {
                complete(message, status)
            }
        }
    }

    /// 修改用户背景
    func updateUserBgImage(_ bgData: Data, progressHandler: ((_ progress:Progress)->())?, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        TSGlobalNetManager.uploadImage(data: bgData, progressHandler: { (progress) in
            progressHandler?(progress)
        }) { (node, message, status) in
            if status == true {
                let path = TSURLPathV2.path.rawValue + TSURLPathV2.User.user.rawValue
                let params: [String: Any] = ["bg": node!]
                try! RequestNetworkData.share.textRequest(method: .patch, path: path, parameter: params, complete: { (data, status) in
                    var message: String?
                    if !status {
                        message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
                    }
                    complete(message, status)
                })
            } else {
                complete(message, status)
            }
        }
    }

}

// MARK: - 用户打赏

extension TSUserNetworkingManager {

    /// 打赏指定用户
    /// userId - 打赏的用户Id
    /// amount - 打赏金额
    func reward(username: Any, amount: Double, stickerBundleId: String?, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1.请求url
        let requestMethod = TSUserRewardNetworkMethod().reward
        // 2.请求参数
        var params: [String: Any] = ["amount": amount]
    
        if let stickerBundleId = stickerBundleId, stickerBundleId.isEmpty == false {
            params.updateValue("sticker_artist", forKey: "type")
            params.updateValue(stickerBundleId, forKey: "sticker_bundle_id")
        }
        
        if let user = CurrentUserSessionInfo {
            params["request_id"] = user.requestKey
        }
        if TSAppConfig.share.localInfo.shouldShowRewardAlert {
            //Password
            if let inputCode = TSUtil.share().inputCode {
                params.updateValue(inputCode, forKey: "password")
                TSUtil.share().inputCode = nil
            }
        }
        
        //3.请求
        try! RequestNetworkData.share.textRequest(method: requestMethod.method, path: requestMethod.fullPathWith(replace: "\(username)"), parameter: params, encoding: URLEncoding.default, complete: { (data, status) in
            var message: String?
            if !status {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
            }
            complete(message, status)
        })
    }

    /// 指定用户的打赏列表
    /// 指定用户的打赏统计信息

}

// MARK: - 其他用户相关

extension TSUserNetworkingManager {

    // 用户关注/取消关注的请求
    class func followOperate(_ followOperate: TSFollowOperate, userId: Int, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1. url
        var  request: Request<Empty>
        switch followOperate {
        case .follow:
            request = UserNetworkRequest.follow
        case .unfollow:
            request = UserNetworkRequest.unfollow
        }
        request.urlPath = request.fullPathWith(replacers: ["\(userId)"])
        // 2. request
        RequestNetworkData.share.text(request: request) { (result) in
            switch result {
            case .error(_):
                complete("network_problem".localized, false)
            case .failure(let failure):
                complete(failure.message, false)
            case .success(_):
                complete(nil, true)
            }
        }
    }

}


extension TSUserNetworkingManager {

    func getAutoLevelingDialogMessage(complete: @escaping ((_ msgModel: DisplayAutoUpgradeDialogModel?, _ msg: String?, _ status: Bool) -> Void)) -> Void {
        let path = TSURLPathV2.path.rawValue + TSURLPathV2.User.autoLevelingUpgradeDialogMessage.rawValue
        try! RequestNetworkData.share.textRequest(method: .get, path: path, parameter: nil, complete: { (data, status) in
            var message: String?
            if status {
                let msgModel = Mapper<DisplayAutoUpgradeDialogModel>().map(JSONObject: data)
                complete(msgModel, message, status)
            } else {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
                complete(nil, message, false)
            }
        })
    }
    
    func updateUserAutoLevelingUpgrade(complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) {
        // 3.发起请求
        let path = TSURLPathV2.path.rawValue + TSURLPathV2.User.updateAutoLevelingUpgradeFlag.rawValue
        try! RequestNetworkData.share.textRequest(method: .patch, path: path, parameter: nil, complete: { (data, status) in
            var message: String?
            if !status {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
            }
            complete(message, status)
        })
    }
    
//    func gamificationUserLeveling(complete: @escaping ((_ msgModel: GamificationResponseModel?, _ msg: String?, _ status: Bool) -> Void)) -> Void {
//        let path = TSURLPathV2.path.rawValue + TSURLPathV2.User.gamificationUserLevelingInfo.rawValue
//        try! RequestNetworkData.share.textRequest(method: .get, path: path, parameter: nil, complete: { (data, status) in
//            var message: String?
//            if status {
//                let msgModel = Mapper<GamificationResponseModel>().map(JSONObject: data)
//                complete(msgModel, message, status)
//            } else {
//                message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
//                complete(nil, message, false)
//            }
//        })
//    }
}
