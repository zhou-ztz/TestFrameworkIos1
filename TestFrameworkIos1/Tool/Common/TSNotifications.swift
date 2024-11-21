//
//  TSNotifications.swift
//  Thinksns Plus
//
//  Created by lip on 2017/2/13.
//  Copyright © 2017年 LeonFa. All rights reserved.
//
//  通知名称记录类

import Foundation

extension Notification.Name {
    /// 记录`Reachability`相关的通知
    public struct Reachability {
        /// 当检测到网络连通性变动时会发送该通知.
        public static let Changed = NSNotification.Name(rawValue: "com.ts-plus.notification.name.reachability.changed")
    }

    /// 头像按钮相关通知
    public struct AvatarButton {
        /// 当头像按钮被点击时,会发出该通知
        ///
        /// - Note:
        ///   - 思路: 头像点击的通知,默认让导航控制器接收,导航控制器显示时接收通知,不显示时,撤销通知接收,收到通知后,push 出对应的视图控制器.
        ///   - 注意事项: 不是导航控制包含的视图控制器的头像点击需要单独处理
        /// - userInfo: 用户 id 通过 ["uid": <Int>] 进行传递
        public static let DidClick = NSNotification.Name("com.ts-plus.notification.name.avatarButton.didClick")
        /// 当头像按钮被点击时,且是未知用户
        ///
        /// - Note:
        ///   - 思路: 该通知发送给根控制器,收到该通知后,显示弹窗
        /// - userInfo: None
        public static let UnknowDidClick = NSNotification.Name("com.ts-plus.notification.name.avatarButton.unknowDidClick")
    }

    /// 记录动态相关的通知
    public struct Moment {
        /// 用户在话题里面发布了新动态
        public static let TopicAddNew = NSNotification.Name(rawValue: "com.ts-plus.notification.name.moment.topicAddNew")
        /// 支付完成后刷新动态列表
        public static let paidReloadFeedList = NSNotification.Name("com.ts-plus.notification.name.moment.paidReloadFeedList")
        /// 动态详情页删除了某条动态需要发通知给所有列表更新数据源(匹配当前删除的动态的id)
        public static let momentDetailVCDelete = NSNotification.Name("com.ts-plus.notification.name.moment.delete")
        /// 刷新动态列表
        public static let reload = NSNotification.Name("com.yippi.notification.name.moment.reload")
        /// when a moment is liked/commented
        public static let update = NSNotification.Name("com.yippi.notification.name.moment.update")

        public static let block = NSNotification.Name("com.yippi.notification.name.moment.block")
        
        //动态商家主页小程序跳转
        public static let momentMerchantDidClick = NSNotification.Name("com.yippi.notification.name.moment.merchant.didClick")
        
        public static let recommendedChanged = NSNotification.Name("com.yippi.notification.name.moment.recommendedChanged")
    }

    /// 记录动态相关的通知
    public struct CommentChange {
        /// 用户发布了新的动态
        public static let change = NSNotification.Name(rawValue: "com.ts-plus.notification.name.comment.changed")
        /// 去编辑动态-传入model
        public static let editModel = NSNotification.Name(rawValue: "com.ts-plus.notification.name.comment.editModel")
    }
    
    /// 表情的通知
    public struct Reaction {
        /// 重新弹出表情列表
        public static let show = NSNotification.Name(rawValue: "com.ts-plus.notification.name.reaction.show")
    }

    /// 记录频道相关的通知
    public struct Channels {
        /// 用户频道的订阅状态发生改变
        public static let follow = NSNotification.Name(rawValue: "com.ts-plus.notification.name.channels.follow")
    }

    /// 推送相关通知
    public struct APNs {
        /// 收到了通知的推送
        public static let receiveNotice = NSNotification.Name(rawValue: "com.ts-plus.notification.name.apns.receive.notice")
        /// 查询到了未读数据
        public static let queryData = NSNotification.Name(rawValue: "com.ts-plus.notification.name.apns.queryData")
    }

    /// 导航控制器相关推送
    public struct NavigationController {
        /// 显示指示器A
        /// 显示内容格式 ["content": "显示内容"]
        public  static  let showIndicatorA = NSNotification.Name(rawValue: "com.ts-plus.novigationcontroller.showindicator")
        public  static  let showIMErrorIndicatorA = NSNotification.Name(rawValue: "com.ts-plus.novigationcontroller.showIMErrorIndicatorA")
    }

    /// 用户相关通知
    public struct User {
        /// 用户登录
        public static let login = NSNotification.Name("com.ts-plus.notification.name.user.toLogin")
        public static let UpdateBiometricSetting = Notification.Name("UpdateBiometricSetting")
        public static let LoginNotification = Notification.Name("Notification_UserLoggedIn")
    }

