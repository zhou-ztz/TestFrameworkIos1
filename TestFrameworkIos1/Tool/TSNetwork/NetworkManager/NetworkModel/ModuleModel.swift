//
//  ModuleModel.swift
//  Yippi
//
//  Created by Yong Tze Ling on 09/05/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import ObjectMapper


public struct ModuleModel: Mappable {
    var id = -1
    var module: String = ""
    var status: Bool = false
    var actionName: String = ""
    var actionValue: String = ""
    var floatImageUrl: String = ""
    var floatLocation = ""
    var authMode = ""
    var version: Int = 0
    
    public init?(map: Map) {
    }
    mutating public func mapping(map: Map) {
        id <- map["id"]
        module <- map["module"]
        status <- map["status"]
        floatImageUrl <- map["float.image_url"]
        actionName <- map["action.type"]
        actionValue <- map["action.extra"]
        floatLocation <- map["float.location"]
        authMode <- map["action.auth_mode"]
        version <- map["version"]
    }

    init(id: Int, module: String, status: Bool) {
        self.id = id
        self.module = module
        self.status = status
    }
}

struct ModuleFlags {
    //Services
    public let gamesEnabled: Bool
    public let waveEnabled: Bool //Abandon since v6.6.0, as using status = 0, 1 to show hide wave from energy list api
    public let stickerEnabled: Bool
    public let faceUnityEnabled: Bool
    public let hotelAndFlightEnabled: Bool
    public let shoppingEnabled: Bool
    public let educationEnabled: Bool
    public let newsEnabled: Bool
    //ThirdParty
    public let rewardsLinkEnabled: Bool
    public let taMallEnabled: Bool

    //HelpDesk
    public let supportCentreEnabled: Bool
    public let customerSupportEnabled: Bool

    //HallOfFame
    public let hallOfFameEnabled: Bool

    public let gintellEnabled: Bool
    public let mobileTopupEnabled: Bool

    //GamificationLeveling
    public let gamificationEnabled: Bool

    //FeedBlockButton
    public let hideFeedBlockButton: Bool

    //Hide Show mini program
    public let miniProgramEnabled: Bool

    //Hide Show utilities bill
    public let utilitiesBillEnabled: Bool

    public let isWalletEnabled: Bool
    //Hide Yipps Hunter
    public let yippsHunterEnabled: Bool

    static func load(modules: [ModuleModel]?) -> ModuleFlags {
        let map = modules?.toDictionary { $0.id }
        return ModuleFlags(gamesEnabled: map?[AppModuleId.Games.rawValue]?.status ?? false,
                           waveEnabled: map?[AppModuleId.Eostrewave.rawValue]?.status ?? false,
                           stickerEnabled: map?[AppModuleId.Sticker.rawValue]?.status ?? false,
                           faceUnityEnabled: map?[AppModuleId.FaceUnity.rawValue]?.status ?? false,
                           hotelAndFlightEnabled: map?[AppModuleId.HotelFlight.rawValue]?.status ?? false,
                           shoppingEnabled: map?[AppModuleId.Shopping.rawValue]?.status ?? false,
                           educationEnabled: map?[AppModuleId.Education.rawValue]?.status ?? false,
                           newsEnabled: map?[AppModuleId.News.rawValue]?.status ?? false,
                           rewardsLinkEnabled: map?[AppModuleId.RewardsLink.rawValue]?.status ?? false,
                           taMallEnabled: map?[AppModuleId.TAMall.rawValue]?.status ?? false,
                           supportCentreEnabled: map?[AppModuleId.Report.rawValue]?.status ?? true,
                           customerSupportEnabled: map?[AppModuleId.Report.rawValue]?.status ?? false,
                           hallOfFameEnabled: map?[AppModuleId.HallOfFame.rawValue]?.status ?? false,
                           gintellEnabled: map?[AppModuleId.Gintell.rawValue]?.status ?? false,
                           mobileTopupEnabled: map?[AppModuleId.MobileTopUp.rawValue]?.status ?? false,
                           gamificationEnabled: map?[AppModuleId.GamificationLeveling.rawValue]?.status ?? false,
                           hideFeedBlockButton: map?[AppModuleId.FeedBlockButton.rawValue]?.status ?? false,
                           miniProgramEnabled: map?[AppModuleId.MiniProgram.rawValue]?.status ?? false,
                           utilitiesBillEnabled: map?[AppModuleId.UtilitiesBill.rawValue]?.status ?? false,
                           isWalletEnabled: map?[AppModuleId.Wallet.rawValue]?.status ?? false,
                           yippsHunterEnabled: map?[AppModuleId.YippsHunter.rawValue]?.status ?? false)
    }
}
