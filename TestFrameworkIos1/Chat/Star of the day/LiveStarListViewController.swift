//
//  LiveStarListViewController.swift
//  Yippi
//
//  Created by Yong Tze Ling on 02/04/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit
import PusherSwift
import ObjectMapper
import DeepDiff

public let kCellRowHeight: CGFloat = 54.0
public let kCellRowHeightForEvent: CGFloat = 68.0

enum LiveListEntryType {
    case live
    case homepage
    case search
}

class LiveStarListViewController: TSViewController {
    
    var selectedListType: LiveStarListTableType = .daily
    var timer: Timer!
    private var liveType: LiveType = .starOfTheDay
    var pusher: Pusher?
    
    private lazy var liveListHeaderView: LiveStarListHeaderView = LiveStarListHeaderView(frame: CGRect.zero)
    
    public lazy var liveListViewContainer: LiveStarListViewContainer = LiveStarListViewContainer(frame: CGRect.zero).configure {
        $0.extraScrollViewDelegate = self
    }

    public lazy var table: TSTableView = {
        let table = TSTableView(frame: .zero, style: .plain)
        table.separatorColor = UIColor(hex: 0xededed)
        table.separatorInset = .zero
        table.delegate = self
        table.dataSource = self
        table.bounces = false
        table.backgroundColor = .white
        table.showsVerticalScrollIndicator = false
        table.mj_footer = nil
        table.mj_header = nil
        table.register(LiveStarCell.nib(), forCellReuseIdentifier: LiveStarCell.cellIdentifier)
        if #available(iOS 11.0, *) {
            table.insetsContentViewsToSafeArea = true
        }
        return table
    }()
    
    private let titleLabel: UILabel = UILabel().configure {
        $0.applyStyle(.bold(size: 16, color: UIColor.black.withAlphaComponent(0.85)))
    }
    
    private var timeRangeLabel = UILabel().configure {
        $0.text = "Hours Remaining"
        $0.font = UIFont.systemRegularFont(ofSize: 14)
        $0.textColor = .gray
    }
    
    private let timeRangeView: LiveStarButton = LiveStarButton(text: "...", showBackground: false)
        
    private var footerView: UIView = UIView().configure {
        $0.backgroundColor = .white
        $0.dropShadow()
        $0.isUserInteractionEnabled = true
    }
    
    private lazy var tableFooterLabel: UILabel = {
        let footerLabel = UILabel()
        footerLabel.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 50)
        footerLabel.textAlignment = .center
        footerLabel.font = UIFont.systemFont(ofSize: TSFont.SubInfo.mini.rawValue)
        footerLabel.textColor = TSColor.normal.minor
        footerLabel.backgroundColor = .white
        footerLabel.text = "live_slot_ranking_limit".localized
        return footerLabel
    }()

    
    private let headerStackview = UIStackView().configure {
        $0.axis = .vertical
        $0.distribution = .fillEqually
        $0.alignment = .leading
    }
    
    private let headerContainer = UIStackView().configure {
        $0.axis = .vertical
        $0.distribution = .fillProportionally
        $0.alignment = .leading
        $0.spacing = 16
    }
    
    private let timeContainer = UIView().configure {
        $0.backgroundColor = .white
    }

    
    private let headerBanner = UIImageView().configure {
        $0.backgroundColor = .clear
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    private let headerStackviewWrapper = UIStackView().configure {
        $0.axis = .horizontal
        $0.distribution = .fill
        $0.alignment = .leading
        $0.spacing = 8
    }
    
    private var headerLeftIcon: UIImageView = UIImageView().configure { $0.backgroundColor = .clear }
    private let headerView: UIView = UIView().configure { $0.backgroundColor = .white }
    private let separatorLine: UIView = UIView().configure { $0.backgroundColor = UIColor(hex: 0xededed) }
    private let viewMoreView: UIView = UIView()
    private let viewMoreButton: UIButton = UIButton().configure {
        $0.setTitle("global_search_sotd_more".localized, for: .normal)
        $0.setImage(UIImage.set_image(named: "ic_arrow_next"), for: .normal)
        $0.semanticContentAttribute = .forceRightToLeft
        $0.setTarget(self, action: #selector(viewFullList), for: .touchUpInside)
        $0.set(font: UIFont.systemFont(ofSize: 14, weight: .regular))
        $0.tintColor = AppTheme.red
        $0.setTitleColor(AppTheme.red, for: .normal)
    }
    private let searchBottomView: UIStackView = UIStackView().configure {
        $0.axis = .vertical
        $0.distribution = .fill
        $0.alignment = .fill
    }
    
    private let feedId: Int
    private let isHost: Bool
    private var isPortrait: Bool
    
    private var lists: [StarSlotModel] = []
    private var oldLists: [StarSlotModel] = []

    private var hostRankInfo: SlotRankModel? {
        didSet{
            if footerView.superview == nil && self.liveEntryType != .search {
                setupFooterView()
            }
        }
    }
    private let hostInfo: UserInfoModel?
    
    private var iconUrl: String?
    
    private var streamerEventSlot: String = ""
    
    private var liveEntryType: LiveListEntryType
    
    var shouldBroadcast = false

    var onShowUserProfileHandler: ((UserInfoType) -> Void)?
    var onPlayLiveHandler: ((Int) -> Void)?
    var onShowLiveRank: ((Int) -> Void)?
        
    private var rankObject: StarSlotModel? {
        didSet {
            if let object = rankObject {
                self.updateList(with: object)
            }
        }
    }

    private var selectedLanguage: String?
    
    public var extraScrollViewDelegate:TSScrollDelegate?

    init(feedId: Int, hostInfo: UserInfoModel?, isHost: Bool, isPortrait: Bool, type: LiveType = .starOfTheDay, topLeftIcon: String = "", entryType: LiveListEntryType = .live, selectedLanguage: String? = nil) {
        self.feedId = feedId
        self.hostInfo = hostInfo
        self.isHost = isHost
        self.isPortrait = isPortrait
        self.liveType = type
        self.iconUrl = topLeftIcon
        self.liveEntryType = entryType
        self.selectedLanguage = selectedLanguage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if self.liveType == .starOfTheDay {
            updateLiveContainerLayout()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func updateLiveContainerLayout() {
        liveListViewContainer.setNeedsLayout()
        liveListViewContainer.layoutIfNeeded()
                
        let width = liveListViewContainer.scrollView.frame.width

        switch liveListViewContainer.selectedFilterType {
        case .daily:
            liveListViewContainer.scrollView.setContentOffset(CGPoint(x: 0 * width, y: 0), animated: false)
        case .weekly:
            liveListViewContainer.scrollView.setContentOffset(CGPoint(x: 1 * width, y: 0), animated: false)
        case .monthly:
            liveListViewContainer.scrollView.setContentOffset(CGPoint(x: 2 * width, y: 0), animated: false)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .clear
        
        switch self.liveType {
        case .starOfTheDay:
            if liveListViewContainer.superview == nil && liveListHeaderView.superview == nil {
                setupView()
            }
            updateLiveContainerLayout()
        default:
            if table.superview == nil && headerContainer.superview == nil {
                setupView()
            }
        }
    }
    
    func setupView() {
        switch self.liveType {
        case .event:
            setupEventView()
        default:
            liveListHeaderView = LiveStarListHeaderView(frame: CGRect.zero, liveEntryType: liveEntryType, streamerLanguage: selectedLanguage)

            liveListHeaderView.delegate = self

            self.view.addSubview(liveListHeaderView)

            liveListHeaderView.snp.makeConstraints {
                $0.left.right.equalToSuperview()
                $0.top.equalToSuperview().offset(0)
            }

            var prefferedWidth: CGFloat = 0.0
            
            let width: CGFloat = self.presentationController?.presentedView?.frame.width ?? 0.0
            let height: CGFloat = self.presentationController?.presentedView?.frame.height ?? 0.0

            if width > height {
                prefferedWidth = height
            } else {
                prefferedWidth = width
            }

            liveListViewContainer = LiveStarListViewContainer(frame: CGRect.zero, feedId: feedId, liveEntryType: liveEntryType, width: prefferedWidth, hostInfo: self.hostInfo, language: selectedLanguage)
            liveListViewContainer.extraScrollViewDelegate = self
            liveListViewContainer.delegate = self
            
            self.view.addSubview(liveListViewContainer)
            if liveEntryType == .search {
                let bottomPaddingView = UIView()
                self.view.addSubview(searchBottomView)
                searchBottomView.addArrangedSubview(viewMoreView)
                searchBottomView.addArrangedSubview(bottomPaddingView)
                bottomPaddingView.snp.makeConstraints {
                    $0.height.equalTo(20+TSBottomSafeAreaHeight)
                    $0.width.equalToSuperview()
                }

                viewMoreView.snp.makeConstraints {
                    $0.height.equalTo(20)
                    $0.width.equalToSuperview()
                }
                viewMoreView.addSubview(viewMoreButton)
                viewMoreButton.snp.makeConstraints {
                    $0.height.centerX.equalToSuperview()
                    $0.width.equalToSuperview().dividedBy(2)
                }
                searchBottomView.snp.makeConstraints {
                    $0.left.right.bottom.equalToSuperview()
                }

                liveListViewContainer.snp.makeConstraints {
                    $0.top.equalTo(liveListHeaderView.snp.bottom)
                    $0.left.right.equalToSuperview()
                    $0.bottom.equalTo(searchBottomView.snp.top).offset(-15)
                }
            } else {
                liveListViewContainer.snp.makeConstraints {
                    $0.top.equalTo(liveListHeaderView.snp.bottom)
                    $0.left.right.bottom.equalToSuperview()
                }
            }
            onSelectSegmentItem(0)
        }
    }

    @objc private func viewFullList() {
        let rankingHomePageViewController = RankingHomePageViewController()
        rankingHomePageViewController.defaultPageIndex = 0
        
        if self.navigationController != nil {
            self.navigationController?.pushViewController(rankingHomePageViewController, animated: true)
        } else {
            self.present(rankingHomePageViewController.fullScreenRepresentation, animated: true, completion: nil)
        }
    }
    
    private func setupEventView() {
        titleLabel.text = "live_event_ranking".localized

        headerStackview.addArrangedSubview(titleLabel)
        headerStackview.addArrangedSubview(timeRangeView)

        headerStackviewWrapper.addArrangedSubview(headerLeftIcon)
        headerStackviewWrapper.addArrangedSubview(headerStackview)

        headerContainer.addArrangedSubview(headerStackviewWrapper)
        headerContainer.addArrangedSubview(headerBanner)
        headerContainer.addArrangedSubview(separatorLine)

        headerView.addSubview(headerContainer)

        self.view.addSubview(headerView)
        self.view.addSubview(table)
        
        setEventViewConstraint()
        
        separatorLine.makeVisible()
        headerBanner.makeHidden()
        headerLeftIcon.makeHidden()
        
        self.fetchLiveEventList()
    }
    
    private func setEventViewConstraint() {
        headerLeftIcon.snp.makeConstraints {
            $0.height.width.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(0)
        }
        timeRangeView.snp.makeConstraints {
            $0.height.equalTo(25)
            $0.left.equalTo(titleLabel.snp.left).offset(-8)
        }
        
        headerStackviewWrapper.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            if #available(iOS 11, *) {
                $0.right.equalTo(view.safeAreaLayoutGuide.snp.right).offset(-16)
            } else {
                $0.right.equalToSuperview().offset(-16)
            }
        }
        
        headerBanner.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.height.equalTo(headerBanner.snp.width).dividedBy(7)
        }
                
        headerContainer.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview().offset(-16)
        }
        
        separatorLine.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.left.right.equalToSuperview()
        }

        headerView.snp.makeConstraints {
            $0.left.top.right.equalToSuperview()
        }
                
        table.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.top.equalTo(separatorLine.snp.bottom)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.isPortrait {
            self.view.roundCornerWithCorner([.topLeft, .topRight], radius: 10, fillColor: .white)
        }

        if self.liveEntryType == .search { return }
        
        if self.liveType == .starOfTheDay {
            self.liveListViewContainer.dailyList.pusher?.connect()
        }
        
        pusher?.connect()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if self.liveType == .starOfTheDay {
            self.liveListViewContainer.dailyList.pusher?.disconnect()
        }

        pusher?.disconnect()
    }
    
    deinit {
        disposeTimer()

        self.footerView.removeFromSuperview()

        if let livePusher = pusher {
            livePusher.unsubscribe(self.liveType.pusherChannel)
            livePusher.disconnect()
            pusher = nil
        }
    }

    @objc func openInfoPage(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        let webview = TSWebViewController(url: url, type: .defaultType)
        let nav = TSNavigationController(rootViewController: webview)
        self.present(nav.fullScreenRepresentation, animated: true, completion: nil)
    }
    
    private func fetchLiveEventList() {
//        TSLiveNetworkManager().getLiveEventList(feedId, completion: { [weak self] response in
//            
//            defer { self?.table.reloadData() }
//            guard let data = response else {
//                self?.table.show(placeholderView: .network)
//                self?.table.tableFooterView = nil
//                return
//            }
//            
//            if let unrankData = data.slotUnrank {
//                self?.streamerEventSlot = data.streamerSlot
//                self?.hostRankInfo = unrankData
//            }
//            
//            guard let list = data.rankingList, list.count > 0 else {
//                self?.table.show(placeholderView: .empty)
//                self?.table.tableFooterView = nil
//                return
//            }
//            
//            self?.shouldBroadcast = data.broadcastSubscription
//            
//            if let badgeUrl = self?.iconUrl, badgeUrl != "" {
//                self?.headerLeftIcon.sd_setImage(with: URL(string: badgeUrl), completed: nil)
//                self?.headerLeftIcon.makeVisible()
//            } else {
//                self?.headerLeftIcon.makeHidden()
//            }
//            
//            if let imgUrlString = data.imgUrl, let imgUrl = URL(string: imgUrlString), UIApplication.shared.canOpenURL(imgUrl) {
//                self?.headerBanner.sd_setImage(with: imgUrl, completed: nil)
//                self?.headerBanner.addTap(action: { [weak self] (_) in
//                    self?.openInfoPage(urlString: data.link.orEmpty)
//                })
//                self?.headerBanner.makeVisible()
//                self?.separatorLine.makeHidden()
//
//            } else {
//                self?.headerBanner.makeHidden()
//                self?.separatorLine.makeVisible()
//            }
//            
//            self?.lists = list
//            self?.timeRangeView.makeHidden()
//            self?.updateFooter()
//            
//            if self?.shouldBroadcast ?? false {
//                self?.setupPusher()
//            }
//        }) { [weak self] error in
//            self?.showError(message: error?.localizedDescription ?? "network_problem".localized)
//        }
    }
    
    private func setupFooterView() {
        guard let info = self.hostInfo, let slotRankInfo = self.hostRankInfo  else {
            return
        }
        
        var cellHeight = kCellRowHeight
        
        switch self.liveType {
            case .event:
                cellHeight = kCellRowHeightForEvent
            default: break
        }

        if let cell = Bundle.main.loadNibNamed("LiveStarCell", owner: self, options: nil)?.first as? LiveStarCell {
            cell.setupFooterModel(info, slotRankInfo: slotRankInfo, type: self.liveType, timePeriod: self.streamerEventSlot, iconUrl: self.iconUrl.orEmpty, entryType: self.liveEntryType)
            if self.liveEntryType == .live {
                cell.onLiveIndicator.sd_setImage(with: Bundle.main.url(forResource: "blue-v3", withExtension: ".gif"), completed: nil)
            }
            footerView.addSubview(cell.contentView)
            cell.contentView.bindToEdges()
            self.view.addSubview(footerView)
            footerView.snp.makeConstraints {
                $0.left.bottom.right.equalToSuperview()
                $0.height.equalTo(cellHeight + TSBottomSafeAreaHeight)
            }
            
            footerView.addTap { [weak self] _ in
                self?.showNotInRankScoreResultView(model: slotRankInfo)
            }

            cell.avatarView.buttonForAvatar.addAction { [weak self] in
                self?.onShowUserProfileHandler?(info)
            }
            
            table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: cellHeight + TSBottomSafeAreaHeight, right: 0)
        }
    }
        
    private func updateFooter(_ rankModel: SlotRankModel? = nil) {
        if let cell = Bundle.main.loadNibNamed("LiveStarCell", owner: self, options: nil)?.first as? LiveStarCell {
            if self.liveEntryType == .live, cell.onLiveIndicator.animatedImage == nil {
                cell.onLiveIndicator.sd_setImage(with: Bundle.main.url(forResource: "blue-v3", withExtension: ".gif"), completed: nil)
            }
            
            if let model = rankModel {
                guard let info = self.hostInfo else { return }
                cell.setHostModel(info, rank: model, at: model.level, type: self.liveType, iconUrl: self.iconUrl.orEmpty, timePeriod: self.streamerEventSlot)

                footerView.addTap { [weak self] _ in
                    self?.showNotInRankScoreResultView(model: model)
                }

                cell.avatarView.buttonForAvatar.addAction { [weak self] in
                    self?.onShowUserProfileHandler?(info)
                }
            } else {
                if let index = lists.firstIndex(where: { $0.userIdentity == hostInfo?.userIdentity }) {
                    let model = lists[index]
                    cell.setModel(model, at: index + 1, type: self.liveType, iconUrl: self.iconUrl.orEmpty)

                    footerView.addTap { [weak self] _ in
                        self?.showScoreResultView(model)
                    }
                    cell.avatarView.buttonForAvatar.addAction { [weak self] in
                        self?.onShowUserProfileHandler?(model)
                    }
                } else {
                    guard let info = self.hostInfo, let ranking = self.hostRankInfo else { return }
                    cell.setHostModel(info, rank: ranking, at: ranking.level, type: self.liveType, iconUrl: self.iconUrl.orEmpty, timePeriod: self.streamerEventSlot)

                    footerView.addTap { [weak self] _ in
                        self?.showNotInRankScoreResultView(model: ranking)
                    }

                    cell.avatarView.buttonForAvatar.addAction { [weak self] in
                        self?.onShowUserProfileHandler?(info)
                    }
                }
            }
            
            
            footerView.removeAllSubViews()
            footerView.addSubview(cell.contentView)
            cell.contentView.bindToEdges()
        }
    }
    
    fileprivate func showScoreResultView(_ model: StarSlotModel) {
        let isHideGoLiveButton: Bool = model.feedId == feedId || model.status != YPLiveStatus.onlive.rawValue || isHost
        
        let view = LiveScoreResultView(from: .live,type: model.rank?.score == 0 ? .noResult : .ranked, views: model.rank?.views ?? 0, tips: Int(model.rank?.tips ?? 0), score: Int(model.rank?.score ?? 0), isButtonHidden: isHideGoLiveButton, liveType: self.liveType, iconUrlString: self.iconUrl.orEmpty)
        
        let popup = TSAlertController(style: .popup(customview: view))
        
        view.goToLiveButton.addTap { [weak self] _ in
            popup.dismiss { [weak self] in
                self?.disposeTimer()
                
                switch self?.liveEntryType {
                case .homepage, .search:
                    self?.navigateLive(feedId: model.feedId)
                default:
                    self?.onPlayLiveHandler?(model.feedId)
                }
            }
        }

        popup.modalPresentationStyle = .overFullScreen
        self.present(popup, animated: false)
    }
    
    fileprivate func showNotInRankScoreResultView(model: SlotRankModel) {
        var view = LiveScoreResultView(from: .live, type: model.score == 0 ? .noResult : .notRanked, views: model.views, tips: Int(model.tips), score: Int(model.score))

        switch self.liveType {
        case .event:
            view = LiveScoreResultView(from: .live, type: model.score == 0 ? .noResult : .notRanked, views: model.views, tips: Int(model.tips), score: Int(model.score), liveType: .event, iconUrlString: "")
        default: break
        }

        let popup = TSAlertController(style: .popup(customview: view))
        popup.modalPresentationStyle = .overFullScreen
        self.present(popup, animated: false)
    }

    
    override var shouldAutorotate: Bool {
        if self.liveEntryType == .homepage {
            return false
        }
        return !isHost
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return isHost ? (isPortrait ? .portrait : .landscapeLeft) : [.portrait, .landscape]
    }
    
    func updateFrame(_ size: CGSize) {
        self.view.frame.size = size
        self.view.roundCornerWithCorner([.topLeft, .topRight], radius: size.width > size.height ? 0 : 10, fillColor: .white)
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    private func setupPusher() {
        let options = PusherClientOptions(
            host: .cluster("ap1")
        )
        pusher = Pusher(key: TSAppConfig.share.environment.starQuestPusherKey, options: options)
        guard let pusher = pusher else { return }
        pusher.connect()
        let sodChannel = pusher.subscribe(self.liveType.pusherChannel)
        let _ = sodChannel.bind(eventName: self.liveType.pusherEventName, callback: { [weak self] (data) in
            guard let self = self else { return }
            guard let sodData = data as? [String:AnyObject] else { return }
            guard let ranking = sodData["ranking"] as? [String:AnyObject], let userRank = ranking["slot_rank"] as? [String:AnyObject] else { return }
            guard var rankingObj = Mapper<StarSlotModel>().map(JSONObject: ranking), let slotRankObj = Mapper<SlotRankModel>().map(JSONObject: userRank) else { return }
            rankingObj.rank = slotRankObj
            self.rankObject = rankingObj
        })
    }
    
    
    private func updateList(with rankingObject: StarSlotModel) {
        let oldLists = self.lists
        var newLists = self.lists
        
        if let existingDataIndex = newLists.firstIndex(where: { $0.userIdentity == rankingObject.userIdentity }) {
            newLists.remove(at: existingDataIndex)
        }
        newLists.append(rankingObject)
        newLists.sort { $0.rank?.score ?? 0 > $1.rank?.score ?? 0 }
        while newLists.count > 50 {
            newLists.removeLast()
        }
        
        if rankingObject.userIdentity == self.hostInfo?.userIdentity {
            self.hostRankInfo = rankingObject.rank
        }
        self.updateFooter()
        let changes = diff(old: oldLists, new: newLists)
        
        self.table.reload(changes: changes, insertionAnimation: .none, deletionAnimation: .none, replacementAnimation: .none, updateData: { [weak self] in
            self?.lists = newLists
        })
    }
}

