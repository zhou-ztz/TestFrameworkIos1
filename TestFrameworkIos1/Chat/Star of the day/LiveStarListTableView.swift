//
//  LiveStarListTableView.swift
//  Yippi
//
//  Created by CC Teoh on 23/08/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit
import SnapKit
import PusherSwift
import DeepDiff
import ObjectMapper
import Combine

protocol LiveStarListTableViewDelegate: class {
    func onPressUserProfile(_ userModel: UserInfoType)
    func onPressCell(_ userModel: StarSlotModel)
    func willSetupFooter(_ model: SlotRankModel)
    func willUpdateFooter()
    func willUpdateFooter(_ model: SlotRankModel)
    func pusherUpdateDataSource(_ object: StarSlotModel)
}

class StarLiveQueue<T>: NSObject, QueueTaskProtocol {
    var model: StarSlotModel?
    var executable: (() -> Future<T, Error>)
    var priority: TaskPriority = .normal
    
    init(model: StarSlotModel, executable: @escaping (() -> Future<T, Error>), priority: TaskPriority = .normal, isExecuting: Bool = false) {
        self.model = model
        self.executable = executable
        self.priority = priority
    }
}

class LiveStarListTableView: UIView {
    var rankObject: StarSlotModel? {
        didSet {
            if let object = rankObject {
                self.delegate?.pusherUpdateDataSource(object)
            }
        }
    }
    
    weak var delegate: LiveStarListTableViewDelegate?
    
    var hostInfo: UserInfoModel?
    
    var pusher: Pusher?

    private var pusherChannelName: String = "score-update"
    
    private var shouldBroadcast = false
    
    var feedId: Int?
    
    private var firstView = RankingFirstThreeView(liveStarPlace: .second).configure {
        $0.backgroundColor = .clear
    }
    
    private var secondView = RankingFirstThreeView(liveStarPlace: .first).configure {
        $0.backgroundColor = .clear
    }
    
    private var thirdView = RankingFirstThreeView(liveStarPlace: .third).configure {
        $0.backgroundColor = .clear
    }
    
