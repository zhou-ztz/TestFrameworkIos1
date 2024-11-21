//
// Created by Francis Yeap on 01/12/2020.
// Copyright (c) 2020 Toga Capital. All rights reserved.
//


import Foundation
import Lottie

enum ReactionTypes: Int, CaseIterable {
    //love, like, heart_eyes, surprised, sad, angry)
    case heart = 0
    case like = 1
    case awesome = 2
    case wow = 3
    case cry = 4
    case angry = 5
    
    static func initialize(with stringValue: String) -> ReactionTypes? {
        switch stringValue {
        case ReactionTypes.like.apiName: return .like
        case ReactionTypes.heart.apiName: return .heart
        case ReactionTypes.awesome.apiName: return .awesome
        case ReactionTypes.wow.apiName: return .wow
        case ReactionTypes.cry.apiName: return .cry
        case ReactionTypes.angry.apiName: return .angry
        default: return nil
        }
    }
    
    func unHighlightColor(for theme: Theme) -> UIColor {
        switch theme {
        case .dark:
            return .white
        case .white:
            return AppTheme.pinkishGrey
        }
    }

    var apiName: String {
        switch self {
        case .like: return "like"
        case .heart: return "love"
        case .awesome: return "awesome"
        case .wow: return "wow"
        case .cry: return "sad"
        case .angry: return "angry"
        }
    }

    var colorSignature: UIColor {
        switch self {
        case .like: return UIColor.systemBlue
        case .heart: return UIColor.systemPink
        case .awesome: return UIColor.gray
        case .wow: return UIColor.systemYellow
        case .cry: return UIColor.red
        case .angry: return UIColor.orange
        }
    }
    
    var image: UIImage {
        switch self {
        case .like: return UIImage.set_image(named: "blue_like")!
        case .heart: return UIImage.set_image(named: "red_heart")!
        case .awesome: return UIImage.set_image(named: "cry_laugh")!
        case .wow: return UIImage.set_image(named: "surprised")!
        case .cry: return UIImage.set_image(named: "cry")!
        case .angry: return UIImage.set_image(named: "angry")!
        }
    }

    var imageName: String {
        switch self {
        case .like: return "blue_like"
        case .heart: return "red_heart"
        case .wow: return "surprised"
        case .awesome: return "cry_laugh"
        case .cry: return "cry"
        case .angry: return "angry"
        }
    }
    
    var lottieAnimation: Animation {
        switch self {
        case .like: return Animation.named("reaction-like")!
        case .heart: return Animation.named("reaction-love")!
        case .wow: return Animation.named("reaction-wow")!
        case .awesome: return Animation.named("reaction-awesome")!
        case .cry: return Animation.named("reaction-cry")!
        case .angry: return Animation.named("reaction-angry")!
        }
    }

    var title: String {
        switch self {
        case .like: return "like_reaction".localized
        case .heart: return "love_reaction".localized
        case .wow: return "wow_reaction".localized
        case .awesome: return "awesome_reaction".localized
        case .cry: return "sad_reaction".localized
        case .angry: return "angry_reaction".localized
        }
    }

//    func generateStyle(for theme: Theme) -> HeadingSelectionViewStyles {
//        switch theme {
//        case .white:
//            return .icon(text: self.title, highlightColor: UIColor.black, unhighlightColor: AppTheme.pinkishGrey,
//                    iconSelect: image, iconDeselect: image, indicatorColor: colorSignature)
//
//        case .dark:
//            return .icon(text: self.title, highlightColor: UIColor.white, unhighlightColor: UIColor.white.withAlphaComponent(0.3),
//                    iconSelect: image, iconDeselect: image, indicatorColor: colorSignature)
//        }
//    }
}
