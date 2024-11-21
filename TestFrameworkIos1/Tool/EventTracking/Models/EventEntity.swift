//
//  EventEntity.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2024/1/30.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import Foundation
import UIKit
import ObjectBox
import ObjectMapper

class EventEntity: Entity, Codable{

    var id: Id = 0
    var itemId: String = ""
    var itemType: String = ""
    var bhvType: String = ""
    var traceId: String = ""
    var traceInfo: String = ""
    var sceneId: String = ""
    var bhvTime: String = ""
    var bhvValue: String = ""
    var userId: String = ""
    var platform: String = ""
    var imei: String = ""
    var appVersion: String = ""
    var netType: String = ""
    var ip: String = ""
    var login: String = ""
    var reportSrc: String = ""
    var deviceModel: String = ""
    var longitude: String = ""
    var latitude: String = ""
    var moduleId: String = ""
    var pageId: String = ""
    var position: String = ""
    var messageId: String = ""
    var appName: String = ""
    var partitionDate: String = ""
    var fetchOrigin: String = ""
    
    required init() { }
    
    required init?(map: Map) { }
    
    /// 初始化方法，允许传入非可选参数，使用默认值的参数可以不传
    /// - Parameters:
    ///   - id: 实体ID，默认值为0
    ///   - itemId: 内容ID，默认值为"0"
    ///   - itemType: 内容类型
    ///   - bhvType: 行为类型
    ///   - traceInfo: 请求埋点信息，默认值为空字符串
    ///   - sceneId: 场景ID，默认值为"1"
    ///   - bhvTime: 行为发生的时间戳，默认为当前时间戳
    ///   - bhvValue: 行为详情，默认值为"1"
    ///   - userId: 用户ID，默认值为当前用户ID或空字符串
    ///   - login: 是否登录用户，默认值为"1"
    ///   - moduleId: 模块ID
    ///   - pageId: 页面ID
    ///   - appName: 对应app名称，默认值为"rewardsLink"
    ///   - partitionDate: 分区日期，默认为当前日期的经典时间格式
    init(
         itemId: String,
         itemType: String,
         bhvType: String,
         traceInfo: String,
         sceneId: String = "rewardsLink",
         bhvTime: String = Date().timeStamp,
         bhvValue: String = "1",
         userId: String = TSCurrentUserInfo.share.userInfo?.userIdentity.stringValue ?? "-1",
         login: String = "1",
         deviceModel: String = Device.modelName,
         moduleId: String,
         pageId: String,
         appName: String = "rewardsLink",
         partitionDate: String = Date().classicTimeFormat) {
        
        self.itemId = itemId
        self.itemType = itemType
        self.bhvType = bhvType
        self.traceId = "ios\(Date().milliStamp)"
        self.traceInfo = traceInfo
        self.sceneId = sceneId
        self.bhvTime = bhvTime
        self.bhvValue = bhvValue
        self.userId = userId
        self.platform = "ios"
        self.imei = Device.currentUDID
        self.appVersion = Device.appVersion()
        self.netType = TSReachability.share.getNetWorkType()
        self.ip = IPInfoManager.shared.retrieveStoredIPAddress() ?? ""
        self.login = login
        self.reportSrc = "2"
        self.deviceModel = deviceModel
        self.longitude = AppUtil().getCurrentLongitude()
        self.latitude = AppUtil().getCurrentLatitude()
        self.moduleId = moduleId
        self.pageId = pageId
        self.position = "\(AppUtil().getCurrentLongitude()),\(AppUtil().getCurrentLatitude())"
        self.messageId = Date().milliStamp
        self.appName = appName
        self.partitionDate = partitionDate
        self.fetchOrigin = moduleId
    }
    
    /// 便利初始化方法，用于常见的使用场景
    /// - Parameters:
    ///   - itemType: 内容类型
    ///   - bhvType: 行为类型
    ///   - moduleId: 模块ID
    ///   - pageId: 页面ID
    convenience init(itemType: String, bhvType: String, moduleId: String, pageId: String) {
        self.init(itemType: itemType, bhvType: bhvType, moduleId: moduleId, pageId: pageId)
    }
    
    enum CodingKeys: String, CodingKey {

        case id
        case itemId = "item_id"
        case itemType = "item_type"
        case bhvType = "bhv_type"
        case traceId = "trace_id"
        case traceInfo = "trace_info"
        case sceneId = "scene_id"
        case bhvTime = "bhv_time"
        case bhvValue = "bhv_value"
        case userId = "user_id"
        case platform
        case imei
        case appVersion = "app_version"
        case netType = "net_type"
        case ip
        case login
        case reportSrc = "report_src"
        case deviceModel = "device_model"
        case longitude
        case latitude
        case moduleId = "module_id"
        case pageId = "page_id"
        case position
        case messageId = "message_id"
        case appName = "app_name"
        case partitionDate = "partition_date"
        case fetchOrigin = "fetch_origin"
    }
    

}
