//
//  NetworkDispatcher.swift
//  YippiCore
//
//  Created by Francis Yeap on 5/28/19.
//  Copyright © 2019 Chew. All rights reserved.
//
import Foundation
import UIKit

public extension JSONDecoder.DateDecodingStrategy {
    static let iso8601withFractionalSeconds = custom {
        let container = try $0.singleValueContainer()
        let string = try container.decode(String.self)
        guard let date = Formatter.iso8601.date(from: string) else {
            throw DecodingError.dataCorruptedError(in: container,
                  debugDescription: "Invalid date: " + string)
        }
        return date
    }
}

public extension JSONEncoder.DateEncodingStrategy {
    static let iso8601withFractionalSeconds = custom {
        var container = $1.singleValueContainer()
        try container.encode(Formatter.iso8601.string(from: $0))
    }
}


public extension Formatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        return formatter
    }()
}


public enum YPHTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

@objcMembers
public class YPRequestData {
    private var baseAddress: String
    private let relativePath: String
    public let method: YPHTTPMethod
    public let params: [String: Any?]?
    
    public var fullPath: String {
        return baseAddress + relativePath
    }

    public init(
        baseUrl: String,
        path: String,
        method: YPHTTPMethod = .get,
        params: [String: Any?]? = nil
    ) {
        baseAddress = baseUrl
        
        if baseAddress.hasSuffix("/"){
            self.relativePath = path.hasPrefix("/") ? String(path.dropFirst()) : path
        }else{
            self.relativePath = path.hasPrefix("/") ? path : "/\(path)"
        }
        self.method = method
        self.params = params
    }
    
    public convenience init(path: String, method: YPHTTPMethod = .get, params: [String: Any?]? = nil){
        self.init(baseUrl: FeedIMSDKManager.shared.param.apiBaseURL, path: path, method: method, params: params)
    }
    
    public init(apiPaymentBaseURL:String, path: String, method: YPHTTPMethod = .get, params: [String: Any?]? = nil){
        baseAddress = apiPaymentBaseURL
        
        if baseAddress.hasSuffix("/"){
            self.relativePath = path.hasPrefix("/") ? String(path.dropFirst()) : path
        }else{
            self.relativePath = path.hasPrefix("/") ? path : "/\(path)"
        }
        self.method = method
        self.params = params
    }
}

public protocol RequestType {
    associatedtype T: YPRequestData
    associatedtype ResponseType: Decodable
    var data: T { get }
//    var encodingType: URLE
}

// Create for improvisations later
//public func cast<T>(_ value: Any?) -> T {
//    if let nilExpressibleObj = T.self as? ExpressibleByNilLiteral.Type {
//        if let value = value {
//            return value as! T
//        } else {
//            return nilExpressibleObj.init(nilLiteral: ()) as! T
//        }
//    } else {
//        return value as! T
//    }
//}

