//
//  InputEmoticonContainerView.swift
//  Yippi
//
//  Created by Khoo on 06/07/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation

import SVProgressHUD

protocol InputEmoticonProtocol: NSObjectProtocol {
    func didPressSend(_ sender: Any?)
    func didPressAdd(_ sender: Any?)
    func selectedEmoticon(_ emoticonID: String?, catalog emotCatalogID: String?, description: String?, stickerId: String?)
    func sendEmoji(_ emojiTag: String?)
    func didPressMySticker(_ sender: Any?)
    func didPressCustomerSticker()
}

class InputEmoticonContainerView: UIView {
    
    typealias EmoticonActionCallback = (String?, String?, String?) -> Void
    typealias EmojiActionCallback = (String?) -> Void
    typealias AddStickerCallback = () -> Void
    typealias MyStickerSettingCallback = () -> Void
    typealias SendButtonTappedCallback = () -> Void
    typealias AddCustomerStickerCallback = () -> Void
    
    var tabView: InputEmoticonTabView? {
        didSet {
            
        }
    }
    
    
    weak var delegate: InputEmoticonProtocol?
    weak var config: IMChatViewConfig? {
        set {
            self.loadUIComponents()
        }
        get {
            return self.config
        }
    }
    
    var theme: Theme = .white
    
    private let kCellSizeCacheKey: Void? = nil
    
    private var cellSizeCache = NSCache<AnyObject, AnyObject>()
    
    var stickerTappedCallback: EmoticonActionCallback?
    var emojiTappedCallback: EmojiActionCallback?
    var addStickerCallback: AddStickerCallback?
    var myStickerTappedCallback: MyStickerSettingCallback?
    var sendButtonTappedCallback: SendButtonTappedCallback?
    var addCustomerStickerCallback: AddCustomerStickerCallback?
    
    //Custom view in keyboard
    var stickerView: UICollectionView? = nil
    let addButton: UIButton? = nil
    var bundleList: [Any]? = nil
    var stickerArray: [Any]? = nil
    let selectedBundleButton: UIButton? = nil
    var currentBundlePage: Int = 0
    let moreBtn: UIButton? = nil
    var downloadBtn: UIButton? = nil
    let downloadableStickerImage: UIImageView? = nil
    var bundleToDownload: [String:Any]? = nil
    let EmotPageControllerMarginBottom = 10
    var selectedType = TabType.customer
    var customerStickers = [CustomerStickerItem]()
    
    let inset: CGFloat = 10
    let minimumLineSpacing: CGFloat = 10
    let minimumInteritemSpacing: CGFloat = 10
    
