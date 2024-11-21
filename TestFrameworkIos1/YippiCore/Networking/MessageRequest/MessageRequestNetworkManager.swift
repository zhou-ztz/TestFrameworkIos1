//
//  MessageRequestNetworkManager.swift
//  Yippi
//
//  Created by Tinnolab on 03/09/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import UIKit
import ObjectMapper

class MessageRequestNetworkManager: NSObject {
    
    func getMessageReqCount() {
        var request = MessageRequestRequest().requestCount
        request.urlPath = request.fullPathWith(replacers: [])
        RequestNetworkData.share.text(request: request, complete: { (result) in
            
            switch result {
            case .error(_):
                let indicator = TSIndicatorWindowTop(state: .faild, title: "network_problem".localized)
                indicator.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            case .failure(let response):
                if response.statusCode == 429 { return }
                var errorMessage = "network_problem".localized
                if let message = response.message {
                    errorMessage = message
                }
                let indicator = TSIndicatorWindowTop(state: .faild, title: errorMessage)
                indicator.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            case .success(let response):
                if let model = response.model {
                    MessageRequestRealmManager().deleteRequestCount()
                    MessageRequestRealmManager().saveRequestCount(model)
                    NotificationCenter.default.post(name: Notification.Name("RefreshRequestCount"), object: nil)
                }
            }
        })
    }
    