extension LiveStarListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kCellRowHeightForEvent
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LiveStarCell.cellIdentifier, for: indexPath) as! LiveStarCell
        
        let model = lists[indexPath.row]
        cell.setEventModel(model, at: indexPath.row + 1, timePeriod: self.streamerEventSlot, iconUrl: self.iconUrl.orEmpty)
        cell.avatarView.buttonForAvatar.addAction { [weak self] in
            self?.onShowUserProfileHandler?(model)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.lists.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = lists[indexPath.row]
        self.showScoreResultView(model)
    }
}

extension LiveStarListViewController: LiveStarListViewContainerDelegate {
    func yesterdayResultString(currentDate: Date) -> String {
        let dateString = currentDate.toFormat("dd MMMM YYYY")
        let finalString = String(format: "sotd_result_of_date".localized, dateString)
        return finalString
    }
    
    func lastWeekResultString(currentDate: Date, slotEndTime: Date) -> String {
        let date1String = currentDate.toFormat("dd")
        let date2String = slotEndTime.toFormat("dd MMMM YYYY")
        let fullDateString = String(format: "%@-%@", date1String, date2String)
        let finalString = String(format: "sotd_result_of_week".localized, fullDateString)
        return finalString
    }
    
    func lastMonthResultString(currentDate: Date) -> String {
        let dateString = currentDate.toFormat("MMMM YYYY")
        let finalString = String(format: "sotd_result_of_month".localized, dateString)
        return finalString
    }
    
