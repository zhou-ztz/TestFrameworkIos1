//
//  TSGlobalNetManager.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/9/8.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

import Combine

public var livePushConfig: LiveConnectionConfig? =  nil
public var livePullConfig: LiveConnectionConfig? = nil

public struct LiveConnectionConfig {
    var activeIp: String?
    var options: [String]?
    var host: String
}

struct HTTPDNSModel : Codable {
    
    let host : String?
    let ips : [String]?
    let ipsv6 : [String]?
    let originTtl : Int?
    let ttl : Int?
    
    
    enum CodingKeys: String, CodingKey {
        case host = "host"
        case ips = "ips"
        case ipsv6 = "ipsv6"
        case originTtl = "origin_ttl"
        case ttl = "ttl"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        host = try values.decodeIfPresent(String.self, forKey: .host)
        ips = try values.decodeIfPresent([String].self, forKey: .ips)
        ipsv6 = try values.decodeIfPresent([String].self, forKey: .ipsv6)
        originTtl = try values.decodeIfPresent(Int.self, forKey: .originTtl)
        ttl = try values.decodeIfPresent(Int.self, forKey: .ttl)
    }
}

private var cancellables = Set<AnyCancellable>()

class TSGlobalNetManager: NSObject {
    static var resolvePullDNSTrottler: Throttler = Throttler.init(time: .seconds(0), queue: .global(), mode: .deferred, immediateFire: true) {
        guard TSAppConfig.share.launchInfo?.httpdnsPullConfig == true else { return}
        TSGlobalNetManager.resolveDNS(targetDomain: TSAppConfig.share.environment.pullLiveHost, isPush: false)
    }
    
    static var resolvePushDNSTrottler: Throttler = Throttler.init(time: .seconds(0), queue: .global(), mode: .deferred, immediateFire: true) {
//        guard TSAppConfig.share.launchInfo?.httpdnsPushConfig == true else { return }
        
        TSGlobalNetManager.resolveDNS(
            targetDomain: TSAppConfig.share.environment.pushLiveHost,
            isPush: true,
            onSuccess: { ips in
                
                let group = DispatchGroup()
                var bestIp: (averagePing: Double, ip: String) = (Double.greatestFiniteMagnitude, "")
                
                for ip in ips {
                    group.enter()
                    TSGlobalNetManager.ping(host: ip)
                        .sink(receiveCompletion: { _ in
                            group.leave()
                            cancellables.removeFirst()
                        }, receiveValue: { averagePing in
                            defer { group.leave() }
                            guard let averagePing = averagePing else { return }
                            if bestIp.averagePing > averagePing {
                                bestIp = (averagePing: averagePing, ip: ip)
                            }
                        }).store(in: &cancellables)
                }
                
                group.wait(timeout: .now() + 3)
                group.notify(queue: .global()) {
                    livePushConfig = LiveConnectionConfig(activeIp: bestIp.ip, options: ips, host: TSAppConfig.share.environment.pushLiveHost)
                }
        })
    }
    
    static func ping(host: String) -> Future<TimeInterval?, Error> {
        
        return Future() { promise in
            
            guard host.isEmpty == false else {
                promise(.success(nil))
                return
            }
            
//            PlainPing.ping(host) { (latency, error) in
//                guard let latency = latency, error != nil else {
//                    promise(.failure(YPErrorType.noData))
//                    return
//                }
//                
//                promise(.success(latency))
//            }
        }
        
    }
    
    class func resolveDNS(targetDomain: String, isPush: Bool, onSuccess: (([String]) -> Void)? = nil) {
        var urlComponents =  URLComponents(string: "http://203.107.1.33/120868/d")!
        let hostComponent = URLQueryItem(name: "host", value: targetDomain)
        urlComponents.queryItems = [hostComponent]
        
        let url = try! urlComponents.asURL()
        let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if let error = error {
                let objError = error as NSError
                switch objError.code {
                case NSURLErrorCancelled:
                    return
                    
                default: return
                }
            }
            
            guard let _data = data else { return }
            
            
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
                LogManager.Log("HttpReponse: \(httpResponse.statusCode)", loggingType: .apiResponseData)
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else { return }
            
            switch statusCode {
            case 200...299:
                let jsonDecoder = JSONDecoder()
                let result = try? jsonDecoder.decode(HTTPDNSModel.self, from: _data)
                if isPush {
                    livePushConfig = LiveConnectionConfig(activeIp: result?.ips?.first, options: result?.ips, host: (result?.host).orEmpty)
                } else {
                    livePullConfig = LiveConnectionConfig(activeIp: result?.ips?.first, options: result?.ips, host: (result?.host).orEmpty)
                }
                
                onSuccess?(result?.ips ?? [])
                
            default: break
            }
        }
        
