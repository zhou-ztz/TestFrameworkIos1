//
//  LiveStarListHeaderView.swift
//  Yippi
//
//  Created by CC Teoh on 06/08/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit
import SnapKit

protocol LiveStarListHeaderViewDelegate: class {
    func onSelectSegmentItem(_ item: Int)
    func dismiss()
    func openStaticInfoPage()
    func onShowLiveStarRank()
}

class LiveStarListHeaderView: UIView {
    
    weak var delegate: LiveStarListHeaderViewDelegate?
    
    private var liveEntryType: LiveListEntryType = .live
    
    private var backButton: UIButton = UIButton().configure {
        $0.setImage(UIImage.set_image(named: "iconsArrowCaretleftBlack"), for: .normal)
    }

    private let infoButton: UIButton = UIButton().configure {
        $0.setImage(UIImage.set_image(named: "ic_star_info"), for: .normal)
    }
    
    private let timeContainer = UIStackView().configure {
        $0.axis = .vertical
        $0.distribution = .fillProportionally
        $0.alignment = .leading
        $0.spacing = 16
    }
        
    private let segmentedView = CustomizeSegmentedView(frame: CGRect.zero).configure {
        $0.items = ["sotd_result_daily".localized , "sotd_result_weekly".localized, "sotd_result_monthly".localized]
        $0.font = UIFont(name: "PingFangSC-Medium", size: 12)
        $0.selectedIndex = 0
        $0.unselectedLabelColor = .black
        $0.selectedLabelColor = .white
        $0.thumbColor = .systemBlue
        $0.padding = 8
        $0.addTarget(self, action: #selector(LiveStarListHeaderView.segmentValueChanged(_:)), for: .valueChanged)
    }
    
    private let headerContainer = UIStackView().configure {
        $0.axis = .vertical
        $0.distribution = .fill
        $0.alignment = .leading
        $0.spacing = 16
    }
    
    private let timeRangeContainer = UIStackView().configure {
        $0.axis = .horizontal
        $0.distribution = .fill
        $0.alignment = .center
        $0.spacing = 16
    }
    
    public var timeRangeView: LiveStarButton = LiveStarButton(text: "", showBackground: false).configure {
        $0.titleLabel.textColor = .black
    }
    
    private var pastResultLabel = UILabel().configure {
//        $0.setTextWithIcon(text: SOTDType.daily.passResultButtonString,
//                           image: UIImage.set_image(named: "ic_arrow_next")!,
//                           imagePosition: .back,
//                           imageSize: CGSize(width: 20, height: 20), yOffset: -6)
        $0.applyStyle(.regular(size: 12, color: UIColor.black))
        $0.textAlignment = .right
    }
    
    private var navView = UIView().configure {
        $0.backgroundColor = .clear
    }

    private var titleLabel = UILabel().configure {
        $0.setTextWithIcon(text: "live_star_of_day_ranking".localized,
                           image: UIImage.set_image(named: "ic_arrow_next")!,
                           imagePosition: .back,
                           imageSize: CGSize(width: 20, height: 20), yOffset: -4)
        $0.applyStyle(.bold(size: 16, color: UIColor.black.withAlphaComponent(0.85)))
        $0.textAlignment = .left
    }

    private var languageLabel = UILabel().configure {
        $0.applyStyle(.semibold(size: 10, color: AppTheme.UIColorFromRGB(red: 59, green: 179, blue: 255)))
    }

    private let titleView = UIView().configure {
        $0.backgroundColor = .clear
    }

    private let languageView = UIView().configure {
        $0.backgroundColor = AppTheme.UIColorFromRGB(red: 218, green: 237, blue: 250)
        $0.roundCorner(4)
    }

    private let rightItemsStackView = UIStackView().configure {
        $0.axis = .horizontal
        $0.distribution = .fill
        $0.alignment = .center
        $0.spacing = 8
    }

    private lazy var feedCategoryView = { return FeedCategorySelectorView(type: .language(code: userConfiguration?.searchLanguageCode)) }()
    private var selectorView: CategoryWrapperView?

    private var language: String? = nil
    
    public var isPastResultSelected: Bool = false
    
    init(frame: CGRect, liveEntryType:  LiveListEntryType = .live, streamerLanguage: String? = nil) {
        self.liveEntryType = liveEntryType
        self.language = streamerLanguage
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        self.backgroundColor = liveEntryType == .search ? UIColor.clear : UIColor(hex: 0xF4FBFF)
        feedCategoryView.optionView.borderView.backgroundColor = UIColor(red: 228/255, green: 244/255, blue:255/255, alpha: 1.0)
        feedCategoryView.optionView.label.applyStyle(.semibold(size: 10, color: UIColor(red: 59/255, green: 179/255, blue: 255/255, alpha: 1.0)))
        
        backButton.addTarget(self, action: #selector(self.backButtonOnTapped), for: .touchUpInside)
        infoButton.addTarget(self, action: #selector(self.openStaticInfoPage), for: .touchUpInside)
        pastResultLabel.addAction { [weak self] in
            guard let self = self else { return }
            self.isPastResultSelected.toggle()
            self.updatePassResultLabel()
            self.delegate?.onSelectSegmentItem(self.segmentedView.selectedIndex)
        }

        headerContainer.addArrangedSubview(navView)

        switch liveEntryType {
        case .live:
                rightItemsStackView.addArrangedSubview(titleLabel)
                rightItemsStackView.addArrangedSubview(languageView)
                rightItemsStackView.addArrangedSubview(infoButton)
                navView.addSubview(rightItemsStackView)
                timeContainer.addArrangedSubview(segmentedView)
                timeContainer.addArrangedSubview(timeRangeContainer)
                timeRangeContainer.addArrangedSubview(timeRangeView)
                timeRangeContainer.addArrangedSubview(pastResultLabel)
                headerContainer.addArrangedSubview(timeContainer)
                languageView.addSubview(languageLabel)

                titleLabel.addAction { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.onShowLiveStarRank()
                }
            case .homepage:
                rightItemsStackView.addArrangedSubview(titleLabel)
                rightItemsStackView.addArrangedSubview(feedCategoryView)
                navView.addSubview(rightItemsStackView)
                timeContainer.addArrangedSubview(segmentedView)
                timeContainer.addArrangedSubview(timeRangeContainer)
                timeRangeContainer.addArrangedSubview(timeRangeView)
                timeRangeContainer.addArrangedSubview(pastResultLabel)
                headerContainer.addArrangedSubview(timeContainer)
                setLanguageHandler()

            case .search:
                navView.addSubview(timeRangeView)
                navView.addSubview(feedCategoryView)
                setLanguageHandler()
        }

        addSubview(headerContainer)
        
        setConstraints()
    }

    private func setLanguageHandler() {
        let languages = LanguageStoreManager().fetch()
        feedCategoryView.onTapOpen = { [weak self] in
            guard let self = self else { return }
            UIView.animate(withDuration: 0.2) {
                self.feedCategoryView.optionView.arrowImageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
            }
            guard self.selectorView == nil else {
                self.selectorView?.hide()
                return
            }
            self.selectorView = CategoryWrapperView(options: [.language(selections: languages,
                                                                        preselection: (TSCurrentUserInfo.share.isLogin ? userConfiguration?.searchLanguageCode : UserDefaults.standard.string(forKey: "SEARCHLANGUAGECODE")).orEmpty,
                                                                        onSelect: { [weak self] code in
                                                                            if TSCurrentUserInfo.share.isLogin {
                                                                                userConfiguration?.searchLanguageCode = code
                                                                                userConfiguration?.save()
                                                                            } else {
                                                                                UserDefaults.standard.setValue(code, forKey: "SEARCHLANGUAGECODE")
                                                                            }
                                                                            self?.feedCategoryView.optionView.label.text = (LanguageCategorySelector().options.first(where: { $0.code == (TSCurrentUserInfo.share.isLogin ? userConfiguration?.searchLanguageCode : UserDefaults.standard.string(forKey: "SEARCHLANGUAGECODE")).orEmpty })?.name).orEmpty
                                                                            self?.delegate?.onSelectSegmentItem(0)
                                                                        })])
            self.superview?.addSubview(self.selectorView!)
            self.selectorView!.snp.makeConstraints { (v) in
                v.top.equalTo(self.feedCategoryView.snp.bottom)
                v.left.bottom.right.equalToSuperview()
            }

            self.selectorView!.notifyComplete = { [weak self] in
                self?.selectorView = nil
                UIView.animate(withDuration: 0.2) {
                    self?.feedCategoryView.optionView.arrowImageView.transform = .identity
                }
            }

            self.layoutIfNeeded()
        }
    }
    
    private func setConstraints() {
        navView.snp.makeConstraints {
            $0.left.equalToSuperview().inset(8)
            switch self.liveEntryType {
                case .live, .homepage:
                    $0.top.equalToSuperview().offset(16)
                    if #available(iOS 11, *) {
                        $0.right.equalTo(self.safeAreaLayoutGuide.snp.right).offset(-16)
                    } else {
                        $0.right.equalToSuperview().offset(-16)
                    }
                    $0.height.equalTo(50)
                case .search:
                    $0.top.equalToSuperview()
                    $0.height.equalTo(30)
                    $0.right.equalToSuperview()
            }
        }

        headerContainer.snp.makeConstraints {
            $0.left.right.top.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-8)
        }

        switch liveEntryType {
            case .live:
                let languageList = LanguageStoreManager().fetch()
                let languageName = languageList.first(where: { $0.code == language })?.name
                languageLabel.text = languageName == nil ? "text_global".localized : languageName
                languageLabel.sizeToFit()
                rightItemsStackView.snp.makeConstraints {
                    $0.top.right.bottom.equalToSuperview()
                    $0.left.equalToSuperview().inset(8)
                }
            case .homepage:
                rightItemsStackView.snp.makeConstraints {
                    $0.top.right.bottom.equalToSuperview()
                    $0.left.equalToSuperview().inset(8)
                }
                feedCategoryView.setContentHuggingPriority(.required, for: .horizontal)
                feedCategoryView.content.snp.removeConstraints()
                feedCategoryView.content.snp.makeConstraints { (make) in
                    make.top.bottom.equalToSuperview().inset(5)
                    make.right.equalToSuperview()
                    make.left.lessThanOrEqualToSuperview().inset(12)
                }
            default:
                timeRangeView.snp.makeConstraints {
                    $0.height.equalTo(25)
                    $0.centerY.equalToSuperview()
                    $0.left.equalToSuperview().offset(8)
                }
                feedCategoryView.snp.makeConstraints {
                    $0.right.centerY.equalToSuperview()
                }
                return
        }

        timeContainer.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(8)
        }
        
        timeRangeContainer.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
        }

