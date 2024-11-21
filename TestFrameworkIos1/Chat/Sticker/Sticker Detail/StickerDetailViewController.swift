//
//  StickerDetailViewController.swift
//  Yippi
//
//  Created by Yong Tze Ling on 06/12/2018.
//  Copyright © 2018 Toga Capital. All rights reserved.
//

import UIKit
import Apollo

import SnapKit
import Toast

class StickerDetailViewController: TSViewController {
    let bottomViewHeight: CGFloat = 52
    private var collectionView: UICollectionView!
    private var bundleId: String
    private var stickerDetail: StickerQuery.Data?
    private let kCellSpacing: CGFloat = 16.0
    var downloadButton: UIButton!
    var voteButton = UIButton(type: .custom)
    var isHeaderExpanded = false
    
    init(bundleId: String) {
        self.bundleId = bundleId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        loadStickerDetail()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.checkDownload),
            name: NSNotification.Name(rawValue: "Notification_StickerBundleDownloaded"),
            object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }

    private func configureView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        self.view.addSubview(collectionView)

        collectionView.register(StickerDetailHeader.nib(), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: StickerDetailHeader.cellIdentifier)
        collectionView.register(StickerImageCell.nib(), forCellWithReuseIdentifier: StickerImageCell.cellIdentifier)


        collectionView.bindToSafeEdges()
        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.backgroundColor = AppTheme.white
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomViewHeight + 16, right: 0)
        setupActionMenu()
    }
    
    private func configureNavigationBarTitle () {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        label.textColor = InconspicuousColor().navTitle
        label.font = UIFont.boldSystemFont(ofSize: TSFont.Navigation.headline.rawValue)
        label.backgroundColor = UIColor.clear
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.text = self.title
        
        self.navigationItem.titleView = label
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.frame = self.view.bounds
    }
    
    func setupActionMenu() {
        let bottomView = UIView().configure {
            $0.backgroundColor = AppTheme.white
        }
        
        let stackview = UIStackView().configure {
            $0.axis = .horizontal
            $0.distribution = .fillEqually
            $0.alignment = .fill
        }
        
        func actionButton(_ title: String, image: String) -> UIButton {
            let button = TSButton(type: .custom)
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
            button.titleLabel?.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
            button.setImage(UIImage.set_image(named: image), for: .normal)
            button.setTitle(title, for: .normal)
            button.titleLabel?.numberOfLines = 1
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.titleLabel?.lineBreakMode = .byClipping
            button.setTitleColor(TSColor.normal.blackTitle, for: .normal)
            return button
        }
        
        let tipButton = actionButton("text_tips".localized, image: "ic_tip_black")
        tipButton.addAction { [weak self] in
            self?.rewardButtonDidTapped()
        }
        let shareButton = actionButton("text_share".localized, image: "ic_sticker_share")
        shareButton.addAction { [weak self] in
            self?.shareButtonDidTapped()
        }
        downloadButton = actionButton("text_download".localized, image: "ic_download")
        downloadButton.addAction { [weak self] in
            self?.downloadDidTapped()
        }
        
        if TSAppConfig.share.localInfo.isOpenReward == true {
            stackview.addArrangedSubview(tipButton)
        }
        stackview.addArrangedSubview(shareButton)
        stackview.addArrangedSubview(downloadButton)
        
        setDownloadButton(isDownloaded: StickerManager.shared.isBundleDownloaded(bundleId))

        bottomView.addSubview(stackview)
        stackview.bindToEdges()

        self.view.addSubview(bottomView)
        
        bottomView.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.height.equalTo(bottomViewHeight + TSBottomSafeAreaHeight)
        }
    }

    private func setDownloadButton(isDownloaded: Bool) {
        self.downloadButton.stopShimmering()
        if isDownloaded {
            downloadButton.setImage(nil, for: .normal)
            downloadButton.setTitleColor(.darkGray, for: .normal)
            downloadButton.setTitle("text_downloaded".localized, for: .normal)
        } else {
            downloadButton.setImage(UIImage.set_image(named: "ic_download"), for: .normal)
            downloadButton.setTitleColor(TSColor.normal.blackTitle, for: .normal)
            downloadButton.setTitle("text_download".localized, for: .normal)
        }
    }
    
    private func addVoteButton() {
        voteButton.frame = CGRect(x: 0 , y: self.view.bounds.height * 0.9 , width: 300, height: 50)
        voteButton.applyStyle(.custom(text: "text_vote".localized, textColor: AppTheme.twilightBlue, backgroundColor: AppTheme.secondaryColor, cornerRadius: 25))
        voteButton.titleLabel?.font = AppTheme.Font.bold(14)
        voteButton.center.x = self.view.center.x
        voteButton.addTarget(self, action: #selector(voteDidTapped), for: .touchUpInside)
        self.view.addSubview(voteButton)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: voteButton.bounds.size.height + 25, right: 0)
    }
    
    private func loadStickerDetail() {
        let apollo = YPApolloClient
        let query = StickerQuery.init(bundle_id: bundleId)
        
        apollo.fetch(query: query) { [weak self] obj, error in
            guard error == nil else {
                self?.show(placeholder: .network)
                return
            }
            
            self?.stickerDetail = obj?.data
            let bundleInfo = obj?.data?.sticker?.fragments.bundleInfo
            
            DispatchQueue.main.async {
                if let bundleInfo = bundleInfo {
                    self?.removePlaceholderView()
                    self?.title = bundleInfo.bundleName.orEmpty
                    self?.configureNavigationBarTitle()
                    self?.collectionView.reloadData()
                }
            }
        }
    }
}