        dataTask.resume()
    }
    
    /// 上传图片
    class func uploadImage(data: Data, fileName: String = "plus.jpeg", mimeType: String = "image/jpeg", channel: String = "public", progressHandler: ((_ progress:Progress)->())?, complete: @escaping ((_ node: String?, _ msg: String?, _ status: Bool) -> Void)) {
        TSGlobalNetManager().uploadRequest(data: data, fileName: fileName, mimeType: mimeType, channel: channel, progressHandler: { (progress) in
            progressHandler?(progress)
        }) { (node, msg, status) in
            complete(node, msg, status)
        }
    }
    /// 上传文件
    class func uploadFile(data: Data, fileName: String = "plus.jpeg", mimeType: String = "image/jpeg", channel: String = "public", complete: @escaping ((_ node: String?, _ msg: String?, _ status: Bool) -> Void)) {
        TSGlobalNetManager().uploadRequest(data: data, fileName: fileName, mimeType: mimeType, channel: channel, progressHandler: nil) { (node, msg, status) in
            complete(node, msg, status)
        }
    }
    /// 创建上传任务并完整data上传
    /// data: 上传的文件数据，先创建一个上传任务，然后根据上传任务进行上传
    /// complete: 完成的回调,
    fileprivate func uploadRequest(data: Data, fileName: String = "plus.jpeg", mimeType: String = "image/jpeg", channel: String = "public", progressHandler: ((_ progress:Progress)->())?, complete: @escaping ((_ node: String?, _ msg: String?, _ status: Bool) -> Void)) {
        let hash = TSUtil.md5(data)
        var request = Request<Empty>(method: .post, path: "storage", replacers: [])
        request.urlPath = request.fullPathWith(replacers: [])
        var params: [String:Any] = [:]
        params.updateValue(fileName, forKey: "filename")
        params.updateValue(hash, forKey: "hash")
        params.updateValue(data.count, forKey: "size")
        params.updateValue(mimeType, forKey: "mime_type")
        params.updateValue(["channel": channel], forKey: "storage")
        request.parameter = params
        RequestNetworkData.share.text(request: request) { (networkResult) in
            switch networkResult {
            case .error(_):
                complete(nil, "network_problem".localized, false)
            case .failure(let response):
                if response.statusCode == 404 {
                    complete(nil, "network_problem".localized, false)
                } else {
                    complete(nil, response.message, false)
                }
            case .success(let reponse):
                if let result = reponse.sourceData as? Dictionary<String, Any> {
                    if let uri = result["uri"] as? String, let method = result["method"] as? String, let headers = result["headers"] as? Dictionary<String, Any> {
                        var requestMethod: HTTPMethod = .put
                        if method == "PUT" {
                            requestMethod = .put
                        } else if method == "POST" {
                            requestMethod = .post
                        } else if method == "PATCH" {
                            requestMethod = .patch
                        } else {
                            complete(nil,  "upload_way_not_supported".localized, false)
                        }
                        //
                        //  "form": null, // 上传时候的表单，如果是 NULL 则表示整个 Body 是二进制文件流，如果是对象，则构造 `application/form-data` 表单对象
                        //  "file_key": null, // 如果存在 `form` 表单信息，文件流所使用的 key 名称
                        if let fileKey = result["file_key"] as? String, let form = result["form"] as? Dictionary<String, Any> {
                            complete(nil,  "upload_type_not_supported".localized, false)
                        } else {
                            /// header必须是[String,String]类型，但是服务器返回的字段中有Int的value，所以需要转换一下
                            var coustomHeaders: HTTPHeaders = [:]
                            for key in headers.keys {
                                if let Headervalue = headers[key] as? String {
                                    coustomHeaders.updateValue(Headervalue, forKey: key)
                                } else if let Headervalue = headers[key] as? Int {
                                    coustomHeaders.updateValue(String(Headervalue), forKey: key)
                                }
                            }
                            let uploadRequest = Alamofire.upload(data, to: uri, method: requestMethod, headers: coustomHeaders)
                            /// 上传进度
                            uploadRequest.uploadProgress(closure: { (progress) in
                                progressHandler?(progress)
                            })
                            uploadRequest.responseString(completionHandler: { (response) in
                                let responseResult = response.result
                                if responseResult.isSuccess {
                                    if let node = result["node"] as? String {
                                        complete(node,  "upload_success".localized, true)
                                    }else {
                                        complete(nil,  "return_node_empty".localized, false)
                                    }
                                } else {
                                    complete(nil, "network_problem".localized, false)
                                }
                            })
                        }
                    }
                }
            }
        }
    }
}