    public var tableHeaderBottomLabel = UILabel().configure {
        $0.font = UIFont.systemRegularFont(ofSize: 12)
        $0.textColor = .gray
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    private var firstThreeViewContainer = UIView()
    
    private var tableHeaderContainer = UIView().configure {
        $0.backgroundColor = .white
    }
    
    private var firstThreeViewWrapper = UIStackView().configure {
        $0.backgroundColor = .clear
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.alignment = .fill
        $0.spacing = 6
    }
    private var liveFilterType: LiveStarListTableType
    private var liveEntryType: LiveListEntryType
    private var topThreeLists: [StarSlotModel] = [] {
        didSet {
            updateFirstThreeData(topThreeLists)
        }
    }
    private var lists: [StarSlotModel] = []
    private var oldLists: [StarSlotModel] = []
    
    public var table = TSTableView().configure {
        $0 = TSTableView(frame: .zero, style: .grouped)
        $0.separatorColor = UIColor(hex: 0xededed)
        $0.separatorInset = .zero
        $0.bounces = false
        $0.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: CGFloat.leastNormalMagnitude))
        $0.backgroundColor = .white
        $0.showsVerticalScrollIndicator = false
        $0.mj_footer = nil
        $0.mj_header = nil
        $0.register(LiveStarCell.nib(), forCellReuseIdentifier: LiveStarCell.cellIdentifier)
        if #available(iOS 11.0, *) {
            $0.insetsContentViewsToSafeArea = true
        }
    }

    var roomInfoLanguage: String?
    
    private var queue: WorkPoolQueue<Bool, StarLiveQueue<Bool>> = WorkPoolQueue<Bool, StarLiveQueue<Bool>>()
    
    private lazy var starLivePool: WorkerPool<Bool, StarLiveQueue<Bool>> = {
        return WorkerPool<Bool, StarLiveQueue<Bool>>(queue: queue, maxWorker: 1)
    }()
    
    private var taskQueue: [StarLiveQueue<Bool>] {
        return queue.tasks
    }
    
    public var extraScrollViewDelegate:TSScrollDelegate?
    
    init(frame: CGRect, liveFilterType: LiveStarListTableType, liveEntryType: LiveListEntryType) {
        self.liveFilterType = liveFilterType
        self.liveEntryType = liveEntryType
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        setupTableView()
        
        addSubview(table)
        
        table.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            
            var width = UIScreen.main.bounds.width
            let height = UIScreen.main.bounds.height
            
            if width > height
            {
                width = height
            }

            make.width.equalTo(width)
        }
        
        updateInfoText(isPassedResult: false)
        
        firstThreeViewContainer.backgroundColor = liveEntryType == .search ? .clear : UIColor(hex: 0xF4FBFF)
    }
    
    deinit {
        if let livePusher = pusher {
            livePusher.unsubscribe(pusherChannelName)
            livePusher.disconnect()
            pusher = nil
        }
    }
    
    private func setupPusher() {
        let options = PusherClientOptions(
            host: .cluster("ap1")
        )
        pusher = Pusher(key: TSAppConfig.share.environment.starQuestPusherKey, options: options)
        guard let pusher = pusher else { return }
        pusher.connect()
        if let language = roomInfoLanguage {
            pusherChannelName = "score-update-" + language
        }
        let sodChannel = pusher.subscribe(pusherChannelName)
        let _ = sodChannel.bind(eventName: pusherChannelName, callback: { [weak self] (data) in
            guard let self = self else { return }
            guard let sodData = data as? [String:AnyObject] else { return }
            guard let ranking = sodData["ranking"] as? [String:AnyObject], let userRank = ranking["slot_rank"] as? [String:AnyObject] else { return }
            guard var rankingObj = Mapper<StarSlotModel>().map(JSONObject: ranking), let slotRankObj = Mapper<SlotRankModel>().map(JSONObject: userRank) else { return }
            rankingObj.rank = slotRankObj
            self.rankObject = rankingObj
        })
    }
    
    public func updateInfoText(isPassedResult: Bool, month: Date? = Date()) {
        switch self.liveFilterType {
        case .daily:
            if isPassedResult {
                tableHeaderBottomLabel.text = "sotd_yesterday_ranking_info_text".localized
            } else {
                tableHeaderBottomLabel.text = ""
            }
        case .weekly:
            if isPassedResult {
                tableHeaderBottomLabel.text = "sotd_last_week_ranking_info_text".localized
            } else {
                tableHeaderBottomLabel.text = "sotd_7_days_ranking_info_text".localized
            }
        case .monthly:
            if isPassedResult {
                tableHeaderBottomLabel.text = String(format: "sotd_last_month_ranking_info_text".localized, (month ?? Date()).toFormat("MMMM yyyy"))
            } else {
                tableHeaderBottomLabel.text = "sotd_30_days_ranking_info_text".localized
            }
        }
    }
    
    func updateList(with object: StarSlotModel) {
        let task = StarLiveQueue(model: object,
                                 executable: { () -> Future<Bool, Error> in
                                    return self.processUpdateList(with: object)
        }, priority: .normal)
        queue.enqueue(task: task)
        
        starLivePool.startTakingJob()
    }
    
    func processUpdateList(with object: StarSlotModel) -> Future<Bool, Error> {
        
        var combinedList = self.topThreeLists + self.lists as [StarSlotModel]
        let oldLists = self.lists

        return Future() { promise in
            guard combinedList.count > 0 else { return }
            
            if let existingTopThreeDataIndex = combinedList.firstIndex(where: { $0.userIdentity == object.userIdentity }) {
                combinedList.remove(at: existingTopThreeDataIndex)
            }
            combinedList.append(object)
            combinedList.sort { $0.rank?.score ?? 0 > $1.rank?.score ?? 0 }
            while combinedList.count > 50 {
                combinedList.removeLast()
            }
            
            self.topThreeLists = Array(combinedList.prefix(3)) as [StarSlotModel]
            let newList = Array(combinedList.dropFirst(3)) as [StarSlotModel]

            DispatchQueue.main.async { [weak self] in
                if object.userIdentity == self?.hostInfo?.userIdentity, let rank = object.rank {
                    self?.delegate?.willSetupFooter(rank)
                }
                
                self?.delegate?.willUpdateFooter()
                
                let changes = diff(old: oldLists, new: newList)
                UIView.performWithoutAnimation { [weak self] in
                    self?.table.reload(changes: changes, insertionAnimation: .none, deletionAnimation: .none, replacementAnimation: .none, updateData: {
                        self?.lists = newList
                    }, completion: { [weak self] (success) in
                        guard let self = self else { return }
                        if let updatedRowIndex = self.lists.firstIndex(where: { $0.userIdentity == object.userIdentity }) {
                            let updateRowStart = max(0, updatedRowIndex - 2)
                            let updateRowEnd = min(self.lists.count - 1, updatedRowIndex + 2)
                            for rowIndexToUpdate in updateRowStart..<updateRowEnd {
                                if let updatedCell = self.table.cellForRow(at: IndexPath(row: rowIndexToUpdate, section: 0)) as? LiveStarCell {
                                    updatedCell.setModel(self.lists[rowIndexToUpdate], at: rowIndexToUpdate + 4)
                                }
                            }
                        }
                        promise(.success(true))
                    })
                }
            }
            
        }
    }
    
    func updateNonDailyList(with object: StarSlotModel) {
        let combinedList = self.topThreeLists + self.lists as [StarSlotModel]
        
        guard let _ = combinedList.first(where: { $0.userIdentity == object.userIdentity }), let existingObjectIndex = combinedList.firstIndex(where: { $0.userIdentity == object.userIdentity }), combinedList.count > 0 else {
            return
        }
        
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: existingObjectIndex, section: 0)
            let isVisible = self.table.indexPathsForVisibleRows?.contains{$0 == indexPath}
            if let v = isVisible, v == true {
                self.table.reloadRows(at: [indexPath], with: .none)
            }
        }
    }

    
    func fetchDailyDataWithoutId(selectedLanguage: String? = nil, completion: @escaping (LiveStarSlotModel?) -> Void) {
        var topThreeeSlot = 0
//        TSLiveNetworkManager().getSlotListWithoutId(selectedLanguage: selectedLanguage, completion: { [weak self] response in
//            defer {
//                self?.table.reloadData()
//            }
//            guard let self = self else {
//                return
//            }
//            guard let data = response else {
//                self.showPlaceholder()
//                self.table.tableFooterView = nil
//                self.clearRankingList()
//                return
//            }
//            
//            guard let list = data.slotList, list.count > 0 else {
//                self.showPlaceholder()
//                self.table.tableFooterView = nil
//                self.clearRankingList()
//                completion(data)
//                return
//            }
//            
//            self.table.removePlaceholderViews()
//            
//            if let uid = TSCurrentUserInfo.share.userInfo?.userIdentity, let index = list.firstIndex(where: { $0.userIdentity == uid }), let rankModel = list[index].rank {
//                self.delegate?.willSetupFooter(rankModel)
//            }
//            
//            for shortlisted in list.prefix(3) {
//                if let rank = shortlisted.rank, rank.score != 0 {
//                    topThreeeSlot += 1
//                }
//            }
//            
//            self.topThreeLists = Array(list.prefix(topThreeeSlot)) as [StarSlotModel]
//            
//            self.lists = Array(list.dropFirst(topThreeeSlot)) as [StarSlotModel]
//            
//            if self.lists.count == 0 {
//                self.showPlaceholder()
//            }
//            
//            if self.liveEntryType == .search {
//                self.lists = Array(self.lists.prefix(3)) as [StarSlotModel]
//                completion(data)
//                return
//            }
//            
//            self.shouldBroadcast = data.broadcastSubscription
//            
//            if data.broadcastSubscription {
//                self.setupPusher()
//            }
//            
//            self.table.removePlaceholderViews()
//            completion(data)
//            
//        }) { [weak self] error in
//            self?.parentViewController?.showError(message: error?.localizedDescription ?? "network_problem".localized)
//        }
    }
    
    
    func fetchDailyData(completion: @escaping (LiveStarSlotModel?) -> Void) {
        guard let feedId = feedId else {
            return
        }
        
        var topThreeeSlot = 0

//        let selectedLanguage = UserDefaults.selectedFilterLanguage
//        TSLiveNetworkManager().getSlotList(feedId, selectedLanguage: selectedLanguage, completion: { [weak self] response in
//            defer {
//                self?.table.reloadData()
//            }
//            guard let data = response else {
//                self?.showPlaceholder()
//                self?.table.tableFooterView = nil
//                self?.clearRankingList()
//                return
//            }
//            
//            if let unrankData = data.slotUnrank {
//                self?.delegate?.willSetupFooter(unrankData)
//            }
//            
//            guard let list = data.slotList, list.count > 0 else {
//                self?.showPlaceholder()
//                self?.table.tableFooterView = nil
//                self?.clearRankingList()
//                return
//            }
//            
//            for shortlisted in list.prefix(3) {
//                if let rank = shortlisted.rank, rank.score != 0 {
//                    topThreeeSlot += 1
//                }
//            }
//            
//            self?.topThreeLists = Array(list.prefix(topThreeeSlot)) as [StarSlotModel]
//            
//            self?.lists = Array(list.dropFirst(topThreeeSlot)) as [StarSlotModel]
//            
//            if self?.lists.count ?? 0 < 1 {
//                self?.showPlaceholder()
//            }
//            
//            self?.shouldBroadcast = data.broadcastSubscription
//            
//            if data.broadcastSubscription {
//                self?.setupPusher()
//            }
//            
//            self?.table.removePlaceholderViews()
//            completion(data)
//        }) { [weak self] error in
//            self?.parentViewController?.showError(message: error?.localizedDescription ?? "network_problem".localized)
//        }
    }
    
    private func clearRankingList() {
        self.topThreeLists = []
        self.lists = []
    }
    
    func fetchData(with timePeriod: String = "7", requestPassResult: Bool = false, completion: @escaping (LiveEventModel?) -> Void) {
        guard let feedId = feedId else {
            return
        }
        var periodType: Int = requestPassResult ? -1 : 0
        var topThreeeSlot = 0

//        let selectedLanguage = roomInfoLanguage
//        TSLiveNetworkManager().getTimePeriodSlotList(feedId, days: timePeriod, periodType: periodType, selectedLanguage: selectedLanguage, completion: { [weak self] response in
//            defer { self?.table.reloadData() }
//            guard let data = response else {
//                self?.showPlaceholder()
//                self?.table.tableFooterView = nil
//                self?.clearRankingList()
//                completion(nil)
//                return
//            }
//            
//            guard let list = data.rankingList, list.count > 0 else {
//                self?.showPlaceholder()
//                self?.table.tableFooterView = nil
//                self?.clearRankingList()
//                completion(nil)
//                return
//            }
//            
//            if let unrank = data.slotUnrank {
//                self?.delegate?.willUpdateFooter(unrank)
//            }
//            
//            for shortlisted in list.prefix(3) {
//                if let rank = shortlisted.rank, rank.score != 0 {
//                    topThreeeSlot += 1
//                }
//            }
//            
//            self?.topThreeLists = Array(list.prefix(topThreeeSlot)) as [StarSlotModel]
//            
//            self?.lists = Array(list.dropFirst(topThreeeSlot)) as [StarSlotModel]
//            
//            if self?.lists.count ?? 0 < 1 {
//                self?.showPlaceholder()
//            }
//            
//            self?.table.removePlaceholderViews()
//            completion(data)
//        }) { [weak self] error in
//            self?.parentViewController?.showError(message: error?.localizedDescription ?? "network_problem".localized)
//            completion(nil)
//        }
    }
    
    func fetchDataWithoutId(with timePeriod: String = "7", requestPassResult: Bool = false, completion: @escaping (LiveEventModel?) -> Void) {
        var topThreeeSlot = 0
        var periodType: Int = requestPassResult ? -1 : 0

        let selectedLanguage = roomInfoLanguage
//        TSLiveNetworkManager().getTimePeriodSlotListWithoutId(timePeriod, periodType: periodType, selectedLanguage: selectedLanguage, completion: { [weak self] response in
//            defer { self?.table.reloadData() }
//            guard let data = response else {
//                self?.showPlaceholder()
//                self?.table.tableFooterView = nil
//                self?.clearRankingList()
//                completion(nil)
//                return
//            }
//            
//            guard let list = data.rankingList, list.count > 0 else {
//                self?.showPlaceholder()
//                self?.table.tableFooterView = nil
//                self?.clearRankingList()
//                completion(nil)
//                return
//            }
//            
//            if let unrank = data.slotUnrank {
//                self?.delegate?.willUpdateFooter(unrank)
//            }
//            
//            for shortlisted in list.prefix(3) {
//                if let rank = shortlisted.rank, rank.score != 0 {
//                    topThreeeSlot += 1
//                }
//            }
//            
//            self?.topThreeLists = Array(list.prefix(topThreeeSlot)) as [StarSlotModel]
//            
//            self?.lists = Array(list.dropFirst(topThreeeSlot)) as [StarSlotModel]
//            
//            if self?.lists.count ?? 0 < 1 {
//                self?.showPlaceholder()
//            }
//            
//            self?.table.removePlaceholderViews()
//            completion(data)
//        }) { [weak self] error in
//            self?.parentViewController?.showError(message: error?.localizedDescription ?? "network_problem".localized)
//            completion(nil)
//        }
    }
    
    private func setupTableView() {
        table.delegate = self
        table.dataSource = self
        table.estimatedSectionHeaderHeight = CGFloat.leastNormalMagnitude
        table.estimatedSectionFooterHeight = CGFloat.leastNormalMagnitude
        table.sectionFooterHeight = CGFloat.leastNormalMagnitude
        table.sectionHeaderHeight = UITableView.automaticDimension
        table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kCellRowHeight, right: 0)
    }
    
    private func showPlaceholder() {
        self.table.show(placeholderView: .custom(image: UIImage.set_image(named: "icLiveListEmptyPlaceholder"), text: "sotd_empty_list_placeholder_text".localized), theme: .white, margin: self.tableHeaderContainer.height, height: self.table.height - self.tableHeaderContainer.height)
    }
    
    private func updateFirstThreeData(_ models: [StarSlotModel]) {
        [secondView, firstView, thirdView].enumerated().forEach { (index, view) in
            if index < models.count {
                DispatchQueue.main.async {
                    view.updateModel(models[index])
                    
                    view.statusView.addTap(action: { [weak self] (_) in
                        self?.delegate?.onPressCell(models[index])
                    })
                    
                    view.nameLabel.addTap(action: { [weak self] (_) in
                        self?.delegate?.onPressUserProfile(models[index])
                    })
                    
                    view.resultView.addTap(action: { [weak self] (_) in
                        self?.delegate?.onPressCell(models[index])
                    })
                    
                    view.avatarView.buttonForAvatar.addAction { [weak self] in
                        self?.delegate?.onPressUserProfile(models[index])
                    }
                }
            }
            else {
                DispatchQueue.main.async {
                    view.emptyModel()
                }
            }
        }
    }
    
    private func sizeItemToFit(view: UIView?) -> CGSize {
        guard let view = view else {
            return CGSize.zero
        }
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        let size = CGSize(width: view.bounds.width, height: view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height)
        
        return size
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        firstThreeViewContainer.addBottomRoundedEdge(curvedPercent: 30, width: self.parentViewController?.view.frame.width ?? UIScreen.main.bounds.height / 2)
    }
    
    
    private func addHeaderView() -> UIView? {
        
        firstThreeViewWrapper.addArrangedSubview(firstView)
        firstThreeViewWrapper.addArrangedSubview(secondView)
        firstThreeViewWrapper.addArrangedSubview(thirdView)
        
        firstThreeViewContainer.addSubview(firstThreeViewWrapper)
        
        firstView.snp.makeConstraints {
            $0.height.equalTo(sizeItemToFit(view: firstView).height)
            $0.width.equalTo(sizeItemToFit(view: firstView).width)
        }
        secondView.snp.makeConstraints {
            $0.height.equalTo(sizeItemToFit(view: secondView).height)
            $0.width.equalTo(sizeItemToFit(view: secondView).width)
        }
        thirdView.snp.makeConstraints {
            $0.height.equalTo(sizeItemToFit(view: thirdView).height)
            $0.width.equalTo(sizeItemToFit(view: thirdView).width)
        }
        
        firstThreeViewWrapper.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview()
        }
        
        tableHeaderContainer.addSubview(firstThreeViewContainer)
        tableHeaderContainer.addSubview(tableHeaderBottomLabel)
        
        firstThreeViewContainer.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
        }
        
        tableHeaderBottomLabel.sizeToFit()
        
        tableHeaderBottomLabel.snp.makeConstraints {
            $0.trailing.leading.equalToSuperview().inset(8)
            $0.centerX.equalToSuperview()
            $0.top.equalTo(firstThreeViewContainer.snp.bottom)
            $0.bottom.equalToSuperview().offset(-16)
        }
        setNeedsLayout()
        layoutIfNeeded()
        return tableHeaderContainer
    }
    
    func disableScroll() {
        table.isScrollEnabled = false
    }
    
}

extension LiveStarListTableView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.tableHeaderContainer.superview == nil {
            return addHeaderView()
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kCellRowHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LiveStarCell.cellIdentifier, for: indexPath) as! LiveStarCell
        
        let model = lists[indexPath.row]
        cell.setStarModel(model, at: indexPath.row + 4)
        cell.avatarView.buttonForAvatar.addAction { [weak self] in
            self?.delegate?.onPressUserProfile(model)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.lists.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = lists[indexPath.row]
        self.delegate?.onPressCell(model)
    }
    
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