    func didSetupFooter(_ model: SlotRankModel) {
        self.hostRankInfo = model
    }
    
    func didUpdateFooter() {
        self.updateFooter()
    }
    
    func didUpdateFooter(_ model: SlotRankModel) {
        self.updateFooter(model)
    }
    
    func selectedFilter(_ model: LiveStarSlotModel, isPassResult: Bool) {
        if isPassResult {
            switch selectedListType {
            case .daily:
                self.liveListHeaderView.timeRangeView.setText(yesterdayResultString(currentDate: model.slotStartTime), image: nil)
            case .weekly:
                self.liveListHeaderView.timeRangeView.setText(lastWeekResultString(currentDate: model.slotStartTime, slotEndTime: model.slotEndTime), image: nil)
            case .monthly:
                self.liveListHeaderView.timeRangeView.setText(lastMonthResultString(currentDate: model.slotStartTime), image: nil)
            }
        } else {
            if model.isSameDate {
                if self.liveEntryType == .search {
                    self.liveListHeaderView.timeRangeView.setText("today".localized, image: nil)
                } else {
                    self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
                        self?.updateTime(currentDate: model.currentDate, endDate: model.slotEndDate, startDate: model.slotStartDayAndMonth)
                    }
                    if let timer = self.timer {
                        RunLoop.current.add(timer, forMode: .common)
                    }
                }
            } else {
                self.liveListHeaderView.timeRangeView.setText(String(format: "live_list_start_at".localized, model.slotStartDate), image: nil)
            }
        }
    }
    
    func selectedFilter(_ model: LiveEventModel, isPassResult: Bool) {
        if isPassResult {
            switch selectedListType {
            case .daily:
                self.liveListHeaderView.timeRangeView.setText(yesterdayResultString(currentDate: model.periodStartTime ?? Date()), image: nil)
            case .weekly:
                self.liveListHeaderView.timeRangeView.setText(lastWeekResultString(currentDate: model.periodStartTime ?? Date(), slotEndTime: model.periodEndTime ?? Date()), image: nil)
            case .monthly:
                self.liveListHeaderView.timeRangeView.setText(lastMonthResultString(currentDate: model.periodStartTime ?? Date()), image: nil)
            }
        } else {
            if model.isSameDate {
                if self.liveEntryType == .search {
                    self.liveListHeaderView.timeRangeView.setText("today".localized, image: nil)
                } else {
                    self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
                        self?.updateTime(currentDate: model.currentDate, endDate: model.periodEndTime ?? Date(), startDate: model.slotStartDayAndMonth)
                    }
                    if let timer = self.timer {
                        RunLoop.current.add(timer, forMode: .common)
                    }
                }
            } else {
                self.liveListHeaderView.timeRangeView.setText(String(format: "live_list_start_at".localized, model.slotStartDate), image: nil)
            }
        }
    }
    
    func presentUserProfileView(userId: Int) {
//        let vc = HomePageViewController(userId: userId)
//        self.present(vc.fullScreenRepresentation, animated: true, completion: nil)
    }
    
    func onPressedUserProfile(_ userModel: UserInfoType) {
        switch (self.liveEntryType){
        case .homepage, .search:
            self.presentUserProfileView(userId: userModel.userIdentity)
        case .live:
            self.onShowUserProfileHandler?(userModel)
        }
    }
    
    func onPressedCell(_ userModel: StarSlotModel) {
        self.showScoreResultView(userModel)
    }
}