public extension RequestType {
    @discardableResult
    func execute (
        dispatcher: NetworkDispatcherProtocol = URLSessionNetworkDispatcher.instance,
        onSuccess: @escaping (ResponseType?) -> Void,
        onError: @escaping (YPErrorType) -> Void
        ) -> URLSessionDataTask? {
        
        let data = self.data
        let fullpath = data.fullPath
        
        return dispatcher.dispatch(
            request: data,
            onSuccess: { (responseData: Data, statusCode: Int?) in
                
                LogManager.Log("Request: \(fullpath)", loggingType: .apiRequestData)
                LogManager.Log("Params: \(self.data.params)", loggingType: .apiRequestData)
                LogManager.Log("Status Code: \(String(describing: statusCode ?? -999))", loggingType: .apiResponseData)
                LogManager.Log("Response: \(String(describing: responseData.prettyPrintedJSONString ?? ""))", loggingType: .apiResponseData)
                
                XCGLoggerManager.shared.logRequestInfo("Request: \(fullpath)")
                XCGLoggerManager.shared.logRequestInfo("Params: \(self.data.params)")
                XCGLoggerManager.shared.logRequestInfo("Status Code: \(String(describing: statusCode ?? -999))")
                XCGLoggerManager.shared.logRequestInfo("Response: \(String(describing: responseData.prettyPrintedJSONString ?? ""))")
                
                do {
                    guard let statusCode = statusCode else { return onError(YPErrorType.noCode) }
                    
                    let jsonDecoder = JSONDecoder()
                    jsonDecoder.dateDecodingStrategy = .iso8601withFractionalSeconds
                    
                    switch statusCode {
                    case 204:
                        let result = try? jsonDecoder.decode(ResponseType.self, from: responseData) // expect nil
                        DispatchQueue.main.async {
                            onSuccess(result)
                        }
                        
                    case 200...299:
                        let result = try jsonDecoder.decode(ResponseType.self, from: responseData)
                        DispatchQueue.main.async {
                            onSuccess(result)
                        }
                        
                    case 401:
                        DispatchQueue.main.async {
                            onError(YPErrorType.unauthorized)
                        }
                        
                    case 503:
                        DispatchQueue.main.async {
                            onError(YPErrorType.serverUnavailable)
                        }
                        
                    default:
                        guard let dictionary = try? JSONSerialization.jsonObject(with: responseData, options: JSONSerialization.ReadingOptions.allowFragments) as? Dictionary<String, Any?> else {
                            LogManager.Log("Unable to serialize nor decode", loggingType: .exception)
                            DispatchQueue.main.async {
                                onError(YPErrorType.carriesMessage("Unable to serialize nor decode", code: statusCode, errCode: statusCode))
                            }
                            return
                        }
                        
                        /// https://slimkit.github.io/docs/api-v2-overview.html
                        /// 第一种, 第四种
                        if let message = dictionary["message"] as? String {
                            if let errors = (dictionary["errors"] as? [String: Any]) {
                                if let amountErrors = errors["amount"] as? [String] {
                                    if let firstError = amountErrors.first {
                                        DispatchQueue.main.async {
                                            onError(YPErrorType.violations(firstError, violations: errors))
                                        }
                                    }
                                } else {
                                    DispatchQueue.main.async {
                                        onError(YPErrorType.violations(message, violations: errors))
                                    }
                                }
                            } else if let code =  dictionary["code"] as? Int, let errorCode = ErrorCode(rawValue: code) {
                                DispatchQueue.main.async {
                                    onError(YPErrorType.error(message, code: errorCode))
                                }
                            } else {
                                DispatchQueue.main.async {
                                    onError(YPErrorType.carriesMessage(message, code: statusCode, errCode: nil))
                                }
                            }
                        }
                            /// 第二种
                        else if let messages: Array<String> = (dictionary["message"] as? Array<String>) {
                            if let message = messages.first {
                                    DispatchQueue.main.async {
                                        let errCode = dictionary["code"] as? Int
                                        onError(YPErrorType.carriesMessage(message, code: statusCode, errCode: errCode))
                                    }
                                
                            } else {
                                DispatchQueue.main.async {
                                    onError(YPErrorType.unIdentified(dictionary, code: statusCode))
                                }
                            }
                        }
                            /// 第三种
                        else {
                            DispatchQueue.main.async {
                                onError(YPErrorType.unIdentified(dictionary, code: statusCode))
                            }
                        }
                    }
                    
                } catch let error {
                    
                    LogManager.Log(error, loggingType: .exception)
                    let response = String(data: responseData, encoding: .utf8)
                    let reason = fullpath.appending(";").appending(response.orEmpty)
                    LogManager.LogError(name: "Mapping Error", reason: reason)
                    DispatchQueue.main.async {
                        onError(YPErrorType.mappingError(response))
                    }
                }
        },
            onError: { (error: YPErrorType) in
                LogManager.Log(error, loggingType: .apiRequestData)
                DispatchQueue.main.async {
                    onError(error)
                }
        }
        )
    }
}

public protocol NetworkDispatcherProtocol {
    func dispatch(request: YPRequestData, onSuccess: @escaping (Data, Int?) -> Void, onError: @escaping (YPErrorType) -> Void) -> URLSessionDataTask?
}

public class URLSessionNetworkDispatcher: NetworkDispatcherProtocol {
    public static let instance = URLSessionNetworkDispatcher()
    private init() {}
    
