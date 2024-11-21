//
//  RquestNetworkData.swift
//  Pods
//
//  Created by lip on 2017/5/16.
//
//  网络请求数据处理

import UIKit
import ObjectMapper
import Alamofire

extension Notification.Name {
    public struct Network {
        /// 当服务器检测到登录授权不合法时会发送该通知
        public static let Illicit = NSNotification.Name(rawValue: "com..notification.name.network.Illicit")
        /// 当服务器停机维护时会发送该通知
        public static let HostDown = NSNotification.Name(rawValue: "com..notification.name.network.HostDown")
    }
}

/// 网络请求错误
///
/// - uninitialized: 未正常初始化
public enum RquestNetworkDataError: Error {
    case uninitialized
}

public enum NetworkError: String {
    /// 网络请求错误（非超时以外的一切错误都会抛出该值，具体错误信息会输出到控制台）
    case networkErrorFailing = "com.zhiyicx.www.network.erro.failing"
    /// 网络请求超时
    case networkTimedOut = "com.zhiyicx.www.network.time.out"
    /// 取消了请求
    case requestCanceled = "com.zhiyicx.www.network.request.canceled"
}

/// 网络请求协议
public protocol NetworkRequest {
    /// 网络请求路径
    ///
    /// - Warning: 该路径指的只最终发送给服务的路径,不包含根地址
    var urlPath: String! { set get }
    /// 网络请求方式
    var method: HTTPMethod { set get }
    /// 网络请求参数
    var parameter: [String: Any]? { set get }
    /// 网络请求参数
    var parameterBody: Any? { set get }
    /// 相关的响应数据模型
    ///
    /// - Note: 该模型需要实现相对应的解析协议
    associatedtype ResponseModel: Mappable
}

/// 空类型
///
/// - Note: 设置 NetworkRequest.ResponseModel 为该类型表示不需要解析 ResponseModel
public struct Empty: Mappable {
    public init?(map: Map) {
    }
    public func mapping(map: Map) {
    }
}

/// 完整响应数据
public struct NetworkFullResponse<T: NetworkRequest> {
    /// 响应编号
    public let statusCode: Int
    /// 响应数据,由请求体配置的参数决定
    public var model: T.ResponseModel?
    /// 响应一组数据,由请求体配置参数决定
    public var models: [T.ResponseModel]
    /// 服务器响应数据
    public var message: String?
    /// 源数据
    public var sourceData: Any?
}

/// 网络请求结果
///
/// - success: 响应成功,返回数据
/// - failure: 响应序列化错误,返回失败原因
/// - error: 请求错误
public enum NetworkResult<T: NetworkRequest> {
    case success(NetworkFullResponse<T>)
    case failure(NetworkFullResponse<T>)
    case error(NetworkError)
}

/// 服务器响应数据
///
/// 服务器可能会响应 Dictionary<String, Any>; Array<Any>; 以及 空数组
/// 服务器指定使用空数组表示无数据的情况
/// - Warning: 当出现数据解析或者超时等错误时, 返回 nil
public typealias NetworkResponse = Any

public class RequestNetworkData: NSObject {
    var rootURL: String { return TSAppConfig.share.rootServerAddress }
    private let textRequestTimeoutInterval = 45
    private let serverResponseInfoKey = "message"
    var authorization: String?
    public override init() {}

    public static let share = RequestNetworkData()
    public var isShowLog = true

