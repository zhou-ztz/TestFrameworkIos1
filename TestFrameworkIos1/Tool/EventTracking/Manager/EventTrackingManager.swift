//
//  EventTrackingManager.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2024/1/30.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import UIKit
import SVProgressHUD

/// 行为类型
public enum BehaviorType: String {
    //曝光
    case expose    = "expose"
    //点击
    case click     = "click"
    //搜索
    case search     = "search"
    //点赞
    case like      = "like"
    //取消点赞
    case unlike    = "unlike"
    //评论
    case comment   = "comment"
    //收藏
    case collect   = "collect"
    //取消收藏
    case uncollect = "uncollect"
    //停留时长
    case stay      = "stay"
    //分享
    case share     = "share"
    //打赏
    case tip       = "tip"
    //负反馈
    case dislike   = "dislike"
    //信息-动态分享至好友
    case im_msg    = "im_message"
    //转发
    case forward   = "forward"
    //小程序 log
    case miniAppLog   = "mini_app_log"
    //行为类型
    case event   = "event"
    //Scash支付成功
    case scashSuccess   = "scash_payment_success"
    //Scash支付等待中
    case scashPending   = "scash_payment_pending"
    //Scash支付失败
    case scashFailed   = "scash_payment_failed"
    //Scash支付退款
    case scashRefund   = "scash_payment_refund"
    //Scash支付未知
    case scashUnknown   = "scash_payment_unknown"
}

/// 上报数据类型
public enum ItemType: String {
    //========动态========
    //图片动态
    case image         = "image"
    //图片动态
    case shortvideo    = "shortvideo"
    //图片动态
    case item          = "item"
    
    //========首页========
    //顶部moudle app 模块
    case homeModuleApp          = "home_module_app"
    //底部发现更多
    case homeFindMore           = "home_find_more"
    //首页Banner
    case homeBanner             = "home_banner"
    
    //========搜索========
    //搜索商家
    case searchMerchant         = "merchant"
    //搜索动态
    case searchFeed             = "feed"
    //搜索用户
    case searchUser             = "user"
    //小程序log
    case miniLog                = "mini_log"
    
    //========代金劵========
    //代金劵主页
    case voucherDashboard    = "voucher_dashboard"

    //代金劵里列表
    case voucherCategory    = "voucher_category_list"

    //代金劵里搜索模块
    case voucherSearch    = "voucher_search"
    //代金劵里详细
    case voucherDetail    = "voucher_detail"
    //获取代金劵里
    case getVoucher    = "get_voucher"
    //兌換券
    case voucherRedeem    = "voucher_redeem"
    
    //========商家地图========
    //商家地图 彈出視窗
    case mapviewMerchantPopup    = "mapview_merchant_popup"
    //商家地图 搜索
    case mapviewMerchantSearch    = "mapview_merchant_search"
    
    //========SCash========
    //SCash
    case scash    = "scash_payment"
    //水电费账单
    case utilitiesBillProvider = "utilities_bill_provider"
    case utilitiesBillProviderSelected = "utilities_bill_provider_selected"
    case utilitiesBillProviderCategorySelected = "utilities_bill_provider_category_selected"
    // 手机充值
    case mobileTopUpProvider = "mobile_top_up_provider"
    case mobileTopUpProviderSelected = "mobile_top_up_provider_selected"
    case mobileTopUpProviderPackagesSelected = "mobile_top_up_provider_packages_selected"
}

/// 模块ID
public enum ModuleId: String {
    //首页模块
    case home    = "home"
    //搜索模块
    case search  = "search"
    //动态模块
    case feed    = "feed"
    //小程序
    case miniApp    = "mini_app"
    //代金劵
    case voucher    = "voucher"
    //获取代金劵
    case voucherRedeem    = "voucher_redeem"
    //商家地图
    case merchantMapView    = "mapview_merchant"
    //SCash
    case scash    = "scash_payment"
    //水电费账单
    case utilitiesBill = "utilities_bill"
    // 手机充值
    case mobileTopUp = "mobile_top_up"
}

/// 页面ID
public enum PageId: String {
    //========动态========
    //首页模块
    case home                   = "home"
    //搜索模块
    case search                 = "search"
    //动态模块
    case feed                   = "feed"
    
    //========首页========
    //顶部moudle app 模块
    case homeModuleApp          = "home_module_app"
    //底部发现更多
    case homeFindMore           = "home_find_more"
    //首页Banner
    case homeBanner             = "home_banner"
    
    //========搜索========
    //搜索商家
    case searchMerchant         = "search_merchant"
    //搜索动态
    case searchFeed             = "search_feed"
    //搜索用户
    case searchUser             = "search_user"
    //小程序
    case miniApp                = "mini_app"
    
    //========代金劵========
    //代金劵主页
    case voucherDashboardCategory    = "voucher_dashboard_category"
    case voucherDashboardVoucher    = "voucher_dashboard_voucher"
    //代金劵里列表
    case voucherCategoryListCategory    = "voucher_category_list_category"
    case voucherCategoryListVoucher    = "voucher_category_list_voucher"
    //代金劵里搜索模块
    case voucherSearch    = "voucher_search"
    //代金劵里详细
    case voucherDetail    = "voucher_detail"
    //获取代金劵里
    case getVoucher    = "get_voucher"
    //兌換券
    case voucherRedeem    = "voucher_redeem"
    
