//
//  LiveStarListViewContainer.swift
//  Yippi
//
//  Created by CC Teoh on 17/08/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit
import SnapKit
import PusherSwift
import ObjectMapper

public enum LiveStarListTableType {
    case daily, weekly, monthly
}

protocol LiveStarListViewContainerDelegate: class {
    func onPressedUserProfile(_ userModel: UserInfoType)
    func onPressedCell(_ userModel: StarSlotModel)
    func selectedFilter(_ model: LiveStarSlotModel, isPassResult: Bool)
    func selectedFilter(_ model: LiveEventModel, isPassResult: Bool)
    func didSetupFooter(_ model: SlotRankModel)
    func didUpdateFooter()
    func didUpdateFooter(_ model: SlotRankModel)
}

class LiveStarListViewContainer: UIView {
    weak var delegate: LiveStarListViewContainerDelegate?
    
    lazy var dailyList: LiveStarListTableView = LiveStarListTableView(frame: .zero, liveFilterType: .daily, liveEntryType: self.liveEntryType).configure {
        $0.extraScrollViewDelegate = self
    }
    
    var selectedFilterType: LiveStarListTableType = .daily
    
    let scrollView = UIScrollView()

    private lazy var weeklyList: LiveStarListTableView = LiveStarListTableView(frame: .zero, liveFilterType: .weekly, liveEntryType: self.liveEntryType).configure {
        $0.extraScrollViewDelegate = self
    }
    private lazy var monthlyList: LiveStarListTableView = LiveStarListTableView(frame: .zero, liveFilterType: .monthly, liveEntryType: self.liveEntryType).configure {
        $0.extraScrollViewDelegate = self
    }
    private var feedId: Int
    private var hostInfo: UserInfoModel?
    private var viewWidth: CGFloat = UIScreen.main.bounds.width
    private var liveType: LiveType = .starOfTheDay
    private var liveEntryType: LiveListEntryType = .live
    private var roomInfoLanguage: String?
    
    public var activeTableView: TSTableView {
        get {
            switch selectedFilterType {
            case .weekly:
                return weeklyList.table
            case .monthly:
                return monthlyList.table
            default:
                return dailyList.table
            }
        }
    }
    
    public var extraScrollViewDelegate:TSScrollDelegate?

    init(frame: CGRect, feedId: Int = -1, liveEntryType: LiveListEntryType = .live, width: CGFloat = UIScreen.main.bounds.width, hostInfo: UserInfoModel? = nil, language: String? = nil) {
        self.feedId = feedId
        self.liveEntryType = liveEntryType
        self.viewWidth = width
        self.hostInfo = hostInfo
        self.roomInfoLanguage = language
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        addSubview(scrollView)
        
        if let info = self.hostInfo {
            dailyList.hostInfo = info
            weeklyList.hostInfo = info
            monthlyList.hostInfo = info
        }
        
        dailyList.delegate = self
        scrollView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
        
        dailyList.feedId = self.feedId
        dailyList.roomInfoLanguage = self.roomInfoLanguage
        add(childView: dailyList, at: 0)
        
        if liveEntryType != .search {
            weeklyList.delegate = self
            monthlyList.delegate = self

            weeklyList.feedId = self.feedId
            monthlyList.feedId = self.feedId

            weeklyList.roomInfoLanguage = self.roomInfoLanguage
            monthlyList.roomInfoLanguage = self.roomInfoLanguage

            add(childView: weeklyList, at: 1)
            add(childView: monthlyList, at: 2)
        } else {
            dailyList.disableScroll()
        }
    }
    