    func getMessageReqList(after: Int? = nil, specialRequest: Bool = false, complete: @escaping((_ requestList:[MessageRequestModel]?, _ status:Bool) -> Void)) {
        var request = MessageRequestRequest().msgRequestList
        request.urlPath = request.fullPathWith(replacers: [])
        
        if let id = after {
            request.urlPath = request.urlPath + "&after=\(id)"
        }
        
        RequestNetworkData.share.text(request: request, complete: { (result) in
            
            switch result {
            case .error(_):
                let indicator = TSIndicatorWindowTop(state: .faild, title: "network_problem".localized)
                indicator.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                complete(nil, false)
            case .failure(let response):                
               // if response.statusCode == 429 { return }
                
                var errorMessage = "network_problem".localized
                if let message = response.message {
                    errorMessage = message
                }
                let indicator = TSIndicatorWindowTop(state: .faild, title: errorMessage)
                if specialRequest == false { indicator.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval) }
                complete(nil, false)
                
            case .success(let response):
                if after == nil {
                    MessageRequestRealmManager().deleteRequestList()
                }
                MessageRequestRealmManager().saveRequestList(response.models) {
                    complete(response.models, true)
                }
                
            }
        })
    }
    
    func markMessageRead(messageId:Int, complete: @escaping(() -> Void)) {
        let parameters: [String: Any] = ["id": messageId]
        
        var request = MessageRequestRequest().markRead
        request.urlPath = request.fullPathWith(replacers: [])
        request.parameter = parameters
        
        RequestNetworkData.share.text(request: request, complete: { (result) in
            switch result {
            case .error(_):
                let indicator = TSIndicatorWindowTop(state: .faild, title: "network_problem".localized)
                indicator.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            case .failure(let response):
                if response.statusCode == 429 { return }
                var errorMessage = "network_problem".localized
                if let message = response.message {
                    errorMessage = message
                }
                let indicator = TSIndicatorWindowTop(state: .faild, title: errorMessage)
                indicator.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            case .success(_):
                complete()
            }
        })
    }
    
    func deleteAllMessageRequest(complete: @escaping(() -> Void)) {
        guard let user = CurrentUserSessionInfo else { return }
        let parameters: [String: Any] = ["delete_type": "all", "request_id": user.requestKey]
        
        var request = MessageRequestRequest().deleteMessageRequest
        request.urlPath = request.fullPathWith(replacers: [])
        request.parameter = parameters
        
        RequestNetworkData.share.text(request: request, complete: { (result) in
            switch result {
            case .error(_):
                let indicator = TSIndicatorWindowTop(state: .faild, title: "network_problem".localized)
                indicator.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            case .failure(let response):
                if response.statusCode == 429 { return }
                var errorMessage = "network_problem".localized
                if let message = response.message {
                    errorMessage = message
                }
                let indicator = TSIndicatorWindowTop(state: .faild, title: errorMessage)
                indicator.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            case .success(_):
                self.getMessageReqCount()
                complete()
            }
        })
    }
    
    func deleteSingleMessageRequest(requestId:Int, complete: @escaping(() -> Void)) {
        let parameters: [String: Any] = ["delete_type": "single", "request_id": requestId]
        
        var request = MessageRequestRequest().deleteMessageRequest
        request.urlPath = request.fullPathWith(replacers: [])
        request.parameter = parameters
        
        RequestNetworkData.share.text(request: request, complete: { (result) in
            switch result {
            case .error(_):
                let indicator = TSIndicatorWindowTop(state: .faild, title: "network_problem".localized)
                indicator.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            case .failure(let response):
                if response.statusCode == 429 { return }
                var errorMessage = "network_problem".localized
                if let message = response.message {
                    errorMessage = message
                }
                let indicator = TSIndicatorWindowTop(state: .faild, title: errorMessage)
                indicator.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            case .success(_):
                self.getMessageReqCount()
                complete()
            }
        })
    }
    
    func getChatHistory(id:Int, limit:Int, before:Int? = nil, after:Int? = nil, complete: @escaping((_ requestList:[MessageDetailModel]?, _ status:Bool, _ message: String?) -> Void)) {
        var request = MessageRequestRequest().chatHistory
        request.urlPath = request.fullPathWith(replacers: ["\(id)", "\(limit)"])
        if let id = before {
            request.urlPath = request.urlPath + "&before=\(id)"
        }
        if let id = after {
            request.urlPath = request.urlPath + "&after=\(id)"
        }
        
        RequestNetworkData.share.text(request: request, complete: { (result) in
            
            switch result {
            case .error(_):
                let indicator = TSIndicatorWindowTop(state: .faild, title: "network_problem".localized)
                indicator.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                complete(nil, false, nil)
            case .failure(let response):
                if response.statusCode == 429 {
                    complete(nil, false, "")
                    return
                }
                var errorMessage = "network_problem".localized
                if let message = response.message {
                    errorMessage = message
                }
                complete(nil, false, errorMessage)
            case .success(let response):
                MessageRequestRealmManager().saveMessageHistory(response.models)
                complete(response.models, true, nil)
            }
        })
    }
    
    func sendMessage(id:Int, content:String, complete: @escaping((_ status: Bool, _ result: MessageDetailModel?, _ isBlock: Bool?) -> Void)) {
        
        let parameters: [String: Any] = ["to_user_id": id, "content": content]
        
        var request = MessageRequestRequest().sendMessage
        request.urlPath = request.fullPathWith(replacers: [])
        request.parameter = parameters
        
        RequestNetworkData.share.text(request: request, complete: { (result) in
            switch result {
            case .error(_):
                let indicator = TSIndicatorWindowTop(state: .faild, title: "network_problem".localized)
                indicator.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                complete(false, nil, nil)
            case .failure(let response):
                if response.statusCode == 429 {
                    complete(false, nil, nil)
                }else if response.statusCode == 422 {
                    complete(false, nil, true)
                } else {
                    var errorMessage = "network_problem".localized
                    if let message = response.message {
                        errorMessage = message
                    }
                    let indicator = TSIndicatorWindowTop(state: .faild, title: errorMessage)
                    indicator.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                    complete(false, nil, nil)
                }
            case .success(let result):
                if let model = result.model {
                    MessageRequestRealmManager().saveMessageHistory([model])
                    complete(true, model, nil)
                } else {
                    complete(false, nil, nil)
                }
            }
        })
    }
    
    func addFriend(id:Int, complete: @escaping(() -> Void)) {
        
        let parameters: [String: Any] = ["user_id": id]
        
        var request = MessageRequestRequest().followFriend
        request.urlPath = request.fullPathWith(replacers: [])
        request.parameter = parameters
        
        RequestNetworkData.share.text(request: request, complete: { (result) in
            switch result {
            case .error(_):
                let indicator = TSIndicatorWindowTop(state: .faild, title: "network_problem".localized)
                indicator.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            case .failure(let response):
                if response.statusCode == 429 { return }
                var errorMessage = "network_problem".localized
                if let message = response.message {
                    errorMessage = message
                }
                let indicator = TSIndicatorWindowTop(state: .faild, title: errorMessage)
                indicator.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
            case .success(_):
                self.getMessageReqCount()
                complete()
            }
        })
    }
    
    func blacklistFriend(id:Int, complete: @escaping((_ status: Bool) -> Void)) {
        
        var request = MessageRequestRequest().blacklistFriend
        request.urlPath = request.fullPathWith(replacers: ["\(id)"])
        
        RequestNetworkData.share.text(request: request, complete: { (result) in
            switch result {
            case .error(_):
                let indicator = TSIndicatorWindowTop(state: .faild, title: "network_problem".localized)
                indicator.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                complete(false)
            case .failure(let response):
                if response.statusCode == 429 {
                    complete(false)
                    return
                }
                var errorMessage = "network_problem".localized
                if let message = response.message {
                    errorMessage = message
                }
                let indicator = TSIndicatorWindowTop(state: .faild, title: errorMessage)
                indicator.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
                complete(false)
            case .success(_):
                complete(true)
            }
        })
    }
}
