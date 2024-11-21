//
//  UnreadCountNetworkManager.swift
//  ThinkSNS +
//
//  Created by lip on 2017/9/8.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  未读数网络请求管理
// 现在由两个接口完成: unread-count获取具体的列表数据 counts获取未读数量

import UIKit
import NIMSDK
class UnreadCountNetworkManager {
    static let share = UnreadCountNetworkManager()

    var responseNotices: UserCounts?

    func unreadCount(complete: ((Bool) -> Void)? = nil) {
        if TSCurrentUserInfo.share.isLogin == false {
            complete?(false)
            return
        }
        var request = UserNetworkRequest().counts
        request.urlPath = request.fullPathWith(replacers: [])
        RequestNetworkData.share.text(request: request) { [weak self] (result) in
            switch result {
            case .failure(_), .error(_):
                complete?(false)
                break
            case .success(let response):
                if let model = response.model {
                    TSCurrentUserInfo.share.unreadCount.system = model.system.badge
                    TSCurrentUserInfo.share.unreadCount.like = model.like.badge
                    TSCurrentUserInfo.share.unreadCount.comments = model.comment.badge
                    TSCurrentUserInfo.share.unreadCount.follows = model.follow.badge
                    TSCurrentUserInfo.share.unreadCount.at = model.at.badge
                    TSCurrentUserInfo.share.unreadCount.reject = model.reject?.badge ?? 0
                    
                    TSCurrentUserInfo.share.unreadCount.isHiddenNoticeBadge = TSCurrentUserInfo.share.unreadCount.allNoticeUnreadCount() <= 0
                    DispatchQueue.main.async {
                        self?.updateTabbarBadge()
                    }
                    // 这里直接解析处理 简化之前的逻辑
                    self?.responseNotices = response.model
                    self?.processNotice()

                    complete?(true)
                }
            }
        }
    }
    
    func unreadChatRequestCount(complete: ((Bool) -> Void)? = nil) {
        if TSCurrentUserInfo.share.isLogin == false {
            complete?(false)
            return
        }
        
        MessageRequestNetworkManager().getMessageReqList(specialRequest: true, complete: { [weak self] (result, status) in
            complete?(true)
        })
    }

