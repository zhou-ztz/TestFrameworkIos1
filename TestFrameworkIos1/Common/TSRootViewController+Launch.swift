//
//  TSRootViewController+Launch.swift
//  ThinkSNS +
//
//  Created by lip on 2017/5/24.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  处理程序启动后需要执行的操作

import UIKit
import ObjectMapper

extension TSRootViewController {
    
    //    func saveLanguageList(_ languages: [LanguageObject]) {
    //        DatabaseManager().languageFilter.deleteAll()
    //        guard languages.count > 0 else {
    //            DatabaseManager().languageFilter.save(languages: [LanguageObject(code: "", name: "text_global".localized)])
    //            UserDefaults.standard.removeObject(forKey: "LanguageRefreshFlag")
    //            return
    //        }
    //
    //        var newLanguages: [LanguageObject] = languages
    //        // Manually add first and last item as backend no return
    //        newLanguages.insert(LanguageObject(code: "", name: "text_global".localized), at: 0)
    //        newLanguages.insert(LanguageObject(code: "OTHER", name: "text_others".localized), at: newLanguages.count)
    //        DatabaseManager().languageFilter.save(languages: newLanguages)
    //    }
    
    // Checking to inidicate calling api or not
    // Explanation: Logic same with show advertisement when launch app which only call api once in a day
    func isLanguageNeedRefresh() -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let date = dateFormatter.string(from: Date())
        
        guard let countryFlagObject = UserDefaults.standard.object(forKey: "LanguageRefreshFlag") as? [String:Any], let storedDate = countryFlagObject["datetime"] as? String, storedDate == date else {
            UserDefaults.standard.set(["datetime": date], forKey: "LanguageRefreshFlag")
            UserDefaults.standard.synchronize()
            return true
        }
        
        return false
    }
    
    // Checking to inidicate calling api or not
    // Explanation: Logic same with show advertisement when launch app which only call api once in a day
    
    
    /// 设置启动页广告图
    /// [待修改] 历史原因广告是单独处理的,后续需要都使用 TSAppconfig 来处理
    func showAdvert() {
//        let launchAdverts = DatabaseManager().advert.getObjects(type: .launch)
//        guard launchAdverts.isEmpty == false, self.isAdvertRepeated() == false else {
//            return
//        }
//        
//        // 2.显示启动页
//        var models = launchAdverts.map { TSAdverLaunchModel(object: $0) }
//        /// 倒序一下，后台配置的是依据等级往后排。
//        models = models.reversed()
//        // 3.设置第一个广告位不可跳过
//        var newModel = models[0]
//        newModel.canSkip = true
//        models[0] = newModel
//        // 4.显示广告
//        advert.setAdert(models: models)
//        view.addSubview(advert)
//        advert.starAnimation()
    }
    
    private func isAdvertRepeated() -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let date = dateFormatter.string(from: Date())
        
        guard let advertFlagObject = UserDefaults.standard.object(forKey: "AdvertRepeatFlag") as? [String:Any],
              let storedDate = advertFlagObject["datetime"] as? String,
              storedDate == date else {
            
            UserDefaults.standard.set(["datetime": date], forKey: "AdvertRepeatFlag")
            UserDefaults.standard.synchronize()
            return false
        }
        
        return true
    }
    
    /// 检测版本号信息(返回一个数组)
    func getVersionData() {
//        TSSystemNetworkManager.getVersionData { (data, result) in
//            guard result, let data = data else {
//                return
//            }
//            /// 更新本次启动获取版本信息标识
//            self.didUpdateAppVersionInfo = true
//            if data.isEmpty {
//                TSCurrentUserInfo.share.lastCheckAppVesin = nil
//                return
//            } else {
//                let newVersion = data[0]
//                TSCurrentUserInfo.share.lastCheckAppVesin = newVersion
//                self.checkAppVersion(lastCheckModel: newVersion)
//            }
//        }
    }
}
