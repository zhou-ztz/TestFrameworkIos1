//
//  IMCallRequest.swift
//  Yippi
//
//  Created by Wong Jin Lun on 15/03/2023.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import Foundation
import ObjectMapper

enum CallType: String {
    case voice = "voice"
    case video = "video"
}

enum CallGroupType: String {
    case group = "group"
    case individual = "individual"
}

enum CallActionType: String {
    case accept = "accept"
    case reject = "reject"
    case missed = "missed"
    case end = "end"
    case group_end = "group_end"
}

fileprivate class CallRequestTypes {
    
    let getCallList = TSNetworkRequestMethod(method: .get, path: "call-log", replace: nil)
    let retrieveCallDetail = TSNetworkRequestMethod(method: .post, path: "call-log/details", replace: nil)
    let startCallStore = TSNetworkRequestMethod(method: .post, path: "call-log/start", replace: nil)
    let callLogPatch = TSNetworkRequestMethod(method: .patch, path: "call-log", replace: nil)
  
}

public class CallRequest {
    
    func getCallList(onSuccess: @escaping (CallListResponseModel?) -> Void, onFailure: @escaping (String?) -> Void) {
        var request = CallRequestTypes().getCallList
        
        try! RequestNetworkData.share.textRequest(method: request.method, path: request.fullPath(), parameter: nil, complete: { (data, status) in
            var message: String?
            if status {
                let modelList = Mapper<CallListResponseModel>().map(JSONObject: data)
                onSuccess(modelList)
            } else {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
                onFailure(message)
            }
        })
        
    }
    
    func retrieveCallDetail(filterId: String, onSuccess: @escaping (CallDetailResponseModel?) -> Void, onFailure: @escaping (String?) -> Void) {
        var request = CallRequestTypes().retrieveCallDetail
        
        let params: [String: Any] = ["filter_id": filterId]
        
        try! RequestNetworkData.share.textRequest(method: request.method, path: request.fullPath(), parameter: params, complete: { (data, status) in
            var message: String?
            if status {
                let modelList = Mapper<CallDetailResponseModel>().map(JSONObject: data)
                onSuccess(modelList)
            } else {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
                onFailure(message)
            }
        })
    }
    
    /*
    "yunxin_id": "12312366", (yunxin call id)
    "from": "2000050", (user id)
    "to": "123123", (user id or group id)
    "call_type": "voice", (voice or video)
    "group_type": "group", (group or individual)
    "start_call": "2023-03-10 10:16:28" (time)
    */
    func startCallStore(yunxiId: String, from: String, to: String, callType: CallType, startCall: String, groupType: String, onSuccess: @escaping (StartCallResponseModel?) -> Void, onFailure: @escaping (String?) -> Void) {
        var request = CallRequestTypes().startCallStore
        
        let params: [String: Any] = ["yunxin_id": yunxiId, "from": from, "to": to, "call_type": callType.rawValue, "start_call": startCall, "group_type": groupType]
        
        try! RequestNetworkData.share.textRequest(method: request.method, path: request.fullPath(), parameter: params, complete: { (data, status) in
            var message: String?
            if status {
                let modelList = Mapper<StartCallResponseModel>().map(JSONObject: data)
                onSuccess(modelList)
            } else {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
                onFailure(message)
            }
        })
    }
    
    /*
    "yunxin_id" : "12312366", (yunxin call id)
    "action" : "end", (accept/reject/missed/end/group_end)
    "action_time" : "2023-03-10 10:58:48", (time)
    "group_type": "group" (group or individual)
    */
    func callLogPatch(yunxiId: String, action: CallActionType, actionTime: String, groupType: CallGroupType, onSuccess: @escaping () -> Void, onFailure: @escaping (String?) -> Void) {
        var request = CallRequestTypes().callLogPatch
        
        let params: [String: Any] = ["yunxin_id": yunxiId, "action": action.rawValue,   "action_time": actionTime, "group_type": groupType.rawValue]
        
        try! RequestNetworkData.share.textRequest(method: request.method, path: request.fullPath(), parameter: params, complete: { (data, status) in
            var message: String?
            if status {
                onSuccess()
            } else {
                message = TSCommonNetworkManager.getNetworkErrorMessage(with: data)
                onFailure(message)
            }
        })
    }
    
}