extension StickerDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stickerDetail?.sticker?.stickerLists?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StickerImageCell.cellIdentifier, for: indexPath) as! StickerImageCell
        if let sticker = stickerDetail?.sticker?.stickerLists?[indexPath.row] {
            cell.configure(sticker.stickerIcon.orEmpty)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: StickerDetailHeader.cellIdentifier, for: indexPath) as! StickerDetailHeader
        if let detail = self.stickerDetail {
            header.configure(stickerDetail: detail, delegate: self, isExpanded: isHeaderExpanded)
        }
        return header
    }
}

extension StickerDetailViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let longWidth: CGFloat = self.view.bounds.width - (kCellSpacing * CGFloat(5))
        let width: CGFloat = (longWidth) / CGFloat(4)
        return CGSize(width: width, height: width)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let label = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: collectionView.bounds.width, height: CGFloat.leastNormalMagnitude)))
        label.numberOfLines = isHeaderExpanded ? 0 : 5
        label.lineBreakMode = .byWordWrapping
        label.text = stickerDetail?.sticker?.fragments.bundleInfo.description
        label.sizeToFit()
        return CGSize(width: collectionView.frame.width, height: (collectionView.bounds.width / 2) + 171 + label.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: kCellSpacing, bottom: 0, right: kCellSpacing)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return kCellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return kCellSpacing / 2
    }
}

extension StickerDetailViewController: StickerDetailHeaderDelegate {
    
    @objc func voteDidTapped() {
    }

    func rewardButtonDidTapped() {
        guard let bundle = stickerDetail?.sticker?.fragments.bundleInfo else {
            return
        }
//        self.presentTipping(target: bundle.bundleId, type: .sticker) { [weak self] (_, _) in
//            
//            DispatchQueue.main.async {
//                if let header = self?.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: 0)) as? StickerDetailHeader {
//                    header.updateTipsLabel()
//                }
//            }
//        }
    }

    func shareButtonDidTapped() {
        guard let sticker = stickerDetail?.sticker?.fragments.bundleInfo else {
            return
        }
        
//        let shareListView = ShareListView(shareType: .sticker)
//        shareListView.setUI()
//        shareListView.delegate = self
//        shareListView.messageModel = TSmessagePopModel(stickerInfo: sticker)
//        shareListView.show(URLString: ShareURL.sticker.rawValue + sticker.bundleId, image: nil, description: sticker.description, title: sticker.bundleName)
    }
    
    func downloadDidTapped() {
        guard let bundle = stickerDetail?.sticker?.fragments.bundleInfo else {
            return
        }
        if StickerManager.shared.isBundleDownloaded(bundle.bundleId) {
            return
        }
        self.downloadButton.startShimmering(background: false)

        StickerManager.shared.downloadSticker(for: bundle.bundleId) { [weak self] in
            DispatchQueue.main.async {
                if let header = self?.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: 0)) as? StickerDetailHeader {
                    header.updateDownloadLabel()
                }
            }
        } onError: { [weak self] errMsg in
            DispatchQueue.main.async {
                self?.view.makeToast(errMsg, duration: 1.5, position: CSToastPositionCenter)
            }
        }

    }
    
    @objc func checkDownload() {
        self.setDownloadButton(isDownloaded: StickerManager.shared.isBundleDownloaded(self.bundleId))
    }
    
    func removeDidTapped() {

    }
    
    func showArtistInfoDidTapped() {
        guard let artist = stickerDetail?.sticker?.artist?.fragments.artistInfo else {
            return
        }

        let vc = ArtistCollectionViewController(artistId: artist.artistId, artistName: artist.artistName)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func expandStickDescDidTapped() {
        isHeaderExpanded = !isHeaderExpanded
        collectionView.performBatchUpdates({
            let indexSet = IndexSet(integer: 0)
            self.collectionView.reloadSections(indexSet)
        }, completion: nil)
    }
    
    func openContestWeb(_ url: String) {
        guard let pageUrl = URL(string: url) else { return }
//        let webview = BridgedWebController(url: pageUrl, query: false, frame: self.view.frame)
//        self.heroPush(webview)
    }
}

extension StickerDetailViewController: ShareListViewDelegate {
    func didClickDisableCommentButton(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
        
    }
    
    func didClickReportButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
        
    }
    
    func didClickCollectionButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
        
    }
    
    func didClickDeleteButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
        
    }
    
    func didClickRepostButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath?) {
        if let bundleInfo = stickerDetail?.sticker?.fragments.bundleInfo {
//            let releaseVC = TSReleasePulseViewController(isHiddenshowImageCollectionView: true)
//            releaseVC.sharedModel = SharedViewModel.getModel(bundleInfo)
//            let navigation = TSNavigationController(rootViewController: releaseVC).fullScreenRepresentation
//            self.navigationController?.present(navigation, animated: true, completion: nil)
        }
    }
    
    func didClickApplyTopButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
        
    }
    
    func didClickSetTopButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
        
    }
    
    func didClickCancelTopButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
        
    }
    
    func didClickSetExcellentButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
        
    }
    
    func didClickCancelExcellentButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {
        
    }
    
    func didClickShareExternal(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath?, items: [Any]) {
        
    }
    
    func didClickShareQr(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath?, items: [Any]) {
    }
    
    func didClickMessageButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath?, model: TSmessagePopModel) {
        let picker = ContactsPickerViewController(model: model, configuration: ContactsPickerConfig.shareToChatConfig(), finishClosure: nil)
        self.navigationController?.pushViewController(picker, animated: true)
    }
}
