//
//  TSConversationTableViewController.swift
//  Thinksns Plus
//
//  Created by lip on 2017/2/18.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  会话列表

import UIKit
import RealmSwift

class TSConversationTableViewController: TSTableViewController {
    var noticeCellModel: [NoticeConversationCellModel]
    weak var superViewController: NewMessageViewController?

    /// 消息页以及子页面的头像尺寸
    let avatarSizeType = AvatarType.width38(showBorderLine: false)

    // MARK: - lifecycle
    init(style: UITableView.Style, model: [NoticeConversationCellModel]) {
        self.noticeCellModel = model
        super.init(style: style)
        self.setupTableView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("不支持xib")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupTableView() {
        tableView.backgroundColor = UIColor.white
        tableView.register(TSConversationTableViewCell.nib(), forCellReuseIdentifier: TSConversationTableViewCell.cellReuseIdentifier)
        tableView.register(NoticeConversationCell.self, forCellReuseIdentifier: "NoticeConversationCell")
        tableView.separatorStyle = .none
        tableView.mj_header = nil
        tableView.mj_footer = nil
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noticeCellModel.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return processNotices(indexPath)
    }

    func processNotices(_ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoticeConversationCell") as! NoticeConversationCell
        cell.model = noticeCellModel[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kTSConversationTableViewCellDefaltHeight
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let didClickCellTitle = noticeCellModel[indexPath.row]
            switch didClickCellTitle.title {
            case "chat_notification_comment".localized:
                EventTrackingManager.instance.track(event: .viewCommentNoti)
                let receiveCommentVC = ReceiveCommentTableVC()
                navigationController?.pushViewController(receiveCommentVC, animated: true)
            case "chat_notification_liked".localized:
                EventTrackingManager.instance.track(event: .viewLikeNoti)
                let receiveLike = ReceiveLikeTableVC()
                navigationController?.pushViewController(receiveLike, animated: true)
            case "review_notificaiton".localized:
                // 需获取审核通知列表 展示哪种类型的审核通知，默认使用动态评论置顶
                let showType: ReceivePendingController.ShowType = TSCurrentUserInfo.share.unreadCount.pendingType
                let pendingVC = ReceivePendingController(showType: showType)
                self.navigationController?.pushViewController(pendingVC, animated: true)
            case "chat_notification_system".localized:
                EventTrackingManager.instance.track(event: .viewSystemNoti)
                let systemNoticeVC = NoticeTableViewController()
                self.navigationController?.pushViewController(systemNoticeVC, animated: true)
            case "chat_notification_tag_me".localized:
                EventTrackingManager.instance.track(event: .viewAtMeNoti)
                let atMeListVC = TSAtMeListVCViewController()
                navigationController?.pushViewController(atMeListVC, animated: true)
            case "chat_notification_team_invitation".localized:
                EventTrackingManager.instance.track(event: .viewTeamInvitationNoti)
                let vc = GroupNotificationTableVC()
                navigationController?.pushViewController(vc, animated: true)
            default:
                assert(false, "点击效果未配置完毕")
            }
            return
        }
    }
}
