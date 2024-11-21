//
//  FeedHeaderType.swift
//  Yippi
//
//  Created by Francis Yeap on 22/10/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import FLAnimatedImage
import Foundation

enum HeadingType {
    case title(text: String)
    case image(defaultState: UIImage, selected: UIImage)
}
protocol FeedHeaderProtocol { var title: String { get } }
protocol FeedSubTypeProtocol { }

enum FeedHeaderType: Int {
    case following = 2, recommended = 1
    
    var title: String {
        switch self {
        case .following:
            return "home_tab_following".localized
        case .recommended:
            return UserDefaults.recommendedEnabled ? "search_user_recommend".localized : "search_user_hot".localized
        }
    }
}

enum FeedRecommendedSubType: FeedSubTypeProtocol {
    case feeds, live, miniVideo, popular
}
