//
//  MoreDataManager.swift
//  Yippi
//
//  Created by Yong Tze Ling on 09/05/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation
import UIKit

class MoreDataManager {
    
    static let shared = MoreDataManager()
    
    private let modules: [ModuleModel]? = TSAppConfig.share.localInfo.modules ?? [ModuleModel(id: 17, module: "Centre Report", status: true)]
    
    private var allItems: [MoreItem] {
        guard let modules = modules else { return [] }
        let filteredItems = modules.filter { $0.status == true || $0.id == 26 }.compactMap {  MoreItem(rawValue: $0.id) }
        return filteredItems.filter { !$0.isExcludingService }
    }

    private var helpDesks: [MoreItem] {
        return fillUpEmptySpace(allItems.filter { $0.isHelpDesk })
    }
    
    private var thirdPartyServices: [MoreItem] {
        return fillUpEmptySpace(allItems.filter { $0.isThirdPartyService })
    }
    
    private var otherServices: [MoreItem] {
        return fillUpEmptySpace(allItems.filter { !$0.isHelpDesk && !$0.isThirdPartyService })
    }
    
    var headerTitles = [String]()
    
    var count: Int {
        return dataSource.count
    }
    
    var dataSource: [[MoreItem]] {
        var temp = [[MoreItem]]()
        
        if otherServices.count > 0 {
            temp.append(otherServices)
            headerTitles.append("powered_by_toga".localized)
        }
        
        if helpDesks.count > 0 {
            temp.append(helpDesks)
            headerTitles.append("more_helpDesk".localized)
        }
        
        if thirdPartyServices.count > 0 {
            temp.append(thirdPartyServices)
            headerTitles.append("more_official_partners".localized)
        }
        
        return temp
    }
    
    var walletService: [VerticalView] {
        return allItems.filter { $0.isWalletService }.compactMap {
            let v = VerticalView(title: $0.info.title, image: $0.info.icon)
            v.type = $0
            return v
        }
    }
    
    private func fillUpEmptySpace(_ items: [MoreItem]) -> [MoreItem] {
        guard items.count > 0 else { return [] }
        var tempItems = items
        if items.count % 4 == 1 {
            tempItems.append(contentsOf: [.empty, .empty, .empty])
        }
        if items.count % 4 == 2 {
            tempItems.append(contentsOf: [.empty, .empty])
        }
        if items.count % 4 == 3 {
            tempItems.append(.empty)
        }
        
        return tempItems
    }
    
    func isGamesEnabled() -> Bool {
        if let modules = modules, let gameModuleIndex = modules.firstIndex(where: { $0.id == 2 }) {
            return modules[gameModuleIndex].status
        }
        return true
    }
}

enum MoreItem: Int {
    
    case news = 1
    case games = 2
    case sticker = 4
    case wave = 5
    case reward = 7
    case taMall = 8
    case shopping = 9
    case education = 10
    case beauty = 12
    case hotelAndFlight = 15
    case reportCentre = 17
    case customerSupport = 19
    case gintell = 23
    case mobileTopup = 24
    case eshop = 26
    case utilitiesBill = 27
    case charity = 30
    case earn = 32
    case empty = -1
    
    var isHelpDesk: Bool {
        switch self {
        case .reportCentre, .customerSupport:
            return true
        default:
            return false
        }
    }
    
    var isThirdPartyService: Bool {
        switch self {
        case .reward, .taMall:
            return true
        default:
            return false
        }
    }
    
    var isExcludingService: Bool {
        switch self {
        case .games:
            return true
        default:
            return false
        }
    }

    var isWalletService: Bool {
        switch self {
        case .gintell, .hotelAndFlight, .mobileTopup, .eshop, .utilitiesBill, .charity:
            return true
        default:
            return false
        }
    }
    
    var info: (title: String, icon: UIImage?) {
        switch self {
        case .wave:
            return ("more_wave".localized, UIImage.set_image(named: "more_wave"))
        case .sticker:
            return ("more_sticker_shop".localized, UIImage.set_image(named: "more_stickers"))
        case .beauty:
            return ("more_beauty_sticker".localized, UIImage.set_image(named: "more_camera"))
        case .shopping:
            return ("more_shopping".localized, UIImage.set_image(named: "more_shopping"))
        case .hotelAndFlight:
            return ("more_togago".localized, UIImage.set_image(named: "more_travel"))
        case .education:
            return ("more_education".localized, UIImage.set_image(named: "more_education"))
        case .news:
            return ("more_news".localized, UIImage.set_image(named: "more_news"))
        case .games:
            return ("more_togagames".localized, UIImage.set_image(named: "more_games"))
        case .reward:
            return ("more_rewardslink".localized, UIImage.set_image(named: "more_reward"))
        case .taMall:
            return ("more_ta_mall".localized, UIImage.set_image(named: "more_tamall"))
        case .reportCentre:
            return ("more_reportCentre".localized, UIImage.set_image(named: "more_report_center"))
        case .customerSupport:
            return ("more_reportCentre".localized, UIImage.set_image(named: "more_report_center"))
        case .gintell:
            return ("title_massage".localized, UIImage.set_image(named: "icMassageChair"))
        case .mobileTopup:
            return ("text_mobile_topup".localized, UIImage.set_image(named: "icSrsTopup"))
        case .eshop:
            return("text_eshop_title".localized, UIImage.set_image(named: "ic_eshop"))
        case .utilitiesBill:
            return("srs_utilities_bills".localized, UIImage.set_image(named: "ic_utilities_bills"))
        case .charity:
            return("rw_wallet_service_charity_label".localized, UIImage.set_image(named: "charity_rice"))
        case .earn:
            return("yipps_wanted_refer_and_earn".localized, UIImage.set_image(named: "iconsReferEarnBlack"))
        case .empty:
            return ("", nil)
        }
    }
    
    var page: (navTitle: String, url: String) {
        switch self {
        case .hotelAndFlight:
            let token = TSCurrentUserInfo.share.accountToken?.token
            let country = CurrentUserSessionInfo?.country
            guard let _token = token else { return ("more_togago".localized, "https://cn.togago.com/") }

            let url = String(format: TSAppConfig.share.environment.togagoUrl.localized, country.orEmpty)
            print(url)
            return ("more_togago".localized, url)
            
        case .education:
            return ("e_learning".localized, "https://education.transparent.com/yippi/game/ng/#/login")
        case .taMall:
            return ("more_ta_mall".localized, "http://tamall.online")
        case .shopping:
            return ("", "itms://itunes.apple.com/us/app/t-pocket/id1234017809")
        case .reward:
            return ("more_rewardslink".localized, "")
        default:
            return ("", "")
        }
    }
    
    var event: Event {
        switch self {
        case .taMall: return .viewTAMall
        case .hotelAndFlight: return .viewTogaGo
        case .reward: return .viewRewardslink
        default: return .Wave3Clicked
        }
    }
    
    var yippswantedServiceTitle: String {
        switch self {
        case .eshop:
            return "yipps_wanted_service_topz_mall".localized
        case .charity:
            return "yipps_wanted_service_charity".localized
        case .mobileTopup:
            return "yipps_wanted_service_mobile_bill".localized
        case .utilitiesBill:
            return "yipps_wanted_service_utilities_bill".localized
        case .gintell:
            return "yipps_wanted_service_rest_n_go".localized
        case .hotelAndFlight:
            return "yipps_wanted_service_togago".localized
        default:
            return ""
        }
    }
}
