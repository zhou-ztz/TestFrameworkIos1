//
//  MomentListBasicCellModel.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/10/31.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  动态列表基础样式 cell model

import UIKit


/// 发送状态
enum SendStatus: Int {
    /// 发送成功
    case success = 0
    /// 正在发送中
    case sending
    /// 发送失败
    case faild
}

@objc enum feedType: Int {
    case text = 0
    case live
    case video
    case picture
    case repost
    case shared
}

public class FeedListCellModel {
    
    // 数据 id 类型
    enum IdType {
        /// 广告（分页标识）
        case advert(pageId: Int, link: String)
        /// 动态（动态 id）
        case feed(feedId: Int)
        /// 帖子（圈子 id，帖子 id）
        case post(gourpId: Int, postId: Int)
        /// 话题（话题 ID， 动态ID）
        case topic(topicId: Int, postId: Int)
        
        var link: String? {
            switch self {
            case .advert(_, let link):
                return link
            default:
                return nil
            }
        }
        
        var id: Int {
            switch self {
            case .feed(let feedId):
                return feedId
            case .post(let groupId, let postId):
                return postId
            case .advert(let pageId, let link):
                return pageId
            case .topic(let topicId, let postId):
                return topicId
            }
        }
        
        subscript(index: String) -> Int? {
            switch self {
            case .advert(let pageId, _):
                if index == "pageId" {
                    return pageId
                }
            case .feed(let feedId):
                if index == "feedId" {
                    return feedId
                }
            case .post(let groupId, let postId):
                if index == "groupId" {
                    return groupId
                }
                if index == "postId" {
                    return postId
                }
            case .topic(let topicId, let postId):
                if index == "groupId" {
                    return topicId
                }
                if index == "feedId" {
                    return postId
                }
            }
            return nil
        }
    }
    /// 用于搜索排序的
    var idindex = 0
    /// 动态 id
    var id: IdType = .feed(feedId: 0)
    /// index 用于话题动态分页
    var index: Int = 0
    /// 用户 id
    var userId: Int = 0
    /// 用户名，为空则不显示
    var userName = ""
    /// 头像信息，为 nil 则不显示头像
    var avatarInfo: AvatarInfo?
    /// 文字标题，为空则不显示
    var title = ""
    /// 文字内容，为空则不显示
    var content = ""
    /// 图片，为空则不显示
    /// 当该动态是含有视频时,会把视频的封面当做以往的单张图片处理展示
    var pictures: [PaidPictureModel] = []
    /// 文章来源，为空则不显示
    var from = ""
    /// 话题，为空则不显示评论
    var topics: [TopicListModel] = []
    /// 工具栏信息，为 nil 则不显示工具栏
    var toolModel: FeedListToolModel?
    /// 评论，为空则不显示评论
    var comments: [FeedCommentListCellModel] = []

    var time: Date?

    var location: TSPostLocationModel?
    /// 在线视频播放地址
    var videoURL: String = ""
    // By Kit Foong (Added video height and width property)
    /// 视频高度
    var videoHeight: Double = 0.0
    /// 视频宽度
    var videoWidth: Double = 0.0
    
    /// 视频封面id
    var videoCoverId: Int = 0
    
    /// 视频id
    var videoId: Int = 0
    
    /// 视频Path
    var videoPath: String = ""
    
    /// 本地视频文件地址
    var localVideoFileURL: String?
    /// 转发的类型
    var repostType: String? = nil
    /// 转发的ID
    var repostId: Int = 0
    /// 转发信息
    var repostModel: TSRepostModel? = nil
    /// 热门标识
    var hot: Int = 0
    /// 分享信息
    var sharedModel: SharedViewModel? = nil
    
    var canAcceptReward: Int = 0
    
    var userInfo: UserInfoModel? = nil
    
    var liveModel: LiveEntityModel? = nil

    //商户列表信息
    var rewardsMerchantUsers: [TSRewardsLinkMerchantUserModel] = []
    
    var tagUsers: [UserInfoModel] = []
    
    var rewardsLinkMerchantUsers: [UserInfoModel] = []
    
    var privacy: String = "EVERYONE"

    var isEdited: Bool = false

    var videoType: Int = 0 //2 is minivideo
    
    var feedType: FeedContentType {
        if liveModel != nil, liveModel?.status == 1, pictures.count > 0 {
            return .live
        } else if (videoURL.isEmpty == false || localVideoFileURL?.isEmpty == false), pictures.count > 0 {
            if videoType == 2 {
                return .miniVideo
            }
            return .video
        } else if pictures.count > 0 {
            return .picture
        } else if repostId > 0, repostModel != nil {
            return .repost
        } else if sharedModel != nil {
            return .share
        } else {
            return .normalText
        }
    }