    /// 游客模式相关通知
    public struct Visitor {
        public static let login = NSNotification.Name("com.ts-plus.notification.name.visitor.toLogin")
    }

    /// 资讯相关通知
    public struct News {
        /// 点了资讯详情页面的喜欢按钮
        public static let pressNewsDetailLikeBtn = NSNotification.Name("com.ts-plus.notification.name.news.pressNewsDetailLikeBtn")
        /// 点了资讯详情页面的取消喜欢按钮
        public static let pressNewsDetailUnlikeBtn = NSNotification.Name("com.ts-plus.notification.name.news.pressNewsDetailUnlikeBtn")
    }

    /// 聊天相关通知
    public struct Chat {
        /// 点了聊天内的图片
        public static let tapChatDetailImage = NSNotification.Name("com.ts-plus.notification.name.chat.tapChatDetailImage")
        /// 环信获取密码失败
        public static let hyGetPasswordFalse = NSNotification.Name("com.ts-plus.notification.name.chat.hyGetPasswordFalse")
        /// 点击了聊天详情内测编辑群名称按钮
        public static let clickEditGroupBtn = NSNotification.Name("com.ts-plus.notification.name.chat.clickEditGroupBtn")
        /// 获取当有群成员变动系统消息时，更新群信息
        public static let uploadGrupInfo = NSNotification.Name("com.ts-plus.notification.name.chat.uploadGrupInfo")
        /// 获取到最新的群信息，需要更新聊天详情的本地数据
        public static let uploadLocGrupInfo = NSNotification.Name("com.ts-plus.notification.name.chat.uploadLocGrupInfo")
        /// 消息详情页的弹窗提示,通过object携带msg:xxx
        public static let showNotice = NSNotification.Name("com.ts-plus.notification.name.chat.showNotice")
    }

    /// 圈子相关
    public struct Group {
        public static let uploadGroupInfo = NSNotification.Name("com.ts-plus.notification.name.group.uploadGroupInfo")
        public static let joined = NSNotification.Name(rawValue: "com.ts-plus.notification.name.group.joined")
    }
    
    /// 设置跳转
    public struct Setting {
        public static let setPassword = NSNotification.Name(rawValue: "com.ts-plus.notification.name.setting.setPassword")
        public static let updateFloatButton = NSNotification.Name(rawValue: "com.ts-plus.notification.name.setting.updateFloatButton")
        public static let launchComplete = NSNotification.Name(rawValue: "com.ts-plus.notification.name.setting.launchcomplete")
        public static let configUpdated = NSNotification.Name(rawValue: "Config updated")
    }
    
    public struct Video {
        public static let muteAll = NSNotification.Name(rawValue: "com.ts-plus.notification.name.setting.muteAll")
        public static let disableAutoplay = NSNotification.Name(rawValue: "com.ts-plus.notification.name.setting.noAutoplay")
    }
    
    public struct Subscribe {
        public static let reloadStar = NSNotification.Name(rawValue: "com.ts-plus.notification.name.subscribe.reloadStar")
    }
    
    public struct DashBoard {
        public static let reloadCollectionView = NSNotification.Name(rawValue: "com.ts-plus.notification.name.dashboard.reloadCollectionView")
        public static let reloadCSBadge = NSNotification.Name(rawValue: "com.ts-plus.notification.name.dashboard.reloadCSBadge")
        public static let reloadNotificationBadge = NSNotification.Name(rawValue: "com.ts-plus.notification.name.dashboard.reloadNotificationBadge")
        public static let reloadUserInfo = NSNotification.Name(rawValue: "com.ts-plus.notification.name.dashboard.reloadUserInfo")
        public static let teenModeChanged = NSNotification.Name("com.yippi.notification.name.moment.teenModeChanged")
    }
    
    public struct Wallet {
        public static let reloadBalance = NSNotification.Name(rawValue: "com.ts-plus.notification.name.wallet.reloadBalance")
    }
    
    public struct Country {
        public static let reloadCountry = NSNotification.Name(rawValue: "com.ts-plus.notification.name.dashboard.reloadCountry")
        public static let reloadMobileTopup = NSNotification.Name(rawValue: "reloadMobileTopup")
    }
    
    public struct SCash {
        public static let rlpgCallBack = NSNotification.Name(rawValue: "rlpgCallBackURL")
    }

    public struct Voucher {
        public static let stopVideo = NSNotification.Name(rawValue: "com.ts-plus.notification.name.voucher.stopVideo")
        public static let updateRedeemedVoucher = NSNotification.Name(rawValue: "updateRedeemedVoucher")
    }
    
    public struct Chatroom {
        public static let updateProfile = Notification.Name("updateProfile")
        
    }
    
    public struct Transaction {
        static let reloadYear = Notification.Name("reloadYear")
    }
}
