//
//  TSReportNetworkManager.swift
//  ThinkSNS +
//
//  Created by 小唐 on 15/12/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  举报相关的请求
/**
 

 **/

import Foundation

import ObjectMapper

/// 圈子举报处理类型
enum TSGroupReportProcessOperate {
    /// 同意
    case accept
    /// 拒绝
    case reject
}

class TSReportNetworkManager {

}

// MARK: - 举报

extension TSReportNetworkManager {

    /// 获取举报的种类
    ///
    /// - Parameters:
    ///   - complete: 请求结果回调
    class func getReportTypes(complete: @escaping ((_ model: ReportIncidentTypeModel?, _ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1.请求 url
        var request = TSReportNetworkRequest.reportTypes
        request.urlPath = request.fullPathWith(replacers: [])
        // 2.发起请求
        try! RequestNetworkData.share.textRequest(method: .get, path:  request.urlPath , parameter: nil, complete: { (data, status) in
            var message: String?
            if status {
                let model = Mapper<ReportIncidentTypeModel>().map(JSONObject: data)
                complete(model, message, true)
            } else {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
                complete(nil, message, false)
            }
        })
    }
    
    /// 举报圈子    因举报界面中暂不兼容圈子举报，所以圈子举报接口单独添加
    ///
    /// - Parameters:
    ///   - groupId: 圈子id
    ///   - reason: 举报原因
    ///   - complete: 请求结果回调
    class func reportGroup(groupId: Int, reason: String, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1.请求 url
        var request = TSReportNetworkRequest.group
        request.urlPath = request.fullPathWith(replacers: ["\(groupId)"])
        // 2.配置参数
        let parameters: [String: Any] = ["reason": reason]
        request.parameter = parameters
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete("network_request_fail".localized, false)
            case .failure(let response):
                complete(response.message, false)
            case .success(let response):
                complete(response.message, true)
            }
        }
    }

    /// 举报
    ///
    /// - Parameters:
    ///   - type: 举报类型
    ///   - reportTargetId: 举报对象的id
    ///   - reason: 举报原因
    ///   - complete: 请求结果回调
    class func report(type: ReportTargetType, reportTargetId: Int, reportType: Int, reason: String, files: [Int], complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1.请求 url
        var request: Request<Empty>
        switch type {
        case .Comment(commentType: let commentType, sourceId: _, groupId: _):
            request = TSReportNetworkRequest.Comment.other
            if commentType == .post {
                request = TSReportNetworkRequest.Comment.post
            }
        case .Post:
            request = TSReportNetworkRequest.post
        case .Moment, .Live:
            request = TSReportNetworkRequest.moment
        case .User:
            request = TSReportNetworkRequest.user
        case .Group:
            request = TSReportNetworkRequest.group
        case .Topic:
            request = TSReportNetworkRequest.topic
        case .News:
            request = TSReportNetworkRequest.news
        }
        request.urlPath = request.fullPathWith(replacers: ["\(reportTargetId)"])
        // 2.配置参数
        var parameters: [String: Any] = [String: Any]()
        // 有的地方传的参数叫content，有的地方传的参数叫reason，topic：message，不用判断的解决方案
        parameters.updateValue(reason, forKey: "reason")
        parameters.updateValue(reason, forKey: "content")
        parameters.updateValue(reason, forKey: "message")
        // By Kit Foong (New added report type and images params)
        parameters.updateValue(reportType, forKey: "report_type")
        if files.isEmpty == false && files.count > 0 {
            parameters.updateValue(files, forKey: "images")
        }
        print(parameters)
        request.parameter = parameters
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete("network_problem".localized, false)
            case .failure(let response):
                complete(response.message, false)
            case .success(let response):
                complete(response.message, true)
            }
        }
    }
}

// MARK: - 评论举报
/// 暂时使用上面的举报，之后根据需要再来建立统一的评论处理
extension TSReportNetworkManager {

}

// MARK: - 圈子的举报管理

extension TSReportNetworkManager {

    /// 圈子举报处理
    ///
    /// - Parameters:
    ///   - reportId: 举报id
    ///   - processOperate: 对举报的处理：同意 | 拒绝
    ///   - complete: 请求结果回调
    class func groupReportProcess(reportId: Int, processOperate: TSGroupReportProcessOperate, complete: @escaping ((_ msg: String?, _ status: Bool) -> Void)) -> Void {
        // 1.请求 url
        var request: Request<Empty>
        switch processOperate {
        case .accept:
            request = TSReportNetworkRequest.Group.accept
        case .reject:
            request = TSReportNetworkRequest.Group.reject
        }
        request.urlPath = request.fullPathWith(replacers: ["\(reportId)"])
        // 2.配置参数
        // 3.发起请求
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete("network_request_fail".localized, false)
            case .failure(let response):
                complete(response.message, false)
            case .success(let response):
                complete(response.message, true)
            }
        }
    }

}
