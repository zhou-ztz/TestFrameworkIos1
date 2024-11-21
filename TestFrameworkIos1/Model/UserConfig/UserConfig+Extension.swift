//
//  TSRootViewController+UserSession.swift
//  Yippi
//
//  Created by ChuenWai on 08/05/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import Kronos
import SwiftDate



extension UserConfig {
    
    func updateLocalDataWithEndTime(endTime: TimeInterval) {
        guard activeSessions.count > 0 else { return }
        activeSessions[activeSessions.count - 1].end_time = Int(endTime)
    }

    func updateLocalDataWithStartTime(startTime: TimeInterval) {
        let newData = TSDuration(start_time: Int(startTime), end_time: 0)
        activeSessions.append(newData)
    }
    
    func saveUserStartTime(lastEndTime: TimeInterval = Date.getCurrentTime().timeIntervalSince1970) {
        let now = lastEndTime
        guard let lastDuration = activeSessions.last else {
            let newDuration = TSDuration(start_time: Int(now), end_time: 0)
            activeSessions.append(newDuration)
            return
        }
                
        if lastDuration.end_time <= 0 {
            activeSessions.popLast()
        }
        
        let newDuration: TSDuration = TSDuration(start_time: Int(now), end_time: 0)
        activeSessions.append(newDuration)
        save()
    }
    
    /// Call endpoint to update user session duration
    func updateUserDuration(duration: [TSDuration]) {
        guard TSCurrentUserInfo.share.isLogin == true else {
            return
        }
        let durationParams = convertParamToDictionary(duration: duration)
        
        func saveUserStartTime() {
            if let lastEndTime = activeSessions.last?.end_time {
                self.saveUserStartTime(lastEndTime: Double(lastEndTime))
            } else {
                self.saveUserStartTime()
            }
        }
        
        TSUserNetworkingManager().sendUserSessionDuration(duration: durationParams, complete: { [weak self] (treasure) in
            guard let self = self else { return }
            saveUserStartTime()
             
//            self.activeSessions.removeAll()
//
//            if TSCurrentUserInfo.share.unreadCount.dailyTreasure < 1 {
//                TSCurrentUserInfo.share.unreadCount.dailyTreasure = treasure ?? 0
//                NotificationCenter.default.post(name: NSNotification.Name("userDailyTreasure"), object: nil)
//                UnreadCountNetworkManager().updateTabbarFeedBadge(show: TSCurrentUserInfo.share.unreadCount.dailyTreasure > 0)
//            }
            
        }) { (error) in
            saveUserStartTime()
            LogManager.LogError(name: "Post User Session Error", reason: error?.errorMessage)
            return
        }
    }

    
    func checkUserSessionDuration() {
        var totalDuration = 0.0
        let now = Date.getCurrentTime()
        
        self.updateLocalDataWithEndTime(endTime: now.timeIntervalSince1970)

        /// Get from bootstrapper to detect whether the user active time can pass to server to prevent spamming the api
        let userInterval = TSAppConfig.share.localInfo.userSessionInterval * 60
        
        guard activeSessions.count < 10 else {
            updateUserDuration(duration: activeSessions)
            return
        }

        var duration: TimeInterval = 0.0
        /// To get all the time record in db as if the duration limit doesn't reach to call endpoint will store in db
        for (_, time) in activeSessions.enumerated() {
            let start = TimeInterval(time.start_time)
            let end = TimeInterval(time.end_time)
            duration = abs(start-end)
            totalDuration += duration
        }

        /// To check if all record in db + current duration is hit the endpoint calling requirement
        if totalDuration > Double(userInterval) {
            self.updateUserDuration(duration: activeSessions)
        } else {
            self.updateLocalDataWithStartTime(startTime: now.timeIntervalSince1970)
        }
    }

    func convertParamToDictionary(duration: [TSDuration]) -> [[String : Any]] {
        var durationParams: [[String : Any]] = []
        for (_, object) in duration.enumerated() {
            do {
                let dic = try object.asDictionary()
                durationParams.append(dic)
            } catch {
                LogManager.Log("Convert duration to userSessionFail", loggingType: .exception)
            }
        }

        return durationParams
    }

}