    func processNotice() {
        guard let notices = responseNotices else {
            return
        }
        if !notices.like.preview_users_names.isEmpty {
            var likeUsers = ""
            let count = notices.like.preview_users_names.count > 3 ? 3 : notices.like.preview_users_names.count
            for user in notices.like.preview_users_names[0..<count] {
                likeUsers = likeUsers + user + "、"
            }
            likeUsers.remove(at: likeUsers.index(before: likeUsers.endIndex))
            if notices.like.preview_users_names.count <= 1 {
                likeUsers += "notification_like_me_one".localized
            } else {
                likeUsers += "notification_like_me_more".localized
            }
            TSCurrentUserInfo.share.unreadCount.likedUsers = likeUsers
            TSCurrentUserInfo.share.unreadCount.likeUsersDate = notices.like.last_created_at
        } else {
                TSCurrentUserInfo.share.unreadCount.likedUsers = nil
                TSCurrentUserInfo.share.unreadCount.likeUsersDate = nil
        }

        if !notices.comment.preview_users_names.isEmpty {
            var commentsUser = ""
            let count = notices.comment.preview_users_names.count > 2 ? 2 : notices.comment.preview_users_names.count
            for user in notices.comment.preview_users_names[0..<count] {
                commentsUser = commentsUser + user + "、"
            }
            commentsUser = commentsUser.substring(to: commentsUser.index(before: commentsUser.endIndex))
            if notices.comment.preview_users_names.count <= 1 {
                commentsUser += "notification_comment_me".localized
            } else {
                commentsUser += "notification_comment_me_more".localized
            }
            TSCurrentUserInfo.share.unreadCount.commentsUsers = commentsUser
            TSCurrentUserInfo.share.unreadCount.commentsUsersDate = notices.comment.last_created_at
        } else {
            TSCurrentUserInfo.share.unreadCount.commentsUsers = nil
            TSCurrentUserInfo.share.unreadCount.commentsUsersDate = nil
        }

        if !notices.at.preview_users_names.isEmpty {
            var atUser = ""
            let count = notices.at.preview_users_names.count > 2 ? 2 : notices.at.preview_users_names.count
            for userName in notices.at.preview_users_names[0..<count] {
                atUser = atUser + userName + "、"
            }
            atUser = atUser.substring(to: atUser.index(before: atUser.endIndex))
            if notices.at.preview_users_names.count <= 1 {
                atUser += "notification_at_me".localized
            } else {
                atUser += "notification_at_me_more".localized
            }
            TSCurrentUserInfo.share.unreadCount.atUsers = atUser
            TSCurrentUserInfo.share.unreadCount.atUsersDate = notices.at.last_created_at
        } else {
            TSCurrentUserInfo.share.unreadCount.atUsers = ""
            TSCurrentUserInfo.share.unreadCount.atUsersDate = nil
        }

        if !notices.follow.preview_users_names.isEmpty {
            var followedUser = ""
            let count = notices.follow.preview_users_names.count > 2 ? 2 : notices.follow.preview_users_names.count
            for user in notices.follow.preview_users_names[0..<count] {
                followedUser = followedUser + user + "、"
            }
            followedUser = followedUser.substring(to: followedUser.index(before: followedUser.endIndex))
            if notices.follow.preview_users_names.count <= 1 {
                followedUser += "notification_follow_me".localized
            } else {
                followedUser += "notification_follow_me_more".localized
            }
            TSCurrentUserInfo.share.unreadCount.followedUsers = followedUser
            TSCurrentUserInfo.share.unreadCount.followedUsersDate = notices.follow.last_created_at
        } else {
            TSCurrentUserInfo.share.unreadCount.followedUsers = nil
            TSCurrentUserInfo.share.unreadCount.followedUsersDate = nil
        }
        
        // 解析系统消息
        if notices.system.first == nil {
            return
        }
        if let type = notices.system.first.data["type"] as? String {
            var content = ""
            if type == "reward" {
                if let sender = notices.system.first.data["sender"] as? [String:Any] {
                    if let name = sender["name"] {
                        content = String(format: "noti_sys_rewarded_you".localized, "\(name)")
                    }
                }
            } else if type == "reward:feeds" {
                if let sender = notices.system.first.data["sender"] as? [String:Any] {
                    if let name = sender["name"] {
                        content = String(format: "noti_sys_rewarded_your_moment".localized, "\(name)")
                    }
                }
            } else if type == "reward:live" {
                if let sender = notices.system.first.data["sender"] as? [String:Any] {
                    if let name = sender["name"] {
                        content = String(format: "noti_sys_rewarded_your_live".localized, "\(name)")
                    }
                }
            } else if type == "reward:news" {
                if let news = notices.system.first.data["news"] as? [String:Any] {
                    if let sender = notices.system.first.data["sender"] as? [String:Any] {
                        if let sendername = sender["name"], let newsname = news["title"], let amount = notices.system.first.data["amount"], let unit = notices.system.first.data["unit"] {
                            content = "noti_sys_your_event".localized + "《\(newsname)》" + String(format: "noti_sys_event_rewarded".localized , "\(sendername)", "\(amount)", "\(unit)")
                        }
                    }
                }
            } else if type == "user-certification" {
                if let state = notices.system.first.data["state"] as? String {
                    if state == "rejected" {
                        if let contentt = notices.system.first.data["contents"] as? String {
                            content = String(format: "noti_sys_request_authentication_rejected".localized , "\(contentt)")
                        } else {
                            content = "noti_sys_authentication_rejected".localized
                        }
                    } else {
                        content = "noti_sys_request_authentication_approved".localized
                    }
                }
            } else if type == "qa:answer-adoption" {
                content = "noti_sys_submitted_qna_approved".localized
            } else if type == "question:answer" {
                content = "noti_sys_submitted_qna_approved".localized
            } else if type == "qa:reward" {
                if let sender = notices.system.first.data["sender"] as? [String:Any], let name = sender["name"] as? String {
                    content = String(format: "noti_sys_rewarded_your_answer".localized, "\(name)")
                }
            } else if type == "qa:invitation" {
                if let question = notices.system.first.data["question"] as? [String:Any] {
                    if let sender = notices.system.first.data["sender"] as? [String:Any] {
                        if let sendername = sender["name"], let questionname = question["subject"] {
                            content = String(format: "noti_sys_invite_you_answer".localized,"\(sendername)","\(questionname)")
                        }
                    }
                }
            } else if type == "qa:question-topic:reject" {
                if let topic = notices.system.first.data["topic_application"] as? [String:Any], let name = topic["name"] {
                    content = String(format:"noti_sys_topic_rejected".localized, "\(name)")
                }
            } else if type == "qa:question-topic:passed" {
                if let topic = notices.system.first.data["topic_application"] as? [String:Any], let name = topic["name"] {
                    content = String(format:"noti_sys_topic_approved".localized, "\(name)")
                }
            } else if type == "pinned:feed/comment" {
                if let comment = notices.system.first.data["comment"] as? [String:Any] {
                    if let name = comment["contents"] {
                        if let state = notices.system.first.data["state"] as? String {
                            if state == "rejected" {
                                content = String(format: "noti_sys_pin_moment_rejected".localized, "\(name)")
                            } else {
                                content = String(format: "noti_sys_pin_moment_approved".localized, "\(name)")
                            }
                        }
                    }
                }
            } else if type == "pinned:news/comment" {
                if let comment = notices.system.first.data["comment"] as? [String:Any] {
                    if let news = notices.system.first.data["news"] as? [String:Any] {
                        if let commentname = comment["name"], let newsname = news["name"] {
                            if let state = notices.system.first.data["state"] as? String {
                                if state == "rejected" {
                                    content = String(format: "noti_sys_news_comment_pin_rejected".localized, "\(newsname)", "\(commentname)")
                                } else {
                                    content = String(format: "noti_sys_news_comment_pin_approved".localized, "\(newsname)", "\(commentname)")
                                }
                            }
                        }
                    }
                }
            } else if type == "group:comment-pinned" {
                if let state = notices.system.first.data["state"] as? String {
                    if state == "rejected" {
                        content = "noti_sys_comment_pin_rejected".localized
                    } else {
                        content = "noti_sys_comment_pin_approved".localized
                    }
                }
            } else if type == "group:post-pinned" {
                if let post = notices.system.first.data["post"] as? [String:Any] {
                    if let name = post["name"] {
                        if let state = notices.system.first.data["state"] as? String {
                            if state == "rejected" {
                                content = String(format: "noti_sys_post_pin_rejected".localized, "\(name)")
                            } else {
                                content = String(format: "noti_sys_post_pin_approved".localized, "\(name)")
                            }
                        }
                    }
                }
            } else if type == "group:join" {
                if let group = notices.system.first.data["group"] as? [String:Any], let groupname = group["name"] {
                    if let state = notices.system.first.data["state"] as? String {
                        if state == "rejected" {
                            content = String(format: "noti_sys_join_group_rejected".localized, "\(groupname)")
                        } else {
                            content = String(format: "noti_sys_join_group_approved".localized, "\(groupname)")
                        }
                    } else {
                        if let user = notices.system.first.data["user"] as? [String:Any], let username = user["name"] {
                            content = String(format: "noti_sys_request_join_group".localized, "\(username)", "\(groupname)")
                        }
                    }
                }
            } else if type == "group:send-comment-pinned" {
                if let post = notices.system.first.data["post"] as? [String:Any] {
                    if let title = post["title"] {
                        content = String(format: "noti_sys_user_request_pin_comment_your_post".localized, "\(title)")
                    }
                }
            } else if type == "group:post-reward" {
                if let sender = notices.system.first.data["sender"] as? [String:Any], let sendername = sender["name"] as? String {
                    if let post = notices.system.first.data["post"] as? [String:Any], let postname = post["title"] as? String {
                        content = String(format:"noti_sys_rewarded_your_post".localized, "\(sendername)","\(postname)")
                    }
                }
            } else if type == "purchase" {
                if let sender = notices.system.first.data["sender"] as? [String:Any] {
                    if let name = sender["name"] {
                        content = String(format: "noti_sys_buy_your_moment".localized , "\(name)")
                    }
                }
            } else if type == "user-cash" {
                if let state = notices.system.first.data["state"] as? String {
                    if state == "rejected" {
                        content = "noti_sys_fail_cash_out".localized
                    } else {
                        content = "noti_sys_success_cash_out".localized
                    }
                }
            } else if type == "pinned:feeds" {
                if let state = notices.system.first.data["state"] as? String {
                    if state == "rejected" {
                        content = "noti_sys_request_pin_top_rejected".localized
                    } else if state == "admin" {
                        content = "noti_sys_admin_set_pin_top".localized
                    } else {
                        content = "noti_sys_request_pin_top_approved".localized
                    }
                }
            } else if type == "user-currency:cash" {
                if let state = notices.system.first.data["state"] as? String {
                    if state == "rejected" {
                        if let contentt = notices.system.first.data["contents"] as? String {
                            content = "noti_sys_cash_out_fail_reason".localized + "\(contentt)"
                        } else {
                            content = "noti_sys_cash_out_fail_reason".localized
                        }
                    } else {
                        content = "noti_sys_cash_out_approved".localized
                    }
                }
            } else if type == "report" {
                content = "noti_sys_report_action_took".localized
                if let state = notices.system.first.data["state"] as? String, let contentt = notices.system.first.data["subject"] as? String {
                    if state == "rejected" {
                        if let resourceData = notices.system.first.data["resource"] as? [String:Any], let remark = resourceData["remark"] as? String {
                            content = String(format: "noti_sys_report_on_user_action_rejected".localized, remark)
                        }
                    } else {
                        if let resourceData = notices.system.first.data["resource"] as? [String:Any], let typeS = resourceData["type"] as? String {
                            if typeS == "users" {
                                content = "noti_sys_report_on_user_action_took".localized
                            } else if typeS == "feed_topics" {
                                content = "noti_sys_report_moment".localized + "「\(contentt)」" + "noti_sys_action_took_on_report".localized
                            } else if typeS == "comments" {
                                content = "noti_sys_report_on_user_action_took".localized
                            } else if typeS == "questions" {
                                content = "noti_sys_report_question".localized + "「\(contentt)」" + "noti_sys_action_took_on_report".localized
                            } else if typeS == "feeds" {
                                content = "noti_sys_report_on_user_action_took".localized
                            } else if typeS == "news" {
                                content = "noti_sys_report_news".localized + "「\(contentt)」" + "noti_sys_action_took_on_report".localized
                            } else if typeS == "answers" {
                                content = "noti_sys_report_answer".localized + "「\(contentt)」" + "noti_sys_action_took_on_report".localized
                            } else if typeS == "posts" || typeS == "group-posts" {
                                content = "noti_sys_report_post_action_took".localized
                            } else if typeS == "groups" {
                                content = "noti_sys_report_group".localized + "「\(contentt)」" + "noti_sys_action_took_on_report".localized
                            }
                        }
                    }
                }
            } else if type == "qa:question-topic:accept" {
                if let topicData = notices.system.first.data["topic"] as? [String:Any], let name = topicData["name"] as? String {
                    content = String(format:  "noti_sys_topic_creation_approved".localized, name)
                }
            } else if type == "group:transform" {
                content =  "noti_sys_transfer_group_to_you".localized
                if let group = notices.system.first.data["group"] as? [String:Any], let groupname = group["name"], let user = notices.system.first.data["user"] as? [String:Any], let username = user["name"] {
                    content = String(format:  "noti_sys_user_transfer_group_to_you".localized, "\(username)", "\(groupname)")
                }
            } else if type == "group:report_post" {
                if let sender = notices.system.first.data["sender"] as? [String:Any], let sendername = sender["name"] as? String, let post = notices.system.first.data["post"] as? [String:Any], let postname = post["title"] as? String, let group = notices.system.first.data["group"] as? [String:Any], let groupName = group["name"] as? String {
                    content = String(format: "noti_sys_report_post_under_your_group".localized ,"\(sendername)", "\(groupName)", "\(postname)")
                }
            } else if type == "group:report" {
                content = "noti_sys_group_content_reported_action_took".localized
                if let state = notices.system.first.data["state"] as? String, let contentt = notices.system.first.data["report"] as? String {
                    if state == "pass" {
                        content = String(format: "noti_sys_group_content_reported_approved".localized, "\(contentt)")
                    } else {
                        content = String(format: "noti_sys_group_content_reported_rejected".localized, "\(contentt)")
                    }
                } else {
                    if let state = notices.system.first.data["state"] as? String {
                        if state == "pass" {
                            content = "noti_sys_group_reported_action_took".localized
                        } else {
                            content = "noti_sys_group_reported_rejected".localized
                        }
                    }
                }
            } else if type == "group:menbers" {
                if let group = notices.system.first.data["group"] as? [String:Any], let groupName = group["name"] as? String, let message = notices.system.first.data["message"] as? String {
                    content = message
                }
            } else if type == "qa:question-excellent:accept" {
                content = "noti_sys_question_featured".localized
            } else if type == "qa:question-excellent:reject" {
                content = "noti_sys_question_featured_rejected".localized
            } else if type == "group:pinned-admin" {
                if let message = notices.system.first.data["message"] as? String {
                    content = message
                } else {
                    content = "noti_sys_post_pinned_by_admin".localized
                }
            } else if type == "group:report-comment" {
                /// x举报了你的圈子[xx]下的帖子[xxx]的评论[xxxx]
                if let sender = notices.system.first.data["sender"] as? [String:Any], let sendername = sender["name"] as? String, let post = notices.system.first.data["post"] as? [String:Any], let postname = post["title"] as? String, let group = notices.system.first.data["group"] as? [String:Any], let groupName = group["name"] as? String, let comment = notices.system.first.data["comment"] as? [String:Any], let contents = comment["contents"] as? String {
                    content = String(format: "noti_sys_report_comment_post_under_your_group".localized, "\(sendername)", "\(groupName)", "\(postname)","\(contents)")
                }
            } else if type == "group:report-post" {
                /// x举报了你的圈子[xx]下的帖子[xxx]
                if let sender = notices.system.first.data["sender"] as? [String:Any], let sendername = sender["name"] as? String, let post = notices.system.first.data["post"] as? [String:Any], let postname = post["title"] as? String, let group = notices.system.first.data["group"] as? [String:Any], let groupName = group["name"] as? String {
                    content = String(format: "noti_sys_report_post_under_your_group".localized ,"\(sendername)", "\(groupName)", "\(postname)")
                }
            } else if type == "transfer:yipps" {
                if let sender = notices.system.first.data["sender"] as? [String:Any] {
                    if let name = sender["name"] {
                        content = String(format: "noti_sys_transferred_you".localized, "\(name)")
                    }
                }
            }
            TSCurrentUserInfo.share.unreadCount.systemInfo = content
            TSCurrentUserInfo.share.unreadCount.systemTime = notices.system.first.created_at
        } else {
        }
    }
    // MARK: - 新的未读的数量
    func unreadCountVer2(complete: @escaping (_ model: UserCounts) -> Void) {
        var request = UserNetworkRequest().counts
        request.urlPath = request.fullPathWith(replacers: [])
        RequestNetworkData.share.text(request: request) { [weak self] (result) in
            switch result {
            case .success(let response):
                if let model = response.model {
//                    // 更新一下消息的红点
//                    TSCurrentUserInfo.share.unreadCount.system = model.system
//                    TSCurrentUserInfo.share.unreadCount.like = model.liked
//                    TSCurrentUserInfo.share.unreadCount.comments = model.commented
//                    TSCurrentUserInfo.share.unreadCount.pending = model.pinned
//                    // 更新单独的未审核数量
//                    TSCurrentUserInfo.share.unreadCount.newsCommentPinned = model.newsCommentPinned
//                    TSCurrentUserInfo.share.unreadCount.feedCommentPinned = model.feedCommentPinned
//                    TSCurrentUserInfo.share.unreadCount.groupJoinPinned = model.groupJoinPinned
//                    TSCurrentUserInfo.share.unreadCount.postPinned = model.postPinned
//                    TSCurrentUserInfo.share.unreadCount.postCommentPinned = model.postCommentPinned
//                    TSCurrentUserInfo.share.unreadCount.at = model.at
//                    TSCurrentUserInfo.share.unreadCount.mutual = model.mutual
//                    TSCurrentUserInfo.share.unreadCount.follows = model.following
                    TSCurrentUserInfo.share.unreadCount.isHiddenNoticeBadge = TSCurrentUserInfo.share.unreadCount.allNoticeUnreadCount() <= 0
                    DispatchQueue.main.async {
                        self?.updateTabbarBadge()
                    }
                    complete(response.model!)
                }
            case .failure(_), .error(_):
                break
            }
        }
    }
    // MARK: - 更新tabbar的红点状态
    func updateTabbarBadge(complete: ((Int) -> Void)? = nil) {
        // 更新tabbar红点状态
//        if let currentTC = TSRootViewController.share.currentShowViewcontroller as? TSHomeTabBarController {
//        if let tabVC = TSRootViewController.share.tabbarVC as? TabBarViewController {
//            let tabBar = tabVC.customTabBar
//            let tsUnred = TSCurrentUserInfo.share.unreadCount
//            let imUnred = ChatMessageManager.shared.getIMUnreadCount()
//            let requestCount = ChatMessageManager.shared.getRequestCount(getGroupCount: true)
                      
//            MTPushService.setBadge(tsUnred.allNoticeUnreadCount() + imUnred + requestCount)
//            // 更新桌面applicationIconBadgeNumber
//            UIApplication.shared.applicationIconBadgeNumber = tsUnred.allNoticeUnreadCount() + imUnred + requestCount
//            
//            // 消息
//            if (imUnred + requestCount) > 0 {
//                tabBar.showBadge(.message, (imUnred + requestCount) > 99 ? "99+" : (imUnred + requestCount).stringValue)
//            } else {
//                tabBar.hiddenBadge(.message)
//            }
            // 个人中心 暂时不需要
//            if (tsUnred.system + tsUnred.like + tsUnred.comments + tsUnred.at + tsUnred.follows + tsUnred.pending) > 0 {
//                tabBar.showBadge(.myCenter)
//            } else {
//                tabBar.hiddenBadge(.myCenter)
//            }
            
//            complete?(requestCount)
//        }
    }
    
    func getGroupNotiCount() -> Int {
        let filter = NIMSystemNotificationFilter()
        filter.notificationTypes = [NSNumber(nonretainedObject: NIMSystemNotificationType.teamInvite), NSNumber(nonretainedObject: NIMSystemNotificationType.teamApply)]
        var notif = NIMSDK.shared().systemNotificationManager.fetchSystemNotifications(nil, limit: 20, filter: filter) ?? []
        notif = notif.filter { $0.type.rawValue == 0 || $0.type.rawValue == 2 }
        var uniqueValues = Set<String>()
        notif = notif.filter{ uniqueValues.insert("\($0.targetID)&\($0.sourceID)").inserted }
        return notif.count
    }

    func updateTabbarFeedBadge(show: Bool) {
//        if let currentTC = TSRootViewController.share.currentShowViewcontroller as? TSHomeTabBarController {
//            let tabBar = currentTC.customTabBar
//
//            if show == true {
//                tabBar.showBadge(.feed)
//            } else {
//                tabBar.hiddenBadge(.feed)
//            }
//        }
    }
}
