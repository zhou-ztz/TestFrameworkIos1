//
//  LegacyFeedType.swift
//  Yippi
//
//  Created by Francis Yeap on 23/10/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import UIKit


/// 动态列表的类型
enum FeedListType: Equatable {
    case new
    case hot
    case recommend
    case follow
    case teen
    case intelligent
    case tagged(userId: Int)
    case save(userId: Int)
    case user(userId: Int)
    case detail(feedId: Int)
    
    var trendingLiveFilter: String {
        switch self {
        case .hot:
            return "pinned"
        case .recommend:
            return "recommend"
        case .follow:
            return "follow"
        case .intelligent:
            return "intelligent"
            
        default:
            return ""
        }
    }
    
    var rawValue: String {
        switch self {
        case .teen: return "teen"
        case .new: return "new"
        case .follow: return "follow"
        case .recommend: return "recommend"
        case .hot: return "hot"
        case .intelligent: return "intelligent"
        case .user: return "user"
        case .tagged: return "tagged"
        case .save: return "collect"
        default: return ""
        }
    }
    
    var boxFilterType: String {
        switch self {
        case .user(let userId):
            return userId.stringValue
        default:
            return self.rawValue
        }
    }
    
    static func ==(lhs: FeedListType, rhs: FeedListType) -> Bool {
        switch (lhs, rhs) {
        case (.hot, .hot), (.follow, .follow), (.new, .new):
            return true
        case (.user(let a), .user(let b)):
            return a == b
        case (.detail(let a), .detail(let b)):
            return a == b
        default:
            return false
        }
    }
}

enum PostType {
    case photo
    case video
    case text
    case live
    case miniVideo
    
    var postButton: VerticalView {
        switch self {
        case .photo:
            let view = VerticalView(title: "photo".localized, image: UIImage.set_image(named: "ic_new_post_photo"))
            view.customiseLabel()
            return view
        case .video:
            let view = VerticalView(title: "video".localized, image: UIImage.set_image(named: "ic_new_post_video"))
            view.customiseLabel()
            return view
        case .miniVideo:
            let view = VerticalView(title: "mini_video".localized, image: UIImage.set_image(named: "ic_new_post_mini_video"))
            view.customiseLabel()
            return view
        case .live:
            let view = VerticalView(title: "text_live".localized, image: UIImage.set_image(named: "ic_new_post_live"))
            view.customiseLabel()
            return view
        case .text:
            let view = VerticalView(title: "text".localized, image: UIImage.set_image(named: "ic_new_post_text"))
            view.customiseLabel()
            return view
            
        }
    }
}

enum filterButtonType {
    case feed
    case live
}

enum FeedContentType {
    case normalText
    case picture
    case video
    case live
    case miniVideo
    case share
    case repost
}

