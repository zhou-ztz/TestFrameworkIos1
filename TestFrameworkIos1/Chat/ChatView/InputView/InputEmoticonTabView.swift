//
//  InputEmoticonTabView.swift
//  Yippi
//
//  Created by Khoo on 09/07/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation

import SnapKit

enum TabType: String {
    case emoji
    case customer
    case sticker
}

protocol InputEmoticonTabDelegate{
    func tabViewDidSelectEmoji(_ type: TabType)
    func tabViewDidSelectCustomer(_ type: TabType)
    func tabView(_ tabView: InputEmoticonTabView?, didSelectTabIndex index: Int, tabType type: TabType)
}

enum BorderPosition : Int {
    case leftBorder
    case rightBorder
    case topBorder
    case bottomBorder
}

class InputEmoticonTabView: UIControl {
    var sendButton: UIButton!
    var myStickerButton: UIButton?
    var delegate: InputEmoticonTabDelegate?
    
    var tabs: [UIView]?
    var seps: [UIView]?
    
    var stickerTab: UICollectionView? = nil
    let button: UIButton? = nil
    var bundleList: [Any]? = nil
    var currentBundlePage: Int = 0
    var buttonCount: Int = 0
    let currentUserID: String? = nil
    var tabLeftBorder: CALayer? = nil
    var myStickerleftBorder: CALayer? = nil
    var customerStickerleftBorder: CALayer? = nil
    var tabBottomBorder: CALayer? = nil
    var selectedIndex: Int = 0
    
    var shopButton: UIButton?
    var emojiButton: UIButton?
    
    var customerStickerButton: UIButton!
    
    let cellReuseIdentifier = "IMStickerTabCollectionViewCell"
    
    var theme: Theme = .white
    
    init(frame: CGRect, isNight: Bool = false) {
        super.init(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: CGFloat(Constants.NIM.NIMInputEmoticonTabViewHeight)))
        tabs = [UIView]()
        seps = [UIView]()
        
        renderScrollableTabView()
        
        sendButton = UIButton(type: .custom)
        sendButton.setTitle("send".localized, for: .normal)
        sendButton.titleLabel?.font = UIFont.systemFont(ofSize: 13.0)
        sendButton.backgroundColor = UIColor(hexString: "#0079ff")
        
        sendButton.height = Constants.NIM.NIMInputEmoticonTabViewHeight
        sendButton.width = Constants.NIM.NIMInputEmoticonSendButtonWidth
        
        layer.borderColor = UIColor(hexString: "#8A8E93")?.cgColor
        layer.borderWidth = CGFloat(Constants.NIM.NIMInputLineBoarder)
        
        currentBundlePage = 0
        self.bundleList = StickerManager.shared.loadOwnStickerBundle()
//        StickerManager.shared.loadOwnStickerList { [self] (complete) in
//            if complete {
//                self.bundleList = StickerManager.shared.loadOwnStickerBundle()
//                self.stickerTab?.reloadData()
//            }
//        }
        self.stickerTab?.reloadData()
        selectedIndex = -1
        myStickerButton = UIButton(type: .custom)
        myStickerButton!.setImage(UIImage.set_image(named: "ic_mysticker")?.withRenderingMode(.alwaysOriginal), for: .normal)
        myStickerleftBorder = addBorder(.leftBorder, borderWidth: 1, frame: stickerTab!.frame)
        myStickerButton!.layer.addSublayer(myStickerleftBorder!)
        myStickerleftBorder!.isHidden = true
        