class LiveStarButton: UIView {
    
    private let gradientView = TSGradientView(colors: [UIColor(hex: 0x0091fb), UIColor(hex: 0x00bdef)])
    var titleLabel = TSLabel().configure {
        $0.numberOfLines = 0
        $0.preferredMaxLayoutWidth = UIScreen.main.bounds.width
    }
    private let iconImage = UIImageView().configure {
        $0.contentMode = .scaleAspectFit
    }
    
    private(set) var text: String?
    private(set) var image: UIImage?
    
    init(text: String? = nil, image: UIImage? = nil, showBackground: Bool) {
        self.text = text
        self.image = image
        super.init(frame: .zero)
        setup(showBackground: showBackground)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup(showBackground: Bool = true) {
        self.clipsToBounds = true
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if showBackground == true {
            self.addSubview(gradientView)
            gradientView.bindToEdges()
        }
        
        let stackview = UIStackView(arrangedSubviews: [iconImage, titleLabel]).configure {
            $0.axis = .horizontal
            $0.distribution = .fill
            $0.alignment = .center
            $0.spacing = 2
            $0.verticalCompressionResistancePriority = .defaultHigh
            $0.horizontalCompressionResistancePriority = .defaultHigh
        }
        self.addSubview(stackview)
        stackview.snp.makeConstraints {
            $0.left.equalToSuperview().offset(8)
            $0.right.equalToSuperview().offset(-8)
            $0.top.equalToSuperview().offset(4)
            $0.bottom.equalToSuperview().offset(-4)
        }

        titleLabel.textColor = .white
        titleLabel.text = self.text
        titleLabel.sizeToFit()
        
        iconImage.snp.makeConstraints {
            $0.height.equalTo(10)
            $0.width.equalTo(20)
        }
        
        if self.image != nil {
            iconImage.image = self.image
            iconImage.makeVisible()
        } else {
            iconImage.makeHidden()
        }
        
        titleLabel.font = UIFont.systemMediumFont(ofSize: 10)
        self.roundCorner(12.5)
    }
        
    func setText(_ text: String, image: UIImage?, size: CGFloat = 14, color: UIColor = .gray) {
        if text == "" {
            titleLabel.makeHidden()
        } else {
            self.text = text
            titleLabel.text = text
            titleLabel.sizeToFit()
            titleLabel.font = UIFont.systemRegularFont(ofSize: size)
            titleLabel.textColor = color
            // By Kit Foong (if text is not empty set visible)
            titleLabel.makeVisible()
        }
        
        if image != nil {
            self.image = image
            iconImage.image = image
            iconImage.makeVisible()
        } else {
            iconImage.makeHidden()
        }
    }
}


//Live timer countdown
extension LiveStarListViewController {
    @objc func updateTime(currentDate: Date, endDate: Date, startDate: String) {
        let userCalendar = Calendar.current
        switch selectedListType {
        case .daily:
            let timeLeft = userCalendar.dateComponents([.day, .hour, .minute, .second], from: currentDate, to: endDate)
            let countdownString = String(format: "%02ld:%02ld:%02ld", timeLeft.hour!, timeLeft.minute!, timeLeft.second!)
            let timeString = String(format: "live_list_hours_remaining".localized, countdownString)
            self.liveListHeaderView.timeRangeView.setText(timeString, image: nil, size: 12, color: .black)
            timerCheck(currentDate: currentDate, endDate: endDate, startDate: startDate)
        default:
            let timeLeft = userCalendar.dateComponents([.day], from: currentDate, to: endDate)
            let newRemainingTimeText = String(format: "sotd_days_remaining".localized, timeLeft.day?.stringValue ?? "0")
            self.liveListHeaderView.timeRangeView.setText(newRemainingTimeText, image: nil, size: 12, color: .black)
        }
    }
        