    // Config Data
    override var frame: CGRect {
        didSet {
            self.reloadData()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadConfig()
        self.loadUIComponents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    func loadConfig () {
        NotificationCenter.default.addObserver(self, selector: #selector(self.screenOrientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        self.backgroundColor = .clear
    }
    
    @objc func screenOrientationChanged() {
        stickerView?.collectionViewLayout.invalidateLayout()
        stickerView?.scrollRectToVisible(CGRect(x: 0, y: 0, width: self.stickerView!.width, height: self.stickerView!.height), animated: false)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: 260)
    }
    
    public func setEmotionNightMode(isNight: Bool) {
        if isNight {
            theme = .dark
            self.stickerView?.backgroundColor = AppTheme.materialBlack
            self.tabView?.backgroundColor = AppTheme.materialBlack
        } else {
            theme = .white
            self.stickerView?.backgroundColor = .white
            self.tabView?.backgroundColor = .white
        }
        self.tabView?.setEmotionNightMode(isNight: isNight)
    }
    
    func downloadAllStickers(bundleID: String) {
        StickerManager.shared.downloadSticker(for: bundleID, completion: nil) { (error) in
            
        }
    }
    
    @objc func redownloadSticker () {
        let bundle = bundleToDownload
        let bundleId: String = bundle != nil ? bundle!["bundle_id"] as! String : ""
        
        SVProgressHUD.show(withStatus: "loading".localized)
        
        StickerManager.shared.downloadSticker(for: bundleId) {
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.refreshStickerKeyboard()
            }
            
        } onError: { (error) in
            
        }
    }
    
    func refreshStickerKeyboard () {
        bundleList = StickerManager.shared.loadOwnStickerBundle()
        self.refreshStickerDisplay()
        self.tabView!.refreshTabView()
    }
    
    func refreshStickerDisplay () {
        guard let bundleList = bundleList else { return }
        
        currentBundlePage = currentBundlePage > bundleList.count - 1 ? bundleList.count - 1 : currentBundlePage
        currentBundlePage = currentBundlePage <= 0 ? 0 : currentBundlePage
        let bundle:[String:Any]? = bundleList.count == 0 ? nil : bundleList[currentBundlePage] as? [String:Any]
        let bundleId = bundle != nil ? bundle!["bundle_id"] as? String: ""
        let bundleIcon = bundle != nil ? bundle!["bundle_icon"] as? String : ""
        let stickerArray = StickerManager.shared.loadStickerBundle(bundleId.orEmpty)
        
        downloadableStickerImage?.sd_setImage(with: URL(string: bundleIcon.orEmpty), completed: nil)
        
        bundleToDownload = bundle
        
        let stickePerPage = Constants.stickerPerPage
        var totalPage = stickerArray!.count/stickePerPage
        
        if stickerArray!.count % stickePerPage == 0 {
            totalPage += 1
        }
        
        self.stickerArray = stickerArray
        self.loadCustomerStickerList()
        DispatchQueue.main.async {
            // self.downloadBtn?.isHidden = (stickerArray?.count ?? 0 == 0 || stickerArray == nil) ?  false : true
            self.downloadableStickerImage?.isHidden = (stickerArray?.count == 0 || stickerArray == nil) ? false: true
            self.stickerView?.reloadData()
            self.stickerView?.scrollRectToVisible(CGRect(x: 0, y: 0, width: self.stickerView!.width, height: self.stickerView!.height), animated: false)
        }
    }
    
    func reloadData () {
        
    }
    
    func loadCustomerStickerList(){
        guard let userID = TSCurrentUserInfo.share.userInfo?.userIdentity else { return }
        let documentsPath =  NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
        if !FileManager.default.fileExists(atPath: documentsPath + "/customerSticker/" + "/\(userID)/" ) {
            StickerManager.shared.fetchMyCustomerStickers(first: 10000, after: "") { [weak self] (stickers) in
                guard let stickers = stickers else {return}
                DispatchQueue.main.async {
                    self?.customerStickers = stickers
                    self?.stickerView?.reloadData()
                }
            }
        } else {
            StickerManager.shared.getCustomerStickerList { [weak self] (stickers) in
                guard let stickers = stickers else {return}
                
                DispatchQueue.main.async {
                    self?.customerStickers = stickers
                    self?.stickerView?.reloadData()
                }
            }
        }
    }
    
    // MARK: - Sticker View download manager
    func loadUIComponents () {
        let stickerLayout = UICollectionViewFlowLayout()
        stickerLayout.scrollDirection = .vertical
        stickerView = UICollectionView(frame: CGRect(x: 0,y: 0, width: self.width, height: self.height), collectionViewLayout: stickerLayout)
        stickerView?.register(IMStickerCollectionCell.self, forCellWithReuseIdentifier: "STICKER_CELL_REUSE_ID")
        stickerView?.dataSource = self
        stickerView?.delegate = self
        stickerView?.backgroundColor = .white
        stickerView?.alwaysBounceHorizontal = false
        stickerView?.alwaysBounceVertical = true
        stickerView?.showsHorizontalScrollIndicator = false
        stickerView?.showsVerticalScrollIndicator = false
        stickerView?.isPagingEnabled = false
        
        self.addSubview(stickerView!)
        
        stickerView?.snp.makeConstraints({ (make) in
            make.leading.trailing.top.equalTo(self)
            make.bottom.equalTo(self).inset(CGFloat(Constants.stickerThumbHeight + EmotPageControllerMarginBottom) + TSBottomSafeAreaHeight)
        })
        
        downloadBtn = UIButton(type: .system)
        downloadBtn?.tintColor = AppTheme.dullBlue
        downloadBtn?.frame = CGRect(x: 0, y: 0, width: 150, height: 50)
        downloadBtn?.contentMode = .center
        downloadBtn?.contentEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        downloadBtn?.layer.cornerRadius = 8
        downloadBtn?.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        downloadBtn?.layer.shadowOpacity = 1.0
        downloadBtn?.layer.shadowRadius = 2.0
        downloadBtn?.layer.masksToBounds = false
        downloadBtn?.backgroundColor = AppTheme.secondaryColor
        downloadBtn?.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        downloadBtn?.setTitle("sticker_redownload".localized, for: .normal)
        downloadBtn?.sizeToFit()
        downloadBtn?.addTarget(self, action: #selector(redownloadSticker), for: .touchUpInside)
        downloadBtn?.isHidden = true
        
        //        stickerView?.addSubview(downloadBtn!)
        //
        //        downloadBtn?.snp.makeConstraints({ (make) in
        //            make.width.equalTo(180)
        //            make.height.equalTo(50)
        //            make.centerX.equalTo(stickerView!)
        //            make.centerY.equalTo(stickerView!)
        //        })
        
        bundleList = StickerManager.shared.loadOwnStickerBundle()
        
        if let bundleList = bundleList as? [[String:Any]], bundleList.count == 0 {
            for bundle in bundleList {
                if let bundleId = bundle["bundle_id"] as? String {
                    self.downloadAllStickers(bundleID: bundleId)
                }
            }
        }
        
        tabView = InputEmoticonTabView(frame: CGRect(x: 0, y: 0, width: Int(self.width), height: Constants.stickerThumbHeight + EmotPageControllerMarginBottom), isNight: self.theme == .dark)
        tabView?.autoresizingMask = .flexibleWidth
        tabView?.backgroundColor = UIColor.white
        tabView?.delegate = self
        tabView?.sendButton.addTarget(self, action: #selector(didPressSend(_:)), for: .touchUpInside)
        tabView?.myStickerButton?.addTarget(self, action: #selector(didPressMySticker(_:)), for: .touchUpInside)
        tabView?.shopButton?.addTarget(self, action: #selector(didPressAdd(_:)), for: .touchUpInside)
        addSubview(tabView!)
        
        tabView?.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(self)
            $0.height.equalTo(Constants.stickerThumbHeight + EmotPageControllerMarginBottom)
            $0.top.equalTo(stickerView!.snp.bottom)
        }
        
        self.refreshStickerKeyboard()
    }
}

extension InputEmoticonContainerView: InputEmoticonTabDelegate {
    func tabViewDidSelectEmoji(_ type: TabType) {
        selectedType = type
        stickerView?.reloadData()
    }
    
    func tabViewDidSelectCustomer(_ type: TabType) {
        selectedType = type
        stickerView?.reloadData()
    }
    
    func tabView(_ tabView: InputEmoticonTabView?, didSelectTabIndex index: Int, tabType type: TabType) {
        currentBundlePage = index
        self.refreshStickerDisplay()
        selectedType = type
        stickerView?.reloadData()
    }
}

extension InputEmoticonContainerView: EmoticonButtonTouchDelegate {
    func sendEmoji(emojiTag: String) {
        self.delegate?.sendEmoji(emojiTag)
    }
    
    func selectedEmoticon(emoticon: String, catalogID: String, stickerId: String) {
        self.delegate?.selectedEmoticon(emoticon, catalog: catalogID, description: nil, stickerId: stickerId)
    }
    
    @objc func didPressSend (_ sender: Any?) {
        self.delegate?.didPressSend(sender)
        //self.sendButtonTappedCallback?()
    }
    
    @objc func didPressAdd (_ sender: Any?) {
        self.delegate?.didPressAdd(sender)
        //self.addStickerCallback?()
    }
    
    @objc func didPressMySticker(_ sender: Any?) {
        self.delegate?.didPressMySticker(sender)
        // self.myStickerTappedCallback?()
    }
    
    func addCustomerSticker() {
        self.delegate?.didPressCustomerSticker()
    }
}

extension InputEmoticonContainerView: EmojiItemTappedDelegate {
    func emojiItemTapped(emojiText: String) {
        self.sendEmoji(emojiTag: emojiText)
    }
}

extension InputEmoticonContainerView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == stickerView {
            if selectedType == TabType.emoji {
                //  No need action
            } else if selectedType == TabType.customer {
                if indexPath.row == 0 {
                    self.addCustomerSticker()
                } else {
                    let sticker = self.customerStickers[indexPath.row - 1]
                    
                    let bundleId = "-1"
                    let stickerUrl = sticker.stickerUrl
                    let stickerId = sticker.customStickerId
                    self.selectedEmoticon(emoticon: stickerUrl ?? "", catalogID: bundleId, stickerId: stickerId ?? "")
                    self.stickerTappedCallback?(stickerUrl, bundleId, stickerId)
                }
            } else {
                if let stickerArray = stickerArray, let sticker = stickerArray[indexPath.row] as? [String:Any], let bundleId = sticker["bundle_id"] as? String, let stickerUrl = sticker["sticker_icon"] as? String  {
                    self.selectedEmoticon(emoticon: stickerUrl, catalogID: bundleId, stickerId: "")
                    self.stickerTappedCallback?(stickerUrl, bundleId, "")
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if selectedType == TabType.emoji {
            if let rootViewController = UIApplication.topViewController() {
                if rootViewController.shouldAutorotate {
                    // Live Audience
                    if UIDevice.current.orientation.isLandscape {
                        return CGSize(width: ScreenHeight, height: stickerView!.height)
                    }
                } else {
                    // Live Streamer and orientation support landscape
                    if rootViewController.supportedInterfaceOrientations.contains(.landscapeLeft) {
                        return CGSize(width: ScreenHeight, height: stickerView!.height)
                    }
                }
            }
            
            return CGSize(width: ScreenWidth, height: stickerView!.height)
        }
        
        var cellsPerRow = 4
        
        if let rootViewController = UIApplication.topViewController() {
            if rootViewController.shouldAutorotate {
                // Live Audience
                if UIDevice.current.orientation.isLandscape {
                    cellsPerRow = 7
                }
            } else {
                // Live Streamer and orientation support landscape
                if rootViewController.supportedInterfaceOrientations.contains(.landscapeLeft) {
                    cellsPerRow = 7
                }
            }
        }
        
        let marginsAndInsets = inset * 2 + collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right + minimumInteritemSpacing * CGFloat(cellsPerRow - 1)
        let itemWidth = ((collectionView.bounds.size.width - marginsAndInsets) / CGFloat(cellsPerRow)).rounded(.down)
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if selectedType == TabType.emoji {
            return  UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        
        return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if selectedType == TabType.emoji {
            return  1
        }
        
        return minimumLineSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if selectedType == TabType.emoji {
            return  1
        }
        
        return minimumInteritemSpacing
    }
}

extension InputEmoticonContainerView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if selectedType == TabType.emoji {
            return 1
        } else if selectedType == TabType.customer {
            return 1 + customerStickers.count
        }
        
        return stickerArray?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = "STICKER_CELL_REUSE_ID"
        let row = indexPath.row
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? IMStickerCollectionCell else {
            return UICollectionViewCell()
        }
        
        cell.imageView.image = nil
        
        let cacheKey = "Sticker"
        
        let sizeForCell = self.cellSizeCache.object(forKey: cacheKey as AnyObject)
        
        if sizeForCell != nil {
            if let size = sizeForCell as? CGSize {
                cell.imageView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            }
        }
        
        cell.imageView.isHidden = false
        cell.emojiLabel.isHidden = true
        cell.bgView.isHidden = true
        cell.emojiView.isHidden = true
        
        cell.setViewNightMode(isNight: self.theme == .dark)
        
        if selectedType == TabType.emoji {
            cell.delegate = self
            cell.imageView.isHidden = true
            cell.emojiView.isHidden = false
            
            if UIDevice.current.orientation.isLandscape {
                cell.emojiView.frame = CGRect(x: 0, y: 0, width: ScreenHeight, height: cell.frame.size.height)
            } else {
                cell.emojiView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: cell.frame.size.height)
            }
            cell.emojiView.screenOrientationChanged()
        } else if selectedType == TabType.customer {
            if row == 0 {
                cell.imageView.isHidden = true
                cell.bgView.isHidden = false
            } else {
                let sticker = customerStickers[row - 1]
                cell.imageView.sd_setImage(with: URL(string: sticker.stickerUrl ?? ""), completed: nil)
                cell.imageView.shouldCustomLoopCount = true
                cell.imageView.animationRepeatCount = 0
            }
        } else {
            if let stickerArray = stickerArray, let bundle = stickerArray[row] as? [String:Any], let iconUrl = bundle["sticker_icon"] as? String {
                cell.imageView.sd_setImage(with: URL(string: iconUrl), completed: nil)
                cell.imageView.shouldCustomLoopCount = true
                cell.imageView.animationRepeatCount = 0
            }
        }
        
        return cell
    }
}