    //========商家地图========
    //商家地图 彈出視窗
    case mapviewMerchantPopup    = "mapview_merchant_popup"
    //商家地图 搜索
    case mapviewMerchantSearch    = "mapview_merchant_search"
    
    //========SCash========
    //SCash
    case scash    = "scash_payment"
    //水电费账单
    case utilitiesBillProviderList = "utilities_bill_provider_list"
    case utilitiesBillProviderCategoryList = "utilities_bill_provider_category_list"
    // 手机充值
    case mobileTopUpProviderList = "mobile_top_up_provider_list"
    case mobileTopUpProviderDetail = "mobile_top_up_provider_detail"
}

class EventTrackingManager: NSObject {
    public static let instance = EventTrackingManager()
    
    private let maxEventCount = 50 //上报数据最高存储数，超过上传一次，并且清空已有数据
   
    private var eventCache: [EventEntity] = []
    
    private var isPostingEvents = false //标志位，指示是否正在上传事件数据
    
    func trackEvent(itemId: String = "0", itemType: String, behaviorType: BehaviorType, sceneId: String, moduleId: String, pageId: String, behaviorValue: String = "1", traceInfo: String = "1") {
        let event = EventEntity(itemId: itemId, itemType: itemType, bhvType: behaviorType.rawValue, traceInfo: traceInfo, sceneId: sceneId == "" ? "rewardslink" : sceneId, bhvValue: behaviorValue, moduleId: moduleId, pageId: pageId)
        
        // 用eventCache记录埋点数，可以避免频繁调用fetch()查询数据库
        eventCache.append(event)
        EventStoreManager().add(event)
        
//        print("====== 上报成功第\(eventCache.count)条数据： moduleId: \(event.moduleId) ItemID: \(event.itemId), ItemType: \(event.itemType) bhvType: \(event.bhvType) sceneId: \(event.sceneId)")
      
        guard !isPostingEvents else {
            return
        }
          
        //判断缓存埋点数据大于上报数
        if eventCache.count >= maxEventCount {
            // 调用上传方法
            self.postCachedEvents()
        }

    }
    
    /// 转移 AnalyticsManager track方法
    @objc public func track(event: Event) {
        
        self.trackEvent(itemId: "0", itemType: event.name(), behaviorType: BehaviorType.event, sceneId: "", moduleId: event.name(), pageId: "")
    }
    
    /// 转移 AnalyticsManager track方法
    @objc public func track(event: Event, with properties: [String: Any]) {
        self.trackEvent(itemId: "0", itemType: event.name(), behaviorType: BehaviorType.event, sceneId: "", moduleId: event.name(), pageId: "")
    }
    
    /// 提交缓存中的埋点数据
    private func postCachedEvents() {
        print("====== 达到数量上传埋点数据")
        // 设置标志位，表示正在上传事件数据
        isPostingEvents = true
        self.postEvent(list: eventCache) { [weak self] (message, code, status) in
            guard let self = self else { return }
            // 上传完成后，将标志位设置为false
            self.isPostingEvents = false
            
            if status == true {
                // 清空缓存列表
                print("====== 埋点提交成功")
//                SVProgressHUD.showSuccess(withStatus: "Successful translation of \(maxEventCount) event tracking submissions for testing purposes")
                self.eventCache.removeAll()
                EventStoreManager().clear()
            } else {
//                SVProgressHUD.showSuccess(withStatus: "Event tracking failed for testing purposes.")
            }
        }
    }
    /// 提交并清除所有的埋点数据
    func postEvents() {
        print("====== 提交并清除所有的埋点数据")
        let list = EventStoreManager().fetch()
        guard list.count > 0 else { return }
        self.postEvent(list: list) { [weak self] (message, code, status) in
            guard let self = self else { return }
            if status == true {
                // 清空缓存列表
                print("====== 埋点提交成功")
                self.eventCache.removeAll()
                EventStoreManager().clear()
            }
        }
    }

    /// 用户行为上报
    private func postEvent(list: [EventEntity], completion: @escaping (String, Int, Bool?) -> Void) {
        
        // 1. url
        var request = BasicEventNetworkRequest().postEventData
        request.urlPath = request.fullPathWith(replacers: [])
        // 2. params
        do {
            let jsonData = try JSONEncoder().encode(list)
            request.parameterBody = jsonData
        } catch {
            print("Error encoding JSON: \(error)")
        }
     
        // 3. request 这里和后端约定直接将数组数据以Body方式传值
        EventRequestNetworkData.share.textWithBody(request: request) { (result) in
            switch result {
            case .error(_):
                completion("network_problem".localized, 0, false)
            case .failure(let error):
                completion(error.message ?? "network_problem".localized, error.statusCode, false)
            case .success(let response):
                completion("", 0, true)
            }
        }
    }
    
}