        timeRangeView.snp.makeConstraints {
            $0.height.equalTo(25)
        }

        segmentedView.snp.makeConstraints {
            $0.height.equalTo(32)
            $0.leading.trailing.equalToSuperview()
        }

        if self.liveEntryType == .live {
            languageView.snp.makeConstraints {
                $0.height.equalTo(20)
            }
            
            languageLabel.snp.makeConstraints {
                $0.left.right.equalToSuperview().inset(5)
                $0.center.equalToSuperview()
            }
        }

        languageLabel.setContentHuggingPriority(.required, for: .horizontal)
        //pastResultLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        if self.liveEntryType == .live {
            infoButton.snp.makeConstraints {
                $0.height.width.equalTo(21)
            }
        }

    }
    
    @objc func openStaticInfoPage() {
        self.delegate?.openStaticInfoPage()
    }
        
    @objc func backButtonOnTapped() {
        self.delegate?.dismiss()
    }
    
    func updatePassResultLabel() {
        var newText = "sotd_yesterday".localized
//        switch self.segmentedView.selectedIndex {
//        case 1:
//            newText = self.isPastResultSelected ? SOTDType.weekly.currentResultButtonString : SOTDType.weekly.passResultButtonString
//        case 2:
//            newText = self.isPastResultSelected ? SOTDType.monthly.currentResultButtonString : SOTDType.monthly.passResultButtonString
//        default:
//            newText = self.isPastResultSelected ? SOTDType.daily.currentResultButtonString : SOTDType.daily.passResultButtonString
//        }
//        self.pastResultLabel.setTextWithIcon(text: newText,
//                           image: UIImage.set_image(named: "ic_arrow_next")!,
//                           imagePosition: .back,
//                           imageSize: CGSize(width: 20, height: 20), yOffset: -6)
    }
    
    @objc func segmentValueChanged(_ sender: AnyObject?){
        self.isPastResultSelected = false
        self.updatePassResultLabel()
        self.delegate?.onSelectSegmentItem(segmentedView.selectedIndex)
    }
            
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}