        shopButton = UIButton(type: .custom)
        shopButton!.setImage(UIImage.set_image(named: "add_sticker")?.withRenderingMode(.alwaysOriginal), for: .normal)
        shopButton!.addTarget(self, action: #selector(onTouchShopButton), for: .touchUpInside)
       // shopButton!.contentEdgeInsets = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        shopButton!.contentMode = .center
        
        emojiButton = UIButton(type: .custom)
        emojiButton!.setImage(UIImage.set_image(named: "iconsEmojiBlack")?.withRenderingMode(.alwaysOriginal), for: .normal)
        emojiButton!.addTarget(self, action: #selector(onTouchEmojiButton), for: .touchUpInside)
       // shopButton!.contentEdgeInsets = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        emojiButton!.contentMode = .center
        
        customerStickerButton = UIButton()
        customerStickerButton!.setImage(UIImage.set_image(named: "group13")?.withRenderingMode(.alwaysOriginal), for: .normal)
        customerStickerButton.addTarget(self, action: #selector(onTouchcustomerButton), for: .touchUpInside)
        customerStickerButton.contentMode = .center
        customerStickerButton.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        customerStickerleftBorder = addBorder(.leftBorder, borderWidth: 1, frame: stickerTab!.frame)
        customerStickerButton!.layer.addSublayer(customerStickerleftBorder!)
        
        addSubview(customerStickerButton)
        addSubview(shopButton!)
        addSubview(emojiButton!)
        
        shopButton!.snp.makeConstraints {
            $0.leading.top.equalTo(self)
            $0.bottom.equalTo(self).inset(TSBottomSafeAreaHeight)
            $0.width.equalTo(50)
        }
        
        emojiButton!.snp.makeConstraints {
            $0.leading.equalTo(shopButton!.snp.trailing)
            $0.bottom.equalTo(self).inset(TSBottomSafeAreaHeight)
            $0.width.equalTo(50)
            $0.top.equalTo(self)
        }
        
        customerStickerButton.snp.makeConstraints {
            $0.leading.equalTo(emojiButton!.snp.trailing)
            $0.bottom.equalTo(self).inset(TSBottomSafeAreaHeight)
            $0.width.equalTo(50)
            $0.top.equalTo(self)
        }
        
        stickerTab!.snp.makeConstraints {
            $0.top.equalTo(self)
            $0.bottom.equalTo(self).inset(TSBottomSafeAreaHeight)
            $0.leading.equalTo(customerStickerButton.snp.trailing)
        }
        
        addSubview(myStickerButton!)
        myStickerButton!.snp.makeConstraints {
            $0.trailing.top.equalTo(self)
            $0.bottom.equalTo(self).inset(TSBottomSafeAreaHeight)
            $0.leading.equalTo(stickerTab!.snp.trailing)
            $0.width.equalTo(50)
        }
        
        layer.borderColor = AppTheme.imStickerBorder.cgColor
        
        tabBottomBorder = addBorder(.bottomBorder, borderWidth: 1, frame: frame)
        layer.addSublayer(tabBottomBorder!)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func onTouchShopButton () {
        
    }
    
    @objc func onTouchcustomerButton(){
        selectedIndex = -1
        delegate?.tabViewDidSelectCustomer(TabType.customer)
        self.stickerTab?.reloadData()
        self.customerStickerButton.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        self.emojiButton!.backgroundColor = .clear
    }
    
    public func setEmotionNightMode(isNight: Bool) {
        if isNight {
            theme = .dark
            
            myStickerButton!.setImage(UIImage.set_image(named: "ic_sticker_setting")?.withRenderingMode(.alwaysOriginal), for: .normal)
            shopButton!.setImage(UIImage.set_image(named: "plus")?.withRenderingMode(.alwaysOriginal), for: .normal)
            customerStickerButton!.setImage(UIImage.set_image(named: "ic_sticker_custom2")?.withRenderingMode(.alwaysOriginal), for: .normal)
            emojiButton!.setImage(UIImage.set_image(named: "iconsEmojiWhite")?.withRenderingMode(.alwaysOriginal), for: .normal)
            
            layer.borderColor = UIColor.clear.cgColor
            layer.borderWidth = CGFloat(Constants.NIM.NIMInputLineBoarder)
            
            myStickerleftBorder?.isHidden = true
            customerStickerleftBorder?.isHidden = true
            tabLeftBorder?.isHidden = true
            tabBottomBorder?.isHidden = true
        } else {
            theme = .white
            
            myStickerButton!.setImage(UIImage.set_image(named: "ic_mysticker")?.withRenderingMode(.alwaysOriginal), for: .normal)
            shopButton!.setImage(UIImage.set_image(named: "add_sticker")?.withRenderingMode(.alwaysOriginal), for: .normal)
            customerStickerButton.setImage(UIImage.set_image(named: "group13"))
            emojiButton!.setImage(UIImage.set_image(named: "iconsEmojiBlack")?.withRenderingMode(.alwaysOriginal), for: .normal)
            
            myStickerleftBorder?.isHidden = false
            customerStickerleftBorder?.isHidden = false
            tabLeftBorder?.isHidden = false
            tabBottomBorder?.isHidden = false
        }
        
        stickerTab?.reloadData()
    }
    
    func renderScrollableTabView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 50, height: 50)
        stickerTab = UICollectionView(frame: CGRect(x: 0.0, y: 0.0, width: self.width - 150, height: CGFloat(Constants.stickerThumbHeight + 10)), collectionViewLayout: layout)
        stickerTab!.register(IMStickerTabCollectionViewCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        stickerTab!.dataSource = self
        stickerTab!.delegate = self
        stickerTab!.backgroundColor = .clear
        stickerTab!.alwaysBounceHorizontal = true
        stickerTab!.bounces = false
        stickerTab!.showsVerticalScrollIndicator = false
        stickerTab!.showsHorizontalScrollIndicator = false
        tabLeftBorder = addBorder(.leftBorder, borderWidth: 1, frame: stickerTab!.frame)
        stickerTab!.layer.addSublayer(tabLeftBorder!)
        addSubview(stickerTab!)
    }
    
    func image(_ image: UIImage?, withAdjustedAlpha newAlpha: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(image?.size ?? CGSize.zero, false, 0.0)
        image?.draw(at: CGPoint.zero, blendMode: .copy, alpha: newAlpha)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    
    func selectTabIndex(_ index: Int) {
        guard let tabs = tabs else { return }
        for i in 0..<tabs.count {
            let btn = tabs[i] as? UIButton
            btn?.isSelected = i == index
        }
    }
    
    func loadStickersFromPlist() -> [Any]? {
        let path = AppUtil.shared.makeDocumentFullPath(Constants.USER_DOWNLOADED_STICKER_BUNDLE_PLIST)
        let dict = AppUtil.shared.content(fromFile: path)
        return dict as? [Any]
    }
    
    func refreshTabView() {
        bundleList = StickerManager.shared.loadOwnStickerBundle()
        let mainThreadQueue = DispatchQueue.main
        mainThreadQueue.async(execute: {
            self.stickerTab!.reloadData()
        })
    }
    
    func addBorder(_ position: BorderPosition, borderWidth width: CGFloat, frame: CGRect) -> CALayer? {
        let border = CALayer()
        border.backgroundColor = AppTheme.imStickerBorder.cgColor
        switch position {
        case .leftBorder:
            border.frame = CGRect(x: 0, y: 0, width: width, height: frame.size.height)
        case .rightBorder:
            border.frame = CGRect(x: frame.size.width, y: 0, width: width, height: frame.size.height)
        case .topBorder:
            border.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: width)
        case .bottomBorder:
            border.frame = CGRect(x: 0, y: frame.size.height, width: frame.size.width, height: width)
        default:
            break
        }
        
        return border
    }
    
    func hideLeftBorder(_ hide: Bool) {
        tabLeftBorder!.isHidden = hide
    }
    
    func showMyStickerLeftBorder(_ show: Bool) {
        myStickerleftBorder?.isHidden = !show
    }
    
    func loadCatalogs(_ emoticonCatalogs: [InputEmoticonCatalog]?) {
        guard let emoticonCatalogs = emoticonCatalogs else { return }
        let array = tabs ?? [] + seps!
        for subView in array {
            subView.removeFromSuperview()
        }
        
        tabs?.removeAll()
        seps?.removeAll()
        
        for catalog in emoticonCatalogs {
            let button = UIButton(type: .custom)
            button.setImage(UIImage.set_image(named: catalog.icon!), for: .normal)
            button.setImage(UIImage.set_image(named: catalog.iconPressed!), for: .highlighted)
            button.setImage(UIImage.set_image(named: catalog.iconPressed!), for: .selected)
            //button.addTarget(self, action: #selector(onTouchTab(_:)), for: .touchUpInside)
            button.sizeToFit()
            self.addSubview(button)
            tabs?.append(button)
            
            let sep = UIView(frame: CGRect(x: 0, y: 0, width: Constants.NIM.NIMInputLineBoarder, height: Constants.NIM.NIMInputEmoticonTabViewHeight))
            
            seps?.append(sep)
            self.addSubview(sep)
        }
    }
    
    @objc func onTouchEmojiButton() {
        selectedIndex = -1
        delegate?.tabViewDidSelectEmoji(TabType.emoji)
        self.stickerTab?.reloadData()
        self.emojiButton!.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        self.customerStickerButton.backgroundColor = .clear
    }
    
    @objc func onTouchTab(index: Int) {
        currentBundlePage = index
        self.selectTabIndex(currentBundlePage)
        delegate?.tabView(self, didSelectTabIndex: index, tabType: TabType.sticker)
        self.emojiButton!.backgroundColor = .clear
        self.customerStickerButton.backgroundColor = .clear
    }
    
    @objc func selectTabIndex(index: Int) {
        for i in 0..<(tabs?.count ?? 0) {
            let btn = self.tabs?[i] as? UIButton
            btn!.isSelected = i == index
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let spacing = 10
        var left = spacing
        for i in 0..<self.tabs!.count {
            let button = self.tabs![i] as! UIButton
            button.frame.origin.y = CGFloat(left)
            button.centerY = self.height * 0.5

            let sep: UIView = self.seps![i]
            sep.frame.origin.y = button.right + CGFloat(spacing)
            left = Int(sep.frame.origin.x + sep.frame.size.width) + spacing
        }

        sendButton.right = self.width
    }
}

extension InputEmoticonTabView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        buttonCount = bundleList!.count
        return buttonCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let i = indexPath.row
        let bundle = bundleList![i] as? [String : Any]
        
        let iconUrl = (bundle == nil) ? "" : bundle!["bundle_icon"] as! String

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! IMStickerTabCollectionViewCell

        let cellIconUrl = URL(string: iconUrl)
        
        selectedIndex = selectedIndex > bundleList!.count ? bundleList!.count : selectedIndex
        cell.configure(nil, icon: cellIconUrl, isSelected: selectedIndex == i, isNightMode: self.theme == .dark)

        //cell.addCellRightBorder(cell.frame)
        
        cell.imageView.sd_setImage(with: cellIconUrl)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.onTouchTab(index: indexPath.row)
        self.setNeedsLayout()

        let selectedCell = collectionView.cellForItem(at: indexPath) as! IMStickerTabCollectionViewCell
        let lastSelectedCell = collectionView.cellForItem(at: IndexPath(row: selectedIndex, section: 0)) as? IMStickerTabCollectionViewCell
        if  lastSelectedCell != nil {
           
            lastSelectedCell!.setBgSelected(false)
        }
        
        selectedCell.setBgSelected(true)
        selectedIndex = indexPath.row
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
//        let selectedCell = collectionView.cellForItem(at: indexPath) as! IMStickerTabCollectionViewCell
//        selectedCell.setBgSelected(true)

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return  UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    //    MARK: - 行最小间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    //    MARK: - 列最小间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset
        
        if theme == .dark {
            self.hideLeftBorder(true)
            self.showMyStickerLeftBorder(false)
        } else {
            if contentOffset.x > 0 {
                self.hideLeftBorder(true)
            } else {
                self.hideLeftBorder(false)
            }
            
            if contentOffset.x >= stickerTab!.width {
                self.showMyStickerLeftBorder(true)
            } else {
                self.showMyStickerLeftBorder(false)
            }
        }
    }
}
