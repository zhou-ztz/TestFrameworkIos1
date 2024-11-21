//
//  StickerMainViewController.swift
//  Yippi
//
//  Created by Yong Tze Ling on 13/05/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import UIKit


protocol StickerMainDelegate: class {
    func seeMoreButtonTapped(section: StickerCollectionSection)
    func artistDidTapped(artist: Sticker)
    func stickerDidTapped(sticker: Sticker)
    func categoryDidTapped(categoryId: Int, categoryName: String)
    func bannerDidTapped(banner: StickerBanner)
    func stickerResultDidTapped(sticker: Sticker)
}

class StickerMainViewController: TSViewController {

    private let navigationBar = StickerNavigationBar()

    private let hotSticker = StickerCarouselView()

    private let navBottomSpacer = UIView()

    private let scrollView = UIScrollView().build {
        $0.bounces = false
        $0.backgroundColor = .white

    }

    private let stackview = UIStackView().configure {
        $0.axis = .vertical
        $0.spacing = 0
        $0.distribution = .fillProportionally
        $0.alignment = .fill
    }

    private let stickerOfTheDay = StickerOfTheDayView()
    private let categoriesView = StickerCategoryView()
    private let recommendView = StickerRecommendView()
    private let newStickerView = StickerNewStickerView()
    private let newArtistView = StickerNewArtistView()
    private let bannerView = StickerHomeBannerView()

    private var data: [StickerCollectionSection]?
    private var banner: StickerHomeBannerSection?
    private var currentHeaderColor: UIColor = .darkGray {
        didSet {
            self.stackview.backgroundColor = currentHeaderColor
            self.navBottomSpacer.backgroundColor = currentHeaderColor
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateDownloadButton), name: NSNotification.Name(rawValue: "Notification_StickerBundleDownloaded"), object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    private func setupUI() {

        navigationBar.titleLabel.text = "menu_sticker".localized

        scrollView.delegate = self
        view.addSubview(scrollView)
        view.addSubview(navigationBar)

        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.contentInset = UIEdgeInsets.zero

        scrollView.bindToSafeEdges()
        navigationBar.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.height.equalTo(TSLiuhaiHeight + 64)
        }

        scrollView.addSubview(stackview)
        stackview.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.leading.trailing.top.bottom.equalToSuperview()
        }

        let spacer = UIView().build { $0.backgroundColor = .white }

        stackview.addArrangedSubview(navBottomSpacer)
        stackview.addArrangedSubview(hotSticker)
        stackview.addArrangedSubview(stickerOfTheDay)
        stackview.addArrangedSubview(newStickerView)
//        stackview.addArrangedSubview(recommendView)
        stackview.addArrangedSubview(newArtistView)
        stackview.addArrangedSubview(categoriesView)
        stackview.addArrangedSubview(bannerView)
        stackview.addArrangedSubview(spacer)

        navBottomSpacer.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(TSLiuhaiHeight + 64)
        }

        spacer.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(TSUserInterfacePrinciples.share.getTSBottomSafeAreaHeight() + 16)
        }

        navBottomSpacer.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(TSLiuhaiHeight + 64)
        }

        spacer.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(TSUserInterfacePrinciples.share.getTSBottomSafeAreaHeight() + 16)
        }

        scrollView.makeHidden()
        navigationBar.makeHidden()
        self.loading(showBackButton: false, shouldAnimatePush: true)
        fetch()
        bind()
    }

    override func placeholderButtonDidTapped() {
        fetch()
    }
}

// MARK: - Private methods
extension StickerMainViewController {

    @objc private func updateDownloadButton() {
        newStickerView.reloadData()
    }


    private func fetch() {

        GetLandingPageStickers().execute { [weak self] response in
            guard let self = self, let data = response?.data else { return }
            defer {
                self.scrollView.makeVisible()
                self.navigationBar.makeVisible()
            }
            self.data = data.stickers
            self.banner = data.banner
            DispatchQueue.main.async {
                self.populateData()
                self.populateBanner()
                self.removePlaceholderView()
                self.navigationBar.reset()
                self.endLoading()
            }

        } onError: { [weak self] (error) in
            guard let self = self else { return }
            defer {
                self.scrollView.makeVisible()
                self.navigationBar.makeVisible()
            }
            DispatchQueue.main.async {
                self.show(placeholder: .network)
                self.view.bringSubviewToFront(self.navigationBar)
                self.navigationBar.set(offset: 1)
                self.endLoading()
            }
        }
    }

    private func populateData() {
        guard let data = data else {
            return
        }

        data.forEach { section in
            switch section.type {
            case .hot_stickers:
                if let color = section.data.first?.backgroundColor {
                    currentHeaderColor = UIColor(hex: color)
                }
                hotSticker.setModel(section)
            case .stickers_of_the_day:
                stickerOfTheDay.set(section)
            case .featured_category:
                categoriesView.set(section)
            case .recomended_artist:
                recommendView.set(section)
            case .new_sticker:
                newStickerView.set(section)
            case .new_artist:
                newArtistView.set(section)

            default:
                break
            }
        }
    }

    private func populateBanner() {
        bannerView.set(banner)
    }

