//
// Created by Francis Yeap on 10/12/2020.
// Copyright (c) 2020 Toga Capital. All rights reserved.
//

import Foundation

final class ReactionUpdateOperation: AsyncOperation {
    
    let feedId: Int
    let feedItem: FeedListCellModel?
    let currReaction: ReactionTypes?
    let reaction: ReactionTypes?
    let networkManager = TSMomentNetworkManager()
    
    var onError: ((_ fallbackReaction: ReactionTypes?, _ message: String) -> Void)?
    var onSuccess: ((_ message: String) -> Void)?
    
    init(feedId: Int, feedItem: FeedListCellModel?, currentReaction: ReactionTypes?, nextReaction: ReactionTypes?)  {
        self.feedId = feedId
        self.feedItem = feedItem
        self.currReaction = currentReaction
        self.reaction = nextReaction
    }
    
    override func main() {
        guard currReaction?.rawValue != reaction?.rawValue else {
            self.state = State.finished // no need update via api is same reaction
            return
        }
        
        networkManager.reactToFeed(id: feedId, reaction: reaction) { [weak self] (message, success) in
            guard let self = self else { return }
            
            if success {
                self.onSuccess?(message.orEmpty)
            } else {
                self.onError?(self.currReaction, message.orEmpty)
            }
            
            self.state = State.finished
            
            if let feedItem = self.feedItem {
                //上报动态点赞事件
                EventTrackingManager.instance.trackEvent(
                    itemId: feedItem.idindex.stringValue,
                    itemType: feedItem.feedType == .miniVideo ? ItemType.shortvideo.rawValue   : ItemType.image.rawValue,
                    behaviorType: (reaction == .heart) ? BehaviorType.like : BehaviorType.unlike,
                    sceneId: "",
                    moduleId: ModuleId.feed.rawValue,
                    pageId: PageId.feed.rawValue)
                
      
            }
        }
    }
}
