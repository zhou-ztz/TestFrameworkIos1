//
//  TSAppConfig.swift
//  ThinkSNS +
//
//  Created by lip on 2017/4/10.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  应用配置信息

import UIKit
import ObjectMapper
import Reachability

private let klaunchKey = "com.zhiyicx.launch"

class TSAppConfig: NSObject {
    static let share = TSAppConfig()
    
    override init() {
        self.environment = AppEnvironmentModel()
        super.init()
        //self.environment.reload()
        self.localInfo = self.loadLocalInfo()
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged), name: Notification.Name.reachabilityChanged, object: nil)
    }
    
    /// 启动配置参数
    var launchInfo: TSAppSettingInfoModel?
    /// 本地配置参数
    var localInfo: TSAppSettingInfoModel = TSAppSettingInfoModel()
    /// 环境信息
    ///
    /// - Note: 历史原因,分享相关配置记录在 ShareConfig.plist 内,后续会写入该处 2017年10月17日11:26:35
    var environment: AppEnvironmentModel
    /// 当前网络环境
    var reachabilityStatus: TSReachabilityStatus = TSReachabilityStatus.NotReachable
    /// More modules
    var moduleFlags: ModuleFlags {
        return ModuleFlags.load(modules: localInfo.modules)
    }
    /// 服务器根地址
    var rootServerAddress: String {
        return self.environment.serverAddress
    }
    /// 埋点服务器根地址
    var rootEventServerAddress: String {
        return self.environment.eventServerAddress
    }
    // MARK: - 参数配置
    /// 更新本地配置参数
    ///
    /// - Note: 如果要单独更新单个参数,需要将旧本地的参数复制一份,然后修改单个参数,再整个更新即可,避免出现写入单个导致整个配置为空的情况
    func updateLocalInfo() {
        if let realLaunchInfo = launchInfo {
            // 转 dic 然后写入文件下次启动APP会从文件载入配置信息
            let dic = realLaunchInfo.toJSON()
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
            let documentsDirectory = paths[0] as! String
            let path = documentsDirectory.appending("/AppConfig.plist")
            
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: path) == false {
                if let bundlePath = Bundle.main.path(forResource: "AppConfig", ofType: "plist") {
                    do {
                        try fileManager.copyItem(atPath: bundlePath, toPath: path)
                    } catch let error as NSError {
                        debugPrint(error)
                    }
                }
            }
            
            do {
                if let _ = NSMutableDictionary(contentsOfFile: path) {
                    let muDic = NSMutableDictionary(dictionary: dic)
                    _ = muDic.write(to: URL(fileURLWithPath: path), atomically: false)
                }
            } catch let error as NSError {
                debugPrint(error)
            }
        }
        
        // 配置信息更
        self.localInfo = self.loadLocalInfo()
    }
    
    @objc func reachabilityChanged(note: NSNotification) {
        TSCurrentUserInfo.share.isAgreeUserCelluarWatchShortVideo = false
        guard let reachability = note.object as? Reachability else {
            return
        }
        if reachability.currentReachabilityStatus() == .ReachableViaWWAN || reachability.currentReachabilityStatus() == .ReachableViaWiFi {
            if (reachability.currentReachabilityStatus() == .ReachableViaWiFi) {
                reachabilityStatus = .WIFI
            } else {
                reachabilityStatus = .Cellular
            }
        } else {
            reachabilityStatus = .NotReachable
        }
    }
    
    /// 应用配置表
    ///
    /// - Returns: 配置信息
    /// - Note: 应用信息配置在`AppConfig.plist`文件内
    private func loadLocalInfo() -> TSAppSettingInfoModel {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let documentsDirectory = paths[0] as! String
        let path = documentsDirectory.appending("/AppConfig.plist")
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path) == false {
            if let bundlePath = Bundle.main.path(forResource: "AppConfig", ofType: "plist") {
                do {
                    try fileManager.copyItem(atPath: bundlePath, toPath: path)
                } catch let error as NSError {
                    assert(false, "\(error)")
                }
            } else {
                fatalError("默认环境配置文件格式错误,查看文档 ./Thinksns Plus Document/应用配置说明.md")
            }
        }
        
        if let dicData = NSDictionary(contentsOfFile: path) as? Dictionary<String, Any> {
            if let model = Mapper<TSAppSettingInfoModel>().map(JSON: dicData) {
                return model
            }
        }
        
        // 如果复制的文件被修改来导致转换错误,就使用 plist 文件生成默认配置
        if let bundlePath = Bundle.main.path(forResource: "AppConfig", ofType: "plist") {
            let dicData = NSDictionary(contentsOfFile: bundlePath) as! Dictionary<String, Any>
            return Mapper<TSAppSettingInfoModel>().map(JSON: dicData)!
        }
        fatalError("默认环境配置文件格式错误,查看文档 ./Thinksns Plus Document/应用配置说明.md")
    }
}