    private func bind() {

        hotSticker.delegate = self
        newStickerView.delegate = self
        recommendView.delegate = self
        newArtistView.delegate = self
        stickerOfTheDay.delegate = self
        categoriesView.delegate = self
        bannerView.delegate = self

        navigationBar.leftButton.addAction { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }

        navigationBar.rightButton.addAction { [weak self] in
            let vc = MyStickersViewController()
            vc.hideShimmer(hide: true)
            self?.heroPush(vc)
        }

        navigationBar.searchButton.addAction { [weak self] in
            let vc = SearchStickerViewController()
            self?.heroPush(vc)
        }

        hotSticker.onColorChanged = { [weak self] color in
            DispatchQueue.main.async {
                self?.currentHeaderColor = color ?? .random
            }
        }
    }
}

extension StickerMainViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        navigationBar.set(offset: scrollView.contentOffset.y)

        if scrollView.contentOffset.y > (scrollView.contentSize.height / 2) {
            scrollView.backgroundColor = .white
        } else {
            scrollView.backgroundColor = currentHeaderColor
        }
    }

    private func showStickerDetail(bundleId: String) {
        let vc = StickerDetailViewController(bundleId: bundleId)
        self.heroPush(vc)
    }
}

extension StickerMainViewController: StickerMainDelegate {

    func seeMoreButtonTapped(section: StickerCollectionSection) {
        let list = StickerListViewController(type: section.type, title: section.title)
        heroPush(list)
    }


    func bannerDidTapped(banner: StickerBanner) {
        guard let actionType = banner.actionType else {
            return
        }
        switch actionType {
        case .url:
            if let value = banner.actionValue, let url = URL(string: value), UIApplication.shared.canOpenURL(url) {
              //  TSAdvertTaskQueue.showDetailVC(urlString: value)
            }
        case .sticker:
            if let bundleId = banner.bundleId {
                showStickerDetail(bundleId: String(bundleId))
            }
        default:
            break
        }
    }

    func artistDidTapped(artist: Sticker) {
        guard let artistId = artist.artistID, let name = artist.artistName else {
            return
        }
        let vc = ArtistCollectionViewController(artistId: artistId.stringValue, artistName: name)
        self.heroPush(vc)
    }

    func stickerDidTapped(sticker: Sticker) {
        guard let bundlerId = sticker.bundleID else {
            return
        }
        showStickerDetail(bundleId: bundlerId.stringValue)
    }

    func categoryDidTapped(categoryId: Int, categoryName: String) {
        let vc = StickerListViewController(type: .stickerByCategory, title: categoryName, categoryId: categoryId)
        self.heroPush(vc)
    }

    func stickerResultDidTapped(sticker: Sticker) {
        if let stat = sticker.todayStats {
//            let view = LiveScoreResultView(from: .sticker, type: .ranked, views: stat.downloadCount, tips: stat.tipsAmount, score: stat.totalPoints, isButtonHidden: true)
//            let popup = TSAlertController(style: .popup(customview: view))
//            popup.modalPresentationStyle = .overFullScreen
//            self.present(popup, animated: false, completion: nil)
        }
    }
}

class StickerNavigationBar: UIView {

    private let backgroundView = UIView().configure {
        $0.backgroundColor = .white
    }

    let leftButton: UIButton = UIButton(type: .custom).configure {
        $0.setImage(UIImage.set_image(named: "IMG_topbar_back_white"), for: .normal)
    }

    let rightButton = UIButton(type: .custom).configure {
        $0.setImage(UIImage.set_image(named: "icStickerMainSetting"), for: .normal)
        $0.tintColor = .white
    }

    let searchButton = UIButton(type: .custom).configure {
        $0.setImage(UIImage.set_image(named: "icStickerSearch"), for: .normal)
        $0.tintColor = .white
    }

    private let stackview = UIStackView().configure {
        $0.axis = .horizontal
        $0.distribution = .equalCentering
        $0.alignment = .center
        $0.spacing = 16
    }

    let titleLabel = UILabel().configure {
        $0.applyStyle(.semibold(size: 17, color: .white))
        $0.textAlignment = .center
    }

    init() {
        super.init(frame: .zero)
        backgroundColor = .clear
        addSubview(backgroundView)
        backgroundView.bindToEdges()
        addSubview(stackview)
        stackview.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview()
            if #available(iOS 11.0, *) {
                $0.top.equalTo(self.safeAreaLayoutGuide.snp.top)
            } else {
                $0.top.equalToSuperview()
            }
        }
        stackview.addArrangedSubview(leftButton)
        stackview.addArrangedSubview(titleLabel)
        stackview.addArrangedSubview(searchButton)
        stackview.addArrangedSubview(rightButton)

        leftButton.snp.makeConstraints {
            $0.width.height.equalTo(28)
        }
        rightButton.snp.makeConstraints {
            $0.width.height.equalTo(28)
        }

        searchButton.snp.makeConstraints {
            $0.width.height.equalTo(28)
        }

        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func set(offset: CGFloat) {

        self.backgroundView.alpha = min(1, offset/self.height)

        if offset < (self.height / 2) {
            leftButton.setImage(UIImage.set_image(named: "iconsArrowCaretleftWhite"), for: .normal)
            rightButton.tintColor = .white
            titleLabel.textColor = .white
            searchButton.tintColor = .white
        } else {
            leftButton.setImage(UIImage.set_image(named: "iconsArrowCaretleftBlack"), for: .normal)
            rightButton.tintColor = .black
            titleLabel.textColor = .black
            searchButton.tintColor = .black
        }
    }

    func reset() {
        self.backgroundView.alpha = 0
        leftButton.setImage(UIImage.set_image(named: "iconsArrowCaretleftWhite"), for: .normal)
        rightButton.tintColor = .white
        titleLabel.textColor = .white
    }
}
