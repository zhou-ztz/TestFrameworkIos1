//
//  NoticeTableViewController.swift
//  ThinkSNS +
//
//  Created by lip on 2017/9/4.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  通知视图控制器

import UIKit

class NoticeTableViewController: TSTableViewController {
    /// 数据源
    lazy var dataSource: [NoticeDetailModel] = []
    /// 数据加载数量
    let limit = 15
    /// 父控制器
    var superViewController: Any?
    /// 分页
    var page = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor.white
        title = "msg_tips_notification".localized
        tableView.register(NoticeTableViewCell.self, forCellReuseIdentifier: "NoticeTableViewController")
        tableView.mj_header.beginRefreshing()
        tableView.mj_footer.isHidden = true
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func refresh() {
        var request = NoticeNetworkRequest().notiList
        request.urlPath = request.fullPathWith(replacers: [])
        page = 1
        let parameter: [String : Any] = ["page":page, "type": "system"]
        request.parameter = parameter
        let readGroup = DispatchGroup()
        readGroup.enter()
        RequestNetworkData.share.text(request: request) { [unowned self] (networkResult) in
            self.page += 1
            self.tableView.mj_header.endRefreshing()
            switch networkResult {
            case .error(_):
                self.page -= 1
                self.show(placeholderView: .network)
            case .failure(let response):
                self.page -= 1
                if let message = response.message {
                    self.show(indicatorA: message, timeInterval: 3)
                    return
                }
                self.show(indicatorA: "error_network".localized, timeInterval: 3)
            case .success(let reponse):
                if let data = reponse.model?.data {
                    self.dataSource = data
                }
                if self.dataSource.isEmpty {
                    self.show(placeholderView: .empty)
                } else {
                    self.removePlaceholderViews()
                }
                if let data = reponse.model?.data {
                    if data.count < 15 {
                        self.tableView.mj_footer.isHidden = true
                        self.tableView.mj_footer.endRefreshingWithNoMoreData()
                    } else {
                        self.tableView.mj_footer.isHidden = false
                        self.tableView.mj_footer.resetNoMoreData()
                    }
                }
                
                self.tableView.reloadData()
                readGroup.leave()
            }
        }
        readGroup.notify(queue: .main) { // 当获取完数据成功后,标记该数据已读,移除小红点
            if self.dataSource.isEmpty {
                return
            }
            var request = NoticeNetworkRequest().readAllNoti
            request.urlPath = request.fullPathWith(replacers: [])
            request.urlPath = request.urlPath + "?type=system"
            let parameter: [String : Any] = ["type": "system"]
            request.parameter = parameter

            RequestNetworkData.share.text(request: request, complete: { (_) in
                TSCurrentUserInfo.share.unreadCount.system = 0
                TSCurrentUserInfo.share.unreadCount.isHiddenNoticeBadge = true
                if let messageVC = self.superViewController as? NewMessageViewController {
                    //messageVC.badges[1].isHidden = true
                }
            })
        }
    }

