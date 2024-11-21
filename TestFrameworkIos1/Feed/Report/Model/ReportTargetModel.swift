//
//  ReportTargetModel.swift
//  ThinkSNS +
//
//  Created by 小唐 on 15/12/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  举报对象的模型
//  注：应修正命名为ViewModel

import Foundation

/// 举报对象的类型
enum ReportTargetType {
    /// 举报评论(若圈子，则需要传入圈子id)
    case Comment(commentType: TSCommentType, sourceId: Int, groupId: Int?)
    /// 举报帖子
    case Post(groupId: Int)
    /// 举报动态
    case Moment
    /// 举报用户
    case User
    /// 举报圈子
    case Group
    /// 举报话题
    case Topic
    /// 举报资讯
    case News
    
    case Live
}

/// 举报对象
struct ReportTargetModel {
    /// 举报对象所属的用户
    var user: UserInfoModel?
    /// 举报类型
    var type: ReportTargetType
    /// 举报动态实体
    var feedItem: FeedListCellModel?
    /// 被举报对象的 图标(举报用户就是用户头像，举报圈子就是圈子头像，不一定存在该值)
    var imageUrl: String?
    /// 被举报对象的 标题
    var title: String?
    /// 被举报对象的 详细描述
    var body: String?
    /// 举报对象的id。(举报评论就是评论id，评论圈子就是圈子id，举报帖子就是帖子id...)
    var targetId: Int

    init(targetId: Int, sourceUser: UserInfoModel?, type: ReportTargetType, imageUrl: String?, title: String?, body: String?) {
        self.targetId = targetId
        self.user = sourceUser
        self.type = type
        self.imageUrl = imageUrl
        self.title = title
        self.body = body
    }

    /// 通过动态/帖子 view model 来初始化，举报动态/帖子
    init?(feedModel model: FeedListCellModel) {
        targetId = model.id["feedId"] ?? 0
        switch model.id {
        case .feed(let feedId):
            targetId = feedId
            feedItem = model
            if let liveModel = model.liveModel {
                type = liveModel.status == YPLiveStatus.onlive.rawValue ? .Live : .Moment
            } else {
                type = .Moment
            }
        case .post(let groupId, let postId):
            targetId = postId
            type = .Post(groupId: groupId)
        default:
            return nil
        }
        var user = UserInfoModel()
        user.userIdentity = model.userId
        user.name = model.userName
        self.user = user
        imageUrl = model.pictures.first?.url
        title = model.title
        body = model.content
    }

    /// 通过动态详情页的数据来初始化
//    init(feedModel model: TSMomentListCellModel) {
//        self.targetId = model.data?.feedIdentity ?? 0
//        if let liveModel = model.data?.liveModel {
//            type = liveModel.status == YPLiveStatus.onlive.rawValue ? .Live : .Moment
//        } else {
//            self.type = .Moment
//        }
//        if let userObject = model.userInfo, userObject.isInvalidated == false {
//            self.user = UserInfoModel(object: userObject)
//        }
//        self.title = model.data?.title
//        self.body = model.data?.content
//        guard let imageObject = model.data?.pictures.first else {
//            return
//        }
//        // 拼接 url
//        let originalSize = CGSize(width: imageObject.width, height: imageObject.height)
//        let url = imageObject.storageIdentity.imageUrl()
//        let imageUrl: String
//        if  imageObject.paid.value == true {
//            imageUrl = url.smallPicUrl(showingSize: CGSize(width: 40, height: 40))
//        } else {
//            // 付费图片加载原图
//            imageUrl = url.smallPicUrl(showingSize: .zero)
//        }
//        self.imageUrl = imageUrl
//    }

    /// 通过动态/帖子的评论的 view model 来初始化，举报动态/帖子的评论
    init(feedCommentModel model: FeedCommentListCellModel) {
        switch model.id {
        case .feed(let feedId, let commentId):
            targetId = commentId
            type = .Comment(commentType: .momment, sourceId: feedId, groupId: nil)
        case .post(let groupId, let postId, let commentId):
            targetId = commentId
            type = .Comment(commentType: .post, sourceId: postId, groupId: groupId)
        }
        var user = UserInfoModel()
        user.userIdentity = model.userId
        user.name = model.name
        self.user = user
        body = model.content
    }

    /// 通过用户 model 来初始化，举报用户
    init(userModel model: UserInfoModel) {
        targetId = model.userIdentity
        type = .User
        user = model
        title = model.name
        imageUrl = model.avatarUrl.orEmpty
    }

    /// 资讯

    /// 评论
    init(comment: TSSimpleCommentModel, commentType: TSCommentType, sourceId: Int, groupId: Int?) {
        self.targetId = comment.id
        self.type = ReportTargetType.Comment(commentType: commentType, sourceId: sourceId, groupId: groupId)
        self.user = comment.userInfo
        self.imageUrl = nil
        self.title = nil
        self.body = comment.content
    }


    /// 话题
    init(topic: TopicModel) {
        targetId = topic.id
        type = .Topic
        user = topic.userInfo
        title = topic.name
        imageUrl = TSUtil.praseTSNetFileUrl(netFile: topic.avatar)
    }
}
