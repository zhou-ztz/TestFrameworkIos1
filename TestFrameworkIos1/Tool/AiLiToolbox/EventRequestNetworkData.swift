//
//  EventRequestNetworkData.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2024/1/30.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import UIKit
import ObjectMapper
import Alamofire

public class EventRequestNetworkData: NSObject {
    var rootURL: String { return TSAppConfig.share.rootEventServerAddress }
    private let textRequestTimeoutInterval = 15
    private let serverResponseInfoKey = "data"
    var authorization: String?
    public override init() {}

    public static let share = EventRequestNetworkData()
    public var isShowLog = true

    lazy var alamofireManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = TimeInterval(self.textRequestTimeoutInterval)
        return Alamofire.SessionManager(configuration: configuration)
    }()
    
    public func configAuthorization(_ authorization: String?) {
        self.authorization = authorization
    }

    public func text<T: NetworkRequest>(request: T, shouldProcessParameter:Bool = true, complete: @escaping (_ result: NetworkResult<T>) -> Void) {
        var dataResponse: DataResponse<Any>!
        let decodeGroup = DispatchGroup()

        var urlRequest:DataRequest = { [weak self] in
            guard let self = self else { return alamofireManager.request(request.urlPath, method: request.method) }
            if shouldProcessParameter {
                let (coustomHeaders, requestPath, encoding) = processParameters(self.authorization, request)
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
            print(result)
            let statusCode = dataResponse.response!.statusCode

            if self.isShowLog {
                LogManager.Log(statusCode, loggingType: .apiResponseData)
                LogManager.Log(result.value, loggingType: .apiResponseData)
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
                }

                if let data = result.value as? [String: Any], let model = Mapper<T.ResponseModel>().map(JSON: data) {
                    let fullResponse = NetworkFullResponse<T>(statusCode: statusCode, model: model, models: [], message: nil, sourceData: result.value)
                    let result = NetworkResult<T>.success(fullResponse)
                    complete(result)
                }
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
    
    public func textWithBody<T: NetworkRequest>(request: T, complete: @escaping (_ result: NetworkResult<T>) -> Void){
        
        let (coustomHeaders, requestPath, _) = processParameters(self.authorization, request)
        
        guard let url =  URL(string: requestPath) else {return}
        var urlRequest = URLRequest(url:url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.allHTTPHeaderFields = coustomHeaders
        // the request is JSON
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        do {
            if let params = request.parameter {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
            }
            if let paramsList = request.parameterBody {
                urlRequest.httpBody = paramsList as? Data
            }
        } catch let error {
            LogManager.Log(error, loggingType: .exception)
        }
        let urlrequest: DataRequest = self.alamofireManager.request(urlRequest)
        urlrequest.responseJSON { response in
            guard response.response != nil else {
                let error = NetworkError.networkErrorFailing
                let result = NetworkResult<T>.error(error)
                complete(result)
                return
            }
            let result = response.result
            print(result)
            let statusCode = response.response?.statusCode ?? 500

            if self.isShowLog {
                LogManager.Log(statusCode, loggingType: .apiResponseData)
                LogManager.Log(result.value as Any, loggingType: .apiResponseData)
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
                LogManager.Log("Request: \(String(describing: request.urlPath))", loggingType: .apiRequestData)
                LogManager.Log("Param: \(String(describing: request.parameter))", loggingType: .apiRequestData)
                LogManager.Log("Status Code: \(String(describing: statusCode))", loggingType: .apiResponseData)
                LogManager.Log("Response: \( String(describing: result.value))", loggingType: .apiResponseData)
                
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
                }

                if let data = result.value as? [String: Any], let model = Mapper<T.ResponseModel>().map(JSON: data) {
                    let fullResponse = NetworkFullResponse<T>(statusCode: statusCode, model: model, models: [], message: nil, sourceData: result.value)
                    let result = NetworkResult<T>.success(fullResponse)
                    complete(result)
                }
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
    
    private func processParameters<T: NetworkRequest>(_ authorization: String?, _ request: T) -> (HTTPHeaders, String, ParameterEncoding) {
        var requestPath = rootURL + request.urlPath
        let customHeaders = self.customHeaders(authorization)

        var encoding: ParameterEncoding!
        request.method == .get ? (encoding = URLEncoding.default) : (encoding = JSONEncoding.default)
        self.isShowLog = true
        if self.isShowLog == true {
            LogManager.Log("RootURL: \(requestPath)", loggingType: .apiRequestData)
            LogManager.Log("Authorization: \(customHeaders["Authorization"] ?? "nil")", loggingType: .apiRequestData)
            LogManager.Log("RequestMethod: \(request.method.rawValue)", loggingType: .apiRequestData)
            LogManager.Log("Parameters: \(request.parameter)", loggingType: .apiRequestData)
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
            LogManager.Log("RootURL: \(requestPath)", loggingType: .apiRequestData)
            LogManager.Log("Authorization: \(coustomHeader["Authorization"] ?? "nil")", loggingType: .apiRequestData)
        }
        
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
        if let responseInfoDic = result.value as? Dictionary<String, Any>, let message = responseInfoDic[self.serverResponseInfoKey] {
            return message as? String ?? ""
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
        
        var headers: [String: String] = [:]
        if let authorization = authorization {
            let token = "Bearer " + authorization
            headers.updateValue(token, forKey: "App-Authorization")
        }
        
        return headers
    }
}