    public func dispatch(request: YPRequestData, onSuccess: @escaping (Data, Int?) -> Void, onError: @escaping (YPErrorType) -> Void) -> URLSessionDataTask? {
        guard let url = URL(string: request.fullPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {
            onError(YPErrorType.invalidUrl)
            return nil
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.timeoutInterval = 15
        
        do {
            if let params = request.params {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
            }
        } catch let error {
            LogManager.Log(error, loggingType: .exception)
            onError(YPErrorType.mappingError(nil))
            return nil
        }
        
        urlRequest.allHTTPHeaderFields = YPHTTPHeaderFields.headers
        
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")  // the request is JSON
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")        // the expected response is also JSON
        urlRequest.setValue(LocalizationManager.getCurrentLanguage(), forHTTPHeaderField: "Accept-Language")
        
        if let token = UserDefaults.standard.string(forKey: "TSAccountTokenSaveKey"),
            let tokenType = UserDefaults.standard.string(forKey: "TSAccountTokenType") {
            urlRequest.setValue("\(tokenType) \(token)", forHTTPHeaderField: "Authorization")
        }
        
        LogManager.Log("Header: \(urlRequest.allHTTPHeaderFields)", loggingType: .apiRequestData)
        
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            
            if let error = error {
                let objError = error as NSError
                switch objError.code {
                case NSURLErrorCancelled:
                    return
                    
                default:
                    onError(YPErrorType.carriesMessage(error.localizedDescription, code: objError.code, errCode: nil
                    ))
                    return
                }
            }
            
            guard let _data = data else {
                onError(YPErrorType.noData)
                return
            }
            
            
            if let obj = try? JSONSerialization.jsonObject(with: _data, options: JSONSerialization.ReadingOptions.allowFragments) {
                if let array = obj as? Array<Dictionary<String, Any>> {
                    LogManager.Log("🌩🌩🌩\n\(array)\n🌩🌩🌩", loggingType: .apiResponseData)
                } else {
                    if let jsonData = try? JSONSerialization.data(withJSONObject: obj as! Dictionary<String, Any>, options: .prettyPrinted),
                        let json = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) {
                        LogManager.Log("🌩🌩🌩\n\(json)\n🌩🌩🌩", loggingType: .apiResponseData)
                    }
                }
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                LogManager.Log("Request: \(String(describing: urlRequest.url?.absoluteString))", loggingType: .apiResponseData)
                LogManager.Log("Status Code: \(String(describing: httpResponse.statusCode))", loggingType: .apiResponseData)
                
                XCGLoggerManager.shared.logRequestInfo("Request: \(String(describing: urlRequest.url?.absoluteString))")
                XCGLoggerManager.shared.logRequestInfo("Status Code: \(String(describing: httpResponse.statusCode))")
            }
            
            onSuccess(_data, (response as? HTTPURLResponse)?.statusCode)
            }
        
        dataTask.resume()
        
        return dataTask
    }
    
    
}

public class YPHTTPHeaderFields {
    public static var headers: [String: String] {
        return [Constants.Headers.Accept: "application/json",
                Constants.Headers.ClientType: UIDevice.current.systemName,
                Constants.Headers.ClientVersion: Device.appVersion(),
                Constants.Headers.DeviceID: Device.currentUDID,
                Constants.Headers.DeviceOS: UIDevice.current.systemVersion,
                Constants.Headers.DeviceModel: Device.modelName,
                Constants.Headers.IOSDevice: "ios",
                Constants.Headers.AcceptLanguage: LocalizationManager.getCurrentLanguage(),
                Constants.Headers.AppFavor: "ios",
                Constants.Headers.ClientAppName: "rewards_link",
                Constants.Headers.DeviceCountry: UserDefaults.standard.string(forKey: "selected-country-code") ?? "MY"]
    }
}

public enum YPErrorType: Error {
    case serverUnavailable
    case unauthorized
    case invalidUrl
    case noData
    case mappingError(_ response: String?)
    case carriesMessage(_ reason: String, code: Int, errCode: Int?)
    case violations(_ reason: String, violations:[String : Any])
    case unIdentified(_ dictionary: Dictionary<String, Any?>, code: Int)
    case noCode /// may not happen
    case error(_ message: String, code: ErrorCode)
}


public enum ErrorCode: Int {
    case offTransactionException = 1
    case settingNotFoundException = 2
    case userVerifyException = 3
    case invalidTransactionException = 4
    case invalidPasswordException = 5
    case invalidAmountException = 6
    case invalidPhoneException = 7
    case customValidationException = 8
    case transactionFreezeException = 9
    case dailyLimitException = 10
    case loginFailedAttemptsException = 11
    case restrictionException = 12
    case otpWaitException = 13
    case otpVerifyException = 14
    case invalidSecurityPinException = 15
    case securityPinNotSetException = 16
    case pinIsLockedException = 17
    case suspiciousActivity = 18
    
    ///
    case transactionIdMissingException = 201
    case insufficientBalanceException = 202
    case aeropayException = 203
    case partnerFailException = 204
    case purchaseFailException = 205
    case invalidCountryException = 207
    case orderClaimedException = 208
    case rewardFinishException = 209
    case tipsException = 210
    case redPacketClaimException = 211
    case eggExpiredException = 212
    case liveEggCountingDownException = 213
    case userNotEligibleException = 214
    case userRewardFinishException = 215
    
    case socialTokenRedeemRefunded = 217
    case socialTokenRedeemReachedLimit = 218
    case socialTokenRedeemUserNotKYC = 219
    case socialTokenRedeemSoldOut = 220
    
    case objectNotFoundException = 404
    
    case socialAccountException = 452
    
    case timeoutException = 1001
    case signExpiredException = 1002
    case transactionRefIdExistsException = 1003
    
    //会议不存在或已结束
    case meetingEndOrInexistence = 1012
    //会议人数已满
    case meetingNumberLimit = 1013
}