    var topReactionList: [ReactionTypes?] = []

    var reactionType: ReactionTypes? = nil

    var translateText: String? = nil
    var isTranslateOn: Bool = false
    var isSponsored = false
    var isPinned = false
    var afterTime: String = ""
    var tagVoucher: TagVoucherModel? = nil
    init() {
    }
    
    /// 初始化动态收藏列表的的数据模型
    convenience init(feedCollection model: FeedListModel) {
        self.init(feedListModel: model)
        toolModel = nil
        comments = []
    }
    /// 初始化首页动态数据模型
    init(feedListModel model: FeedListModel) {
        idindex = model.id
        id = .feed(feedId: model.id)
        index = model.index
        userId = model.userId
        userName = model.userInfo.displayName
        avatarInfo = AvatarInfo(userModel: model.userInfo)
        avatarInfo?.type = .normal(userId: model.userInfo.userIdentity)
        content = model.content
        pictures = model.images?.map { PaidPictureModel(feedImageModel: $0) } ?? []
        toolModel = FeedListToolModel(feedListModel: model)
        comments = model.comments?.map { FeedCommentListCellModel(feedListCommentModel: $0) } ?? []
        topics = model.topics ?? []
        repostType = model.repostType
        repostId = model.repostId
        repostModel = model.repostModel
        sharedModel = model.sharedModel
        hot = model.hot
        location = model.location
        userInfo = model.userInfo

        time = model.create
        
        // 视频的处理
        // 如果存在视频时,视频的封面当做单张图片显示和处理同时设置播放地址
        if let video = model.feedVideo, video.width > 0 && video.height > 0 {
            let picture = PaidPictureModel()
            picture.url = video.videoCoverID.imageUrl()
            picture.originalSize = CGSize(width: video.width, height: video.height)
            pictures = [picture]
            videoURL = video.videoID.imageUrl()
            videoHeight = Double(video.height)
            videoWidth = Double(video.width)
            videoType = video.type
            videoCoverId = video.videoCoverID
            videoId = video.videoID
            videoPath = video.videoPath
        }
        canAcceptReward = model.userInfo.isRewardAcceptEnabled ? 1 : 0
        liveModel = model.liveModel
        privacy = model.privacy
        isEdited = model.isEdited
        topReactionList = model.topReactionList ?? []
        reactionType = model.reactionType
        isSponsored = model.isSponsored
        rewardsMerchantUsers = model.rewardsMerchantUsers ?? []
        tagUsers = model.tagUsers ?? []
        rewardsLinkMerchantUsers = model.rewardsLinkMerchantUsers ?? []
        
        afterTime = model.afterTime
        isPinned = model.isPinned
        tagVoucher = model.tagVoucher
     
    }
    
    init(feedStoreModel model: FeedStoreModel) {
        pictures = model.images?.map { PaidPictureModel(feedImageModel: $0) } ?? []
        // 视频的处理
        // 如果存在视频时,视频的封面当做单张图片显示和处理同时设置播放地址
        if let video = model.feedVideo, video.width > 0 && video.height > 0 {
            let picture = PaidPictureModel()
            picture.url = video.videoCoverID.imageUrl()
            picture.originalSize = CGSize(width: video.width, height: video.height)
            pictures = [picture]
            videoURL = video.videoID.imageUrl()
            videoHeight = Double(video.height)
            videoWidth = Double(video.width)
            videoType = video.type
        }
    }
}

class FeedListToolModel {
    /// 是否点赞
    var isDigg = false
    /// 是否收藏
    var isCollect = false
    /// 点赞数
    var diggCount = 0
    /// 评论数
    var commentCount = 0
    /// 浏览数
    var viewCount = 1
    /// 打赏数
    var rewardCount = 0
    /// 转发数
    var forwardCount = 0
    /// 是否打赏
    var isRewarded = false
    /// 是否禁止留言
    var isCommentDisabled = false
    
    init() {
    }
    
    /// 初始化列表动态数据模型
    init(feedListModel model: FeedListModel) {
        isDigg = model.hasLike
        isCollect = model.hasCollect
        diggCount = model.likeCount
        commentCount = model.commentCount
        viewCount = model.viewCount
        rewardCount = model.rewardCount
        forwardCount = model.feedForwardCount
        isRewarded = model.hasReward
        isCommentDisabled = model.hasDisabled
    }
}
