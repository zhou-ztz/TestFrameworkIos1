//
// Created by lip on 2017/10/17.
// Copyright (c) 2017 ZhiYiCX. All rights reserved.
//

import Foundation

struct AppEnvironmentModel{
    /// 是否隐藏游客开关
    var isHiddenGuestLoginButtonInLaunch: Bool { return AppEnvironment.current.config.isHiddenGuestLoginButtonInLaunch ?? false }
    /// Engage Lab推送的key
    var engageKey: String { return AppEnvironment.current.config.engageKey }
    /// 服务器地址
    var serverAddress: String { return FeedIMSDKManager.shared.param.apiBaseURL }
    /// Biz 服务器地址
    var bizServerAddress: String { return AppEnvironment.current.config.bizApiBaseURL }
    /// Event服务器地址
    var eventServerAddress: String { return AppEnvironment.current.config.eventApiBaseURL }
    
    //
    var identifier: String { return AppEnvironment.current.config.identifier }
    //
    var pushLiveHost: String { return AppEnvironment.current.config.pushLiveHost }
    //
    var pullLiveHost: String { return AppEnvironment.current.config.pullLiveHost }
    //
    var starQuestPusherKey: String { return AppEnvironment.current.config.starQuestPusherKey }
    //
    var alipayProductID: String { return AppEnvironment.current.config.alipayProductID }
    //
    var alipayAppID: String { return AppEnvironment.current.config.alipayAppID }
    //
    var miniProgramKey: String { return AppEnvironment.current.config.miniProgramKey }
    //
    var miniProgramSecret: String { return AppEnvironment.current.config.miniProgramSecret }
    //
    var miniProgramServer: String { return AppEnvironment.current.config.miniProgramServer }
    //
    var eshopAppId: String { return AppEnvironment.current.config.eshopAppId }
    //
    var uploadFileURL: String { return FeedIMSDKManager.shared.param.uploadFileURL }
    //
    var guestUsername: String { return AppEnvironment.current.config.guestUsername }
    //
    var merchantAppId: String { return AppEnvironment.current.config.merchantAppId }
    //
    var togagoClientId: String { return AppEnvironment.current.config.togagoClientId }
    //
    var togagoUrl: String { return AppEnvironment.current.config.togagoUrl }
    //
    var merchantHost: String { return AppEnvironment.current.config.merchantHost }
    //
    var charityAppId: String { return AppEnvironment.current.config.charityAppId }
    //
    var creatorCenterAppId: String { return AppEnvironment.current.config.creatorCenterAppId }
    
    var rlCheckInAppId: String { return AppEnvironment.current.config.rlCheckInAppId }
    //
    var yippsHunterAppId: String { return AppEnvironment.current.config.yippsHunterAppId }
    //
    var universalLinkApiSchema: String { return AppEnvironment.current.config.universalLinkApiSchema }
    
    var universalLinkWebSchema: String { return AppEnvironment.current.config.universalLinkWebSchema }
    
    var universalLinkRegisterSchema: String { return AppEnvironment.current.config.universalLinkRegisterSchema }
    //
    var deepLinkSchema: String { return AppEnvironment.current.config.deepLinkSchema }
    //
    var mapMerchantAppId: String { return AppEnvironment.current.config.mapMerchantAppId }
    
    /// 环信配置Key
    var imAppKey: String { return AppEnvironment.current.config.imAppKey }
    /// 环信配置推送证书名称
    var imApnsName: String { return AppEnvironment.current.config.imApnsName }
    
    // MARK: AppsFlyers
    var afAppID: String { return AppEnvironment.current.config.afAppID }
    
    var afDevKey: String { return AppEnvironment.current.config.afDevKey }
    
    var afInviteOneLinkID: String { return AppEnvironment.current.config.afInviteOneLinkID }
    
    var afBrandDomain: String { return AppEnvironment.current.config.afBrandDomain }

    var lokaliseProjectID: String { return AppEnvironment.current.config.lokaliseProjectID }

    var lokaliseSDKToken: String { return AppEnvironment.current.config.lokaliseSDKToken }
    
    var sobotGroupId: String { return AppEnvironment.current.config.sobotGroupId }
    
    var NTESVerifyCodeID: String { return AppEnvironment.current.config.NTESVerifyCodeID }
    
    var scashCallBackURL: String { return AppEnvironment.current.config.scashURL }
    
    var redpayRoute: String { return AppEnvironment.current.config.redpayURL }
    
    init(){
        
    }
}
