//
//  ChatroomManager.swift
//  Yippi
//
//  Created by Francis on 19/05/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation

import ObjectMapper
import CryptoSwift
import Combine

class ChatroomNetworkManager {
    
    private func apiChecksum(nonce: String, timestamp: String) -> String {
        return ("12e481cc7ae6" + nonce + "\(timestamp)").data(using: .utf8)!.sha1().toHexString()
    }
    
    func translateTexts(message: String, onSuccess: ((String) -> Void)?, onFailure: ((String, Int) -> Void)?) {
        IMTranslateRequestType(text: message).execute(onSuccess: { (response) in
            onSuccess?((response?.text).orEmpty)
        }) { (error) in
            switch error {
            case let .carriesMessage(reason, code, errCode):
                onFailure?(reason, code)
            default: break
            }
        }
    }
    
    func createRoom(creator: String, chatroomName: String)  -> Future<YunXinChatRoomResponse<MeetCloseRoomResponse>?, Error>  {
        let queryitem1 = URLQueryItem(name: "creator", value: creator)
        let queryitem2 = URLQueryItem(name: "name", value: chatroomName)
        var components = URLComponents(string: "https://api.netease.im/nimserver/chatroom/create.action")
        components?.queryItems = [queryitem1, queryitem2]
        
        var urlRequest = URLRequest(url: components!.url!, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 10.0)
        
        let nonce = "\(Int.random(in: 0...9999999))"
        let timeStamp = Date().timeIntervalSince1970
        
        urlRequest.allHTTPHeaderFields = [
            "appKey": Constants.NIMKey,
            "cache-control": "no-cache",
            "checksum":  apiChecksum(nonce: nonce, timestamp: Int(timeStamp).stringValue),
            "contentType": "application/x-www-form-urlencoded",
            "curtime": Int(timeStamp).stringValue,
            "nonce": nonce
        ]
        
        return fetch(request: urlRequest, method: .post)
    }

    func closeRooom(roomId: String, operatorName: String)  -> Future<YunXinResponse<MeetCloseRoomResponse>?, Error>  {
        let queryitem1 = URLQueryItem(name: "roomid", value: roomId)
        let queryitem2 = URLQueryItem(name: "operator", value: operatorName)
        let queryitem3 = URLQueryItem(name: "valid", value: "false")
        var components = URLComponents(string: "https://api.netease.im/nimserver/chatroom/toggleCloseStat.action")
        components?.queryItems = [queryitem1, queryitem2, queryitem3]
        
        var urlRequest = URLRequest(url: components!.url!, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 10.0)
        
        let nonce = "\(Int.random(in: 0...9999999))"
        let timeStamp = Date().timeIntervalSince1970
        
        urlRequest.allHTTPHeaderFields = [
            "appKey": Constants.NIMKey,
            "cache-control": "no-cache",
            "checksum":  apiChecksum(nonce: nonce, timestamp: Int(timeStamp).stringValue),
            "contentType": "application/x-www-form-urlencoded",
            "curtime": Int(timeStamp).stringValue,
            "nonce": nonce
        ]
        
        return fetch(request: urlRequest, method: .post)
    }
    
    
    func fetchRoomIds(accId: String) -> Future<YunXinResponse<MeetQueryUserRoomIdsDescResponse>?, Error> {
        let queryitem = URLQueryItem(name: "creator", value: accId)
        var components = URLComponents(string: "https://api.netease.im/nimserver/chatroom/queryUserRoomIds.action")
        components?.queryItems = [queryitem]
        
        var urlRequest = URLRequest(url: components!.url!, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 10.0)
        
        let nonce = "\(Int.random(in: 0...9999999))"
        let timeStamp = Date().timeIntervalSince1970
        
        urlRequest.allHTTPHeaderFields = [
            "appKey": Constants.NIMKey,
            "cache-control": "no-cache",
            "checksum":  apiChecksum(nonce: nonce, timestamp: Int(timeStamp).stringValue),
            "contentType": "application/x-www-form-urlencoded",
            "curtime": Int(timeStamp).stringValue,
            "nonce": nonce
        ]
        
        return fetch(request: urlRequest, method: .post)
    }
    
    func fetchRoomOnlineNumber(roomArchiveId: String) -> Future<YunXinRoomNumberResponse?, Error>{
        let queryitem = URLQueryItem(name: "roomArchiveId", value: roomArchiveId)
        var components = URLComponents(string: "https://roomkit.netease.im/apps/v2/online-user-list")
        components?.queryItems = [queryitem]
        
        var urlRequest = URLRequest(url: components!.url!, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 10.0)
        
        let nonce = "\(Int.random(in: 0...9999999))"
        let timeStamp = Date().timeIntervalSince1970
        
        urlRequest.allHTTPHeaderFields = [
            "appKey": Constants.NIMKey,
            "cache-control": "no-cache",
            "checksum":  apiChecksum(nonce: nonce, timestamp: Int(timeStamp).stringValue),
            "contentType": "application/x-www-form-urlencoded",
            "curtime": Int(timeStamp).stringValue,
            "nonce": nonce
        ]
        
        return fetch(request: urlRequest, method: .get)
    }
    
    
    func fetch<T: Mappable>(request: URLRequest, method: YPHTTPMethod) -> Future<T?, Error> {
        var request = request
        let sessionConfig = URLSessionConfiguration.default
        
        return Future() { promise in
            
            request.httpMethod = method.rawValue
            _ = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                guard let _data = data else {
                    promise(.failure(YPErrorType.noData))
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
                
                let object = Mapper<T>().map(JSONString: (String(data: _data, encoding: .utf8)).orEmpty)
                promise(.success(object))
            }).resume()
        }
        
    }
    
}


