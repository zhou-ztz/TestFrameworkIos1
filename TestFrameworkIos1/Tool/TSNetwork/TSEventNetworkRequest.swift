//
//  TSEventNetworkRequest.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2024/1/30.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

enum EventVersionType: String {
    case normal = "api/v2/"
}

struct EventRequest<T: Mappable>: NetworkRequest {
    
    /// 网络请求路径
    ///
    /// - Warning: 该路径指的只最终发送给服务的路径,不包含根地址
    var urlPath: String!
    /// 网络请求方式
    var method: HTTPMethod
    /// 网络请求参数
    var parameter: [String: Any]?
    var parameterBody: Any?
    /// 相关的响应数据模型
    ///
    /// - Note: 该模型需要实现相对应的解析协议
    typealias ResponseModel = T
    /// 版本路由
    let version: EventVersionType
    /// 待替换路由
    let path: String
    /// 待替换关键字
    let replacers: [String]
    
    /// 替换拼接完整的路径
    ///
    /// - Parameter replacers: 替换的关键字
    /// - Returns: 完整的路径
    func fullPathWith(replacers: [String]) -> String {
        if replacers.isEmpty || self.replacers.isEmpty {
            return version.rawValue + self.path
        }
        // [待办事项] 将路由用 / 进行拆分 然后比较替换
        var path = version.rawValue + self.path
        for (index, replacer) in self.replacers.enumerated() {
            path = path.replacingOccurrences(of: replacer, with: replacers[index])
        }
        return path
    }

    
    /// 初始化
    ///
    /// - Parameters:
    ///   - version: 接口版本信息
    ///   - method: 接口请求方式
    ///   - path: 接口路径
    ///   - replacers: 接口路径替换关键字
    /// - Warning: replacers 需要避免传入相同的关键字,会导致替换错误
    init(version: EventVersionType = .normal, method: HTTPMethod, path: String, replacers: [String]) {
        self.version = version
        self.method = method
        self.path = path
        self.replacers = replacers
    }
}


struct BasicEventNetworkRequest {

    //用户行为上报
    let postEventData = EventRequest<Empty>(method: .post, path: "behavior/batch", replacers: [""])
    
}