    fileprivate func timerCheck(currentDate: Date, endDate: Date, startDate: String) {
        if currentDate >= endDate {
            let timesUp = "00:00:00"
            let endTimeString = String(format: "live_list_hours_remaining".localized, timesUp)
            self.liveListHeaderView.timeRangeView.setText(endTimeString, image: nil)
            disposeTimer()
        }
    }
    
    private func disposeTimer() {
        guard self.timer != nil else {
            return
        }
        self.timer.invalidate()
    }
}

extension LiveStarListViewController: LiveStarListHeaderViewDelegate {
    
    func onShowLiveStarRank() {
        self.dismiss(animated: true) {
            self.onShowLiveRank?(0)
        }
    }
    
    func openStaticInfoPage() {
        guard let url = URL(string: WebViewType.liveRanking.urlString) else { return }
        
        let webview = TSWebViewController(url: url, type: .defaultType)
        let nav = TSNavigationController(rootViewController: webview, availableOrientations: [.portrait])
        self.present(nav.fullScreenRepresentation, animated: true, completion: nil)
    }
    
    func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func onSelectSegmentItem(_ item: Int) {
        // By Kit Foong (set text empty when change tab)
        self.liveListHeaderView.timeRangeView.setText("", image: nil)
        switch item {
        case 1:
            disposeTimer()
            self.selectedListType = .weekly
            liveListViewContainer.setSelectedFilter(filterType: .weekly, requestPassResult: liveListHeaderView.isPastResultSelected)
            liveListHeaderView.timeRangeView.makeVisible()
        case 2:
            disposeTimer()
            self.selectedListType = .monthly
            liveListViewContainer.setSelectedFilter(filterType: .monthly, requestPassResult: liveListHeaderView.isPastResultSelected)
            liveListHeaderView.timeRangeView.makeVisible()
        default:
            disposeTimer()
            self.selectedListType = .daily
            liveListViewContainer.setSelectedFilter(filterType: .daily, requestPassResult: liveListHeaderView.isPastResultSelected)
            liveListHeaderView.timeRangeView.makeVisible()
        }
        
    }
}

extension LiveStarListViewController: TSScrollDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        extraScrollViewDelegate?.scrollViewDidScroll(scrollView)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        extraScrollViewDelegate?.scrollViewWillBeginDragging?(scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        extraScrollViewDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }
}