    lazy var alamofireManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = TimeInterval(self.textRequestTimeoutInterval)
        return Alamofire.SessionManager(configuration: configuration)
    }()
    
    public func configAuthorization(_ authorization: String?) {
        self.authorization = authorization
    }

    public func text<T: NetworkRequest>(request: T, shouldProcessParameter:Bool = true, isOtherURL: Bool = false, complete: @escaping (_ result: NetworkResult<T>) -> Void) {
        var dataResponse: DataResponse<Any>!
        let decodeGroup = DispatchGroup()

        var urlRequest:DataRequest = { [weak self] in
            guard let self = self else { return alamofireManager.request(request.urlPath, method: request.method) }
            if shouldProcessParameter {
                let (coustomHeaders, requestPath, encoding) = processParameters(self.authorization, request, otherURL: isOtherURL)
                return alamofireManager.request(requestPath, method: request.method, parameters: request.parameter, encoding: encoding, headers: coustomHeaders)
            } else {
                return alamofireManager.request(request.urlPath, method: request.method)
            }
        }()
        
        decodeGroup.enter()
        urlRequest.responseJSON { response in
            guard response.response != nil else {
                let error = NetworkError.networkErrorFailing
                let result = NetworkResult<T>.error(error)
                complete(result)
                return
            }
            
//            if self.isShowLog {
//                LogManager.Log(response.statusCode, loggingType: .apiResponseData)
//                LogManager.Log(response.data, loggingType: .apiResponseData)
//            }

            dataResponse = response
            decodeGroup.leave()
        }

        decodeGroup.notify(queue: DispatchQueue.main) {
            let result = dataResponse.result
            let statusCode = dataResponse.response!.statusCode

            if self.isShowLog {
                LogManager.Log("Request: \(request.urlPath)", loggingType: .apiRequestData)
                LogManager.Log("Param: \(String(describing: request.parameter))", loggingType: .apiRequestData)
                LogManager.Log("Status Code: \(String(describing: statusCode))", loggingType: .apiResponseData)
                LogManager.Log("Response: \(String(describing: result.value))", loggingType: .apiResponseData)
                
                XCGLoggerManager.shared.logRequestInfo("Request: \(request.urlPath)")
                XCGLoggerManager.shared.logRequestInfo("Param: \(String(describing: request.parameter))")
                XCGLoggerManager.shared.logRequestInfo("Status Code: \(String(describing: statusCode))")
                XCGLoggerManager.shared.logRequestInfo("Response: \(String(describing: result.value))")
            }
            
            if let error: NSError = result.error as NSError?, error.domain == NSURLErrorDomain && error.code == NSURLErrorTimedOut {
                let error = NetworkError.networkTimedOut
                let result = NetworkResult<T>.error(error)
                complete(result)
                return
            } else if let error = result.error as NSError?, error.domain == NSURLErrorDomain && error.code != NSURLErrorTimedOut {
                let error = NetworkError.networkErrorFailing
                let result = NetworkResult<T>.error(error)
                complete(result)
                return
            }
            
            if self.isShowLog {
                LogManager.Log("Request: \(request.urlPath)", loggingType: .apiRequestData)
                LogManager.Log("Param: \(String(describing: request.parameter))", loggingType: .apiRequestData)
                LogManager.Log("Status Code: \(String(describing: statusCode))", loggingType: .apiResponseData)
                LogManager.Log("Response: \(String(describing: result.value))", loggingType: .apiResponseData)
                
                XCGLoggerManager.shared.logRequestInfo("Request: \(request.urlPath)")
                XCGLoggerManager.shared.logRequestInfo("Param: \(String(describing: request.parameter))")
                XCGLoggerManager.shared.logRequestInfo("Status Code: \(String(describing: statusCode))")
                XCGLoggerManager.shared.logRequestInfo("Response: \(String(describing: result.value))")
            }
            
            // 状态码正常且需要转换数据
            if statusCode >= 200 && statusCode < 300 && T.ResponseModel.self != Empty.self {
                if let datas = result.value as? [Any], let models = Mapper<T.ResponseModel>().mapArray(JSONObject: datas) {
                    let fullResponse = NetworkFullResponse<T>(statusCode: statusCode, model: nil, models: models, message: nil, sourceData: result.value)
                    let result = NetworkResult.success(fullResponse)
                    complete(result)
                    return
                }

                if let data = result.value as? [String: Any], let model = Mapper<T.ResponseModel>().map(JSON: data) {
                    let fullResponse = NetworkFullResponse<T>(statusCode: statusCode, model: model, models: [], message: nil, sourceData: result.value)
                    let result = NetworkResult<T>.success(fullResponse)
                    complete(result)
                    return
                }
                let fullResponse = NetworkFullResponse<T>(statusCode: statusCode, model: nil, models: [], message: nil, sourceData: result.value)
                let result = NetworkResult<T>.success(fullResponse)
                complete(result)
                return
            }
            // 状态码正常但是不需要转换数据
            if statusCode >= 200 && statusCode < 300 && T.ResponseModel.self == Empty.self {
                let message = self.processSuccessMessage(result: result)
                let fullResponse = NetworkFullResponse<T>(statusCode: statusCode, model: nil, models: [], message: message, sourceData: result.value)
                let result = NetworkResult<T>.success(fullResponse)
                complete(result)
                return
            }
            // 特殊的状态码
            if statusCode == 401 {
                if TSCurrentUserInfo.share.isLogin == false {
                    TSRootViewController.share.guestJoinLandingVC()
                }
                
                if TSCurrentUserInfo.share.userInfo != nil {
                    NotificationCenter.default.post(name: NSNotification.Name.Network.Illicit, object: nil)
                }
            }
            if statusCode == 503 {
                NotificationCenter.default.post(name: NSNotification.Name.Network.HostDown, object: nil)
            }
            // 错误信息的处理
            let message: String? = self.processErrorMessage(result: result)
            let fullResponse = NetworkFullResponse<T>(statusCode: statusCode, model: nil, models: [], message: message, sourceData: result.value)
            let resultResponse = NetworkResult<T>.failure(fullResponse)
            complete(resultResponse)
        }
    }

    private func processParameters<T: NetworkRequest>(_ authorization: String?, _ request: T, otherURL: Bool = false) -> (HTTPHeaders, String, ParameterEncoding) {
        var eboosterURL: String =  TSAppConfig.share.localInfo.eostreApi ?? ""
        var requestPath = otherURL ? eboosterURL + request.urlPath : rootURL + request.urlPath
        let customHeaders = self.customHeaders(authorization)

        var encoding: ParameterEncoding!
        request.method == .get ? (encoding = URLEncoding.default) : (encoding = JSONEncoding.default)
        self.isShowLog = true
        if self.isShowLog == true {
            LogManager.Log("Request: \(requestPath)", loggingType: .apiRequestData)
            LogManager.Log("Authorization: \(customHeaders["Authorization"] ?? "nil")", loggingType: .apiRequestData)
            LogManager.Log("RequestMethod: \(request.method.rawValue)", loggingType: .apiRequestData)
            LogManager.Log("Parameters: \(request.parameter)", loggingType: .apiRequestData)
            
            DispatchQueue.main.async {
                XCGLoggerManager.shared.logRequestInfo("Request: \(requestPath)")
                XCGLoggerManager.shared.logRequestInfo("Authorization: \(customHeaders["Authorization"] ?? "nil")")
                XCGLoggerManager.shared.logRequestInfo("RequestMethod: \(request.method.rawValue)")
                XCGLoggerManager.shared.logRequestInfo("Parameters: \(request.parameter)")
            }
            
        }
        
        return (customHeaders, requestPath, encoding)
    }

    /// 和服务器间的文本请求
    ///
    /// - Parameters:
    ///   - method: 请求方式
    ///   - path: 请求路径,拼接在根路径后
    ///   - parameter: 请求参数
    ///   - complete: 请求结果
    ///
    /// - Note:complete 返回值详细说明
    /// - responseStatus 正确: 该值为 true 时，表示服务正常想数据，NetworkResponse 按照接口约定返回不同的数据
    /// - responseStatus 错误
    ///   - 该值为 false 时: 第一种情况是请求错误(超时,数据格式错误等),该情况下 NetworkResponse 返回 NetworkError.networkErrorFailing 等值, 此时 NetworkResponse 类型为 enum
    ///   - 该值为 false 时: 第二种情况是服务器响应,但内容错误,例如服务器返回 statusCode 404 ,表示无法查询到对应数据
    ///   - 错误信息拆包: 当 responseStatus 错误时,服务器响应错误中含有服务器约定好的值‘message’时,会将对应的错误信息中的首个信息字符串通过 NetworkResponse 返回,此时 NetworkResponse 类型为 String
    /// - 所有详细的错误信息都会打印在控制台
    /// - Throws: 错误状态,如果未成功配置根地址会抛错
    @discardableResult
    public func textRequest(method: HTTPMethod, path: String?, parameter: Dictionary<String, Any>?, encoding: ParameterEncoding? = nil, complete: @escaping (_ responseData: NetworkResponse?, _ responseStatus: Bool) -> Void) throws -> DataRequest {

        let (coustomHeaders, requestPath) = try processParameters(self.authorization, path)

        var encoding = encoding
        if encoding == nil {
            if method == .post {
                encoding = JSONEncoding.default
            } else {
                encoding = URLEncoding.default
            }
        }

        return alamofireManager.request(requestPath, method: method, parameters: parameter, encoding: encoding!, headers: coustomHeaders).responseJSON { [unowned self] response in
            
            if let error: NSError = response.result.error as NSError? {
                if error.domain == NSURLErrorDomain && error.code == NSURLErrorTimedOut {
                    complete(NetworkError.networkTimedOut, false)
                } else if error.code == NSURLErrorCancelled {
                    complete(NetworkError.requestCanceled, false)
                } else {
                    complete(NetworkError.networkErrorFailing, false)
                }
                
                LogManager.Log(error, loggingType: .networkError)
                
                return
            }
            
            var responseStatus: Bool = false
            guard let serverResponse = response.response else {
                assert(false, "服务器响应的数据无法解析")
                return
            }
            
            if isShowLog {
                LogManager.Log("Request: \(requestPath)", loggingType: .apiRequestData)
                LogManager.Log("Header: \(coustomHeaders)", loggingType: .apiRequestData)
                LogManager.Log("Param: \(String(describing: parameter))", loggingType: .apiRequestData)
                LogManager.Log("Status Code: \(String(describing: serverResponse.statusCode))", loggingType: .apiResponseData)
                LogManager.Log("Response: \(String(describing: response.result.value))", loggingType: .apiResponseData)
                
                XCGLoggerManager.shared.logRequestInfo("Request: \(requestPath)")
                XCGLoggerManager.shared.logRequestInfo("Header: \(coustomHeaders)")
                XCGLoggerManager.shared.logRequestInfo("Param: \(String(describing: parameter))")
                XCGLoggerManager.shared.logRequestInfo("Status Code: \(String(describing: serverResponse.statusCode))")
                XCGLoggerManager.shared.logRequestInfo("Response: \(String(describing: response.result.value))")
            }
            
            switch serverResponse.statusCode {
            case 200..<300:
                responseStatus = true
                complete(response.result.value, responseStatus)
                return
                
            case 401:
                NotificationCenter.default.post(name: NSNotification.Name.Network.Illicit, object: nil)
                complete("network_problem".localized, false)
                return
                
            case 422:
                responseStatus = true
                complete(response.result.value, responseStatus)
                return
                
            case 503:
                NotificationCenter.default.post(name: NSNotification.Name.Network.HostDown, object: nil)
                complete("network_problem".localized, false)
                return
                
            default: break
            }
            
            guard let responseInfoDic = response.result.value as? Dictionary<String, Array<String>> else {
                complete(response.result.value, responseStatus)
                return
            }
            
            if responseInfoDic.keys.contains(self.serverResponseInfoKey) {
                complete(responseInfoDic[self.serverResponseInfoKey]![0], responseStatus)
                return
            }
            
            complete(response.result.value, responseStatus)
        }
    }
    
    public func textRequest(method: HTTPMethod, path: String?, parameter: Dictionary<String, Any>?, complete: @escaping (_ responseData: NetworkResponse?, _ responseStatus: Bool, _ statusCode: Int?) -> Void) throws -> DataRequest {
        
        let (coustomHeaders, requestPath) = try processParameters(self.authorization, path)
        
        var encoding: ParameterEncoding!
        if method == .post {
            encoding = JSONEncoding.default
        } else {
            encoding = URLEncoding.default
        }
        
        return alamofireManager.request(requestPath, method: method, parameters: parameter, encoding: encoding, headers: coustomHeaders).responseJSON { [unowned self] response in
            if let error: NSError = response.result.error as NSError? {
                LogManager.Log("http respond error \(error)", loggingType: .apiResponseData)
                if error.domain == NSURLErrorDomain && error.code == NSURLErrorTimedOut {
                    complete(NetworkError.networkTimedOut, false, response.response?.statusCode)
                } else {
                    complete(NetworkError.networkErrorFailing, false, response.response?.statusCode)
                }
                
                LogManager.Log(error, loggingType: .networkError)

                return
            }
            
            var responseStatus: Bool = false
            
            guard let serverResponse = response.response else {
                assert(false, "服务器响应的数据无法解析")
                LogManager.Log("服务器响应的数据无法解析", loggingType: .networkError)
                return
            }
            
            if self.isShowLog {
                LogManager.Log("Request: \(requestPath)", loggingType: .apiRequestData)
                LogManager.Log("Param: \(parameter)", loggingType: .apiRequestData)
                LogManager.Log("Status Code: \(serverResponse.statusCode)", loggingType: .apiResponseData)
                LogManager.Log("Response: \(response.result.value)", loggingType: .apiResponseData)
                
                XCGLoggerManager.shared.logRequestInfo("Request: \(requestPath)")
                XCGLoggerManager.shared.logRequestInfo("Param: \(parameter)")
                XCGLoggerManager.shared.logRequestInfo("Status Code: \(serverResponse.statusCode)")
                XCGLoggerManager.shared.logRequestInfo("Response: \(response.result.value)")
            }
            
            if serverResponse.statusCode >= 200 && serverResponse.statusCode < 300 {
                responseStatus = true
                complete(response.result.value, responseStatus, serverResponse.statusCode)
                return
            }
            if serverResponse.statusCode == 422 {
                responseStatus = true
                complete(response.result.value, responseStatus, serverResponse.statusCode)
                return
            }
            if serverResponse.statusCode == 401 {
                if TSCurrentUserInfo.share.isLogin == false {
                    TSRootViewController.share.guestJoinLandingVC()
                }
                NotificationCenter.default.post(name: NSNotification.Name.Network.Illicit, object: nil)
                complete("network_problem".localized, false, serverResponse.statusCode)
                return
            }
            if serverResponse.statusCode == 503 {
                NotificationCenter.default.post(name: NSNotification.Name.Network.HostDown, object: nil)
                complete("network_problem".localized, false, serverResponse.statusCode)
                return
            }
            guard let responseInfoDic = response.result.value as? Dictionary<String, Array<String>> else {
                complete(response.result.value, responseStatus, serverResponse.statusCode)
                return
            }
            if responseInfoDic.keys.contains(self.serverResponseInfoKey) {
                complete(responseInfoDic[self.serverResponseInfoKey]![0], responseStatus, serverResponse.statusCode)
                return
            }
            complete(response.result.value, responseStatus, serverResponse.statusCode)
        }
    }
    private func processParameters(_ authorization: String?, _ path: String?) throws -> (HTTPHeaders?, String) {
        let coustomHeader: HTTPHeaders = self.customHeaders(authorization)
        
        var requestPath: String = ""
        if let path = path {
            requestPath = rootURL + path
        } else {
            requestPath = rootURL
        }
        
        self.isShowLog = true
        if self.isShowLog == true {
            LogManager.Log("Request: \(requestPath)", loggingType: .apiRequestData)
            LogManager.Log("Authorization: \(coustomHeader["Authorization"] ?? "nil")", loggingType: .apiRequestData)
            
            DispatchQueue.main.async {
                XCGLoggerManager.shared.logRequestInfo("Request: \(requestPath)")
                XCGLoggerManager.shared.logRequestInfo("Authorization: \(coustomHeader["Authorization"] ?? "nil")")
            }
        }
        
        LogManager.Log("Headers: \(coustomHeader)", loggingType: .apiRequestData)
        
        return (coustomHeader, requestPath)
    }
    
    fileprivate func processSuccessMessage(result: Result<Any>) -> String? {
        var message: String? = nil
        
        // json -> ["message": ["value1", "value2"...]]
        if let responseInfoDic = result.value as? Dictionary<String, Array<String>>, let messages = responseInfoDic[self.serverResponseInfoKey] {
            message = messages.first
            return message
        }
        // josn -> ["message": "value"]
        if let responseInfoDic = result.value as? Dictionary<String, String>, let message = responseInfoDic[self.serverResponseInfoKey] {
            return message
        }
        // json -> ["message": ["key1": "value1", "key2": "value2"...]]
        if let responseInfoDic = result.value as? Dictionary<String, Dictionary<String, String>>, let messageDic = responseInfoDic[self.serverResponseInfoKey] {
            message = messageDic.first?.value
            return message
        }
        // json -> ["message": ["key1": value1, "key2": "value2"...]]
        // { "message": { "code": 422, "msg": "Invalid uids, no valid user"} }
        if let responseInfoDic = result.value as? Dictionary<String, Dictionary<String, Any>>, let messageDic = responseInfoDic[self.serverResponseInfoKey] {
            for (_, value) in messageDic.enumerated() {
                if let value = value as? String {
                    message = value
                    break
                }
            }
            return message
        }
        
        return message
    }
    
    fileprivate func processErrorMessage(result: Result<Any>) -> String? {
        var message: String? = nil
        
        // json -> ["message": ["value1", "value2"...]]
        if let responseInfoDic = result.value as? Dictionary<String, Array<String>>, let messages = responseInfoDic[self.serverResponseInfoKey] {
            message = messages.first
            return message
        }
        // josn -> ["message": "value"]
        if let responseInfoDic = result.value as? Dictionary<String, String>, let message = responseInfoDic[self.serverResponseInfoKey] {
            return message
        }
        // json -> ["message": ["key1": "value1", "key2": "value2"...]]
        if let responseInfoDic = result.value as? Dictionary<String, Dictionary<String, String>>, let messageDic = responseInfoDic[self.serverResponseInfoKey] {
            message = messageDic.first?.value
            return message
        }
        // json -> ["message": ["key1": value1, "key2": "value2"...]]
        // { "message": { "code": 422, "msg": "Invalid uids, no valid user"} }
        if let responseInfoDic = result.value as? Dictionary<String, Dictionary<String, Any>>, let messageDic = responseInfoDic[self.serverResponseInfoKey] {
            for (_, value) in messageDic.enumerated() {
                if let value = value as? String {
                    message = value
                    break
                }
            }
            return message
        }
        // json -> { "message": "value", "errors": { "key1": ["value1"], "key2": ["value1", "value2"]}
        // 该种类型下, errors 的第一个key 对应的 value1 显示给用户, value 信息用于开发人员开发中调试
        if let responseInfoDic = result.value as? Dictionary<String, Any> {
            if let errorDic = responseInfoDic["errors"] as? Dictionary<String, Array<String>>, let message = errorDic.first?.value.first {
                // json -> ["message":"value", "errors":["key1":"value1", "key2":"value2"]]
                return message
            } else if let responseInfo = responseInfoDic as? Dictionary<String, Array<String>>, let message = responseInfo.first?.value.first {
                // json -> ["key":["value"], "key2":["value1", "value2"]]
                return message
            } else if let message = responseInfoDic[self.serverResponseInfoKey] as? String {
                // json -> ["message": "value", other...]
                return message
            }
        }
        
        return message
    }

    private func customHeaders(_ authorization: String?) -> HTTPHeaders {
        
        var headers = YPCustomHeaders
        if let authorization = authorization {
            let token = "Bearer " + authorization
            headers.updateValue(token, forKey: "Authorization")
        }
        headers.updateValue("rewards_link", forKey: "X-Client-App-Name")
        headers.updateValue(LocalizationManager.getISOLanguageCode(), forKey: "Accept-Language")
        headers.updateValue(LocalizationManager.getISOLanguageCode(), forKey: "X-Device-Language")
        headers.updateValue(LocationManager.shared.getCountryCode(), forKey: "X-Device-Country")
        return headers
    }
}
