// 
// Copyright © 2018 Toga Capital. All rights reserved.
//


import Foundation

@objc public enum RewardType: Int {
    case stickerArtist
    case photo
    case video
    
    public func name() -> String {
        switch self {
        case .stickerArtist: return "sticker_artist"
        case .photo: return "photo"
        case .video: return "video"
        default:
            return ""
        }
    }
}