    override func loadMore() {
        var request = NoticeNetworkRequest().notiList
        request.urlPath = request.fullPathWith(replacers: [])

        let parameter: [String: Any] = ["limit": 15, "page": page, "type": "system"]
        request.parameter = parameter
        RequestNetworkData.share.text(request: request) { [unowned self] (networkResult) in
            self.page += 1
            self.tableView.mj_header.endRefreshing()
            switch networkResult {
            case .error(_):
                self.page -= 1
            case .failure(let response):
                self.page -= 1
                if let message = response.message {
                    self.show(indicatorA: message, timeInterval: 3)
                    return
                }
                self.show(indicatorA: "error_network".localized, timeInterval: 3)
            case .success(let reponse):
                if let data = reponse.model?.data {
                    self.dataSource = self.dataSource + data
                }
                if let data = reponse.model?.data {
                    if data.count < 15 {
                        self.tableView.mj_footer.isHidden = true
                        self.tableView.mj_footer.endRefreshingWithNoMoreData()
                    } else {
                        self.tableView.mj_footer.isHidden = false
                        self.tableView.mj_footer.resetNoMoreData()
                    }
                }
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoticeTableViewController", for: indexPath) as! NoticeTableViewCell
        let model = dataSource[indexPath.row]
        cell.selectionStyle = .none

        // 解析系统消息
        var content = ""
        if let type = model.data["type"] as? String {  
            if type == "reward" {
                if let sender = model.data["sender"] as? [String:Any] {
                    if var name = sender["name"] {
                        if let id = sender["id"] {
                            name = LocalRemarkName.getRemarkName(userId: "\(id)", username: nil, originalName: name as? String, label: nil)
                        }
                        content = String(format: "noti_sys_rewarded_you".localized, "\(name)")
                    }
                }
            } else if type == "rebate" {
                if let amount = model.data["amount"] as? Double {
                    content = String(format: "noti_sys_rebate_success".localized, amount.stringValue)
                }
            } else if type == "reward:feeds" {
                if let sender = model.data["sender"] as? [String:Any] {
                    if let name = sender["name"] {
                        content = String(format: "noti_sys_rewarded_your_moment".localized, "\(name)")
                    }
                }
            } else if type == "reward:live" {
                if let sender = model.data["sender"] as? [String:Any] {
                    if let name = sender["name"] {
                        content = String(format: "noti_sys_rewarded_your_live".localized, "\(name)")
                    }
                }
            } else if type == "purchase" {
                if let sender = model.data["sender"] as? [String:Any] {
                    if let name = sender["name"] {
                        content = String(format: "noti_sys_buy_your_moment".localized, "\(name)")
                    }
                }
            } else if type == "user-cash" {
                if let state = model.data["state"] as? String {
                    if state == "rejected" {
                        content = "noti_sys_fail_cash_out".localized
                    } else {
                        content = "noti_sys_success_cash_out".localized
                    }
                }
            } else if type == "pinned:feeds" {
                if let state = model.data["state"] as? String {
                    if state == "rejected" {
                        content = "noti_sys_request_pin_top_rejected".localized
                    } else if state == "admin" {
                        content = "noti_sys_admin_set_pin_top".localized
                    } else {
                        content = "noti_sys_request_pin_top_approved".localized
                    }
                }
            } else if type == "user-currency:cash" {
                if let state = model.data["state"] as? String {
                    if state == "rejected" {
                        if let contentt = model.data["contents"] as? String {
                            content = "noti_sys_cash_out_fail_reason".localized + "\(contentt)"
                        } else {
                            content = "noti_sys_cash_out_rejected".localized
                        }
                    } else {
                        content = "noti_sys_cash_out_approved".localized
                    }
                }
            } else if type == "reward:news" {
                if let news = model.data["news"] as? [String:Any] {
                    if let sender = model.data["sender"] as? [String:Any] {
                        if let sendername = sender["name"], let newsname = news["title"], let amount = model.data["amount"], let unit = model.data["unit"] {
                            content = "noti_sys_your_event".localized + "《\(newsname)》" + String(format: "noti_sys_event_rewarded".localized , "\(sendername)", "\(amount)", "\(unit)")
                        }
                    }
                }
            } else if type == "report" {
                content = "noti_sys_report_action_took".localized
                if let state = model.data["state"] as? String, let contentt = model.data["subject"] as? String {
                    if state == "rejected" {
                        if let resourceData = model.data["resource"] as? [String:Any], let remark = resourceData["remark"] as? String {
                            content = String(format: "noti_sys_report_on_user_action_rejected".localized, remark)
                        }
                    } else {
                        if let resourceData = model.data["resource"] as? [String:Any], let typeS = resourceData["type"] as? String {
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
            } else if type == "user-certification" {
                if let state = model.data["state"] as? String {
                    if state == "rejected" {
                        if let contentt = model.data["contents"] as? String {
                            content = String(format: "noti_sys_request_authentication_rejected".localized , "\(contentt)")
                        } else {
                            content = "noti_sys_authentication_rejected".localized
                        }
                    } else if state == "bank_passed" {
                        content = "noti_sys_request_bank_approved".localized
                    } else if state == "bank_rejected" {
                        if let contentt = model.data["contents"] as? String {
                            content = String(format: "noti_sys_request_bank_rejected".localized , "\(contentt)")
                        } else {
                            content = "noti_sys_request_bank_rejected".localized
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
                if let sender = model.data["sender"] as? [String:Any], let name = sender["name"] as? String {
                    content = String(format: "noti_sys_rewarded_your_answer".localized, "\(name)")
                }
            } else if type == "qa:question-topic:accept" {
                if let topicData = model.data["topic"] as? [String:Any], let name = topicData["name"] as? String {
                    content = String(format:"noti_sys_topic_creation_approved".localized, "\(name)")
                }
            } else if type == "qa:invitation" {
                if let question = model.data["question"] as? [String:Any] {
                    if let sender = model.data["sender"] as? [String:Any] {
                        if let sendername = sender["name"], let questionname = question["subject"] {
                            content = String(format: "noti_sys_invite_you_answer".localized,"\(sendername)","\(questionname)")
                        }
                    }
                }
            } else if type == "qa:question-topic:reject" {
                if let topic = model.data["topic_application"] as? [String:Any], let name = topic["name"] {
                    content = String(format:"noti_sys_topic_rejected".localized, "\(name)")
                }
            } else if type == "qa:question-topic:passed" {
                if let topic = model.data["topic_application"] as? [String:Any], let name = topic["name"] {
                    content = String(format:"noti_sys_topic_approved".localized, "\(name)")
                }
            } else if type == "pinned:feed/comment" {
                if let comment = model.data["comment"] as? [String:Any] {
                    if let name = comment["contents"] {
                        if let state = model.data["state"] as? String {
                            if state == "rejected" {
                                content = String(format: "noti_sys_moment_comment_pin_rejected".localized, "\(name)")
                            } else {
                                content = String(format: "noti_sys_moment_comment_pin_approved".localized, "\(name)")
                            }
                        }
                    }
                }
            } else if type == "pinned:news/comment" {
                if let comment = model.data["comment"] as? [String:Any] {
                    if let news = model.data["news"] as? [String:Any] {
                        if let commentname = comment["contents"], let newsname = news["title"] {
                            if let state = model.data["state"] as? String {
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
                if let state = model.data["state"] as? String {
                    if state == "rejected" {
                        content = "noti_sys_comment_pin_rejected".localized
                    } else {
                        content = "noti_sys_comment_pin_approved".localized
                    }
                }
            } else if type == "group:post-pinned" {
                if let post = model.data["post"] as? [String:Any] {
                    if let name = post["title"] {
                        if let state = model.data["state"] as? String {
                            if state == "rejected" {
                                content = String(format: "noti_sys_post_pin_rejected".localized, "\(name)")
                            } else {
                                content = String(format: "noti_sys_post_pin_approved".localized, "\(name)")
                            }
                        }
                    }
                }
            } else if type == "group:join" {
                if let group = model.data["group"] as? [String:Any], let groupname = group["name"] {
                    if let state = model.data["state"] as? String {
                        if state == "rejected" {
                            content = String(format: "noti_sys_join_group_rejected".localized, "\(groupname)")
                        } else {
                            content = String(format: "noti_sys_join_group_approved".localized, "\(groupname)")
                        }
                    } else {
                        if let user = model.data["user"] as? [String:Any], let username = user["name"] {
                            content = String(format: "noti_sys_request_join_group".localized, "\(username)", "\(groupname)")
                        }
                    }
                }
            } else if type == "group:transform" {
                content = "noti_sys_transfer_group_to_you".localized
                if let group = model.data["group"] as? [String:Any], let groupname = group["name"], let user = model.data["user"] as? [String:Any], let username = user["name"] {
                    content = String(format: "noti_sys_user_transfer_group_to_you".localized, "\(username)","\(groupname)")
                }
            } else if type == "group:send-comment-pinned" {
                if let post = model.data["post"] as? [String:Any] {
                    if let title = post["title"] {
                        content = String(format: "noti_sys_user_request_pin_comment_your_post".localized, "\(title)")
                    }
                }
            } else if type == "group:post-reward" {
                if let sender = model.data["sender"] as? [String:Any], let sendername = sender["name"] as? String {
                    if let post = model.data["post"] as? [String:Any], let postname = post["title"] as? String {
                        content = String(format:"noti_sys_rewarded_your_post".localized, "\(sendername)","\(postname)")
                    }
                }
            } else if type == "group:report_post" {
                if let sender = model.data["sender"] as? [String:Any], let sendername = sender["name"] as? String, let post = model.data["post"] as? [String:Any], let postname = post["title"] as? String, let group = model.data["group"] as? [String:Any], let groupName = group["name"] as? String {
                    content = String(format: "noti_sys_report_post_under_your_group".localized ,"\(sendername)", "\(groupName)", "\(postname)")
                }
            } else if type == "group:report" {
                content = "noti_sys_group_content_reported_action_took".localized
                if let state = model.data["state"] as? String, let contentt = model.data["report"] as? String {
                    if state == "pass" {
                        content = String(format: "noti_sys_group_content_reported_approved".localized, "\(contentt)")
                    } else {
                        content = String(format: "noti_sys_group_content_reported_rejected".localized, "\(contentt)")
                    }
                } else {
                    if let state = model.data["state"] as? String {
                        if state == "pass" {
                            content = "noti_sys_group_reported_action_took".localized
                        } else {
                            content = "noti_sys_group_reported_rejected".localized
                        }
                    }
                }
            } else if type == "group:menbers" {
                if let _ = model.data["group"] as? [String:Any], let message = model.data["message"] as? String {
                    content = message
                }
            } else if type == "qa:question-excellent:accept" {
                content = "noti_sys_question_featured".localized
            } else if type == "qa:question-excellent:reject" {
                content = "noti_sys_question_featured_rejected".localized
            } else if type == "group:pinned-admin" {
                if let message = model.data["message"] as? String {
                    content = message
                } else {
                    content = "noti_sys_post_pinned_by_admin".localized
                }
            } else if type == "group:report-comment" {
                /// x举报了你的圈子[xx]下的帖子[xxx]的评论[xxxx]
                if let sender = model.data["sender"] as? [String:Any], let sendername = sender["name"] as? String, let post = model.data["post"] as? [String:Any], let postname = post["title"] as? String, let group = model.data["group"] as? [String:Any], let groupName = group["name"] as? String, let comment = model.data["comment"] as? [String:Any], let contents = comment["contents"] as? String {
                    content = String(format: "noti_sys_report_comment_post_under_your_group".localized, "\(sendername)", "\(groupName)", "\(postname)","\(contents)")
                }
            } else if type == "group:report-post" {
                /// x举报了你的圈子[xx]下的帖子[xxx]
                if let sender = model.data["sender"] as? [String:Any], let sendername = sender["name"] as? String, let post = model.data["post"] as? [String:Any], let postname = post["title"] as? String, let group = model.data["group"] as? [String:Any], let groupName = group["name"] as? String {
                    content = String(format: "noti_sys_report_post_under_your_group".localized ,"\(sendername)", "\(groupName)", "\(postname)")
                }
            } else if type == "transfer:yipps" {
                if let sender = model.data["sender"] as? [String:Any], let sendername = sender["name"] as? String {
                    content = String(format: "noti_sys_transferred_you".localized ,"\(sendername)")
                }
            }
        }
        
        cell.contentLabel.text = content
        cell.createdDateLabel.text = TSDate().dateString(.normal, nDate: model.created_at)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        let model = dataSource[indexPath.row]

        // 解析系统消息
        if let type = model.data["type"] as? String {
            if type == "reward" {
                if let sender = model.data["sender"] as? [String:Any], let id = sender["id"] as? Int {
//                    let vc = HomePageViewController(userId: id)
//                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else if type == "reward:feeds" {
                if let feed_id = model.data["feed_id"] as? Int {
                    let detailVC = FeedInfoDetailViewController(feedId: feed_id, onToolbarUpdated: nil)
                    self.navigationController?.pushViewController(detailVC, animated: true)
                }
            } else if type == "rebate" {
//                let vc = WalletHistoryViewController()
//                self.navigationController?.pushViewController(vc, animated: true)
            } else if type == "user-certification" {
                // do nothing here
            } else if type == "pinned:feed/comment" {
                let pendingVC = ReceivePendingController(showType: .momentCommentTop)
                self.navigationController?.pushViewController(pendingVC, animated: true)
            } else if type == "pinned:news/comment" {
                let pendingVC = ReceivePendingController(showType: .newsCommentTop)
                self.navigationController?.pushViewController(pendingVC, animated: true)
            } else if type == "purchase" {
                return
            } else if type == "user-cash" {
                return
            } else if type == "pinned:feeds" {
                if let feedData = model.data["feed"] as? [String:Any], let feed_id = feedData["id"] as? Int {
                    let detailVC = FeedInfoDetailViewController(feedId: feed_id, onToolbarUpdated: nil)
                    self.navigationController?.pushViewController(detailVC, animated: true)
                }
            } else if type == "report" {
                if let resourceData = model.data["resource"] as? [String:Any], let typeS = resourceData["type"] as? String, let tagetId = resourceData["id"] as? Int {
                    if typeS == "users" {
//                        let userHome = HomePageViewController(userId: tagetId)
//                        self.navigationController?.pushViewController(userHome, animated: true)
                    } else if typeS == "feed_topics" {
                        let topicDetail = TopicPostListVC(groupId: tagetId)
                        self.navigationController?.pushViewController(topicDetail, animated: true)
                    } else if typeS == "comments" {
                        return
                    } else if typeS == "feeds" {
                        let detailVC = FeedInfoDetailViewController(feedId: tagetId, onToolbarUpdated: nil)
                        self.navigationController?.pushViewController(detailVC, animated: true)
                    }
                }
            } else if type == "transfer:yipps" {
                if let sender = model.data["sender"] as? [String:Any], let id = sender["id"] as? Int {
//                    let userHome = HomePageViewController(userId: id)
//                    self.navigationController?.pushViewController(userHome, animated: true)
                }
            }
        }
    }
}
