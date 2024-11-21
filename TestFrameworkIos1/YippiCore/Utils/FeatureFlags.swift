//
// Copyright © 2018 Toga Capital. All rights reserved.
//


import Foundation
import SwiftyUserDefaults

public struct FeatureFlags: Codable, DefaultsSerializable {

    public let shouldFeedListloadUserInfo: Bool
    public let enableArticleCreationInEvents: Bool
    public let enableExpandTagsInEvents: Bool
    
    public static func load() -> FeatureFlags {
        return FeatureFlags(
            shouldFeedListloadUserInfo: true,
            enableArticleCreationInEvents: false,
            enableExpandTagsInEvents: false
        )
    }
}
