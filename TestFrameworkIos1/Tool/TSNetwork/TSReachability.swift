//
//  TSReachability.swift
//  Thinksns Plus
//
//  Created by lip on 2017/2/6.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  网络连接性检查器
//  该类基于 ReachabilitySwift 检查应用的网络状况,每当网络状况变化时发出通知,通知名称查看`TSNotifications.swift`
//  为了保证保证TS + 的统一性,也为了方便后期替换网络监测状况,故编写了该类
//  从应用启动开始,将开始监控整个网络状态

import UIKit
import Reachability
import Alamofire
import CoreTelephony

enum TSReachabilityStatus {
    case WIFI
    case Cellular
    case NotReachable
}

@objc class TSReachability: NSObject {
    let reachability = Reachability.forInternetConnection()
    var reachabilityStatus = TSReachabilityStatus.NotReachable
    static let share = TSReachability()
    private override init() {}

    func startNotifier() {
        guard let reachability = reachability else {
            return
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged), name: Notification.Name.reachabilityChanged, object: reachability)
        do {
            try reachability.startNotifier()
        } catch {
            assert(false, "could not start reachability notifier")
        }
    }
    
    func isReachable () -> Bool{
        if reachability?.currentReachabilityStatus() == .ReachableViaWWAN
            || reachability?.currentReachabilityStatus() == .ReachableViaWiFi {
            return true
        }else {
            return false
        }
    }

    @objc func reachabilityChanged(note: NSNotification) {
        let reachability = note.object as? Reachability

        if (reachability?.currentReachabilityStatus() == .ReachableViaWWAN
            || reachability?.currentReachabilityStatus() == .ReachableViaWiFi) {
            if (reachability!.currentReachabilityStatus() == .ReachableViaWiFi) {
                reachabilityStatus = .WIFI
            } else {
                reachabilityStatus = .Cellular
            }
        } else {
            reachabilityStatus = .NotReachable
        }
        //  [warning] 只有网络变动才会发送通知
        NotificationCenter.default.post(name: Notification.Name.Reachability.Changed, object: self)
    }
    
    @objc func getNetStatus() -> String {

        if ((reachability?.isReachableViaWiFi) != nil){
            return "WIFI"
        }else if ((reachability?.isReachableViaWWAN) != nil){
            return "4G"
        }
        return ""
    }
    
    @objc func getNetWorkType() -> String {
        let netManager = NetworkReachabilityManager()
        if let status = netManager?.networkReachabilityStatus {
            if (status == .reachable(.ethernetOrWiFi)) {
                return "WIFI"
                
            }
        }
        var currentRadioTech = ""
        let info = CTTelephonyNetworkInfo()
        if let current = info.currentRadioAccessTechnology {
            currentRadioTech = current
        }
        if #available(iOS 14.1, *) {
            switch currentRadioTech {
            case CTRadioAccessTechnologyGPRS,
                CTRadioAccessTechnologyEdge,
            CTRadioAccessTechnologyCDMA1x:
                return "2G"
            case CTRadioAccessTechnologyeHRPD,
                CTRadioAccessTechnologyWCDMA,
                CTRadioAccessTechnologyHSDPA,
                CTRadioAccessTechnologyCDMAEVDORev0,
                CTRadioAccessTechnologyCDMAEVDORevA,
                CTRadioAccessTechnologyCDMAEVDORevB,
            CTRadioAccessTechnologyHSUPA:
                return "3G"
            case CTRadioAccessTechnologyLTE:
                return "4G"
            case CTRadioAccessTechnologyNRNSA,
            CTRadioAccessTechnologyNR:
                return "5G"
            default:
                return "4G"
            }
        }else {
            return "4G"
        }
        return "WIFI"
    }

}