    public func add(childView: UIView, at index: Int) {
        self.scrollView.addSubview(childView)
        
        var width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        
        if (width > height)
        {
            width = height
        }
        let leading = width * CGFloat(index)
        childView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(leading)
            $0.top.equalToSuperview()
            $0.width.equalTo(width)
            $0.height.equalTo(scrollView.snp.height)
        }
    }
    
    func setSelectedFilter(filterType: LiveStarListTableType, requestPassResult: Bool = false) {
        selectedFilterType = filterType
        
        let width = self.scrollView.frame.width

        switch filterType {
        case .daily:
            scrollView.setContentOffset(CGPoint(x: 0 * width, y: 0), animated: false)
            if requestPassResult {
                switch liveEntryType {
                    case .live:
                        dailyList.fetchData(with: "1", requestPassResult: requestPassResult, completion: { [weak self] (model) in
                            if let data = model {
                                self?.delegate?.selectedFilter(data, isPassResult: requestPassResult)
                                self?.dailyList.updateInfoText(isPassedResult: requestPassResult)
                            }
                        })
                    default:
                        dailyList.fetchDataWithoutId(with: "1", requestPassResult: requestPassResult, completion: { [weak self] (model) in
                            if let data = model {
                                self?.delegate?.selectedFilter(data, isPassResult: requestPassResult)
                                self?.dailyList.updateInfoText(isPassedResult: requestPassResult)
                            }
                        })
                }
            } else {
                switch liveEntryType {
                    case .live:
                        dailyList.fetchDailyData(completion: { [weak self] data in
                            if let data = data {
                                self?.delegate?.selectedFilter(data, isPassResult: requestPassResult)
                                self?.dailyList.updateInfoText(isPassedResult: requestPassResult)
                            }
                        })
                    default:
                        dailyList.fetchDailyDataWithoutId(selectedLanguage: TSCurrentUserInfo.share.isLogin ? userConfiguration?.searchLanguageCode : UserDefaults.standard.string(forKey: "SEARCHLANGUAGECODE")) { [weak self] data in
                            if let data = data {
                                self?.delegate?.selectedFilter(data, isPassResult: requestPassResult)
                                self?.dailyList.updateInfoText(isPassedResult: requestPassResult)
                            }
                        }
                }
            }
        case .weekly:
            scrollView.setContentOffset(CGPoint(x: 1 * width, y: 0), animated: false)
            switch liveEntryType {
                case .live:
                    weeklyList.fetchData(with: "7", requestPassResult: requestPassResult, completion: { [weak self] (model) in
                        if let data = model {
                            self?.delegate?.selectedFilter(data, isPassResult: requestPassResult)
                            self?.weeklyList.updateInfoText(isPassedResult: requestPassResult)
                        }
                    })
                default:
                    weeklyList.fetchDataWithoutId(with: "7", requestPassResult: requestPassResult, completion: { [weak self] (model) in
                        if let data = model {
                            self?.delegate?.selectedFilter(data, isPassResult: requestPassResult)
                            self?.weeklyList.updateInfoText(isPassedResult: requestPassResult)
                        }
                    })
            }
            
        case .monthly:
            scrollView.setContentOffset(CGPoint(x: 2 * width, y: 0), animated: false)
            switch liveEntryType {
                case .live:
                    monthlyList.fetchData(with: "30", requestPassResult: requestPassResult, completion: { [weak self] (model) in
                        if let data = model {
                            self?.delegate?.selectedFilter(data, isPassResult: requestPassResult)
                            self?.monthlyList.updateInfoText(isPassedResult: requestPassResult, month: data.periodStartTime)
                        }
                    })
                default:
                    monthlyList.fetchDataWithoutId(with: "30", requestPassResult: requestPassResult, completion: { [weak self] (model) in
                        if let data = model {
                            self?.delegate?.selectedFilter(data, isPassResult: requestPassResult)
                            self?.monthlyList.updateInfoText(isPassedResult: requestPassResult, month: data.periodStartTime)
                        }
                    })
            }
        }
    }
}

extension LiveStarListViewContainer: LiveStarListTableViewDelegate {
    func onPressUserProfile(_ userModel: UserInfoType) {
        self.delegate?.onPressedUserProfile(userModel)
    }
    
    func onPressCell(_ userModel: StarSlotModel) {
        self.delegate?.onPressedCell(userModel)
    }
    
    func willSetupFooter(_ model: SlotRankModel) {
        self.delegate?.didSetupFooter(model)
    }
    
    func willUpdateFooter() {
        self.delegate?.didUpdateFooter()
    }
    
    func willUpdateFooter(_ model: SlotRankModel) {
        self.delegate?.didUpdateFooter(model)
    }
    
    func pusherUpdateDataSource(_ object: StarSlotModel) {
        switch self.selectedFilterType {
        case .weekly:
            self.weeklyList.updateNonDailyList(with: object)
        case .monthly:
            self.monthlyList.updateNonDailyList(with: object)
        default:
            self.dailyList.updateList(with: object)
        }
    }
}

extension LiveStarListViewContainer: TSScrollDelegate {
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
